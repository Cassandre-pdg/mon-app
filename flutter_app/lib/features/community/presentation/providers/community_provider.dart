import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/community_model.dart';
import '../../data/community_repository.dart';

const _kReactedPostsKey   = 'salon_reacted_posts';   // Map<postId, reactionType>
const _kReportedPostsKey  = 'salon_reported_posts';   // Set<postId>
const _kPollVotesKey      = 'salon_poll_votes';        // Map<postId, optionIndex>

// ── Repository ────────────────────────────────────────────────
final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository(Supabase.instance.client);
});

// ── Mode de tri du feed ───────────────────────────────────────
enum FeedSortMode { recent, actif }

final feedSortModeProvider = StateProvider<FeedSortMode>(
  (ref) => FeedSortMode.recent,
);

// ── Filtre par type de post ───────────────────────────────────
// null = Tout
final postTypeFilterProvider = StateProvider<PostType?>((ref) => null);

// ── Filtre par tag ────────────────────────────────────────────
// null = pas de filtre
final postTagFilterProvider = StateProvider<String?>((ref) => null);

// ── Posts (temps réel via Supabase stream) ────────────────────
final communityPostsProvider =
    StateNotifierProvider<CommunityPostsNotifier, AsyncValue<List<CommunityPost>>>(
  (ref) => CommunityPostsNotifier(ref.watch(communityRepositoryProvider)),
);

class CommunityPostsNotifier
    extends StateNotifier<AsyncValue<List<CommunityPost>>> {
  final CommunityRepository _repo;
  StreamSubscription? _realtimeSub;

  CommunityPostsNotifier(this._repo) : super(const AsyncValue.loading()) {
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    super.dispose();
  }

  void _subscribeRealtime() {
    _realtimeSub = Supabase.instance.client
        .from('posts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(50)
        .listen(
          (data) {
            if (mounted) {
              // Filtre : seulement les messages racines (pas les réponses)
              final posts = data
                  .map((j) => CommunityPost.fromJson(j))
                  .where((p) => !p.isFlagged && p.parentId == null)
                  .toList();
              state = AsyncValue.data(posts);
            }
          },
          onError: (e, st) {
            if (mounted) state = AsyncValue.error(e, st);
          },
        );
  }

  Future<void> loadPosts() async {
    state = const AsyncValue.loading();
    try {
      final posts = await _repo.getPosts();
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createPost({
    required String content,
    required String authorName,
    required PostType postType,
    String? postTag,
    List<String>? pollOptions,
  }) async {
    try {
      await _repo.createPost(
        content: content,
        authorName: authorName,
        postType: postType,
        postTag: postTag,
        pollOptions: pollOptions,
      );
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Crée une réponse et met à jour le compteur du message parent
  Future<void> createReply({
    required String content,
    required String authorName,
    required String parentId,
  }) async {
    // Optimiste : incrémente replies_count sur le parent
    final current = state.value ?? [];
    final idx = current.indexWhere((p) => p.id == parentId);
    if (idx != -1 && mounted) {
      final updated = List<CommunityPost>.from(current);
      updated[idx] = current[idx].copyWith(
        repliesCount: current[idx].repliesCount + 1,
      );
      state = AsyncValue.data(updated);
    }
    try {
      await _repo.createReply(
        content: content,
        authorName: authorName,
        parentId: parentId,
      );
    } catch (_) {
      // Rollback
      if (mounted) state = AsyncValue.data(current);
      rethrow;
    }
  }

  /// Vote optimiste sur un sondage
  Future<void> votePoll(String postId, int optionIndex) async {
    final current = state.value;
    if (current == null) return;

    final index = current.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = current[index];
    if (post.pollVotes == null) return;

    final newVotes = List<int>.from(post.pollVotes!);
    newVotes[optionIndex]++;
    final updated = List<CommunityPost>.from(current);
    updated[index] = post.copyWith(pollVotes: newVotes);
    state = AsyncValue.data(updated);

    try {
      await _repo.votePoll(postId, optionIndex, post.pollVotes!);
    } catch (_) {
      if (mounted) state = AsyncValue.data(current);
    }
  }

  /// Réaction optimiste — rollback si erreur réseau
  Future<void> reactToPost(String postId, ReactionType reaction) async {
    final current = state.value;
    if (current == null) return;

    final index = current.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = current[index];
    final updated = List<CommunityPost>.from(current);
    updated[index] = post.copyWith(
      reactionsUtile:     reaction == ReactionType.utile     ? post.reactionsUtile + 1     : null,
      reactionsInspirant: reaction == ReactionType.inspirant ? post.reactionsInspirant + 1 : null,
      reactionsMerci:     reaction == ReactionType.merci     ? post.reactionsMerci + 1     : null,
      reactionsBravo:     reaction == ReactionType.bravo     ? post.reactionsBravo + 1     : null,
    );
    state = AsyncValue.data(updated);

    try {
      final count = switch (reaction) {
        ReactionType.utile     => post.reactionsUtile,
        ReactionType.inspirant => post.reactionsInspirant,
        ReactionType.merci     => post.reactionsMerci,
        ReactionType.bravo     => post.reactionsBravo,
      };
      await _repo.reactToPost(postId, reaction, count);
    } catch (_) {
      if (mounted) state = AsyncValue.data(current);
    }
  }

  /// Signalement — masquage optimiste côté client après envoi
  Future<void> reportPost(String postId, String reason) async {
    await _repo.reportPost(postId, reason);
  }

  /// Suppression optimiste
  Future<void> deletePost(String postId) async {
    final current = state.value ?? [];
    if (mounted) {
      state = AsyncValue.data(current.where((p) => p.id != postId).toList());
    }
    try {
      await _repo.deletePost(postId);
    } catch (_) {
      if (mounted) state = AsyncValue.data(current);
    }
  }
}

// ── Compteur de posts de la semaine ──────────────────────────
final weeklyPostCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(communityRepositoryProvider).getWeeklyPostCount();
});

// ── Réactions données par l'utilisateur ──────────────────────
// Stocké : Map<postId, reactionType.name>
final reactedPostsProvider =
    StateNotifierProvider<ReactedPostsNotifier, Map<String, String>>(
  (_) => ReactedPostsNotifier(),
);

class ReactedPostsNotifier extends StateNotifier<Map<String, String>> {
  ReactedPostsNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kReactedPostsKey);
    if (raw != null && mounted) {
      state = Map<String, String>.from(jsonDecode(raw));
    }
  }

  Future<void> addReaction(String postId, ReactionType reaction) async {
    if (state.containsKey(postId)) return;
    state = {...state, postId: reaction.name};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kReactedPostsKey, jsonEncode(state));
  }

  bool hasReacted(String postId) => state.containsKey(postId);

  ReactionType? reactionFor(String postId) {
    final name = state[postId];
    if (name == null) return null;
    return ReactionType.values.firstWhere((r) => r.name == name);
  }
}

