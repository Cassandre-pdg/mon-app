import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/share_service.dart';

// ── Carte "partager l'app Kolyb" — affiché en bas du profil ──
class ShareCard extends StatelessWidget {
  const ShareCard({super.key});

  // Retourne le Rect du widget pour positionner le popover iOS
  Rect? _getShareRect(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final offset = box.localToGlobal(Offset.zero);
    return offset & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final shareButtonKey = GlobalKey();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1836), Color(0xFF22204A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'kolyb',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const Spacer(),
              const Text('🚀', style: TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Partage Kolyb avec tes amis indépendants',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Aide d\'autres indépendants à avancer à leur rythme.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textDarkMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              key: shareButtonKey,
              onPressed: () async {
                await ShareService.shareText(
                  'Je te recommande Kolyb, l\'app pour avancer au quotidien en tant qu\'indépendant. Télécharge-la sur kolyb.app 🚀',
                  sharePositionOrigin: _getShareRect(shareButtonKey),
                );
              },
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text('Partager avec un ami'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
