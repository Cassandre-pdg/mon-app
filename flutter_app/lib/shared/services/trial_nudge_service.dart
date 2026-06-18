import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:logger/logger.dart';

import '../../features/subscription/presentation/providers/subscription_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';

final _log = Logger();

/// Vérifie au jour 5 du trial si le nudge d'avis doit s'afficher.
/// À appeler depuis le dashboard au chargement (une seule fois par session via provider).
final trialNudgeProvider = FutureProvider.autoDispose<void>((ref) async {
  final subAsync = ref.watch(subscriptionStatusProvider);
  final status = subAsync.valueOrNull;

  // Condition : en trial RevenueCat, jour 5 ou plus, pas déjà affiché
  if (status == null || !status.isTrialing) return;
  final daysElapsed = status.trialDaysElapsed ?? 0;
  if (daysElapsed < 5) return;

  final repo = ref.read(subscriptionRepositoryProvider);
  final alreadyShown = await repo.isNudgeAlreadyShown();
  if (alreadyShown) return;

  // Marque immédiatement pour éviter un double affichage
  await repo.markNudgeShown();

  // Accorde l'extension de 7 jours (on ne peut pas vérifier si l'utilisateur note vraiment)
  await repo.grantTrialExtension();

  // Recharge le statut pour que isProProvider reflète l'extension
  ref.read(subscriptionStatusProvider.notifier).refresh();

  _log.i('[TrialNudge] affichage du nudge avis — extension accordée');
});

/// Affiche une bottom sheet d'information avant le popup natif iOS.
/// À appeler depuis le dashboard quand trialNudgeProvider vient de compléter
/// et que les conditions étaient remplies.
Future<void> showTrialNudgeSheet(BuildContext context) async {
  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _TrialNudgeSheet(),
  );
}

class _TrialNudgeSheet extends StatelessWidget {
  const _TrialNudgeSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark ? AppColors.glassBorder : AppColors.grey200,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barre de drag visuelle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.grey400.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const Text('🎁', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),

          Text(
            'Une semaine de plus, pour toi',
            style: AppTextStyles.headingMedium().copyWith(
              color: isDark ? AppColors.textDark : AppColors.textLight,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Text(
            'Tu utilises Kolyb Pro depuis 5 jours. Si l\'app t\'aide à avancer, un petit avis te vaudra 7 jours supplémentaires offerts.',
            style: AppTextStyles.bodyMedium().copyWith(
              color: isDark ? AppColors.textDarkMuted : AppColors.grey400,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('✅', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Text(
                  '7 jours Pro offerts, sans engagement',
                  style: AppTextStyles.bodySmall().copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // CTA principal : ouvre le popup natif iOS
          GestureDetector(
            onTap: () async {
              Navigator.of(context).pop();
              // Délai pour laisser la sheet se fermer avant le popup natif
              await Future.delayed(const Duration(milliseconds: 300));
              final review = InAppReview.instance;
              if (await review.isAvailable()) {
                await review.requestReview();
              }
            },
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '⭐  Laisser un avis et gagner 7 jours',
                  style: AppTextStyles.labelMedium().copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Plus tard',
              style: AppTextStyles.bodySmall().copyWith(
                color: isDark ? AppColors.textDarkMuted : AppColors.grey400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
