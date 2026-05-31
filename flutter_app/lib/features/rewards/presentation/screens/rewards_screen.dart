import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/badge_hex_widget.dart';
import '../../data/badge_model.dart';
import '../../data/badge_preferences_repository.dart';
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
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mes Badges',
          style: AppTextStyles.headingSmall(
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
      ),
      body: badgesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😕', style: TextStyle(fontSize: 48)),
              const SizedBox(height: AppConstants.spacing16),
              Text(
                'Impossible de charger tes badges.',
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
        data: (badges) => _BadgesBody(badges: badges, isDark: isDark),
      ),
    );
  }
}

// ── Corps ─────────────────────────────────────────────────────
class _BadgesBody extends StatelessWidget {
  final List<AppBadge> badges;
  final bool isDark;

  const _BadgesBody({required this.badges, required this.isDark});

  static const _sections = [
    (BadgeCategory.streak,    '🔥 Régularité',  'Ta constance, jour après jour'),
    (BadgeCategory.level,     '⭐ Progression',  'Chaque action te rapproche du prochain palier'),
    (BadgeCategory.flash,     '⚡ Flash',         'Tes micro-victoires s\'accumulent vite'),
    (BadgeCategory.checkin,   '🌅 Check-ins',    'Tu prends soin de toi — et ça compte'),
    (BadgeCategory.project,   '🚀 Projets',      'Tu livres ce que tu commences'),
    (BadgeCategory.community, '💬 Communauté',   'Ta voix enrichit Le Salon'),
    (BadgeCategory.special,   '✨ Spéciaux',      'Des moments uniques qui méritent d\'être célébrés'),
  ];

  @override
  Widget build(BuildContext context) {
    final unlocked = BadgeService.unlockedBadges(badges).length;
    final total    = badges.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProgressHeader(unlocked: unlocked, total: total, isDark: isDark),
          const SizedBox(height: AppConstants.spacing32),

          // Légende des tiers
          _TierLegend(isDark: isDark),
          const SizedBox(height: AppConstants.spacing32),

          for (final s in _sections) ...[
            _BadgeSection(
              category: s.$1,
              title: s.$2,
              subtitle: s.$3,
              badges: BadgeService.byCategory(badges, s.$1),
              isDark: isDark,
            ),
            const SizedBox(height: AppConstants.spacing32),
          ],

          if (unlocked < total)
            Center(
              child: Text(
                'Continue à avancer — chaque badge arrive à son rythme 🌱',
                style: AppTextStyles.bodySmall(
                  color: isDark
                      ? AppColors.textDark.withValues(alpha: 0.38)
                      : AppColors.textLight.withValues(alpha: 0.38),
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

// ── En-tête progression ───────────────────────────────────────
class _ProgressHeader extends StatelessWidget {
  final int unlocked;
  final int total;
  final bool isDark;

  const _ProgressHeader({
    required this.unlocked,
    required this.total,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final progress = unlocked / total;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.38),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          BadgeHexWidget(
            gradientColors: const [Color(0xFFFFB800), Color(0xFFFF4D6A)],
            icon: Icons.workspace_premium_rounded,
            isUnlocked: true,
            isLegendary: unlocked >= 10,
            isRare: unlocked >= 5,
            categoryColor: const Color(0xFFFFB800),
            size: 56,
          ),
          const SizedBox(width: AppConstants.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$unlocked badge${unlocked > 1 ? 's' : ''} débloqué${unlocked > 1 ? 's' : ''}',
                  style: AppTextStyles.headingSmall(color: Colors.white)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'sur $total au total',
                  style: AppTextStyles.bodySmall(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).round()}% de ta collection',
                  style: AppTextStyles.caption(
                    color: Colors.white.withValues(alpha: 0.65),
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

// ── Légende des tiers ─────────────────────────────────────────
class _TierLegend extends StatelessWidget {
  final bool isDark;
  const _TierLegend({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark
        ? AppColors.textDark.withValues(alpha: 0.55)
        : AppColors.textLight.withValues(alpha: 0.55);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TierChip(label: 'Courant',    colors: const [Color(0xFF6D28D9), Color(0xFF8B7FE8)], textColor: textColor),
        const SizedBox(width: 8),
        _TierChip(label: 'Rare',       colors: const [Color(0xFF00D4C8), Color(0xFF6D28D9)], textColor: textColor),
        const SizedBox(width: 8),
        _TierChip(label: 'Légendaire', colors: const [Color(0xFFFFB800), Color(0xFFFF9100)], textColor: textColor),
      ],
    );
  }
}

class _TierChip extends StatelessWidget {
  final String label;
  final List<Color> colors;
  final Color textColor;
  const _TierChip({
    required this.label,
    required this.colors,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: textColor)),
      ],
    );
  }
}

// ── Section catégorie ─────────────────────────────────────────
class _BadgeSection extends StatelessWidget {
  final BadgeCategory category;
  final String title;
  final String subtitle;
  final List<AppBadge> badges;
  final bool isDark;

  const _BadgeSection({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.badges,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) return const SizedBox.shrink();

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
          style: AppTextStyles.bodySmall(
            color: isDark
                ? AppColors.textDark.withValues(alpha: 0.42)
                : AppColors.textLight.withValues(alpha: 0.45),
          ),
        ),
        const SizedBox(height: AppConstants.spacing16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 20,
            childAspectRatio: 0.72,
          ),
          itemCount: badges.length,
          itemBuilder: (context, i) =>
              _BadgeCard(badge: badges[i], isDark: isDark),
        ),
      ],
    );
  }
}

