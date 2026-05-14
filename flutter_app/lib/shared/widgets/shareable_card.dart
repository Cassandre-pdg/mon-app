import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';
import '../services/share_service.dart';

enum ShareCardType { checkin, focus, weekly }

// ── Carte visuelle partageable (post-session ou bilan) ────────
class ShareableCard extends StatelessWidget {
  final ShareCardType type;
  final String emoji;
  final String title;
  final String stat;
  final String message;
  final int streakDays;

  const ShareableCard({
    super.key,
    required this.type,
    required this.emoji,
    required this.title,
    required this.stat,
    required this.message,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D0B1E), Color(0xFF1A1836)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Kolyb
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              'kolyb',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryLight,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Emoji + titre
          Text(emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textDarkMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          // Stat principale
          Text(
            stat,
            style: GoogleFonts.inter(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 20),

          // Message encadré
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.spacing16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.20),
              ),
            ),
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryLight,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Streak pill
          if (streakDays > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(
                    '$streakDays jour${streakDays > 1 ? 's' : ''} de suite',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Footer watermark
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'kolyb.app',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey400,
                ),
              ),
              Text(
                'Ton élan, au quotidien.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Bottom sheet de partage post-session ──────────────────────
class ShareSessionSheet extends StatelessWidget {
  final ShareableCard card;
  final String shareText;

  const ShareSessionSheet({
    super.key,
    required this.card,
    required this.shareText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey400.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Partage ta progression 🎉',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Inspire d\'autres indépendants autour de toi',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.grey400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Aperçu de la carte
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: card,
          ),
          const SizedBox(height: 24),

          // Bouton partager
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await ShareService.shareText(shareText ?? 'Mon élan du jour avec Kolyb : kolyb.app');
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.share_rounded),
              label: const Text('Partager cette carte'),
            ),
          ),
          const SizedBox(height: 12),

          // Bouton ignorer
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Pas maintenant',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.grey400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper pour ouvrir ce sheet depuis n'importe quel écran
  static void show(BuildContext context, ShareableCard card, String shareText) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ShareSessionSheet(card: card, shareText: shareText),
    );
  }
}
