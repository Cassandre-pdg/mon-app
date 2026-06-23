import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/navigation/app_router.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../data/weekly_review_model.dart';
import '../providers/weekly_review_provider.dart';

// ── Page historique des revues hebdomadaires ──────────────────────
class ReviewsHistoryScreen extends ConsumerWidget {
  const ReviewsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(reviewHistoryProvider);
    final isPro = ref.watch(isProProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_rounded,
                          color: AppColors.primaryLight, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text('Mes Revues',
                        style: AppTextStyles.headingMedium(
                            color: AppColors.textDark)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: historyAsync.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary)),
                  error: (_, __) => Center(
                      child: Text('Impossible de charger l\'historique',
                          style: AppTextStyles.bodyMedium(
                              color: AppColors.textDark))),
                  data: (reviews) {
                    if (reviews.isEmpty) {
                      return _EmptyState();
                    }
                    // Gratuit : 2 revues max, graphiques bloqués
                    final visibleReviews =
                        isPro ? reviews : reviews.take(2).toList();
                    final lockedCount =
                        isPro ? 0 : (reviews.length - 2).clamp(0, 999);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Graphiques (Pro uniquement) ────────
                          if (isPro) ...[
                            _ChartsSection(reviews: reviews),
                            const SizedBox(height: 24),
                          ] else ...[
                            _ProChartsTeaser(
                                reviewCount: reviews.length),
                            const SizedBox(height: 24),
                          ],

                          // ── Liste des revues ───────────────────
                          Text('Mes revues',
                              style: AppTextStyles.headingSmall(
                                  color: AppColors.textDark)),
                          const SizedBox(height: 12),
                          ...visibleReviews.map((r) =>
                              _ReviewCard(review: r, isDark: isDark)),

                          // ── Bloc de blocage si gratuit ─────────
                          if (!isPro && lockedCount > 0)
                            _LockedHistoryBanner(
                                lockedCount: lockedCount),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// GRAPHIQUES
// ══════════════════════════════════════════════════════════════════
class _ChartsSection extends StatelessWidget {
  const _ChartsSection({required this.reviews});
  final List<WeeklyReview> reviews;

  @override
  Widget build(BuildContext context) {
    // On affiche max 8 semaines dans les graphiques
    final data = reviews.take(8).toList().reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Graphique 1 — Évolution humeur (linéaire)
        if (data.any((r) => r.avgMood != null)) ...[
          Text('Évolution de l\'humeur',
              style: AppTextStyles.labelMedium(color: AppColors.textDarkMuted)),
          const SizedBox(height: 6),
          Row(children: [
            _LegendDot(color: AppColors.primary, label: 'Humeur'),
            const SizedBox(width: 12),
            _LegendDot(color: AppColors.accent, label: 'Énergie'),
          ]),
          const SizedBox(height: 10),
          _MoodEvolutionChart(reviews: data),
          const SizedBox(height: 20),
        ],

        // Graphique 2 — Tâches complétées par semaine (barres)
        Text('Tâches complétées / semaine',
            style: AppTextStyles.labelMedium(color: AppColors.textDarkMuted)),
        const SizedBox(height: 10),
        _TasksEvolutionChart(reviews: data),
        const SizedBox(height: 20),

        // Graphique 3 — Répartition des badges (donut)
        if (reviews.length >= 3) ...[
          Text('Mes semaines en un coup d\'œil',
              style: AppTextStyles.labelMedium(color: AppColors.textDarkMuted)),
          const SizedBox(height: 10),
          _BadgeDonutChart(reviews: reviews),
        ],
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: AppTextStyles.caption(color: AppColors.textDarkMuted)),
    ]);
  }
}

class _MoodEvolutionChart extends StatelessWidget {
  const _MoodEvolutionChart({required this.reviews});
  final List<WeeklyReview> reviews;

  LineChartBarData _line(List<FlSpot> spots, Color color) =>
      LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 2.5,
        dotData: FlDotData(
          show: true,
          getDotPainter: (_, __, ___, ____) =>
              FlDotCirclePainter(radius: 3, color: color, strokeWidth: 0),
        ),
        belowBarData: BarAreaData(
            show: true, color: color.withValues(alpha: 0.08)),
      );

  @override
  Widget build(BuildContext context) {
    final moodSpots = <FlSpot>[];
    final energySpots = <FlSpot>[];
    for (var i = 0; i < reviews.length; i++) {
      if (reviews[i].avgMood != null) {
        moodSpots.add(FlSpot(i.toDouble(), reviews[i].avgMood!));
      }
      if (reviews[i].avgEnergy != null) {
        energySpots.add(FlSpot(i.toDouble(), reviews[i].avgEnergy!));
      }
    }

    return SizedBox(
      height: 140,
      child: LineChart(LineChartData(
        minY: 0, maxY: 10,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withValues(alpha: 0.06), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, interval: 5, reservedSize: 24,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                style: AppTextStyles.caption(color: AppColors.textDarkMuted)),
          )),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, reservedSize: 22,
            getTitlesWidget: (val, _) {
              final idx = val.toInt();
              if (idx < 0 || idx >= reviews.length) return const SizedBox.shrink();
              final w = reviews[idx].weekStart;
              return Text('S${w.month}/${w.day}',
                  style: AppTextStyles.caption(color: AppColors.textDarkMuted)
                      .copyWith(fontSize: 9));
            },
          )),
        ),
        lineBarsData: [
          _line(moodSpots, AppColors.primary),
          if (energySpots.isNotEmpty) _line(energySpots, AppColors.accent),
        ],
      )),
    );
  }
}

