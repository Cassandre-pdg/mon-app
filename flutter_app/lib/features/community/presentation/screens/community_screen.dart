import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/pill_tab_bar.dart';
import '../../data/community_model.dart';
import '../../data/challenge_model.dart';
import '../providers/community_provider.dart';
import '../providers/challenge_provider.dart';

// ── Dégradé noir → bleu foncé propre au Salon ────────────────
const _salonGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF0D0B1E), Color(0xFF071428)],
);

// ─────────────────────────────────────────────────────────────
// ÉCRAN PRINCIPAL
// ─────────────────────────────────────────────────────────────
class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: const BoxDecoration(gradient: _salonGradient),
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
        // Question de la semaine — 1 ligne discrète
        _WeeklyQuestionBar(
          onTap: () => _openCompose(context, forcedType: PostType.reflexion),
        ),
        const SizedBox(height: 8),

        // Pills filtre type (scroll horizontal)
        _TypeFilterPills(
          selected: ref.watch(postTypeFilterProvider),
          onSelect: (t) => ref.read(postTypeFilterProvider.notifier).state = t,
        ),
        const SizedBox(height: 8),

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
// QUESTION DE LA SEMAINE — 1 ligne discrète
// ─────────────────────────────────────────────────────────────
class _WeeklyQuestionBar extends StatelessWidget {
  final VoidCallback onTap;
  const _WeeklyQuestionBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '💡 Cette semaine : "$currentWeeklyQuestion"',
                style: AppTextStyles.caption(color: AppColors.primaryPale),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Répondre →',
              style: AppTextStyles.caption(color: AppColors.primaryLight),
            ),
          ],
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0B1E).withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
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
// ONGLET DÉFIS
// ─────────────────────────────────────────────────────────────
class _DefisTab extends ConsumerWidget {
  const _DefisTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsync = ref.watch(challengeProvider);

    return challengeAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Text(
          'Impossible de charger le défi',
          style: AppTextStyles.bodyMedium(
              color: AppColors.textDarkMuted),
        ),
      ),
      data: (challenge) {
        if (challenge == null) {
          return Center(
            child: Text(
              'Pas de défi ce mois-ci',
              style: AppTextStyles.bodyMedium(
                  color: AppColors.textDarkMuted),
            ),
          );
        }
        return ListView(
          padding:
              const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _ChallengeCard(challenge: challenge),
            const SizedBox(height: 24),
            const _ChallengeVictoriesSection(),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CARD DÉFI DU MOIS
// ─────────────────────────────────────────────────────────────
class _ChallengeCard extends ConsumerWidget {
  final KolybChallenge challenge;
  const _ChallengeCard({required this.challenge});

  static const _months = [
    '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = challenge.progressRatio;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.22),
            AppColors.chartAmber.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(challenge.emoji,
                  style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Défi ${_months[DateTime.now().month]}',
                      style: AppTextStyles.caption(
                          color: AppColors.primaryPale),
                    ),
                    Text(
                      challenge.title,
                      style: AppTextStyles.headingMedium(
                          color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            challenge.description,
            style: AppTextStyles.bodySmall(
              color: AppColors.textDark.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 16),

          // Barre de progression
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${challenge.userProgressDays}/${challenge.targetDays} jours',
                style: AppTextStyles.caption(
                    color: AppColors.primaryPale),
              ),
              Text(
                'J-${challenge.daysRemaining}',
                style: AppTextStyles.caption(
                    color: AppColors.textDarkMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  AppColors.surfaceDark,
              valueColor: AlwaysStoppedAnimation(
                challenge.isCompleted
                    ? AppColors.chartAmber
                    : AppColors.primary,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),

          // Footer : participants + bouton
          Row(
            children: [
              const Icon(
                Icons.people_outline_rounded,
                size: 14,
                color: AppColors.textDarkMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${challenge.participantsCount} participants',
                style: AppTextStyles.caption(
                    color: AppColors.textDarkMuted),
              ),
              const Spacer(),
              if (!challenge.isJoined)
                GestureDetector(
                  onTap: () =>
                      ref.read(challengeProvider.notifier).joinChallenge(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Je relève 💪',
                      style: AppTextStyles.bodySmall(color: Colors.white)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    'En cours ✓',
                    style:
                        AppTextStyles.bodySmall(color: AppColors.primary)
                            .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          if (challenge.isJoined) ...[
            const SizedBox(height: 10),
            Text(
              challenge.rewardLabel,
              style: AppTextStyles.caption(
                  color: AppColors.chartAmber),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// VICTOIRES DU MOIS (filtrées depuis le feed)
// ─────────────────────────────────────────────────────────────
class _ChallengeVictoriesSection extends ConsumerWidget {
  const _ChallengeVictoriesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityPostsProvider);

    return postsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (posts) {
        final victories = posts
            .where(
              (p) =>
                  p.postType == PostType.victoire &&
                  p.parentId == null,
            )
            .take(10)
            .toList();

        if (victories.isEmpty) {
          return Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  const Text('🏅',
                      style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text(
                    'Sois le premier à partager ta victoire du mois !',
                    style: AppTextStyles.bodyMedium(
                        color: AppColors.textDarkMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Les victoires du mois 🏆',
              style: AppTextStyles.headingSmall(
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 12),
            ...victories.map((p) => _VictoryItem(post: p)),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ITEM VICTOIRE (compact)
// ─────────────────────────────────────────────────────────────
class _VictoryItem extends StatelessWidget {
  final CommunityPost post;
  const _VictoryItem({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.chartAmber.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.authorName,
                  style:
                      AppTextStyles.caption(color: AppColors.chartAmber)
                          .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  post.content,
                  style: AppTextStyles.bodySmall(
                      color: AppColors.textDark),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
