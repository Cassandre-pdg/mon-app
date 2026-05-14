import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';

// Règles de la charte (emoji, titre, description)
const _charterRules = [
  (
    emoji: '🤝',
    title: 'Bienveillance avant tout',
    desc:  'Critique les idées, jamais les personnes. On est ici pour avancer ensemble.',
  ),
  (
    emoji: '🚫',
    title: 'Pas de publicité',
    desc:  'Le Salon n\'est pas un espace de vente ni d\'autopromotion. Partage de l\'expérience réelle.',
  ),
  (
    emoji: '💬',
    title: 'Des conversations vraies',
    desc:  'Partage ce que tu vis vraiment, pas une image parfaite. La vulnérabilité est une force.',
  ),
  (
    emoji: '🙌',
    title: 'Aide si tu peux',
    desc:  'Si quelqu\'un pose une question dans ton domaine, prends 2 minutes. Ce que tu donnes revient.',
  ),
  (
    emoji: '🔒',
    title: 'Ce qui se dit ici reste ici',
    desc:  'Ne reproduis pas les échanges du Salon sans accord. La confiance est notre bien commun.',
  ),
];

/// Affiche la charte du Salon en modal plein écran.
/// Retourne true quand l'utilisateur accepte.
Future<void> showSalonCharterModal(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Charte',
    barrierColor: Colors.black.withValues(alpha: 0.75),
    transitionDuration: const Duration(milliseconds: 420),
    transitionBuilder: (ctx, anim, _, child) {
      final curve = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(curve),
          child: child,
        ),
      );
    },
    pageBuilder: (ctx, _, __) => const _CharterPage(),
  );
}

class _CharterPage extends StatelessWidget {
  const _CharterPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fond dégradé sombre
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D0B1E),
                  Color(0xFF130F2E),
                  Color(0xFF0D0B1E),
                ],
              ),
            ),
          ),

          // Orbes aurora discrets
          Positioned(
            top: -80,
            right: -60,
            child: _Orb(
              size: 280,
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -40,
            child: _Orb(
              size: 220,
              color: AppColors.accent.withValues(alpha: 0.12),
            ),
          ),

          // Contenu
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                    child: Column(
                      children: [
                        // Icône centrale
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: AppColors.gradientMain,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.40),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('👥', style: TextStyle(fontSize: 32)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Titre gradient
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: AppColors.gradientMain,
                          ).createShader(bounds),
                          blendMode: BlendMode.srcIn,
                          child: Text(
                            'La Charte du Salon',
                            style: AppTextStyles.displayLarge(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          'Un espace pour avancer ensemble, à ton rythme.',
                          style: AppTextStyles.bodyMedium(
                            color: Colors.white.withValues(alpha: 0.50),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 36),

                        // Règles
                        ..._charterRules.map(
                          (rule) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _RuleCard(rule: rule),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Note de bas de page
                        Text(
                          'En rejoignant Le Salon, tu acceptes de contribuer à un espace respectueux et sincère.',
                          style: AppTextStyles.caption(
                            color: Colors.white.withValues(alpha: 0.30),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // CTA ancré en bas
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: _AcceptButton(
                    onTap: () => Navigator.of(context).pop(),
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

// ── Carte d'une règle ─────────────────────────────────────────
class _RuleCard extends StatelessWidget {
  const _RuleCard({required this.rule});

  final ({String emoji, String title, String desc}) rule;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.60),
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji dans un cercle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.20),
                  ),
                ),
                child: Center(
                  child: Text(
                    rule.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Titre + description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.title,
                      style: AppTextStyles.headingSmall(
                        color: Colors.white.withValues(alpha: 0.90),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rule.desc,
                      style: AppTextStyles.bodySmall(
                        color: Colors.white.withValues(alpha: 0.48),
                      ),
                    ),
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

// ── Bouton d'acceptation ──────────────────────────────────────
class _AcceptButton extends StatelessWidget {
  const _AcceptButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        constraints: const BoxConstraints(maxWidth: AppConstants.buttonMaxWidth),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusPill),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.45),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "J'accepte la charte",
            style: AppTextStyles.headingSmall(color: Colors.white)
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

// ── Orbe flou décoratif ───────────────────────────────────────
class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: const SizedBox.shrink(),
      ),
    );
  }
}
