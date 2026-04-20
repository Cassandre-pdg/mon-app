import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/constants/app_strings.dart';
import '../../data/community_model.dart';
import '../providers/community_provider.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
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

              // ── Onglets Feed / Groupes ──────────────────────
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
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: isDark
                    ? AppColors.grey400.withValues(alpha: 0.2)
                    : AppColors.grey200,
              ),

              // ── Contenu des onglets ──────────────────────────
              const Expanded(
                child: TabBarView(
                  children: [
                    _FeedTab(),
                    _GroupesTab(),
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

// ── Onglet Feed ───────────────────────────────────────────────
class _FeedTab extends ConsumerWidget {
  const _FeedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityPostsProvider);
    final weeklyCountAsync = ref.watch(weeklyPostCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final weeklyCount = weeklyCountAsync.value ?? 0;
    final canPost = weeklyCount < AppConstants.freeWeeklyPosts;
    final currentUser = Supabase.instance.client.auth.currentUser;
    final authorName =
        currentUser?.userMetadata?['full_name'] as String? ?? 'Kolyb';
    final likedIds = ref.watch(likedPostIdsProvider);

    return Stack(
      children: [
        postsAsync.when(
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
                  style: AppTextStyles.bodyMedium(color: AppColors.grey400),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacing16),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(communityPostsProvider.notifier).loadPosts(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
          data: (posts) => posts.isEmpty
              ? _FeedEmpty(isDark: isDark)
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(communityPostsProvider.notifier).loadPosts(),
                  child: ListView.separated(
                    padding: EdgeInsets.only(
                      left: AppConstants.spacing16,
                      right: AppConstants.spacing16,
                      top: AppConstants.spacing16,
                      // Espace pour le FAB
                      bottom: canPost ? 88 : AppConstants.spacing24,
                    ),
                    itemCount: posts.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppConstants.spacing12),
                    itemBuilder: (context, i) => _PostCard(
                      post: posts[i],
                      isDark: isDark,
                      isOwnPost: posts[i].userId == currentUser?.id,
                      isLiked: likedIds.contains(posts[i].id),
                    ),
                  ),
                ),
        ),

        // ── FAB ou nudge limite ─────────────────────────────
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

// ── Carte d'un post ───────────────────────────────────────────
class _PostCard extends ConsumerWidget {
  final CommunityPost post;
  final bool isDark;
  final bool isOwnPost;
  final bool isLiked;

  const _PostCard({
    required this.post,
    required this.isDark,
    required this.isOwnPost,
    required this.isLiked,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark
              ? AppColors.grey400.withValues(alpha: 0.12)
              : AppColors.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête : avatar + nom + temps
          Row(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: AppTextStyles.bodyMedium(
                        color:
                            isDark ? AppColors.textDark : AppColors.textLight,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _timeAgo(post.createdAt),
                      style: AppTextStyles.caption(color: AppColors.grey400),
                    ),
                  ],
                ),
              ),

              // Menu supprimer (seulement son propre post)
              if (isOwnPost)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.grey400,
                    size: 20,
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDelete(context, ref);
                    }
                  },
                  itemBuilder: (_) => [
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
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing12),

          // Contenu du post
          Text(
            post.content,
            style: AppTextStyles.bodyMedium(
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),

          // Like — désactivé si déjà aimé
          GestureDetector(
            onTap: isLiked
                ? null
                : () async {
                    await ref
                        .read(likedPostIdsProvider.notifier)
                        .addLike(post.id);
                    ref
                        .read(communityPostsProvider.notifier)
                        .likePost(post.id);
                  },
            child: Row(
              children: [
                Icon(
                  isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 18,
                  color: isLiked
                      ? AppColors.secondary
                      : AppColors.secondary.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.likesCount}',
                  style: AppTextStyles.bodySmall(
                    color: isLiked
                        ? AppColors.secondary
                        : AppColors.secondary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
}

// ── FAB créer un post ─────────────────────────────────────────
class _PostFab extends ConsumerWidget {
  final String authorName;
  const _PostFab({required this.authorName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () => _showPostSheet(context, ref),
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.edit_rounded, color: Colors.white),
      label: Text(
        'Partager',
        style: AppTextStyles.bodyMedium(color: Colors.white)
            .copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showPostSheet(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🗣️', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text('Partage avec Le Salon',
                      style: AppTextStyles.headingMedium()),
                ],
              ),
              const SizedBox(height: AppConstants.spacing16),
              TextField(
                controller: ctrl,
                autofocus: true,
                maxLines: 5,
                maxLength: 280,
                decoration: const InputDecoration(
                  hintText:
                      'Qu\'est-ce que tu veux partager aujourd\'hui ? 🚀',
                  counterText: '',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${ctrl.text.length}/280',
                  style: AppTextStyles.caption(color: AppColors.grey400),
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),
              ElevatedButton.icon(
                onPressed: ctrl.text.trim().isEmpty
                    ? null
                    : () => _submit(context, ref, ctrl.text.trim()),
                icon: const Icon(Icons.send_rounded),
                label: const Text('Publier'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    String content,
  ) async {
    Navigator.pop(context);
    try {
      await ref.read(communityPostsProvider.notifier).createPost(
            content: content,
            authorName: authorName,
          );
      // Rafraîchit le compteur hebdomadaire
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
            content: Text('Oups, ton post n\'a pas pu être publié. Réessaie !'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// ── Bannière limite 3 posts/semaine ───────────────────────────
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
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
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
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── État vide du feed ─────────────────────────────────────────
class _FeedEmpty extends StatelessWidget {
  final bool isDark;
  const _FeedEmpty({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('👋', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              AppStrings.emptyCommunity,
              style: AppTextStyles.headingSmall(color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sois le premier à partager quelque chose !',
              style: AppTextStyles.bodyMedium(color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Onglet Groupes ────────────────────────────────────────────
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
            padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
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

// ── Carte d'un groupe ─────────────────────────────────────────
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
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
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
          // Emoji groupe
          Text(group.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: AppConstants.spacing12),

          // Infos groupe
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: AppTextStyles.bodyLarge(
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  group.description,
                  style: AppTextStyles.bodySmall(color: AppColors.grey400),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 14,
                      color: AppColors.grey400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${group.membersCount} membres',
                      style:
                          AppTextStyles.caption(color: AppColors.grey400),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacing12),

          // Bouton rejoindre / quitter
          GestureDetector(
            onTap: () =>
                ref.read(communityGroupsProvider.notifier).toggleGroup(group.id),
            child: AnimatedContainer(
              duration: AppConstants.animFast,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  color: group.isJoined ? Colors.white : AppColors.primary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
