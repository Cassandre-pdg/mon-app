import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';
import '../../features/subscription/presentation/providers/subscription_provider.dart';

/// Widget cadenas Pro — enveloppe n'importe quel contenu.
///
/// Usage simple :
///   ProGate(child: MonWidget())
///
/// Usage avec overlay personnalisé :
///   ProGate(
///     title: 'Titre custom',
///     subtitle: 'Sous-titre custom',
///     child: MonWidget(),
///   )
class ProGate extends ConsumerWidget {
  final Widget child;
  final String title;
  final String subtitle;
  final String emoji;

  const ProGate({
    super.key,
    required this.child,
    this.title = 'Fonctionnalité Pro',
    this.subtitle = 'Accède à cette fonctionnalité en passant à Kolyb Pro.',
    this.emoji = '✨',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(isProProvider);

    // Si Pro → contenu normal
    if (isPro) return child;

    // Sinon → overlay cadenas
    return Stack(
      children: [
        // Contenu flouté en arrière-plan (aperçu)
        IgnorePointer(
          child: Opacity(opacity: 0.25, child: child),
        ),
        // Overlay cadenas
        Positioned.fill(
          child: _ProOverlay(
            title: title,
            subtitle: subtitle,
            emoji: emoji,
          ),
        ),
      ],
    );
  }
}

/// Overlay affiché par-dessus le contenu verrouillé
class _ProOverlay extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;

  const _ProOverlay({
    required this.title,
    required this.subtitle,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDark.withValues(alpha: 0.85)
            : AppColors.backgroundLight.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône cadenas avec halo violet
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B1FA3), Color(0xFF6D28D9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 30)),
                ),
              ),

              const SizedBox(height: AppConstants.spacing16),

              // Badge "Kolyb Pro"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6D28D9), Color(0xFF8B7FE8)],
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                ),
                child: Text(
                  'KOLYB PRO',
                  style: AppTextStyles.caption(color: Colors.white).copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.spacing12),

              Text(
                title,
                style: AppTextStyles.headingSmall(
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppConstants.spacing8),

              Text(
                subtitle,
                style: AppTextStyles.bodyMedium(color: AppColors.grey400),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppConstants.spacing24),

              // CTA
              GestureDetector(
                onTap: () => context.push('/paywall'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacing32,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6D28D9), Color(0xFF8B7FE8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Découvrir Kolyb Pro',
                        style: AppTextStyles.bodyLarge(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.spacing12),

              Text(
                '9,99 €/mois · Annulable à tout moment',
                style: AppTextStyles.caption(color: AppColors.grey400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Petit badge cadenas inline (pour les cards, listes...)
/// Usage : ProBadge() à côté d'un titre
class ProBadge extends StatelessWidget {
  const ProBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6D28D9), Color(0xFF8B7FE8)],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium_rounded,
              color: Colors.white, size: 10),
          const SizedBox(width: 3),
          Text(
            'Pro',
            style: AppTextStyles.caption(color: Colors.white).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