class _TasksEvolutionChart extends StatelessWidget {
  const _TasksEvolutionChart({required this.reviews});
  final List<WeeklyReview> reviews;

  @override
  Widget build(BuildContext context) {
    final maxVal = reviews.fold(0, (m, r) => math.max(m, r.tasksTotal)).toDouble();
    if (maxVal == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(child: Text('Pas encore de données',
            style: AppTextStyles.caption(color: AppColors.textDarkMuted))),
      );
    }

    return SizedBox(
      height: 130,
      child: BarChart(BarChartData(
        maxY: maxVal + 1,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, reservedSize: 22,
            getTitlesWidget: (val, _) {
              final idx = val.toInt();
              if (idx < 0 || idx >= reviews.length) return const SizedBox.shrink();
              final w = reviews[idx].weekStart;
              return Text('S${w.month}/${w.day}',
                  style: AppTextStyles.caption(color: AppColors.textDarkMuted)
                      .copyWith(fontSize: 9));
            },
          )),
        ),
        barGroups: List.generate(reviews.length, (i) {
          final r = reviews[i];
          return BarChartGroupData(
            x: i,
            barRods: [
              // Tâches complétées (violet)
              BarChartRodData(
                toY: r.tasksCompleted.toDouble(),
                color: AppColors.primary,
                width: 14,
                borderRadius: BorderRadius.circular(4),
              ),
              // Tâches totales (transparent)
              BarChartRodData(
                toY: r.tasksTotal.toDouble(),
                color: AppColors.primary.withValues(alpha: 0.15),
                width: 14,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
            barsSpace: 2,
          );
        }),
      )),
    );
  }
}

class _BadgeDonutChart extends StatelessWidget {
  const _BadgeDonutChart({required this.reviews});
  final List<WeeklyReview> reviews;

  @override
  Widget build(BuildContext context) {
    final counts = <ReviewBadge, int>{
      ReviewBadge.fire: 0,
      ReviewBadge.solid: 0,
      ReviewBadge.resilient: 0,
      ReviewBadge.gentle: 0,
    };
    for (final r in reviews) {
      if (r.badge != null) counts[r.badge!] = (counts[r.badge!] ?? 0) + 1;
    }
    final total = counts.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    final colors = {
      ReviewBadge.fire:      AppColors.secondary,
      ReviewBadge.solid:     AppColors.primary,
      ReviewBadge.resilient: AppColors.chartAmber,
      ReviewBadge.gentle:    AppColors.accent,
    };

    return Row(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: PieChart(PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 32,
            sections: counts.entries
                .where((e) => e.value > 0)
                .map((e) => PieChartSectionData(
                      value: e.value.toDouble(),
                      color: colors[e.key]!,
                      radius: 28,
                      showTitle: false,
                    ))
                .toList(),
          )),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: counts.entries
                .where((e) => e.value > 0)
                .map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            color: colors[e.key],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${e.key.emoji} ${e.key.label}',
                            style: AppTextStyles.caption(
                                color: AppColors.textDark)),
                        const Spacer(),
                        Text('×${e.value}',
                            style: AppTextStyles.caption(
                                color: AppColors.textDarkMuted)),
                      ]),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// BLOCS PRO
// ══════════════════════════════════════════════════════════════════

