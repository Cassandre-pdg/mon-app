import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/constants/app_strings.dart';
import '../../data/badge_model.dart';
import '../../domain/badge_service.dart';
import '../providers/rewards_provider.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(badgesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.navBadges,
          style: AppTextStyles.headingSmall(
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
      ),
      body: badgesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😕', style: TextStyle(fontSize: 48)),
              const SizedBox(height: AppConstants.spacing16),
              Text(
                AppStrings.errorGeneric,
                style: AppTextStyles.bodyMedium(color: AppColors.grey400),
              ),
              const SizedBox(height: AppConstants.spacing16),
              ElevatedButton(
                onPressed: () => ref.invalidate(badgesProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (badges) {
          final unlocked = BadgeService.unlockedBadges(badges).length;
          final total = badges.length;
          final progress = unlocked / total;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Résumé progression ────────────────────────
                _ProgressHeader(
                  unlocked: unlocked,
                  total: total,
                  progress: progress,
                  isDark: isDark,
                ),
                const SizedBox(height: AppConstants.spacing32),

                // ── Section Streaks ───────────────────────────
                _BadgeSection(
                  title: '🔥 Streaks',
                  subtitle: 'Récompense ta régularité',
                  badges: BadgeService.byCategory(badges, BadgeCategory.streak),
                  isDark: isDark,
                ),
                const SizedBox(height: AppConstants.spacing32),

                // ── Section Niveaux ───────────────────────────
                _BadgeSection(
                  title: '⭐ Niveaux',
                  subtitle: 'Progresse et monte en grade',
                  badges: BadgeService.byCategory(badges, BadgeCategory.level),
                  isDark: isDark,
                ),
                const SizedBox(height: AppConstants.spacing32),

                // ── Section Spéciaux ──────────────────────────
                _BadgeSection(
                  title: '💪 Spéciaux',
                  subtitle: 'Des moments qui comptent',
                  badges: BadgeService.byCategory(badges, BadgeCategory.special),
                  isDark: isDark,
                ),
                const SizedBox(height: AppConstants.spacing32),

                // ── Message bienveillant si pas tout débloqué ─
                if (unlocked < total)
                  Center(
                    child: Text(
                      'Continue à avancer — les badges arrivent à leur rythme 🌱',
                      style: AppTextStyles.bodySmall(color: AppColors.grey400),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: AppConstants.spacing24),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Barre de progression globale ──────────────────────────────
class _ProgressHeader extends StatelessWidget {
  final int unlocked;
  final int total;
  final double progress;
  final bool isDark;

  const _ProgressHeader({
    required this.unlocked,
    required this.total,
    required this.progress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏅', style: TextStyle(fontSize: 32)),
              const SizedBox(width: AppConstants.spacing12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$unlocked badge${unlocked > 1 ? 's' : ''} débloqué${unlocked > 1 ? 's' : ''}',
                    style: AppTextStyles.headingSmall(color: Colors.white)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'sur $total au total',
                    style: AppTextStyles.bodySmall(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(progress * 100).round()}% de ta collection',
            style: AppTextStyles.caption(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

// ── Section de badges ─────────────────────────────────────────
class _BadgeSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<AppBadge> badges;
  final bool isDark;

  const _BadgeSection({
    required this.title,
    required this.subtitle,
    required this.badges,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headingSmall(
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTextStyles.bodySmall(color: AppColors.grey400),
        ),
        const SizedBox(height: AppConstants.spacing16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: AppConstants.spacing12,
            mainAxisSpacing: AppConstants.spacing12,
            childAspectRatio: 0.85,
          ),
          itemCount: badges.length,
          itemBuilder: (context, i) => _BadgeCard(
            badge: badges[i],
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

// ── Carte d'un badge ──────────────────────────────────────────
class _BadgeCard extends StatelessWidget {
  final AppBadge badge;
  final bool isDark;

  const _BadgeCard({required this.badge, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBadgeDetail(context),
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        padding: const EdgeInsets.all(AppConstants.spacing12),
        decoration: BoxDecoration(
          color: badge.isUnlocked
              ? badge.categoryColor.withValues(alpha: 0.08)
              : isDark
                  ? AppColors.surfaceDark
                  : AppColors.grey100,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: badge.isUnlocked
                ? badge.categoryColor.withValues(alpha: 0.35)
                : isDark
                    ? AppColors.grey400.withValues(alpha: 0.1)
                    : AppColors.grey200,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji ou cadenas
            badge.isUnlocked
                ? Text(
                    badge.emoji,
                    style: const TextStyle(fontSize: 32),
                    textAlign: TextAlign.center,
                  )
                : const Text(
                    '🔒',
                    style: TextStyle(fontSize: 28, color: AppColors.grey400),
                    textAlign: TextAlign.center,
                  ),
            const SizedBox(height: AppConstants.spacing8),

            // Nom du badge
            Text(
              badge.isUnlocked ? badge.name : '???',
              style: AppTextStyles.caption(
                color: badge.isUnlocked
                    ? badge.categoryColor
                    : AppColors.grey400,
              ).copyWith(
                fontWeight: badge.isUnlocked
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppConstants.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji
            Text(
              badge.isUnlocked ? badge.emoji : '🔒',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: AppConstants.spacing16),

            // Nom
            Text(
              badge.isUnlocked ? badge.name : 'Badge verrouillé',
              style: AppTextStyles.headingMedium(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing8),

            // Description
            Text(
              badge.isUnlocked
                  ? badge.description
                  : 'Continue à avancer pour débloquer ce badge.',
              style: AppTextStyles.bodyMedium(color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing24),

            // Statut
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: badge.isUnlocked
                    ? AppColors.success.withValues(alpha: 0.12)
                    : AppColors.grey200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge.isUnlocked ? '✅ Débloqué !' : '⏳ En cours...',
                style: AppTextStyles.labelMedium(
                  color: badge.isUnlocked
                      ? AppColors.success
                      : AppColors.grey400,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
          ],
        ),
      ),
    );
  }
}