// ── Carte de badge ────────────────────────────────────────────
class _BadgeCard extends ConsumerWidget {
  final AppBadge badge;
  final bool isDark;

  const _BadgeCard({required this.badge, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinnedAsync = ref.watch(pinnedBadgesProvider);
    final isPinned = pinnedAsync.valueOrNull?.contains(badge.id) ?? false;

    return GestureDetector(
      onTap: () => _showDetail(context, ref, isPinned),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BadgeHexWidget(
            gradientColors: badge.gradientColors,
            icon: badge.icon,
            isUnlocked: badge.isUnlocked,
            isLegendary: badge.tier == BadgeTier.legendary,
            isRare: badge.tier == BadgeTier.rare,
            categoryColor: badge.categoryColor,
            progress: !badge.isUnlocked ? badge.progressFraction : null,
          ),
          const SizedBox(height: 6),
          // Nom
          Text(
            badge.isUnlocked ? badge.name : '???',
            style: AppTextStyles.caption(
              color: badge.isUnlocked
                  ? badge.categoryColor
                  : (isDark
                      ? AppColors.textDark.withValues(alpha: 0.28)
                      : AppColors.textLight.withValues(alpha: 0.3)),
            ).copyWith(
              fontWeight:
                  badge.isUnlocked ? FontWeight.w600 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          // Progression texte pour badge verrouillé
          if (!badge.isUnlocked &&
              badge.progressCurrent != null &&
              badge.progressGoal != null)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                '${badge.progressCurrent}/${badge.progressGoal}',
                style: TextStyle(
                  fontSize: 10,
                  color: badge.categoryColor.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          // Pin indicator
          if (badge.isUnlocked && isPinned)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.push_pin_rounded,
                size: 11,
                color: badge.categoryColor.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref, bool isPinned) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _BadgeDetailSheet(
        badge: badge,
        isPinned: isPinned,
        isDark: isDark,
      ),
    );
  }
}

// ── Sheet détail d'un badge ───────────────────────────────────
class _BadgeDetailSheet extends ConsumerWidget {
  final AppBadge badge;
  final bool isPinned;
  final bool isDark;

  const _BadgeDetailSheet({
    required this.badge,
    required this.isPinned,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datesAsync = ref.watch(unlockDatesProvider);
    final pinnedAsync = ref.watch(pinnedBadgesProvider);
    final currentlyPinned =
        pinnedAsync.valueOrNull?.contains(badge.id) ?? isPinned;
    final pinnedCount = pinnedAsync.valueOrNull?.length ?? 0;

    final bgColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppConstants.spacing24),

          // Badge hexagonal grand format
          BadgeHexWidget(
            gradientColors: badge.gradientColors,
            icon: badge.icon,
            isUnlocked: badge.isUnlocked,
            isLegendary: badge.tier == BadgeTier.legendary,
            isRare: badge.tier == BadgeTier.rare,
            categoryColor: badge.categoryColor,
            size: 88,
          ),
          const SizedBox(height: AppConstants.spacing16),

          // Nom
          Text(
            badge.isUnlocked ? badge.name : 'Badge verrouillé',
            style: AppTextStyles.headingMedium(
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Description ou hint
          Text(
            badge.isUnlocked ? badge.description : badge.hint,
            style: AppTextStyles.bodyMedium(
              color: isDark
                  ? AppColors.textDark.withValues(alpha: 0.55)
                  : AppColors.textLight.withValues(alpha: 0.55),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing16),

          // Pills : catégorie + tier + statut
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              _Pill(
                label: badge.categoryLabel,
                color: badge.categoryColor,
              ),
              _Pill(
                label: badge.tierLabel,
                color: badge.tier == BadgeTier.legendary
                    ? AppColors.chartAmber
                    : badge.tier == BadgeTier.rare
                        ? AppColors.primaryLight
                        : AppColors.grey400,
              ),
              if (badge.isUnlocked)
                _Pill(label: '✅ Débloqué', color: AppColors.success),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),

          // Date de déverrouillage
          if (badge.isUnlocked)
            datesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (dates) {
                final date = dates[badge.id];
                if (date == null) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: isDark
                            ? AppColors.textDark.withValues(alpha: 0.45)
                            : AppColors.textLight.withValues(alpha: 0.45),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Débloqué le ${BadgePreferencesRepository.formatDate(date)}',
                        style: AppTextStyles.caption(
                          color: isDark
                              ? AppColors.textDark.withValues(alpha: 0.45)
                              : AppColors.textLight.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          // Barre de progression pour badge verrouillé
          if (!badge.isUnlocked &&
              badge.progressCurrent != null &&
              badge.progressGoal != null) ...[
            const SizedBox(height: AppConstants.spacing16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ta progression',
                      style: AppTextStyles.labelMedium(
                        color: isDark
                            ? AppColors.textDark.withValues(alpha: 0.55)
                            : AppColors.textLight.withValues(alpha: 0.55),
                      ),
                    ),
                    Text(
                      '${badge.progressCurrent} / ${badge.progressGoal} ${badge.progressUnit ?? ''}',
                      style: AppTextStyles.labelMedium(
                        color: badge.categoryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: badge.progressFraction ?? 0,
                    minHeight: 6,
                    backgroundColor: badge.categoryColor.withValues(alpha: 0.12),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(badge.categoryColor),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: AppConstants.spacing24),

          // Bouton épingler/désépingler (badges débloqués uniquement)
          if (badge.isUnlocked)
            _PinButton(
              badgeId: badge.id,
              isPinned: currentlyPinned,
              pinnedCount: pinnedCount,
              categoryColor: badge.categoryColor,
              onToggle: () async {
                final notifier =
                    ref.read(pinnedBadgesProvider.notifier);
                await notifier.togglePin(badge.id);
                if (context.mounted) Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}

// ── Bouton épingler ───────────────────────────────────────────
class _PinButton extends StatelessWidget {
  final String badgeId;
  final bool isPinned;
  final int pinnedCount;
  final Color categoryColor;
  final VoidCallback onToggle;

  const _PinButton({
    required this.badgeId,
    required this.isPinned,
    required this.pinnedCount,
    required this.categoryColor,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final canPin = isPinned || pinnedCount < BadgePreferencesRepository.maxPinned;

    if (!canPin) {
      return Text(
        '3 trophées déjà épinglés sur ton profil',
        style: AppTextStyles.bodySmall(color: AppColors.grey400),
        textAlign: TextAlign.center,
      );
    }

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isPinned
              ? null
              : LinearGradient(
                  colors: [
                    categoryColor,
                    categoryColor.withValues(alpha: 0.75),
                  ],
                ),
          color: isPinned
              ? categoryColor.withValues(alpha: 0.10)
              : null,
          borderRadius: BorderRadius.circular(AppConstants.radiusPill),
          border: isPinned
              ? Border.all(color: categoryColor.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
              size: 16,
              color: isPinned ? categoryColor : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              isPinned
                  ? 'Retirer de mes trophées'
                  : 'Épingler sur mon profil',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isPinned ? categoryColor : Colors.white,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pill générique ────────────────────────────────────────────
class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(color: color).copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
