import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/constants/app_strings.dart';
import '../../data/community_model.dart';
import '../providers/community_provider.dart';
import '../providers/challenge_provider.dart';

// ──────────────────────────────────────────────────────────────
// Écran principal "Le Salon" — 3 onglets
// ──────────────────────────────────────────────────────────────
class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Titre ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Text(
                  AppStrings.navCommunity,
                  style: AppTextStyles.headingLarge(
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),

              // ── TabBar ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerHeight: 0,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.grey400,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: AppTextStyles.labelMedium()
                      .copyWith(fontWeight: FontWeight.w600),
                  unselectedLabelStyle: AppTextStyles.labelMedium(),
                  tabs: const [
                    Tab(text: '🗣️  Feed'),
                    Tab(text: '👥  Groupes'),
                    Tab(text: '🏆  Défis'),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: isDark
                    ? AppColors.grey400.withValues(alpha: 0.2)
                    : AppColors.grey200,
              ),

              // ── Contenu ────────────────────────────────────
              const Expanded(
                child: TabBarView(
                  children: [
                    _FeedTab(),
                    _GroupesTab(),
                    _DefisTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Onglet Feed
// ──────────────────────────────────────────────────────────────
class _FeedTab extends ConsumerWidget {
  const _FeedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync     = ref.watch(filteredPostsProvider);
    final weeklyCountAsync = ref.watch(weeklyPostCountProvider);
    final typeFilter     = ref.watch(postTypeFilterProvider);
    final isDark         = Theme.of(context).brightness == Brightness.dark;
    final weeklyCount    = weeklyCountAsync.value ?? 0;
    final canPost        = weeklyCount < AppConstants.freeWeeklyPosts;
    final currentUser    = Supabase.instance.client.auth.currentUser;
    final authorName     = currentUser?.userMetadata?['full_name'] as String? ?? 'Kolyb';
    final reactedPosts   = ref.watch(reactedPostsProvider);
    final pollVoted      = ref.watch(pollVotedProvider);

    return Stack(
      children: [
        Column(
          children: [
            // ── Filtres + tri ──────────────────────────────
            _FeedControls(isDark: isDark),

            // ── Liste ─────────────────────────────────────
            Expanded(
              child: postsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('😕', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: AppConstants.spacing16),
                      Text(
                        AppStrings.errorGeneric,
                        style: AppTextStyles.bodyMedium(
                            color: AppColors.grey400),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spacing16),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(communityPostsProvider.notifier)
                            .loadPosts(),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
                data: (posts) {
                  // Affiche la question hebdo en tête si pas de filtre
                  final showWeekly = typeFilter == null && posts.isNotEmpty;
                  final totalItems = posts.length + (showWeekly ? 1 : 0);

                  if (posts.isEmpty) {
                    return _FeedEmpty(
                      isDark: isDark,
                      hasFilter: typeFilter != null,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref
                        .read(communityPostsProvider.notifier)
                        .loadPosts(),
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                        left: AppConstants.spacing16,
                        right: AppConstants.spacing16,
                        top: AppConstants.spacing12,
                        bottom: canPost
                            ? 88
                            : AppConstants.spacing24,
                      ),
                      itemCount: totalItems,
                      itemBuilder: (context, i) {
                        // Question de la semaine en premier
                        if (showWeekly && i == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppConstants.spacing12),
                            child: _WeeklyQuestionCard(
                              isDark: isDark,
                              authorName: authorName,
                            ),
                          );
                        }
                        final postIndex = showWeekly ? i - 1 : i;
                        final post = posts[postIndex];

                        // Réaction de l'utilisateur sur ce post
                        final rawReaction = reactedPosts[post.id];
                        final userReaction = rawReaction != null
                            ? ReactionType.values.firstWhere(
                                (r) => r.name == rawReaction,
                                orElse: () => ReactionType.utile,
                              )
                            : null;

                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppConstants.spacing12),
                          child: _PostCard(
                            post: post,
                            isDark: isDark,
                            isOwnPost:
                                post.userId == currentUser?.id,
                            userReaction: userReaction,
                            userPollVote: pollVoted[post.id],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        // ── FAB ou nudge limite ──────────────────────────
        Positioned(
          bottom: AppConstants.spacing24,
          right: AppConstants.spacing24,
          left: canPost ? null : AppConstants.spacing16,
          child: canPost
              ? _PostFab(authorName: authorName)
              : _PostLimitBanner(isDark: isDark),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Barre de filtres + tri
// ──────────────────────────────────────────────────────────────
class _FeedControls extends ConsumerWidget {
  final bool isDark;
  const _FeedControls({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeFilter = ref.watch(postTypeFilterProvider);
    final sortMode   = ref.watch(feedSortModeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chips type de post (scrollable)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              _TypeChip(
                emoji: '📋',
                label: 'Tout',
                selected: typeFilter == null,
                isDark: isDark,
                onTap: () =>
                    ref.read(postTypeFilterProvider.notifier).state = null,
              ),
              const SizedBox(width: 8),
              ...PostType.values.map(
                (type) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _TypeChip(
                    emoji: type.emoji,
                    label: type.label,
                    selected: typeFilter == type,
                    isDark: isDark,
                    onTap: () => ref
                        .read(postTypeFilterProvider.notifier)
                        .state = type,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Tri : Récents / Actifs
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => ref.read(feedSortModeProvider.notifier).state =
                    FeedSortMode.recent,
                child: Text(
                  'Récents',
                  style: AppTextStyles.caption(
                    color: sortMode == FeedSortMode.recent
                        ? AppColors.primary
                        : AppColors.grey400,
                  ).copyWith(
                    fontWeight: sortMode == FeedSortMode.recent
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('·',
                    style:
                        AppTextStyles.caption(color: AppColors.grey400)),
              ),
              GestureDetector(
                onTap: () => ref.read(feedSortModeProvider.notifier).state =
                    FeedSortMode.actif,
                child: Text(
                  'Actifs',
                  style: AppTextStyles.caption(
                    color: sortMode == FeedSortMode.actif
                        ? AppColors.primary
                        : AppColors.grey400,
                  ).copyWith(
                    fontWeight: sortMode == FeedSortMode.actif
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),

        Divider(
          height: 1,
          color: isDark
              ? AppColors.grey400.withValues(alpha: 0.12)
              : AppColors.grey200,
        ),
      ],
    );
  }
}

// ── Chip de filtre ────────────────────────────────────────────
class _TypeChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _TypeChip({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.18)
              : isDark
                  ? AppColors.surfaceDark
                  : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.5)
                : isDark
                    ? AppColors.grey400.withValues(alpha: 0.2)
                    : AppColors.grey200,
          ),
        ),
        child: Text(
          '$emoji  $label',
          style: AppTextStyles.labelMedium(
            color: selected
                ? AppColors.primaryLight
                : AppColors.grey400,
          ).copyWith(
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Question hebdomadaire épinglée
// ──────────────────────────────────────────────────────────────
class _WeeklyQuestionCard extends StatelessWidget {
  final bool isDark;
  final String authorName;

  const _WeeklyQuestionCard({
    required this.isDark,
    required this.authorName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.14),
            AppColors.accent.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '🗓️  Question de la semaine',
              style: AppTextStyles.caption(
                      color: AppColors.primaryLight)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            currentWeeklyQuestion,
            style: AppTextStyles.bodyMedium(
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ).copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Text(
            'Partage ta réponse avec Le Salon 👇',
            style: AppTextStyles.caption(color: AppColors.grey400),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Carte d'un post
// ──────────────────────────────────────────────────────────────
class _PostCard extends ConsumerWidget {
  final CommunityPost post;
  final bool isDark;
  final bool isOwnPost;
  final ReactionType? userReaction;
  final int? userPollVote;

  const _PostCard({
    required this.post,
    required this.isDark,
    required this.isOwnPost,
    this.userReaction,
    this.userPollVote,
  });

  String get _initials {
    final parts = post.authorName.trim().split(' ');
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays}j';
    return 'il y a ${(diff.inDays / 7).floor()} sem.';
  }

  Color _typeBg(PostType t) {
    switch (t) {
      case PostType.question:  return AppColors.primary.withValues(alpha: 0.12);
      case PostType.debat:     return AppColors.secondary.withValues(alpha: 0.12);
      case PostType.victoire:  return AppColors.chartAmber.withValues(alpha: 0.12);
      case PostType.aide:      return AppColors.accent.withValues(alpha: 0.12);
      case PostType.reflexion: return AppColors.grey400.withValues(alpha: 0.12);
      case PostType.sondage:   return AppColors.chartViolet.withValues(alpha: 0.12);
    }
  }

  Color _typeFg(PostType t) {
    switch (t) {
      case PostType.question:  return AppColors.primaryLight;
      case PostType.debat:     return AppColors.secondary;
      case PostType.victoire:  return AppColors.chartAmber;
      case PostType.aide:      return AppColors.accent;
      case PostType.reflexion: return AppColors.grey400;
      case PostType.sondage:   return AppColors.chartViolet;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius:
            BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark
              ? AppColors.grey400.withValues(alpha: 0.12)
              : AppColors.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête : avatar + nom + temps + badge type ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar initiales
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                ),
                child: Center(
                  child: Text(
                    _initials,
                    style: AppTextStyles.bodySmall(color: Colors.white)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),

              // Nom + temps
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: AppTextStyles.bodyMedium(
                        color: isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _timeAgo(post.createdAt),
                      style: AppTextStyles.caption(
                          color: AppColors.grey400),
                    ),
                  ],
                ),
              ),

              // Badge type de post
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _typeBg(post.postType),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${post.postType.emoji}  ${post.postType.label}',
                  style: AppTextStyles.caption(
                          color: _typeFg(post.postType))
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),

              // Menu (supprimer si propre post, signaler sinon)
              _PostMenu(
                post: post,
                isOwnPost: isOwnPost,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing12),

          // ── Contenu ──────────────────────────────────────
          Text(
            post.content,
            style: AppTextStyles.bodyMedium(
              color:
                  isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),

          // ── Tag ──────────────────────────────────────────
          if (post.postTag != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                post.postTag!,
                style: AppTextStyles.caption(
                        color: AppColors.primaryLight)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],

          // ── Sondage ───────────────────────────────────────
          if (post.postType == PostType.sondage &&
              post.pollOptions != null) ...[
            const SizedBox(height: 12),
            _PollDisplay(
              post: post,
              userVote: userPollVote,
              isDark: isDark,
              onVote: (i) async {
                await ref
                    .read(pollVotedProvider.notifier)
                    .addVote(post.id, i);
                ref
                    .read(communityPostsProvider.notifier)
                    .votePoll(post.id, i);
              },
            ),
          ],

          const SizedBox(height: AppConstants.spacing12),

          // ── 4 Réactions ───────────────────────────────────
          _ReactionsRow(
            post: post,
            userReaction: userReaction,
            onReact: (reaction) async {
              await ref
                  .read(reactedPostsProvider.notifier)
                  .addReaction(post.id, reaction);
              ref
                  .read(communityPostsProvider.notifier)
                  .reactToPost(post.id, reaction);
            },
          ),
        ],
      ),
    );
  }
}

// ── Menu contextuel du post ───────────────────────────────────
class _PostMenu extends ConsumerWidget {
  final CommunityPost post;
  final bool isOwnPost;

  const _PostMenu({required this.post, required this.isOwnPost});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alreadyReported =
        ref.watch(reportedPostsProvider).contains(post.id);

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz_rounded,
        color: AppColors.grey400,
        size: 20,
      ),
      onSelected: (value) {
        switch (value) {
          case 'delete':
            _confirmDelete(context, ref);
          case 'report':
            _confirmReport(context, ref);
        }
      },
      itemBuilder: (_) => [
        if (isOwnPost)
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 18),
                SizedBox(width: 8),
                Text('Supprimer'),
              ],
            ),
          ),
        if (!isOwnPost && !alreadyReported)
          const PopupMenuItem(
            value: 'report',
            child: Row(
              children: [
                Icon(Icons.flag_outlined,
                    color: AppColors.grey400, size: 18),
                SizedBox(width: 8),
                Text('Signaler'),
              ],
            ),
          ),
        if (!isOwnPost && alreadyReported)
          PopupMenuItem(
            enabled: false,
            child: Row(
              children: [
                Icon(Icons.flag_rounded,
                    color: AppColors.grey400, size: 18),
                const SizedBox(width: 8),
                Text('Signalé',
                    style: AppTextStyles.bodySmall(
                        color: AppColors.grey400)),
              ],
            ),
          ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce post ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(communityPostsProvider.notifier)
                  .deletePost(post.id);
            },
            child: Text(
              'Supprimer',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReport(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Signaler ce post ?'),
        content: const Text(
            'Ce post sera examiné par l\'équipe Kolyb. Merci de contribuer à un salon bienveillant.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(communityPostsProvider.notifier)
                  .reportPost(post.id, 'inapproprié');
              ref
                  .read(reportedPostsProvider.notifier)
                  .addReport(post.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Signalement envoyé. Merci 🙏'),
                ),
              );
            },
            child: const Text('Signaler'),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Rangée de 4 réactions
// ──────────────────────────────────────────────────────────────
class _ReactionsRow extends StatelessWidget {
  final CommunityPost post;
  final ReactionType? userReaction;
  final Future<void> Function(ReactionType) onReact;

  const _ReactionsRow({
    required this.post,
    required this.userReaction,
    required this.onReact,
  });

  int _countFor(ReactionType r) {
    switch (r) {
      case ReactionType.utile:      return post.reactionsUtile;
      case ReactionType.inspirant:  return post.reactionsInspirant;
      case ReactionType.merci:      return post.reactionsMerci;
      case ReactionType.bravo:      return post.reactionsBravo;
    }
  }

  Color _colorFor(ReactionType r) {
    switch (r) {
      case ReactionType.utile:      return AppColors.primary;
      case ReactionType.inspirant:  return AppColors.secondary;
      case ReactionType.merci:      return AppColors.accent;
      case ReactionType.bravo:      return AppColors.chartAmber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasReacted = userReaction != null;

    return Row(
      children: ReactionType.values.map((reaction) {
        final count    = _countFor(reaction);
        final isActive = userReaction == reaction;
        final color    = _colorFor(reaction);

        return Expanded(
          child: GestureDetector(
            onTap: hasReacted ? null : () => onReact(reaction),
            child: AnimatedContainer(
              duration: AppConstants.animFast,
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                color: isActive
                    ? color.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive
                      ? color.withValues(alpha: 0.4)
                      : Colors.transparent,
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    reaction.emoji,
                    style: TextStyle(
                      fontSize: isActive ? 18 : 16,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$count',
                      style: AppTextStyles.caption(
                        color: isActive ? color : AppColors.grey400,
                      ).copyWith(
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Affichage d'un sondage
// ──────────────────────────────────────────────────────────────
class _PollDisplay extends StatelessWidget {
  final CommunityPost post;
  final int? userVote;
  final bool isDark;
  final Future<void> Function(int) onVote;

  const _PollDisplay({
    required this.post,
    this.userVote,
    required this.isDark,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final options    = post.pollOptions!;
    final votes      = post.pollVotes ?? List.filled(options.length, 0);
    final totalVotes = votes.fold<int>(0, (s, v) => s + v);
    final hasVoted   = userVote != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(options.length, (i) {
          final voteCount = i < votes.length ? votes[i] : 0;
          final ratio =
              totalVotes > 0 ? voteCount / totalVotes : 0.0;
          final isSelected = userVote == i;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: hasVoted ? null : () => onVote(i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.14)
                      : isDark
                          ? AppColors.surfaceElevatedDark
                          : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.45)
                        : isDark
                            ? AppColors.grey400.withValues(alpha: 0.15)
                            : AppColors.grey200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            options[i],
                            style: AppTextStyles.bodySmall(
                              color: isDark
                                  ? AppColors.textDark
                                  : AppColors.textLight,
                            ),
                          ),
                        ),
                        if (hasVoted)
                          Text(
                            '${(ratio * 100).round()}%',
                            style: AppTextStyles.caption(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : AppColors.grey400,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                      ],
                    ),
                    if (hasVoted) ...[
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio,
                          backgroundColor:
                              AppColors.grey400.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isSelected
                                ? AppColors.primary
                                : AppColors.grey400
                                    .withValues(alpha: 0.4),
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
        if (hasVoted)
          Text(
            '$totalVotes vote${totalVotes > 1 ? 's' : ''}',
            style: AppTextStyles.caption(color: AppColors.grey400),
          ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// FAB — créer un post
// ──────────────────────────────────────────────────────────────
class _PostFab extends StatelessWidget {
  final String authorName;
  const _PostFab({required this.authorName});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showPostSheet(context),
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.edit_rounded, color: Colors.white),
      label: Text(
        'Partager',
        style: AppTextStyles.bodyMedium(color: Colors.white)
            .copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showPostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _PostSheetContent(authorName: authorName),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Feuille de création de post — 2 étapes
// ──────────────────────────────────────────────────────────────
class _PostSheetContent extends ConsumerStatefulWidget {
  final String authorName;
  const _PostSheetContent({required this.authorName});

  @override
  ConsumerState<_PostSheetContent> createState() =>
      _PostSheetContentState();
}

class _PostSheetContentState
    extends ConsumerState<_PostSheetContent> {
  PostType _postType  = PostType.reflexion;
  bool _onTypeStep    = true; // true = choix du type, false = rédaction
  final _ctrl         = TextEditingController();
  String? _selectedTag;
  final _pollCtrls    = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    for (final c in _pollCtrls) { c.dispose(); }
    super.dispose();
  }

  bool get _canSubmit {
    if (_ctrl.text.trim().isEmpty) return false;
    if (_postType == PostType.sondage) {
      return _pollCtrls
              .where((c) => c.text.trim().isNotEmpty)
              .length >= 2;
    }
    return true;
  }

  Color _typeBg(PostType t) {
    switch (t) {
      case PostType.question:  return AppColors.primary.withValues(alpha: 0.12);
      case PostType.debat:     return AppColors.secondary.withValues(alpha: 0.12);
      case PostType.victoire:  return AppColors.chartAmber.withValues(alpha: 0.12);
      case PostType.aide:      return AppColors.accent.withValues(alpha: 0.12);
      case PostType.reflexion: return AppColors.grey400.withValues(alpha: 0.12);
      case PostType.sondage:   return AppColors.chartViolet.withValues(alpha: 0.12);
    }
  }

  Color _typeFg(PostType t) {
    switch (t) {
      case PostType.question:  return AppColors.primaryLight;
      case PostType.debat:     return AppColors.secondary;
      case PostType.victoire:  return AppColors.chartAmber;
      case PostType.aide:      return AppColors.accent;
      case PostType.reflexion: return AppColors.grey400;
      case PostType.sondage:   return AppColors.chartViolet;
    }
  }

  // ── Étape 0 : choix du type ───────────────────────────────
  Widget _buildTypeStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🗣️', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text('Que veux-tu partager ?',
                style: AppTextStyles.headingMedium()),
          ]),
          const SizedBox(height: 8),
          Text(
            'Choisis le format de ton post',
            style: AppTextStyles.bodySmall(color: AppColors.grey400),
          ),
          const SizedBox(height: 20),

          // Grille 2 colonnes des types
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.6,
            children: PostType.values.map((type) {
              return GestureDetector(
                onTap: () => setState(() {
                  _postType  = type;
                  _onTypeStep = false;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _typeBg(type),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _typeFg(type).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(type.emoji,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          type.label,
                          style: AppTextStyles.bodySmall(
                                  color: _typeFg(type))
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Étape 1 : rédaction ───────────────────────────────────
  Widget _buildEditStep(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête : retour + badge type
            Row(
              children: [
                GestureDetector(
                  onTap: () =>
                      setState(() => _onTypeStep = true),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: AppColors.grey400,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _typeBg(_postType),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_postType.emoji}  ${_postType.label}',
                    style: AppTextStyles.caption(
                            color: _typeFg(_postType))
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_ctrl.text.length}/280',
                  style:
                      AppTextStyles.caption(color: AppColors.grey400),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Zone de texte
            TextField(
              controller: _ctrl,
              autofocus: true,
              maxLines: 4,
              maxLength: 280,
              decoration: InputDecoration(
                hintText: _postType.placeholder,
                counterText: '',
              ),
              onChanged: (_) => setState(() {}),
            ),

            // Options du sondage
            if (_postType == PostType.sondage) ...[
              const SizedBox(height: 14),
              Text('Options du sondage',
                  style: AppTextStyles.labelMedium()),
              const SizedBox(height: 8),
              ...List.generate(_pollCtrls.length, (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: _pollCtrls[i],
                      decoration: InputDecoration(
                        hintText: 'Option ${i + 1}',
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  )),
              if (_pollCtrls.length < 4)
                TextButton.icon(
                  onPressed: () => setState(() =>
                      _pollCtrls.add(TextEditingController())),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Ajouter une option'),
                ),
            ],

            // Sélecteur de tag
            const SizedBox(height: 14),
            Text(
              'Tag (optionnel)',
              style: AppTextStyles.caption(color: AppColors.grey400),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: salonTags.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final tag = salonTags[i];
                  final selected = _selectedTag == tag;
                  return GestureDetector(
                    onTap: () => setState(() =>
                        _selectedTag = selected ? null : tag),
                    child: AnimatedContainer(
                      duration: AppConstants.animFast,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                                .withValues(alpha: 0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? AppColors.primaryLight
                                  .withValues(alpha: 0.5)
                              : AppColors.grey200,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: AppTextStyles.caption(
                          color: selected
                              ? AppColors.primaryLight
                              : AppColors.grey400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _canSubmit
                  ? () => _submit(context)
                  : null,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Publier'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _onTypeStep
        ? _buildTypeStep(context)
        : _buildEditStep(context);
  }

  Future<void> _submit(BuildContext context) async {
    Navigator.pop(context);
    try {
      List<String>? pollOptions;
      if (_postType == PostType.sondage) {
        pollOptions = _pollCtrls
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList();
        if (pollOptions.length < 2) pollOptions = null;
      }

      await ref.read(communityPostsProvider.notifier).createPost(
            content: _ctrl.text.trim(),
            authorName: widget.authorName,
            postType: _postType,
            postTag: _selectedTag,
            pollOptions: pollOptions,
          );
      ref.invalidate(weeklyPostCountProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post partagé, belle énergie ! 🚀'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Oups, ton post n\'a pas pu être publié. Réessaie !'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// ──────────────────────────────────────────────────────────────
// Bannière limite 3 posts/semaine
// ──────────────────────────────────────────────────────────────
class _PostLimitBanner extends StatelessWidget {
  final bool isDark;
  const _PostLimitBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing16,
        vertical: AppConstants.spacing12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius:
            BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Text('🔒', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.paywallNudgePost,
              style: AppTextStyles.bodySmall(
                color:
                    isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// État vide du feed
// ──────────────────────────────────────────────────────────────
class _FeedEmpty extends StatelessWidget {
  final bool isDark;
  final bool hasFilter;
  const _FeedEmpty({required this.isDark, this.hasFilter = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              hasFilter ? '🔍' : '👋',
              style: const TextStyle(fontSize: 56),
            ),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              hasFilter
                  ? 'Aucun post dans cette catégorie pour l\'instant.'
                  : AppStrings.emptyCommunity,
              style: AppTextStyles.headingSmall(
                  color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Sois le premier à partager dans ce format !'
                  : 'Sois le premier à partager quelque chose !',
              style:
                  AppTextStyles.bodyMedium(color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Onglet Groupes
// ──────────────────────────────────────────────────────────────
class _GroupesTab extends ConsumerWidget {
  const _GroupesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(communityGroupsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: AppConstants.spacing16,
            left: AppConstants.spacing8,
          ),
          child: Text(
            'Rejoins les groupes qui te ressemblent',
            style: AppTextStyles.bodyMedium(color: AppColors.grey400),
          ),
        ),
        ...groups.map(
          (group) => Padding(
            padding:
                const EdgeInsets.only(bottom: AppConstants.spacing12),
            child: _GroupCard(group: group, isDark: isDark),
          ),
        ),
        const SizedBox(height: AppConstants.spacing24),
        Center(
          child: Text(
            'D\'autres groupes arrivent bientôt 🌱',
            style: AppTextStyles.caption(color: AppColors.grey400),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Onglet Défis
// ──────────────────────────────────────────────────────────────
class _DefisTab extends ConsumerWidget {
  const _DefisTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsync = ref.watch(challengeProvider);

    return challengeAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Impossible de charger le défi 😕',
          style: AppTextStyles.bodyMedium(color: AppColors.grey400),
        ),
      ),
      data: (challenge) {
        if (challenge == null) {
          return Center(
            child: Text(
              'Aucun défi ce mois-ci encore 🌱',
              style: AppTextStyles.bodyMedium(
                  color: AppColors.grey400),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          children: [
            // ── En-tête du défi mensuel ──────────────────
            Container(
              padding:
                  const EdgeInsets.all(AppConstants.spacing24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0E0E24), Color(0xFF13102E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(
                    AppConstants.radiusLarge),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(challenge.emoji,
                          style: const TextStyle(fontSize: 36)),
                      const SizedBox(
                          width: AppConstants.spacing12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.18),
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Défi du mois 🏆',
                                style:
                                    AppTextStyles.labelMedium(
                                        color: AppColors
                                            .primaryLight),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              challenge.title,
                              style: AppTextStyles.headingSmall(
                                  color: AppColors.textDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing16),
                  Text(
                    challenge.description,
                    style: AppTextStyles.bodyMedium(
                        color: AppColors.textDark
                            .withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: AppConstants.spacing16),

                  // Barre de progression
                  if (challenge.isJoined) ...[
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${challenge.userProgressDays} / ${challenge.targetDays} jours',
                          style: AppTextStyles.labelMedium(
                              color: AppColors.primaryLight),
                        ),
                        Text(
                          '${challenge.daysRemaining}j restants',
                          style: AppTextStyles.caption(
                              color: AppColors.grey400),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: challenge.progressRatio,
                        backgroundColor: AppColors.primary
                            .withValues(alpha: 0.18),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(
                        height: AppConstants.spacing16),
                  ],

                  // Participants & récompense
                  Row(
                    children: [
                      Icon(Icons.people_outline_rounded,
                          size: 16, color: AppColors.grey400),
                      const SizedBox(width: 4),
                      Text(
                        '${challenge.participantsCount} participants',
                        style: AppTextStyles.caption(
                            color: AppColors.grey400),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.chartAmber
                              .withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🎁  ${challenge.rewardLabel}',
                          style: AppTextStyles.caption(
                              color: AppColors.chartAmber),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing16),

                  // Bouton rejoindre / quitter
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (challenge.isJoined) {
                          ref
                              .read(challengeProvider.notifier)
                              .leaveChallenge();
                        } else {
                          ref
                              .read(challengeProvider.notifier)
                              .joinChallenge();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: challenge.isJoined
                            ? AppColors.grey400
                                .withValues(alpha: 0.2)
                            : AppColors.primary,
                        foregroundColor: challenge.isJoined
                            ? AppColors.grey400
                            : Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        challenge.isJoined
                            ? 'Tu participes ✓'
                            : 'Rejoindre le défi',
                        style: AppTextStyles.labelMedium().copyWith(
                          color: challenge.isJoined
                              ? AppColors.grey400
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacing24),

            Center(
              child: Text(
                challenge.isJoined
                    ? 'Continue comme ça, tu avances à ton rythme 💪'
                    : 'Rejoins la communauté dans ce défi mensuel 🌱',
                style:
                    AppTextStyles.bodySmall(color: AppColors.grey400),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Carte d'un groupe
// ──────────────────────────────────────────────────────────────
class _GroupCard extends ConsumerWidget {
  final CommunityGroup group;
  final bool isDark;

  const _GroupCard({required this.group, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedContainer(
      duration: AppConstants.animFast,
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: group.isJoined
            ? AppColors.primary.withValues(alpha: 0.06)
            : isDark
                ? AppColors.surfaceDark
                : AppColors.surfaceLight,
        borderRadius:
            BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: group.isJoined
              ? AppColors.primary.withValues(alpha: 0.3)
              : isDark
                  ? AppColors.grey400.withValues(alpha: 0.12)
                  : AppColors.grey200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(group.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: AppConstants.spacing12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: AppTextStyles.bodyLarge(
                    color: isDark
                        ? AppColors.textDark
                        : AppColors.textLight,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  group.description,
                  style:
                      AppTextStyles.bodySmall(color: AppColors.grey400),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.people_outline_rounded,
                        size: 14, color: AppColors.grey400),
                    const SizedBox(width: 4),
                    Text(
                      '${group.membersCount} membres',
                      style: AppTextStyles.caption(
                          color: AppColors.grey400),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacing12),

          GestureDetector(
            onTap: () => ref
                .read(communityGroupsProvider.notifier)
                .toggleGroup(group.id),
            child: AnimatedContainer(
              duration: AppConstants.animFast,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: group.isJoined
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(
                  color: group.isJoined
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                group.isJoined ? 'Rejoint ✓' : 'Rejoindre',
                style: AppTextStyles.bodySmall(
                  color:
                      group.isJoined ? Colors.white : AppColors.primary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
