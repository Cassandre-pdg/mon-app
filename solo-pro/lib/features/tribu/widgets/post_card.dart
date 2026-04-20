import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../models/tribu_models.dart';

class PostCard extends StatefulWidget {
  final TribuPost post;
  final VoidCallback? onAuthorTap;
  final bool showComments;

  const PostCard({
    super.key,
    required this.post,
    this.onAuthorTap,
    this.showComments = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeCtrl;
  late Animation<double> _likeScale;
  bool _showAllComments = false;

  @override
  void initState() {
    super.initState();
    _likeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _likeScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _likeCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _likeCtrl.dispose();
    super.dispose();
  }

  void _toggleLike() {
    HapticFeedback.lightImpact();
    setState(() {
      if (widget.post.likedByMe) {
        widget.post.likes--;
        widget.post.likedByMe = false;
      } else {
        widget.post.likes++;
        widget.post.likedByMe = true;
        _likeCtrl.forward(from: 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─ Header auteur
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onAuthorTap,
                  child: _Avatar(member: post.author),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onAuthorTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(post.author.prenom,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                            const SizedBox(width: 6),
                            if (post.author.isOnline)
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.accentGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        Text(post.author.metier,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                // Badge type de post
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _postTypeColor(post.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${post.type.emoji} ${post.type.label}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _postTypeColor(post.type),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─ Contenu
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(post.content,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.5)),
          ),

          // ─ Heure
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Text(timeAgo(post.createdAt),
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textLight)),
          ),

          // ─ Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                // Like
                GestureDetector(
                  onTap: _toggleLike,
                  child: AnimatedBuilder(
                    animation: _likeScale,
                    builder: (_, child) => Transform.scale(
                      scale: _likeScale.value,
                      child: child,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          post.likedByMe
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 20,
                          color: post.likedByMe
                              ? AppColors.accent
                              : AppColors.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.likes}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: post.likedByMe
                                ? AppColors.accent
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Commentaires
                GestureDetector(
                  onTap: () =>
                      setState(() => _showAllComments = !_showAllComments),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline,
                          size: 18, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        '${post.comments.length}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.share_outlined,
                    size: 18, color: AppColors.textLight),
              ],
            ),
          ),

          // ─ Commentaires
          if (_showAllComments && post.comments.isNotEmpty) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            ...post.comments.map((c) => _CommentTile(comment: c)),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  Color _postTypeColor(PostType t) {
    switch (t) {
      case PostType.achievement: return AppColors.accentYellow;
      case PostType.tip: return AppColors.primary;
      case PostType.question: return AppColors.accentGreen;
      case PostType.text: return AppColors.textSecondary;
    }
  }
}

class _CommentTile extends StatelessWidget {
  final TribuComment comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(member: comment.author, size: 28, fontSize: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment.author.prenom,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(comment.content,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textPrimary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final TribuMember member;
  final double size;
  final double fontSize;

  const _Avatar({
    required this.member,
    this.size = 38,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(size * 0.3),
          ),
          child: Center(
            child: Text(member.emoji,
                style: TextStyle(fontSize: fontSize)),
          ),
        ),
        if (member.isOnline)
          Positioned(
            right: 1,
            bottom: 1,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: AppColors.accentGreen,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.surface, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
