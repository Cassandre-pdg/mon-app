import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/pill_tab_bar.dart';
import '../../data/community_model.dart';
import '../../data/challenge_model.dart';
import '../providers/community_provider.dart';
import '../providers/challenge_provider.dart';

// ─────────────────────────────────────────────────────────────
// ÉCRAN PRINCIPAL
// ─────────────────────────────────────────────────────────────
class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBackground(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Text(
                    'Le Salon',
                    style: AppTextStyles.headingLarge(color: AppColors.textDark),
                  ),
                ),
                const SizedBox(height: 12),
                PillTabBar(tabs: const ['💬  Messages', '🏆  Défis']),
                const SizedBox(height: 8),
                const Expanded(
                  child: TabBarView(
                    children: [_MessagesTab(), _DefisTab()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ONGLET MESSAGES
// ─────────────────────────────────────────────────────────────
class _MessagesTab extends ConsumerStatefulWidget {
  const _MessagesTab();

  @override
  ConsumerState<_MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends ConsumerState<_MessagesTab> {
  String? _authorName;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    _authorName = user?.userMetadata?['full_name'] as String? ?? 'Kolyb';
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(filteredPostsProvider);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Column(
      children: [
        // Pills filtre type en premier — navigation stable
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: _TypeFilterPills(
            selected: ref.watch(postTypeFilterProvider),
            onSelect: (t) => ref.read(postTypeFilterProvider.notifier).state = t,
          ),
        ),
        const SizedBox(height: 12),

        // Question de la semaine — card visible, contenu dynamique
        _WeeklyQuestionCard(
          onTap: () => _openCompose(context, forcedType: PostType.reflexion),
        ),
        const SizedBox(height: 12),

        // Feed
        Expanded(
          child: postsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (_, __) => _FeedError(
              onRetry: () =>
                  ref.read(communityPostsProvider.notifier).loadPosts(),
            ),
            data: (posts) => posts.isEmpty
                ? const _FeedEmpty()
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(communityPostsProvider.notifier).loadPosts(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: posts.length,
                      itemBuilder: (ctx, i) => _MessageCard(
                        key: ValueKey(posts[i].id),
                        post: posts[i],
                        isOwnPost: posts[i].userId == currentUserId,
                        authorName: _authorName ?? 'Kolyb',
                      ),
                    ),
                  ),
          ),
        ),

        // Barre de composition fixe en bas
        _ComposeBar(onTap: () => _openCompose(context)),
      ],
    );
  }

  void _openCompose(BuildContext context, {PostType? forcedType}) {
    final weeklyCount =
        ref.read(weeklyPostCountProvider).value ?? 0;
    final canPost = weeklyCount < AppConstants.freeWeeklyPosts;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => _ComposeSheet(
        authorName: _authorName ?? 'Kolyb',
        forcedType: forcedType,
        canPost: canPost,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// QUESTION DE LA SEMAINE — card lisible, contenu dynamique
// ─────────────────────────────────────────────────────────────
class _WeeklyQuestionCard extends StatelessWidget {
  final VoidCallback onTap;
  const _WeeklyQuestionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône ampoule
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  '💡',
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(width: 10),
              // Question sur 2 lignes
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question de la semaine',
                      style: AppTextStyles.caption(color: AppColors.primaryPale)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      currentWeeklyQuestion,
                      style: AppTextStyles.bodySmall(color: AppColors.textDark),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Bouton répondre
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Répondre →',
                  style: AppTextStyles.caption(color: AppColors.primaryLight)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PILLS FILTRE TYPE
// ─────────────────────────────────────────────────────────────
class _TypeFilterPills extends StatelessWidget {
  final PostType? selected;
  final void Function(PostType?) onSelect;

  const _TypeFilterPills({required this.selected, required this.onSelect});

  Color _colorFor(PostType type) {
    switch (type) {
      case PostType.question:  return AppColors.primary;
      case PostType.debat:     return AppColors.secondary;
      case PostType.victoire:  return AppColors.chartAmber;
      case PostType.aide:      return AppColors.accent;
      case PostType.reflexion: return AppColors.primaryLight;
      case PostType.sondage:   return AppColors.chartViolet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final types = [null, ...PostType.values];

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final type = types[i];
          final isSelected = selected == type;
          final color =
              type != null ? _colorFor(type) : AppColors.primary;

          return GestureDetector(
            onTap: () => onSelect(isSelected ? null : type),
            child: AnimatedContainer(
              duration: AppConstants.animFast,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.2)
                    : AppColors.surfaceElevatedDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? color
                      : AppColors.grey400.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                type == null ? 'Tout' : type.emoji,
                style: AppTextStyles.labelMedium(
                  color: isSelected ? color : AppColors.textDarkMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CARTE MESSAGE
// ─────────────────────────────────────────────────────────────
class _MessageCard extends ConsumerStatefulWidget {
  final CommunityPost post;
  final bool isOwnPost;
  final String authorName;

  const _MessageCard({
    super.key,
    required this.post,
    required this.isOwnPost,
    required this.authorName,
  });

  @override
  ConsumerState<_MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends ConsumerState<_MessageCard> {
  bool _expanded = false;
  final _replyCtrl = TextEditingController();
  bool _sendingReply = false;

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  String get _initials {
    final parts = widget.post.authorName.trim().split(' ');
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays}j';
    return 'il y a ${(diff.inDays / 7).floor()} sem.';
  }

  Color get _typeColor {
    switch (widget.post.postType) {
      case PostType.question:  return AppColors.primary;
      case PostType.debat:     return AppColors.secondary;
      case PostType.victoire:  return AppColors.chartAmber;
      case PostType.aide:      return AppColors.accent;
      case PostType.reflexion: return AppColors.primaryLight;
      case PostType.sondage:   return AppColors.chartViolet;
    }
  }

  int _reactionCount(ReactionType r) {
    switch (r) {
      case ReactionType.utile:     return widget.post.reactionsUtile;
      case ReactionType.inspirant: return widget.post.reactionsInspirant;
      case ReactionType.merci:     return widget.post.reactionsMerci;
      case ReactionType.bravo:     return widget.post.reactionsBravo;
    }
  }

  Future<void> _react(ReactionType reaction) async {
    await ref
        .read(reactedPostsProvider.notifier)
        .addReaction(widget.post.id, reaction);
    ref
        .read(communityPostsProvider.notifier)
        .reactToPost(widget.post.id, reaction);
  }

  Future<void> _sendReply() async {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sendingReply = true);
    try {
      await ref.read(communityPostsProvider.notifier).createReply(
            content: text,
            authorName: widget.authorName,
            parentId: widget.post.id,
          );
      _replyCtrl.clear();
      ref.invalidate(repliesProvider(widget.post.id));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réponse non envoyée, réessaie !'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sendingReply = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reactedPosts = ref.watch(reactedPostsProvider);
    final isReacted = reactedPosts.containsKey(widget.post.id);
    final myReaction =
        ref.read(reactedPostsProvider.notifier).reactionFor(widget.post.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card principale ─────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _typeColor.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header : avatar + nom + badge type + menu
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 10, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar initiales
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              _typeColor,
                              _typeColor.withValues(alpha: 0.55)
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _initials,
                            style: AppTextStyles.caption(color: Colors.white)
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Nom + badge type + temps
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.post.authorName,
                                  style: AppTextStyles.bodySmall(
                                    color: AppColors.textDark,
                                  ).copyWith(fontWeight: FontWeight.w600),
                                ),
                                if (widget.post.postType !=
                                    PostType.reflexion) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          _typeColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${widget.post.postType.emoji} ${widget.post.postType.label}',
                                      style: AppTextStyles.caption(
                                          color: _typeColor),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              _timeAgo(widget.post.createdAt),
                              style: AppTextStyles.caption(
                                  color: AppColors.textDarkMuted),
                            ),
                          ],
                        ),
                      ),

                      // Menu (supprimer son propre message)
                      if (widget.isOwnPost)
                        _PostMenu(postId: widget.post.id),
                    ],
                  ),
                ),

                // Contenu
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Text(
                    widget.post.content,
                    style:
                        AppTextStyles.bodyMedium(color: AppColors.textDark),
                  ),
                ),

                // Tag
                if (widget.post.postTag != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
                    child: Text(
                      widget.post.postTag!,
                      style: AppTextStyles.caption(
                          color: AppColors.primaryPale),
                    ),
                  ),

                // Réactions + bouton répondre
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Row(
                    children: [
                      // 4 réactions
                      ...ReactionType.values.map((r) => _ReactionChip(
                            reaction: r,
                            count: _reactionCount(r),
                            isSelected: myReaction == r,
                            onTap: isReacted ? null : () => _react(r),
                          )),
                      const Spacer(),

                      // Bouton répondre
                      GestureDetector(
                        onTap: () =>
                            setState(() => _expanded = !_expanded),
                        child: Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 14,
                              color: _expanded
                                  ? AppColors.primaryLight
                                  : AppColors.textDarkMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.post.repliesCount > 0
                                  ? widget.post.repliesCount.toString()
                                  : 'Répondre',
                              style: AppTextStyles.caption(
                                color: _expanded
                                    ? AppColors.primaryLight
                                    : AppColors.textDarkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Réponses inline ─────────────────────────────────
          if (_expanded)
            _RepliesSection(
              parentId: widget.post.id,
              replyCtrl: _replyCtrl,
              isSending: _sendingReply,
              onSend: _sendReply,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CHIP RÉACTION
// ─────────────────────────────────────────────────────────────
class _ReactionChip extends StatelessWidget {
  final ReactionType reaction;
  final int count;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ReactionChip({
    required this.reaction,
    required this.count,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Row(
          children: [
            Text(reaction.emoji, style: const TextStyle(fontSize: 14)),
            if (count > 0) ...[
              const SizedBox(width: 3),
              Text(
                '$count',
                style: AppTextStyles.caption(
                  color: isSelected
                      ? AppColors.textDark
                      : AppColors.textDarkMuted,
                ).copyWith(
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SECTION RÉPONSES INLINE
// ─────────────────────────────────────────────────────────────
class _RepliesSection extends ConsumerWidget {
  final String parentId;
  final TextEditingController replyCtrl;
  final bool isSending;
  final VoidCallback onSend;

  const _RepliesSection({
    required this.parentId,
    required this.replyCtrl,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repliesAsync = ref.watch(repliesProvider(parentId));

    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Réponses existantes
          repliesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Impossible de charger les réponses',
                style:
                    AppTextStyles.caption(color: AppColors.textDarkMuted),
              ),
            ),
            data: (replies) => Column(
              children: replies
                  .map((r) => _ReplyItem(reply: r))
                  .toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Champ de réponse
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevatedDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.22),
                    ),
                  ),
                  child: TextField(
                    controller: replyCtrl,
                    maxLines: 3,
                    minLines: 1,
                    style: AppTextStyles.bodySmall(
                        color: AppColors.textDark),
                    decoration: InputDecoration(
                      hintText: 'Ta réponse...',
                      hintStyle: AppTextStyles.bodySmall(
                          color: AppColors.textDarkMuted),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: isSending ? null : onSend,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: isSending
                      ? const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.send_rounded,
                          size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ITEM RÉPONSE (compact, ligne gauche violet)
// ─────────────────────────────────────────────────────────────
class _ReplyItem extends StatelessWidget {
  final CommunityPost reply;
  const _ReplyItem({required this.reply});

  String get _initials {
    final parts = reply.authorName.trim().split(' ');
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final diff = DateTime.now().difference(reply.createdAt);
    final time = diff.inMinutes < 60
        ? '${diff.inMinutes}m'
        : diff.inHours < 24
            ? '${diff.inHours}h'
            : '${diff.inDays}j';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceElevatedDark,
              ),
              child: Center(
                child: Text(
                  _initials,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        reply.authorName,
                        style: AppTextStyles.caption(color: AppColors.textDark)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        time,
                        style: AppTextStyles.caption(
                            color: AppColors.textDarkMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    reply.content,
                    style:
                        AppTextStyles.bodySmall(color: AppColors.textDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// BARRE DE COMPOSITION (bas de l'écran)
// ─────────────────────────────────────────────────────────────
class _ComposeBar extends StatelessWidget {
  final VoidCallback onTap;
  const _ComposeBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Dégradé transparent → fond pour se fondre sans couper le contenu
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.backgroundDark.withValues(alpha: 0.92),
            AppColors.backgroundDark,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.add_circle_outline_rounded,
                size: 20,
                color: AppColors.primaryLight,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Quoi de neuf ?',
                  style: AppTextStyles.bodyMedium(
                      color: AppColors.textDarkMuted),
                ),
              ),
              Icon(
                Icons.send_rounded,
                size: 18,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SHEET COMPOSITION — 2 étapes
// ─────────────────────────────────────────────────────────────
class _ComposeSheet extends ConsumerStatefulWidget {
  final String authorName;
  final PostType? forcedType;
  final bool canPost;

  const _ComposeSheet({
    required this.authorName,
    this.forcedType,
    required this.canPost,
  });

  @override
  ConsumerState<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends ConsumerState<_ComposeSheet> {
  PostType? _type;
  final _ctrl = TextEditingController();
  String? _selectedTag;
  bool _sending = false;
  int _step = 1;

  @override
  void initState() {
    super.initState();
    if (widget.forcedType != null) {
      _type = widget.forcedType;
      _step = 2;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevatedDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey400.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (!widget.canPost)
              _buildPaywallNudge()
            else if (_step == 1)
              _buildStep1()
            else
              _buildStep2(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaywallNudge() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        children: [
          const Text('🔒', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'Tu as partagé 3 messages cette semaine',
            style: AppTextStyles.headingSmall(color: AppColors.textDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Passe à Pro pour des échanges illimités 🚀',
            style:
                AppTextStyles.bodyMedium(color: AppColors.primaryPale),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Quel type de message ?',
            style:
                AppTextStyles.headingMedium(color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            'Choisis selon ce que tu veux partager',
            style: AppTextStyles.bodySmall(color: AppColors.textDarkMuted),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.3,
            children: PostType.values
                .map((type) => _TypeCard(
                      type: type,
                      onTap: () => setState(() {
                        _type = type;
                        _step = 2;
                      }),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header : retour + type sélectionné
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _step = 1),
                child: const Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 18,
                  color: AppColors.textDarkMuted,
                ),
              ),
              const SizedBox(width: 8),
              if (_type != null) ...[
                Text(_type!.emoji,
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  _type!.label,
                  style: AppTextStyles.headingMedium(
                      color: AppColors.textDark),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Zone de texte
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              maxLines: 5,
              minLines: 3,
              maxLength: 280,
              style:
                  AppTextStyles.bodyMedium(color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: _type?.placeholder ??
                    'Partage quelque chose avec Le Salon...',
                hintStyle: AppTextStyles.bodyMedium(
                    color: AppColors.textDarkMuted),
                counterText: '',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 10),

          // Sélecteur de tag
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: salonTags.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final tag = salonTags[i];
                final isSelected = _selectedTag == tag;
                return GestureDetector(
                  onTap: () => setState(
                      () => _selectedTag = isSelected ? null : tag),
                  child: AnimatedContainer(
                    duration: AppConstants.animFast,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.grey400.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: AppTextStyles.caption(
                        color: isSelected
                            ? AppColors.primaryLight
                            : AppColors.textDarkMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Compteur + bouton publier
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_ctrl.text.length}/280',
                style: AppTextStyles.caption(
                    color: AppColors.textDarkMuted),
              ),
              ElevatedButton.icon(
                onPressed: (_ctrl.text.trim().isEmpty || _sending)
                    ? null
                    : _publish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.3),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                ),
                icon: _sending
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded,
                        size: 16, color: Colors.white),
                label: Text(
                  'Publier',
                  style: AppTextStyles.bodySmall(color: Colors.white)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _publish() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref.read(communityPostsProvider.notifier).createPost(
            content: _ctrl.text.trim(),
            authorName: widget.authorName,
            postType: _type ?? PostType.reflexion,
            postTag: _selectedTag,
          );
      ref.invalidate(weeklyPostCountProvider);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Oups, ton message n\'a pas pu être publié. Réessaie !'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _sending = false);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// CARTE TYPE (grille étape 1)
// ─────────────────────────────────────────────────────────────
class _TypeCard extends StatelessWidget {
  final PostType type;
  final VoidCallback onTap;

  const _TypeCard({required this.type, required this.onTap});

  Color get _color {
    switch (type) {
      case PostType.question:  return AppColors.primary;
      case PostType.debat:     return AppColors.secondary;
      case PostType.victoire:  return AppColors.chartAmber;
      case PostType.aide:      return AppColors.accent;
      case PostType.reflexion: return AppColors.primaryLight;
      case PostType.sondage:   return AppColors.chartViolet;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: _color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(type.emoji,
                style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(
              type.label,
              style: AppTextStyles.caption(color: _color)
                  .copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MENU POST (supprimer)
// ─────────────────────────────────────────────────────────────
class _PostMenu extends ConsumerWidget {
  final String postId;
  const _PostMenu({required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz_rounded,
        color: AppColors.textDarkMuted,
        size: 20,
      ),
      color: AppColors.surfaceElevatedDark,
      onSelected: (value) {
        if (value == 'delete') {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Supprimer ce message ?'),
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
                        .deletePost(postId);
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
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 18),
              const SizedBox(width: 8),
              const Text('Supprimer'),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ÉTAT VIDE DU FEED
// ─────────────────────────────────────────────────────────────
class _FeedEmpty extends StatelessWidget {
  const _FeedEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('👋', style: TextStyle(fontSize: 52)),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              'Le Salon est calme pour l\'instant',
              style: AppTextStyles.headingSmall(
                  color: AppColors.textDarkMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Lance la conversation, tu seras le premier !',
              style: AppTextStyles.bodyMedium(
                  color: AppColors.textDarkMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ÉTAT ERREUR DU FEED
// ─────────────────────────────────────────────────────────────
class _FeedError extends StatelessWidget {
  final VoidCallback onRetry;
  const _FeedError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😕', style: TextStyle(fontSize: 44)),
          const SizedBox(height: AppConstants.spacing16),
          Text(
            'Impossible de charger les messages',
            style: AppTextStyles.bodyMedium(
                color: AppColors.textDarkMuted),
          ),
          const SizedBox(height: AppConstants.spacing16),
          TextButton(
            onPressed: onRetry,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ONGLET DÉFIS — REFONTE
// ─────────────────────────────────────────────────────────────
class _DefisTab extends ConsumerWidget {
  const _DefisTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsync = ref.watch(challengeProvider);

    return challengeAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😕', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 12),
              Text(
                'Impossible de charger le défi du mois',
                style: AppTextStyles.bodyMedium(color: AppColors.textDarkMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      data: (challenge) {
        if (challenge == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacing32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 16),
                  Text(
                    'Pas de défi ce mois-ci',
                    style: AppTextStyles.headingSmall(
                        color: AppColors.textDarkMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reviens bientôt, le prochain arrive !',
                    style: AppTextStyles.bodyMedium(
                        color: AppColors.textDarkMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // Section A : Hero card du défi
            _ChallengeHeroCard(challenge: challenge),

            // Section B : Ma progression (seulement si inscrit)
            if (challenge.isJoined) ...[
              const SizedBox(height: 16),
              _UserProgressCard(challenge: challenge),
            ],

            // Section C : Classement compétitif
            const SizedBox(height: 24),
            _LeaderboardSection(challenge: challenge),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SECTION A — HERO CARD DU DÉFI
// ─────────────────────────────────────────────────────────────
class _ChallengeHeroCard extends ConsumerWidget {
  final KolybChallenge challenge;
  const _ChallengeHeroCard({required this.challenge});

  static const _monthNames = [
    '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];

  /// Action quotidienne selon le type de défi mensuel
  static String _dailyAction(int month) {
    switch (month) {
      case 2:
      case 6:
      case 7:
      case 11:
        return 'Complète ton check-in matin ET soir chaque jour';
      case 3:
        return 'Lance une session Focus chaque jour';
      default:
        return 'Fais ton check-in matin chaque jour';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final monthName = _monthNames[now.month];
    final daysLeft = challenge.daysRemaining;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.28),
            AppColors.surfaceDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header : emoji + mois + J-X ──────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji dans un cercle premium
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      challenge.emoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge "Défi de mai"
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                AppColors.primaryLight.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'Défi de $monthName',
                          style: AppTextStyles.caption(
                            color: AppColors.primaryPale,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        challenge.title,
                        style: AppTextStyles.headingMedium(
                            color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
                // Countdown J-X (rouge si ≤ 7 jours)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: daysLeft <= 7
                        ? AppColors.secondary.withValues(alpha: 0.15)
                        : AppColors.surfaceElevatedDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: daysLeft <= 7
                          ? AppColors.secondary.withValues(alpha: 0.4)
                          : AppColors.glassBorderWhite,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'J-$daysLeft',
                        style: AppTextStyles.bodySmall(
                          color: daysLeft <= 7
                              ? AppColors.secondary
                              : AppColors.textDark,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'restants',
                        style: AppTextStyles.caption(
                            color: AppColors.textDarkMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Description ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Text(
              challenge.description,
              style: AppTextStyles.bodySmall(
                color: AppColors.textDark.withValues(alpha: 0.85),
              ),
            ),
          ),

          // ── Séparateur ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Divider(
              color: AppColors.primary.withValues(alpha: 0.15),
              height: 1,
            ),
          ),

          // ── Comment participer — 3 étapes ──────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comment participer',
                  style: AppTextStyles.labelMedium(color: AppColors.primaryPale)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _StepRow(
                  number: 1,
                  icon: Icons.add_circle_outline_rounded,
                  text: 'Rejoins le défi en appuyant sur le bouton ci-dessous',
                  color: AppColors.primaryLight,
                ),
                const SizedBox(height: 10),
                _StepRow(
                  number: 2,
                  icon: Icons.check_circle_outline_rounded,
                  text: _dailyAction(now.month),
                  color: AppColors.accent,
                ),
                const SizedBox(height: 10),
                _StepRow(
                  number: 3,
                  icon: Icons.emoji_events_outlined,
                  text: 'Partage ta victoire dans Le Salon 🏆',
                  color: AppColors.chartAmber,
                ),
              ],
            ),
          ),

          // ── Séparateur ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Divider(
              color: AppColors.primary.withValues(alpha: 0.15),
              height: 1,
            ),
          ),

          // ── Badge exclusif à débloquer ──────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.chartAmber.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.chartAmber.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Center(
                    child: Text('🏅', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Badge exclusif à débloquer',
                        style: AppTextStyles.caption(color: AppColors.chartAmber)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        challenge.rewardLabel,
                        style:
                            AppTextStyles.bodySmall(color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── CTA principal ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: challenge.isJoined
                ? const _JoinedBadge()
                : _JoinButton(
                    onTap: () =>
                        ref.read(challengeProvider.notifier).joinChallenge(),
                  ),
          ),

          // ── Nombre de participants ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline_rounded,
                  size: 14,
                  color: AppColors.textDarkMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  '${challenge.participantsCount} entrepreneurs relèvent ce défi',
                  style: AppTextStyles.caption(color: AppColors.textDarkMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Étape numérotée ──────────────────────────────────────────
class _StepRow extends StatelessWidget {
  final int number;
  final IconData icon;
  final String text;
  final Color color;

  const _StepRow({
    required this.number,
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cercle numéroté
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 16, color: color.withValues(alpha: 0.8)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall(color: AppColors.textDark),
          ),
        ),
      ],
    );
  }
}

// ── Bouton "Je relève le défi" ───────────────────────────────
class _JoinButton extends StatelessWidget {
  final VoidCallback onTap;
  const _JoinButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💪', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              'Je relève le défi !',
              style: AppTextStyles.bodyMedium(color: Colors.white)
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Badge "Inscrit au défi" ──────────────────────────────────
class _JoinedBadge extends StatelessWidget {
  const _JoinedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: AppColors.primaryLight,
          ),
          const SizedBox(width: 8),
          Text(
            'Tu participes à ce défi',
            style: AppTextStyles.bodySmall(color: AppColors.primaryPale)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SECTION B — MA PROGRESSION
// ─────────────────────────────────────────────────────────────
class _UserProgressCard extends StatelessWidget {
  final KolybChallenge challenge;
  const _UserProgressCard({required this.challenge});

  String _statusLabel() {
    final ratio = challenge.progressRatio;
    if (challenge.isCompleted) return 'Défi accompli 🏆';
    if (ratio >= 0.75) return 'Presque au sommet, tiens bon !';
    if (ratio >= 0.5) return 'Plus que la moitié, continue !';
    if (ratio >= 0.25) return 'Bien lancé, garde le rythme !';
    if (ratio > 0) return 'Tu as commencé, ne t\'arrête plus !';
    return 'Lance-toi, le premier jour compte !';
  }

  Color _statusColor() {
    final ratio = challenge.progressRatio;
    if (challenge.isCompleted) return AppColors.chartAmber;
    if (ratio >= 0.75) return AppColors.accent;
    if (ratio >= 0.5) return AppColors.primaryLight;
    return AppColors.primaryPale;
  }

  @override
  Widget build(BuildContext context) {
    final progress = challenge.progressRatio;
    final done = challenge.userProgressDays;
    final total = challenge.targetDays;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Ma progression',
                style: AppTextStyles.headingSmall(color: AppColors.textDark),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Compteur + cercle ─────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$done',
                            style: AppTextStyles.headingLarge(
                              color: AppColors.primaryLight,
                            ).copyWith(fontSize: 38),
                          ),
                          TextSpan(
                            text: ' / $total jours',
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.textDarkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusLabel(),
                      style: AppTextStyles.caption(color: _statusColor())
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              // Cercle de pourcentage
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.surfaceElevatedDark,
                      valueColor: AlwaysStoppedAnimation(
                        challenge.isCompleted
                            ? AppColors.chartAmber
                            : AppColors.primaryLight,
                      ),
                      strokeWidth: 6,
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: AppTextStyles.caption(color: AppColors.textDark)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Barre de progression ──────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceElevatedDark,
              valueColor: AlwaysStoppedAnimation(
                challenge.isCompleted ? AppColors.chartAmber : AppColors.primary,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SECTION C — CLASSEMENT DU MOIS
// ─────────────────────────────────────────────────────────────

/// Entrée du classement
class _LeaderEntry {
  final String name;
  final int days;
  final bool isCurrentUser;

  const _LeaderEntry({
    required this.name,
    required this.days,
    required this.isCurrentUser,
  });
}

/// Génère un classement mockée déterministe par mois — à remplacer par Supabase en V2
List<_LeaderEntry> _buildMockLeaderboard(KolybChallenge challenge) {
  final now = DateTime.now();
  // Seed stable par mois+année pour une liste cohérente pendant toute la session
  final monthSeed = now.month * 13 + now.year;

  const frenchNames = [
    'Marie B.', 'Thomas L.', 'Sophie M.', 'Lucas D.', 'Emma R.',
    'Nathan V.', 'Léa F.', 'Antoine G.', 'Camille H.', 'Hugo P.',
    'Manon S.', 'Romain C.', 'Clara B.', 'Julien M.', 'Alice T.',
    'Pierre N.', 'Inès K.', 'Maxime R.', 'Laura D.', 'Théo V.',
  ];

  final daysSinceStart = now
      .difference(challenge.startDate)
      .inDays
      .clamp(1, challenge.targetDays);

  // Max 19 fictifs + l'utilisateur = 20 max dans le classement
  final count = challenge.participantsCount.clamp(4, 19);
  final entries = <_LeaderEntry>[];

  for (int i = 0; i < count; i++) {
    // Progression décroissante avec légère variation pour éviter les ex-aequo
    final baseProgress = (daysSinceStart - (i * 0.7)).round();
    final variation = (monthSeed + i * 7) % 4 - 1; // de -1 à +2
    final days = (baseProgress + variation).clamp(0, daysSinceStart);
    entries.add(_LeaderEntry(
      name: frenchNames[i % frenchNames.length],
      days: days,
      isCurrentUser: false,
    ));
  }

  // Insère l'utilisateur courant avec sa progression réelle
  entries.add(_LeaderEntry(
    name: 'Toi',
    days: challenge.userProgressDays,
    isCurrentUser: true,
  ));

  // Tri décroissant par jours complétés
  entries.sort((a, b) => b.days.compareTo(a.days));
  return entries;
}

class _LeaderboardSection extends StatelessWidget {
  final KolybChallenge challenge;
  const _LeaderboardSection({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final entries = _buildMockLeaderboard(challenge);
    final userRank = entries.indexWhere((e) => e.isCurrentUser) + 1;
    final top10 = entries.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Titre + badge de rang utilisateur ──────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Classement du mois',
              style: AppTextStyles.headingSmall(color: AppColors.textDark),
            ),
            if (userRank > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  userRank == 1
                      ? '🥇 Tu mènes !'
                      : userRank == 2
                          ? '🥈 Top 3 !'
                          : userRank == 3
                              ? '🥉 Top 3 !'
                              : 'Tu es ${userRank}e',
                  style: AppTextStyles.caption(color: AppColors.primaryPale)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Prouve ce dont tu es capable 🔥',
          style: AppTextStyles.caption(color: AppColors.textDarkMuted),
        ),
        const SizedBox(height: 16),

        // ── Top 10 ─────────────────────────────────────────
        ...top10.asMap().entries.map((e) => _LeaderRow(
              rank: e.key + 1,
              entry: e.value,
              totalDays: challenge.targetDays,
            )),

        // ── Séparateur + ta position si > top 10 ───────────
        if (userRank > 10) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Expanded(
                  child: Divider(color: AppColors.surfaceElevatedDark),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '···',
                    style: AppTextStyles.caption(
                        color: AppColors.textDarkMuted),
                  ),
                ),
                const Expanded(
                  child: Divider(color: AppColors.surfaceElevatedDark),
                ),
              ],
            ),
          ),
          _LeaderRow(
            rank: userRank,
            entry: entries[userRank - 1],
            totalDays: challenge.targetDays,
          ),
        ],
      ],
    );
  }
}

// ── Ligne du classement ──────────────────────────────────────
class _LeaderRow extends StatelessWidget {
  final int rank;
  final _LeaderEntry entry;
  final int totalDays;

  const _LeaderRow({
    required this.rank,
    required this.entry,
    required this.totalDays,
  });

  String _medal() {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }

  Color _avatarColor() {
    if (entry.isCurrentUser) return AppColors.primary;
    switch (rank % 5) {
      case 1:
        return AppColors.accent;
      case 2:
        return AppColors.secondary;
      case 3:
        return AppColors.chartAmber;
      case 4:
        return AppColors.primaryLight;
      default:
        return AppColors.grey600;
    }
  }

  String get _initials {
    final parts = entry.name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    final progressRatio =
        totalDays > 0 ? (entry.days / totalDays).clamp(0.0, 1.0) : 0.0;
    final avatarColor = _avatarColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: entry.isCurrentUser
              ? AppColors.primary.withValues(alpha: 0.35)
              : isTop3
                  ? AppColors.chartAmber.withValues(alpha: 0.2)
                  : AppColors.surfaceElevatedDark,
        ),
      ),
      child: Row(
        children: [
          // Rang ou médaille
          SizedBox(
            width: 28,
            child: _medal().isNotEmpty
                ? Text(_medal(), style: const TextStyle(fontSize: 20))
                : Text(
                    '$rank',
                    style: AppTextStyles.bodySmall(
                            color: AppColors.textDarkMuted)
                        .copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: 8),

          // Avatar initiales coloré
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarColor.withValues(alpha: 0.2),
              border: Border.all(color: avatarColor.withValues(alpha: 0.5)),
            ),
            child: Center(
              child: Text(
                entry.isCurrentUser ? '✦' : _initials,
                style: TextStyle(
                  fontSize: entry.isCurrentUser ? 14 : 12,
                  fontWeight: FontWeight.w700,
                  color: avatarColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Nom + barre de progression
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.isCurrentUser ? 'Toi 👤' : entry.name,
                        style: AppTextStyles.bodySmall(
                          color: entry.isCurrentUser
                              ? AppColors.primaryPale
                              : AppColors.textDark,
                        ).copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.days}j',
                      style: AppTextStyles.caption(
                        color: entry.isCurrentUser
                            ? AppColors.primaryPale
                            : AppColors.textDarkMuted,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressRatio,
                    backgroundColor: AppColors.surfaceElevatedDark,
                    valueColor: AlwaysStoppedAnimation(
                      entry.isCurrentUser
                          ? AppColors.primaryLight
                          : isTop3
                              ? AppColors.chartAmber
                              : AppColors.grey400,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
