import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/community_model.dart';
import '../../data/community_repository.dart';

const _kJoinedGroupsKey = 'joined_groups';
const _kLikedPostsKey = 'liked_post_ids';

// ── Repository ────────────────────────────────────────────────
final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository(Supabase.instance.client);
});

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

  /// Abonnement temps réel — le feed se met à jour automatiquement
  void _subscribeRealtime() {
    _realtimeSub = Supabase.instance.client
        .from('posts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(50)
        .listen(
          (data) {
            if (mounted) {
              state = AsyncValue.data(
                data.map((j) => CommunityPost.fromJson(j)).toList(),
              );
            }
          },
          onError: (e, st) {
            if (mounted) state = AsyncValue.error(e, st);
          },
        );
  }

  /// Rafraîchissement manuel (pull-to-refresh)
  Future<void> loadPosts() async {
    state = const AsyncValue.loading();
    try {
      final posts = await _repo.getPosts();
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Crée un post — le flux temps réel met à jour le feed automatiquement
  Future<void> createPost({
    required String content,
    required String authorName,
  }) async {
    try {
      await _repo.createPost(content: content, authorName: authorName);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Like optimiste — le flux temps réel synchronise ensuite avec la vraie valeur
  Future<void> likePost(String postId) async {
    final current = state.value;
    if (current == null) return;

    final index = current.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = current[index];
    final updated = List<CommunityPost>.from(current);
    updated[index] = post.copyWith(likesCount: post.likesCount + 1);
    state = AsyncValue.data(updated);

    try {
      await _repo.likePost(postId, post.likesCount);
    } catch (_) {
      // Rollback optimiste en cas d'erreur réseau
      if (mounted) state = AsyncValue.data(current);
    }
  }

  /// Suppression optimiste — disparaît immédiatement de l'UI
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

/// Nombre de posts de l'utilisateur cette semaine (limite freemium)
final weeklyPostCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(communityRepositoryProvider).getWeeklyPostCount();
});

// ── Posts aimés (anti-spam likes) ────────────────────────────

/// Stocke les IDs des posts aimés localement pour éviter les doubles likes
final likedPostIdsProvider =
    StateNotifierProvider<LikedPostIdsNotifier, Set<String>>(
  (ref) => LikedPostIdsNotifier(),
);

class LikedPostIdsNotifier extends StateNotifier<Set<String>> {
  LikedPostIdsNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_kLikedPostsKey) ?? [];
    if (mounted) state = Set.from(ids);
  }

  Future<void> addLike(String postId) async {
    if (state.contains(postId)) return;
    state = {...state, postId};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kLikedPostsKey, state.toList());
  }
}

// ── Groupes ───────────────────────────────────────────────────

/// Notifier pour les groupes rejoints — persisté en SharedPreferences
final communityGroupsProvider =
    StateNotifierProvider<CommunityGroupsNotifier, List<CommunityGroup>>(
  (ref) => CommunityGroupsNotifier(),
);

class CommunityGroupsNotifier extends StateNotifier<List<CommunityGroup>> {
  CommunityGroupsNotifier() : super([]) {
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final joinedIds = prefs.getStringList(_kJoinedGroupsKey) ?? [];

    final groups = predefinedGroups.map((g) {
      g.isJoined = joinedIds.contains(g.id);
      return g;
    }).toList();

    if (mounted) state = groups;
  }

  Future<void> toggleGroup(String groupId) async {
    final updated = state.map((g) {
      if (g.id == groupId) g.isJoined = !g.isJoined;
      return g;
    }).toList();
    state = updated;

    final prefs = await SharedPreferences.getInstance();
    final joinedIds =
        updated.where((g) => g.isJoined).map((g) => g.id).toList();
    await prefs.setStringList(_kJoinedGroupsKey, joinedIds);
  }
}