// ── Posts signalés (local — évite les doublons) ───────────────
final reportedPostsProvider =
    StateNotifierProvider<ReportedPostsNotifier, Set<String>>(
  (_) => ReportedPostsNotifier(),
);

class ReportedPostsNotifier extends StateNotifier<Set<String>> {
  ReportedPostsNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_kReportedPostsKey) ?? [];
    if (mounted) state = Set.from(ids);
  }

  Future<void> addReport(String postId) async {
    state = {...state, postId};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kReportedPostsKey, state.toList());
  }

  bool hasReported(String postId) => state.contains(postId);
}

// ── Votes de sondage donnés par l'utilisateur ─────────────────
// Stocké : Map<postId, optionIndex>
final pollVotedProvider =
    StateNotifierProvider<PollVotedNotifier, Map<String, int>>(
  (_) => PollVotedNotifier(),
);

class PollVotedNotifier extends StateNotifier<Map<String, int>> {
  PollVotedNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPollVotesKey);
    if (raw != null && mounted) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      state = decoded.map((k, v) => MapEntry(k, v as int));
    }
  }

  Future<void> addVote(String postId, int optionIndex) async {
    if (state.containsKey(postId)) return;
    state = {...state, postId: optionIndex};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPollVotesKey, jsonEncode(state));
  }

  bool hasVoted(String postId) => state.containsKey(postId);
  int? voteFor(String postId) => state[postId];
}

// ── Réponses d'un message (chargé à la demande) ──────────────
final repliesProvider =
    FutureProvider.family<List<CommunityPost>, String>((ref, parentId) {
  return ref.watch(communityRepositoryProvider).getReplies(parentId);
});

// ── Posts feed filtrés + triés (computed) ─────────────────────
// Utilisé par _SalonTab pour obtenir la liste finale à afficher
final filteredPostsProvider = Provider<AsyncValue<List<CommunityPost>>>((ref) {
  final postsAsync  = ref.watch(communityPostsProvider);
  final typeFilter  = ref.watch(postTypeFilterProvider);
  final tagFilter   = ref.watch(postTagFilterProvider);
  final sortMode    = ref.watch(feedSortModeProvider);

  return postsAsync.whenData((posts) {
    var list = posts;

    if (typeFilter != null) {
      list = list.where((p) => p.postType == typeFilter).toList();
    }
    if (tagFilter != null) {
      list = list.where((p) => p.postTag == tagFilter).toList();
    }

    if (sortMode == FeedSortMode.actif) {
      list = List.from(list)
        ..sort((a, b) => _score(b).compareTo(_score(a)));
    }

    return list;
  });
});

double _score(CommunityPost p) {
  final hours   = DateTime.now().difference(p.createdAt).inHours;
  final fresh   = (48 - hours).clamp(0, 48) / 48.0 * 25;
  final engage  = p.totalReactions * 1.5 + p.repliesCount * 4.0;
  return engage + fresh;
}

// ── Groupes thématiques ───────────────────────────────────────
final communityGroupsProvider =
    StateNotifierProvider<CommunityGroupsNotifier, List<CommunityGroup>>(
  (_) => CommunityGroupsNotifier(),
);

class CommunityGroupsNotifier extends StateNotifier<List<CommunityGroup>> {
  CommunityGroupsNotifier()
      : super(List<CommunityGroup>.from(v1CommunityGroups));

  void toggleGroup(String id) {
    state = [
      for (final g in state)
        if (g.id == id) g.copyWith(isJoined: !g.isJoined) else g,
    ];
  }
}