// Teaser graphiques floutés avec CTA paywall
class _ProChartsTeaser extends StatelessWidget {
  const _ProChartsTeaser({required this.reviewCount});
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Aperçu flouté — barres factices pour donner envie
        AbsorbPointer(
          child: Opacity(
            opacity: 0.25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Évolution de ton humeur',
                    style: AppTextStyles.labelMedium(
                        color: AppColors.textDarkMuted)),
                const SizedBox(height: 10),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [0.4, 0.6, 0.5, 0.8, 0.7, 0.9, 0.75]
                        .map((h) => Container(
                              width: 20,
                              height: 80 * h,
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Overlay cadenas + CTA
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundDark.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: AppColors.gradientMain),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(height: 12),
                Text(
                  'Graphiques disponibles en Pro',
                  style: AppTextStyles.headingSmall(
                      color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vois ton évolution sur $reviewCount semaine${reviewCount > 1 ? 's' : ''}.',
                  style: AppTextStyles.bodySmall(
                      color: AppColors.textDarkMuted),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.paywall),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: AppColors.gradientMain),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text('Passer à Pro',
                        style: AppTextStyles.labelMedium(
                                color: Colors.white)
                            .copyWith(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Bannière qui bloque les revues au-delà de 2
class _LockedHistoryBanner extends StatelessWidget {
  const _LockedHistoryBanner({required this.lockedCount});
  final int lockedCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.paywall),
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: AppColors.gradientMain),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.lock_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              '+$lockedCount revue${lockedCount > 1 ? 's' : ''} dans ton historique',
              style: AppTextStyles.headingSmall(color: AppColors.textDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Débloque l\'historique complet et les\ngraphiques d\'évolution avec Kolyb Pro.',
              style: AppTextStyles.bodySmall(color: AppColors.textDarkMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(colors: AppColors.gradientMain),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Voir tout mon historique',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMedium(color: Colors.white)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// CARD D'UNE REVUE
// ══════════════════════════════════════════════════════════════════
class _ReviewCard extends StatefulWidget {
  const _ReviewCard({required this.review, required this.isDark});
  final WeeklyReview review;
  final bool isDark;

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _expanded = false;

  String _weekLabel() {
    final s = widget.review.weekStart;
    final e = s.add(const Duration(days: 6));
    return 'Semaine du ${s.day}/${s.month} au ${e.day}/${e.month}';
  }

  String _focusLabel() {
    final h = widget.review.focusMinutes ~/ 60;
    final m = widget.review.focusMinutes % 60;
    if (h == 0) return '${m}min focus';
    if (m == 0) return '${h}h focus';
    return '${h}h${m}min focus';
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.review;
    final badge = r.badge;

    final badgeColor = badge == null ? AppColors.primary : switch (badge) {
      ReviewBadge.fire      => AppColors.secondary,
      ReviewBadge.solid     => AppColors.primary,
      ReviewBadge.resilient => AppColors.chartAmber,
      ReviewBadge.gentle    => AppColors.accent,
    };

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: widget.isDark
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            // ── En-tête ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (badge != null)
                    Text(badge.emoji,
                        style: const TextStyle(fontSize: 22))
                  else
                    const Text('📋',
                        style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_weekLabel(),
                            style: AppTextStyles.labelMedium(
                                color: AppColors.textDark)),
                        if (badge != null) ...[
                          const SizedBox(height: 2),
                          Text(badge.label,
                              style: AppTextStyles.caption(
                                  color: badgeColor)),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppColors.textDarkMuted,
                    size: 20,
                  ),
                ],
              ),
            ),

            // ── Pills stats ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _StatPill(
                    label: '${r.completionRate.toStringAsFixed(0)}% tâches',
                    color: AppColors.accent,
                  ),
                  _StatPill(
                    label: _focusLabel(),
                    color: AppColors.primary,
                  ),
                  if (r.avgMood != null)
                    _StatPill(
                      label: 'Humeur ${r.avgMood!.toStringAsFixed(1)}/10',
                      color: AppColors.secondary,
                    ),
                  _StatPill(
                    label: '${r.checkinsDone} check-ins',
                    color: AppColors.chartAmber,
                  ),
                ],
              ),
            ),

            // ── Détail dépliable ─────────────────────────────────
            if (_expanded) ...[
              const Divider(
                  color: Color(0xFF22204A), height: 1, thickness: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (r.weeklyIntention != null) ...[
                      _DetailRow(
                          emoji: '🎯',
                          label: 'Intention',
                          value: r.weeklyIntention!),
                      const SizedBox(height: 10),
                    ],
                    if (r.bestMoment != null) ...[
                      _DetailRow(
                          emoji: '🌟',
                          label: 'Ce qui a aidé',
                          value: r.bestMoment!),
                      const SizedBox(height: 10),
                    ],
                    if (r.mainBlocker != null) ...[
                      _DetailRow(
                          emoji: '🔍',
                          label: 'Frein identifié',
                          value: r.mainBlocker!),
                      const SizedBox(height: 10),
                    ],
                    if (r.capturesProcessed > 0)
                      _DetailRow(
                          emoji: '💡',
                          label: 'Captures triées',
                          value: '${r.capturesProcessed} idée${r.capturesProcessed > 1 ? 's' : ''} traitée${r.capturesProcessed > 1 ? 's' : ''}'),
                    if (r.weeklyIntention == null &&
                        r.bestMoment == null &&
                        r.mainBlocker == null &&
                        r.capturesProcessed == 0)
                      Text('Revue rapide sans notes.',
                          style: AppTextStyles.bodySmall(
                              color: AppColors.textDarkMuted)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(label,
          style: AppTextStyles.caption(color: color)
              .copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.emoji, required this.label, required this.value});
  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(label,
              style: AppTextStyles.caption(color: AppColors.textDarkMuted)
                  .copyWith(fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(value,
              style: AppTextStyles.bodySmall(color: AppColors.textDark)),
        ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📋', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('Aucune revue pour l\'instant',
              style: AppTextStyles.headingSmall(color: AppColors.textDark)),
          const SizedBox(height: 8),
          Text(
            'Ta première revue apparaîtra ici\naprès le vendredi à 15h.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(color: AppColors.textDarkMuted),
          ),
        ],
      ),
    );
  }
}
