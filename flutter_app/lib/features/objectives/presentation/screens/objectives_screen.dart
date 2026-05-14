import 'dart:math' as math;
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/navigation/app_router.dart';
import '../../../../shared/widgets/aurora_background.dart';
import '../../../../shared/widgets/kolyb_loader.dart';
import '../../data/objective_model.dart';
import '../../data/habit_model.dart';
import '../providers/objectives_provider.dart';
import '../providers/habits_provider.dart';
import '../../../planner/presentation/providers/kanban_provider.dart';

class ObjectivesScreen extends ConsumerWidget {
  const ObjectivesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: AuroraBackgroundPaint(
        orb1Color: AppColors.auroraViolet,
        orb2Color: const Color(0x3300D4C8),
        orb3Color: const Color(0x26FFB800),
        baseColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Pull-to-refresh
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  ref.invalidate(objectivesProvider);
                  ref.invalidate(habitsProvider);
                  await Future.delayed(const Duration(milliseconds: 400));
                },
                builder: (context, mode, pulledExtent, triggerDist, _) {
                  final progress =
                      (pulledExtent / triggerDist).clamp(0.0, 1.0);
                  return Opacity(
                    opacity: progress,
                    child: Center(
                      child: Transform.scale(
                        scale: 0.6 + 0.4 * progress,
                        child: const Icon(Icons.my_location_rounded,
                            color: AppColors.primary, size: 26),
                      ),
                    ),
                  );
                },
              ),

              // En-tête
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: _Header(isDark: isDark),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // Contenu
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ObjectivesContent(isDark: isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── En-tête avec stats dynamiques ────────────────────────────
class _Header extends ConsumerWidget {
  const _Header({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(objectivesCountProvider);
    final habitSummary = ref.watch(habitsTodaySummaryProvider);
    final totalObjectives =
        counts.values.fold(0, (sum, c) => sum + c);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mes Objectifs',
          style: AppTextStyles.displayLarge(
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _todayLabel(),
          style: AppTextStyles.bodySmall(color: AppColors.grey400)
              .copyWith(letterSpacing: 0.1),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatPill(
              icon: Icons.my_location_rounded,
              label: '$totalObjectives objectif${totalObjectives > 1 ? 's' : ''}',
              color: AppColors.primary,
            ),
            _StatPill(
              icon: Icons.loop_rounded,
              label:
                  '${habitSummary.done}/${habitSummary.total} habitude${habitSummary.total > 1 ? 's' : ''}',
              color: AppColors.accent,
            ),
          ],
        ),
      ],
    );
  }

  String _todayLabel() {
    try {
      return DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now());
    } catch (_) {
      return DateFormat('EEEE d MMMM').format(DateTime.now());
    }
  }
}

// ── Contenu principal ─────────────────────────────────────────
class _ObjectivesContent extends ConsumerWidget {
  const _ObjectivesContent({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final objectivesAsync = ref.watch(objectivesProvider);
    final habitsAsync = ref.watch(habitsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 0. Graphique momentum ──────────────────────────────
        habitsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (habits) => _MomentumLineChart(habits: habits, isDark: isDark),
        ),

        const SizedBox(height: 24),

        // ── 1. Objectifs ──────────────────────────────────────
        _SectionLabel('Mes Objectifs', isDark: isDark),
        const SizedBox(height: 12),

        objectivesAsync.when(
          loading: () => const _LoadingCard(),
          error: (e, _) => _ErrorCard(
            onRetry: () => ref.invalidate(objectivesProvider),
          ),
          data: (_) => _ObjectivesHorizonGrid(isDark: isDark),
        ),

        const SizedBox(height: 28),

        // ── 1b. Graphique streaks habitudes ──────────────────
        habitsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (habits) => habits.isEmpty
              ? const SizedBox.shrink()
              : _HabitStreakChart(habits: habits, isDark: isDark),
        ),

        const SizedBox(height: 28),

        // ── 2. Fiches Projet ──────────────────────────────────
        _SectionLabel('Mes Projets', isDark: isDark),
        const SizedBox(height: 12),
        _ProjectHubCard(
          isDark: isDark,
          onTap: () => context.go(AppRoutes.planner),
        ),

        const SizedBox(height: 28),

        // ── 3. Habitudes ──────────────────────────────────────
        _SectionLabel('Mes Habitudes', isDark: isDark),
        const SizedBox(height: 12),

        habitsAsync.when(
          loading: () => const _LoadingCard(),
          error: (e, _) => _ErrorCard(
            onRetry: () => ref.invalidate(habitsProvider),
          ),
          data: (habits) => habits.isEmpty
              ? _HabitsEmptyCard(isDark: isDark)
              : _HabitsList(habits: habits, isDark: isDark),
        ),

        // Bouton ajout habitude (toujours visible)
        const SizedBox(height: 12),
        _AddHabitButton(isDark: isDark),

        const SizedBox(height: 40),
      ],
    );
  }
}

// ── Grille objectifs 3 horizons ───────────────────────────────
class _ObjectivesHorizonGrid extends ConsumerWidget {
  const _ObjectivesHorizonGrid({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(objectivesCountProvider);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _HorizonCard(
                horizon: ObjectiveHorizon.shortTerm,
                count: counts[ObjectiveHorizon.shortTerm] ?? 0,
                isDark: isDark,
                onTap: () => _showObjectivesForHorizon(
                    context, ref, ObjectiveHorizon.shortTerm),
                onAdd: () => _showAddObjectiveSheet(
                    context, ref, ObjectiveHorizon.shortTerm),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _HorizonCard(
                horizon: ObjectiveHorizon.mediumTerm,
                count: counts[ObjectiveHorizon.mediumTerm] ?? 0,
                isDark: isDark,
                onTap: () => _showObjectivesForHorizon(
                    context, ref, ObjectiveHorizon.mediumTerm),
                onAdd: () => _showAddObjectiveSheet(
                    context, ref, ObjectiveHorizon.mediumTerm),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _HorizonCardWide(
          horizon: ObjectiveHorizon.longTerm,
          count: counts[ObjectiveHorizon.longTerm] ?? 0,
          isDark: isDark,
          onTap: () => _showObjectivesForHorizon(
              context, ref, ObjectiveHorizon.longTerm),
          onAdd: () => _showAddObjectiveSheet(
              context, ref, ObjectiveHorizon.longTerm),
        ),
      ],
    );
  }

  void _showObjectivesForHorizon(
    BuildContext context,
    WidgetRef ref,
    ObjectiveHorizon horizon,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ObjectivesListSheet(horizon: horizon),
    );
  }

  void _showAddObjectiveSheet(
    BuildContext context,
    WidgetRef ref,
    ObjectiveHorizon horizon,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddObjectiveSheet(horizon: horizon),
    );
  }
}

// ── Card horizon (demi-largeur) ───────────────────────────────
class _HorizonCard extends StatefulWidget {
  const _HorizonCard({
    required this.horizon,
    required this.count,
    required this.isDark,
    required this.onTap,
    required this.onAdd,
  });
  final ObjectiveHorizon horizon;
  final int count;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  State<_HorizonCard> createState() => _HorizonCardState();
}

class _HorizonCardState extends State<_HorizonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _color {
    switch (widget.horizon) {
      case ObjectiveHorizon.shortTerm:  return AppColors.accent;
      case ObjectiveHorizon.mediumTerm: return AppColors.primary;
      case ObjectiveHorizon.longTerm:   return AppColors.chartAmber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: 148,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? AppColors.surfaceDark.withValues(alpha: 0.80)
                    : AppColors.surfaceLight.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                border: Border.all(
                  color: _color.withValues(alpha: 0.28),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(widget.horizon.emoji,
                              style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onAdd,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('+',
                              style: AppTextStyles.headingSmall(
                                  color: _color)),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Compteur
                  if (widget.count > 0) ...[
                    Text(
                      '${widget.count}',
                      style: AppTextStyles.headingLarge(color: _color),
                    ),
                    const SizedBox(height: 1),
                  ],
                  Text(
                    widget.horizon.label,
                    style: AppTextStyles.headingSmall(
                      color: widget.isDark
                          ? AppColors.textDark
                          : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.horizon.detail,
                    style:
                        AppTextStyles.caption(color: AppColors.grey400),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Card horizon wide (Long terme) ────────────────────────────
class _HorizonCardWide extends StatefulWidget {
  const _HorizonCardWide({
    required this.horizon,
    required this.count,
    required this.isDark,
    required this.onTap,
    required this.onAdd,
  });
  final ObjectiveHorizon horizon;
  final int count;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  State<_HorizonCardWide> createState() => _HorizonCardWideState();
}

class _HorizonCardWideState extends State<_HorizonCardWide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const color = AppColors.chartAmber;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? AppColors.surfaceDark.withValues(alpha: 0.80)
                    : AppColors.surfaceLight.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                border: Border.all(
                  color: color.withValues(alpha: 0.28),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(widget.horizon.emoji,
                          style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.horizon.label,
                              style: AppTextStyles.headingSmall(
                                color: widget.isDark
                                    ? AppColors.textDark
                                    : AppColors.textLight,
                              ),
                            ),
                            if (widget.count > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('${widget.count}',
                                    style: AppTextStyles.caption(
                                        color: color)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.horizon.detail,
                          style: AppTextStyles.caption(
                              color: AppColors.grey400),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onAdd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: color.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        '+ Ajouter',
                        style:
                            AppTextStyles.labelSmall(color: color),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hub projets avec stats dynamiques ────────────────────────
class _ProjectHubCard extends ConsumerStatefulWidget {
  const _ProjectHubCard({required this.isDark, required this.onTap});
  final bool isDark;
  final VoidCallback onTap;

  @override
  ConsumerState<_ProjectHubCard> createState() => _ProjectHubCardState();
}

class _ProjectHubCardState extends ConsumerState<_ProjectHubCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _pressScale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(kanbanStatsProvider);
    final projects = ref.watch(activeProjectsProvider);
    final displayProjects = projects.take(3).toList();

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _pressScale,
        builder: (_, child) =>
            Transform.scale(scale: _pressScale.value, child: child),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: widget.isDark
                    ? AppColors.surfaceDark.withValues(alpha: 0.80)
                    : AppColors.surfaceLight.withValues(alpha: 0.90),
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusLarge),
                border: Border.all(
                  color: widget.isDark
                      ? AppColors.glassBorder
                      : AppColors.grey200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header gradient ────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.chartViolet.withValues(alpha: 0.80),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppConstants.radiusLarge),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('📋',
                            style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mes Projets',
                                style: AppTextStyles.headingSmall(
                                    color: Colors.white),
                              ),
                              Text(
                                '${stats.projects} projet${stats.projects > 1 ? 's' : ''} actif${stats.projects > 1 ? 's' : ''}',
                                style: AppTextStyles.caption(
                                  color: Colors.white
                                      .withValues(alpha: 0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Voir tout',
                                style: AppTextStyles.caption(
                                    color: Colors.white),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 10,
                                  color: Colors.white),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Stats rapides ──────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(18, 14, 18, 0),
                    child: Row(
                      children: [
                        _MiniStat(
                          value: '${stats.todo}',
                          label: 'À faire',
                          color: AppColors.grey400,
                          isDark: widget.isDark,
                        ),
                        const SizedBox(width: 12),
                        _MiniStat(
                          value: '${stats.inProgress}',
                          label: 'En cours',
                          color: AppColors.chartAmber,
                          isDark: widget.isDark,
                          highlight: stats.inProgress > 0,
                        ),
                        const SizedBox(width: 12),
                        _MiniStat(
                          value: '${projects.fold(0, (s, p) => s + p.doneCount)}',
                          label: 'Terminées',
                          color: AppColors.success,
                          isDark: widget.isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Liste projets ──────────────────────────
                  if (displayProjects.isEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(18, 0, 18, 16),
                      child: Text(
                        'Lance ton premier projet →',
                        style: AppTextStyles.bodySmall(
                            color: AppColors.grey400),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                      child: Column(
                        children: [
                          for (int i = 0;
                              i < displayProjects.length;
                              i++) ...[
                            _ProjectRow(
                              project: displayProjects[i],
                              isDark: widget.isDark,
                            ),
                            if (i < displayProjects.length - 1)
                              const SizedBox(height: 10),
                          ],
                          if (projects.length > 3) ...[
                            const SizedBox(height: 10),
                            Text(
                              '+ ${projects.length - 3} autre${projects.length - 3 > 1 ? 's' : ''} projet${projects.length - 3 > 1 ? 's' : ''}',
                              style: AppTextStyles.caption(
                                  color: AppColors.primaryPale),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
    this.highlight = false,
  });
  final String value;
  final String label;
  final Color color;
  final bool isDark;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlight
            ? color.withValues(alpha: 0.12)
            : (isDark
                ? AppColors.surfaceElevatedDark.withValues(alpha: 0.5)
                : AppColors.grey200.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
        border: highlight
            ? Border.all(color: color.withValues(alpha: 0.30))
            : null,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headingSmall(
              color: highlight
                  ? color
                  : (isDark ? AppColors.textDark : AppColors.textLight),
            ).copyWith(fontSize: 18),
          ),
          Text(
            label,
            style: AppTextStyles.caption(color: AppColors.grey400),
          ),
        ],
      ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  const _ProjectRow({required this.project, required this.isDark});
  final dynamic project;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final progress = (project.progressPercent as double).clamp(0.0, 1.0);
    final totalTasks = (project.todoCount as int) +
        (project.inProgressCount as int) +
        (project.doneCount as int);

    Color progressColor;
    if (progress >= 1.0) {
      progressColor = AppColors.success;
    } else if (project.inProgressCount > 0) {
      progressColor = AppColors.chartAmber;
    } else {
      progressColor = AppColors.primary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                project.name as String,
                style: AppTextStyles.labelMedium(
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              totalTasks == 0
                  ? '—'
                  : '${project.doneCount}/$totalTasks',
              style: AppTextStyles.caption(
                color: progress >= 1.0
                    ? AppColors.success
                    : AppColors.grey400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: totalTasks == 0 ? 0 : progress,
            backgroundColor: progressColor.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(progressColor),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

// ── Liste habitudes ───────────────────────────────────────────
class _HabitsList extends ConsumerWidget {
  const _HabitsList({required this.habits, required this.isDark});
  final List<Habit> habits;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = habits.where((h) => h.isDueToday()).toList();
    final other = habits.where((h) => !h.isDueToday()).toList();

    return Column(
      children: [
        if (today.isNotEmpty) ...[
          ...today.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _HabitCard(habit: h, isDark: isDark),
              )),
        ],
        if (other.isNotEmpty) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Pas prévues aujourd\'hui',
              style: AppTextStyles.caption(color: AppColors.grey400),
            ),
          ),
          ...other.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _HabitCard(habit: h, isDark: isDark, muted: true),
              )),
        ],
      ],
    );
  }
}

// ── Card habitude ─────────────────────────────────────────────
class _HabitCard extends ConsumerWidget {
  const _HabitCard({
    required this.habit,
    required this.isDark,
    this.muted = false,
  });
  final Habit habit;
  final bool isDark;
  final bool muted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = habit.isCompletedToday;

    return GestureDetector(
      onTap: muted ? null : () => ref.read(habitsProvider.notifier).toggle(habit.id),
      child: AnimatedContainer(
        duration: AppConstants.animNormal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: done
              ? AppColors.accent.withValues(alpha: 0.10)
              : isDark
                  ? AppColors.surfaceDark.withValues(alpha: muted ? 0.50 : 0.80)
                  : AppColors.surfaceLight.withValues(alpha: muted ? 0.55 : 0.90),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: done
                ? AppColors.accent.withValues(alpha: 0.35)
                : isDark
                    ? AppColors.glassBorder.withValues(alpha: muted ? 0.3 : 1.0)
                    : AppColors.grey200,
            width: done ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Emoji + titre
            Text(habit.emoji,
                style: TextStyle(
                    fontSize: 22,
                    color: muted ? null : null)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: AppTextStyles.bodyMedium(
                      color: done
                          ? AppColors.accent
                          : isDark
                              ? AppColors.textDark.withValues(
                                  alpha: muted ? 0.5 : 1.0)
                              : AppColors.textLight.withValues(
                                  alpha: muted ? 0.5 : 1.0),
                    ).copyWith(
                      decoration:
                          done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        habit.frequency.label,
                        style:
                            AppTextStyles.caption(color: AppColors.grey400),
                      ),
                      if (habit.currentStreak > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '🔥 ${habit.currentStreak}j',
                          style: AppTextStyles.caption(
                              color: AppColors.chartAmber),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Checkbox
            if (!muted)
              AnimatedContainer(
                duration: AppConstants.animNormal,
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: done
                      ? AppColors.accent
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: done
                        ? AppColors.accent
                        : AppColors.grey400,
                    width: 2,
                  ),
                ),
                child: done
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 16)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state habitudes ─────────────────────────────────────
class _HabitsEmptyCard extends StatelessWidget {
  const _HabitsEmptyCard({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDark.withValues(alpha: 0.75)
                : AppColors.surfaceLight.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: isDark ? AppColors.glassBorder : AppColors.grey200,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              const Text('🔁', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 12),
              Text(
                'Pas encore d\'habitudes',
                style: AppTextStyles.headingSmall(
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ajoute tes premières habitudes pour les voir apparaître dans ta journée chaque jour.',
                style:
                    AppTextStyles.bodySmall(color: AppColors.grey400),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bouton ajouter habitude ───────────────────────────────────
class _AddHabitButton extends StatelessWidget {
  const _AddHabitButton({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const _AddHabitSheet(),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.30)),
          ),
          child: Text(
            '+ Créer une habitude',
            style: AppTextStyles.labelMedium(color: AppColors.accent),
          ),
        ),
      ),
    );
  }
}

// ── Éléments communs ──────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.isDark});
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: AppTextStyles.overline(
            color: isDark ? AppColors.textDarkMuted : AppColors.grey600,
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 12),
              const SizedBox(width: 5),
              Text(label, style: AppTextStyles.caption(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      alignment: Alignment.center,
      child: const KolybLoader(),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          const Text('😕', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Impossible de charger. Réessaie.',
              style: AppTextStyles.bodySmall(color: AppColors.textDarkMuted),
            ),
          ),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              'Réessayer',
              style: AppTextStyles.labelSmall(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom sheet : liste objectifs d'un horizon ───────────────
class _ObjectivesListSheet extends ConsumerWidget {
  const _ObjectivesListSheet({required this.horizon});
  final ObjectiveHorizon horizon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final objectives = ref.watch(objectivesByHorizonProvider(horizon));

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey400.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(horizon.emoji,
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Text(
                  horizon.label,
                  style: AppTextStyles.headingMedium(
                    color: isDark
                        ? AppColors.textDark
                        : AppColors.textLight,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) =>
                          _AddObjectiveSheet(horizon: horizon),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '+ Ajouter',
                      style: AppTextStyles.labelSmall(
                          color: AppColors.primaryLight),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (objectives.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Pas encore d\'objectif ${horizon.detail.toLowerCase()}.',
                style:
                    AppTextStyles.bodyMedium(color: AppColors.grey400),
                textAlign: TextAlign.center,
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: objectives.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 10),
                itemBuilder: (_, i) => _ObjectiveListTile(
                  objective: objectives[i],
                  isDark: isDark,
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ── Tuile d'un objectif ───────────────────────────────────────
class _ObjectiveListTile extends ConsumerWidget {
  const _ObjectiveListTile({
    required this.objective,
    required this.isDark,
  });
  final Objective objective;
  final bool isDark;

  Color get _color {
    switch (objective.horizon) {
      case ObjectiveHorizon.shortTerm:  return AppColors.accent;
      case ObjectiveHorizon.mediumTerm: return AppColors.primary;
      case ObjectiveHorizon.longTerm:   return AppColors.chartAmber;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(objective.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error),
      ),
      onDismissed: (_) =>
          ref.read(objectivesProvider.notifier).delete(objective.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark.withValues(alpha: 0.80)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: _color.withValues(alpha: 0.22),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    objective.title,
                    style: AppTextStyles.bodyMedium(
                      color: isDark
                          ? AppColors.textDark
                          : AppColors.textLight,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => ref
                      .read(objectivesProvider.notifier)
                      .complete(objective.id),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: _color.withValues(alpha: 0.3)),
                    ),
                    child: Icon(Icons.check_rounded,
                        color: _color, size: 14),
                  ),
                ),
              ],
            ),
            if (objective.description != null &&
                objective.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                objective.description!,
                style:
                    AppTextStyles.caption(color: AppColors.grey400),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            // Barre de progression
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: objective.progressPercent,
                backgroundColor: _color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(_color),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(objective.progressPercent * 100).round()}% accompli',
              style: AppTextStyles.caption(color: AppColors.grey400),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom sheet : ajouter un objectif ───────────────────────
class _AddObjectiveSheet extends ConsumerStatefulWidget {
  const _AddObjectiveSheet({required this.horizon});
  final ObjectiveHorizon horizon;

  @override
  ConsumerState<_AddObjectiveSheet> createState() =>
      _AddObjectiveSheetState();
}

class _AddObjectiveSheetState extends ConsumerState<_AddObjectiveSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref.read(objectivesProvider.notifier).add(
            title: _titleCtrl.text,
            horizon: widget.horizon,
            description: _descCtrl.text.isEmpty ? null : _descCtrl.text,
          );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color:
              isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey400.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(widget.horizon.emoji,
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Text(
                  'Nouvel objectif ${widget.horizon.label.toLowerCase()}',
                  style: AppTextStyles.headingSmall(
                    color: isDark
                        ? AppColors.textDark
                        : AppColors.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              style: AppTextStyles.bodyMedium(
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
              decoration: InputDecoration(
                hintText: 'Quel est ton objectif ?',
                hintStyle:
                    AppTextStyles.bodyMedium(color: AppColors.grey400),
                filled: true,
                fillColor: isDark
                    ? AppColors.surfaceElevatedDark
                    : AppColors.grey200.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              textCapitalization: TextCapitalization.sentences,
              style: AppTextStyles.bodyMedium(
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Décris-le en quelques mots (optionnel)',
                hintStyle:
                    AppTextStyles.bodyMedium(color: AppColors.grey400),
                filled: true,
                fillColor: isDark
                    ? AppColors.surfaceElevatedDark
                    : AppColors.grey200.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: _loading
                    ? const KolybLoader(size: 6, color: Colors.white)
                    : Text(
                        'Créer cet objectif',
                        style:
                            AppTextStyles.labelMedium(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom sheet : ajouter une habitude ──────────────────────
class _AddHabitSheet extends ConsumerStatefulWidget {
  const _AddHabitSheet();

  @override
  ConsumerState<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends ConsumerState<_AddHabitSheet> {
  final _titleCtrl = TextEditingController();
  String _emoji = '🔁';
  HabitFrequency _frequency = HabitFrequency.daily;
  final List<int> _selectedDays = [];
  bool _loading = false;

  static const _emojis = [
    '🔁', '📚', '💪', '🧘', '✍️', '🚶', '🍎', '💧',
    '🌅', '🎯', '💊', '🎵', '🧹', '💡', '🤝', '🌱',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref.read(habitsProvider.notifier).add(
            title: _titleCtrl.text,
            emoji: _emoji,
            frequency: _frequency,
            daysOfWeek: _frequency == HabitFrequency.daily
                ? []
                : _selectedDays,
          );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color:
              isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey400.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nouvelle habitude',
              style: AppTextStyles.headingSmall(
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 16),

            // Emoji picker
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _emojis.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final e = _emojis[i];
                  final selected = e == _emoji;
                  return GestureDetector(
                    onTap: () => setState(() => _emoji = e),
                    child: AnimatedContainer(
                      duration: AppConstants.animFast,
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.20)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(e,
                            style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Titre
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              style: AppTextStyles.bodyMedium(
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
              decoration: InputDecoration(
                hintText: 'Nom de l\'habitude',
                hintStyle:
                    AppTextStyles.bodyMedium(color: AppColors.grey400),
                filled: true,
                fillColor: isDark
                    ? AppColors.surfaceElevatedDark
                    : AppColors.grey200.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Fréquence
            Text(
              'Fréquence',
              style: AppTextStyles.labelMedium(
                color: isDark ? AppColors.textDarkMuted : AppColors.grey600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: HabitFrequency.values.map((f) {
                final selected = f == _frequency;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _frequency = f),
                    child: AnimatedContainer(
                      duration: AppConstants.animFast,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accent.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppColors.accent
                              : AppColors.grey400.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        f.label,
                        style: AppTextStyles.labelSmall(
                          color: selected
                              ? AppColors.accent
                              : AppColors.grey400,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // Jours si hebdo/custom
            if (_frequency != HabitFrequency.daily) ...[
              const SizedBox(height: 16),
              Text(
                'Jours',
                style: AppTextStyles.labelMedium(
                  color: isDark
                      ? AppColors.textDarkMuted
                      : AppColors.grey600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final day = i + 1;
                  final selected = _selectedDays.contains(day);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (selected) {
                        _selectedDays.remove(day);
                      } else {
                        _selectedDays.add(day);
                      }
                    }),
                    child: AnimatedContainer(
                      duration: AppConstants.animFast,
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.grey400.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          kDayLabels[i],
                          style: AppTextStyles.caption(
                            color: selected
                                ? Colors.white
                                : AppColors.grey400,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: _loading
                    ? const KolybLoader(size: 6, color: Colors.white)
                    : Text(
                        'Créer cette habitude',
                        style:
                            AppTextStyles.labelMedium(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Graphique streaks habitudes ───────────────────────────────
class _HabitStreakChart extends StatelessWidget {
  const _HabitStreakChart({required this.habits, required this.isDark});
  final List<Habit> habits;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final totalHabits = habits.length;
    final completedToday = habits.where((h) => h.isCompletedToday).length;
    final longestStreak =
        habits.map((h) => h.currentStreak).fold(0, math.max);
    final avgStreak = totalHabits > 0
        ? (habits.map((h) => h.currentStreak).reduce((a, b) => a + b) /
                totalHabits)
            .round()
        : 0;

    final progress =
        totalHabits > 0 ? completedToday / totalHabits : 0.0;

    final ringColor = progress >= 1.0
        ? AppColors.success
        : progress >= 0.5
            ? AppColors.primary
            : AppColors.chartAmber;

    final cardBg = isDark
        ? AppColors.surfaceDark.withValues(alpha: 0.75)
        : AppColors.surfaceLight.withValues(alpha: 0.90);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius:
                BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: isDark ? AppColors.glassBorder : AppColors.grey200,
            ),
          ),
          child: Row(
            children: [
              // Anneau de progression
              SizedBox(
                width: 90,
                height: 90,
                child: CustomPaint(
                  painter: _StreakRingPainter(
                    progress: progress,
                    color: ringColor,
                    isDark: isDark,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$completedToday/$totalHabits',
                          style: AppTextStyles.headingSmall(
                            color: isDark
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ).copyWith(fontSize: 15),
                        ),
                        Text(
                          'aujourd\'hui',
                          style: AppTextStyles.caption(
                                  color: AppColors.grey400)
                              .copyWith(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tes habitudes',
                      style: AppTextStyles.headingSmall(
                        color: isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _StatRow(
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.secondary,
                      label: 'Meilleur streak',
                      value: '$longestStreak jour${longestStreak > 1 ? 's' : ''}',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 6),
                    _StatRow(
                      icon: Icons.trending_up_rounded,
                      color: AppColors.accent,
                      label: 'Streak moyen',
                      value: '$avgStreak jour${avgStreak > 1 ? 's' : ''}',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    // Barre de completion du jour
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor:
                            ringColor.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation(ringColor),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      progress >= 1.0
                          ? 'Toutes tes habitudes du jour ! 🎉'
                          : '${(progress * 100).round()}% des habitudes faites',
                      style: AppTextStyles.caption(
                        color: AppColors.grey400,
                      ).copyWith(fontSize: 10),
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

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.isDark,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption(color: AppColors.grey400),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.caption(
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _StreakRingPainter extends CustomPainter {
  const _StreakRingPainter({
    required this.progress,
    required this.color,
    required this.isDark,
  });
  final double progress;
  final Color color;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    if (progress <= 0) return;

    // Glow
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_StreakRingPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Graphique momentum (LineChart animé) ─────────────────────
class _MomentumLineChart extends StatefulWidget {
  const _MomentumLineChart({required this.habits, required this.isDark});
  final List<Habit> habits;
  final bool isDark;

  @override
  State<_MomentumLineChart> createState() => _MomentumLineChartState();
}

class _MomentumLineChartState extends State<_MomentumLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  late List<double> _realData;
  late List<double> _simData;
  late List<double> _completionData;
  double? _touchedX;
  bool _animDone = false;

  static const int _days = 7;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _buildData();
    _ctrl.forward().then((_) {
      if (mounted) setState(() => _animDone = true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _buildData() {
    final habits = widget.habits;

    final avgStreak = habits.isEmpty
        ? 2.0
        : habits
                .map((h) => h.currentStreak.toDouble())
                .reduce((a, b) => a + b) /
            habits.length;

    final completionRate = habits.isEmpty
        ? 0.25
        : habits.where((h) => h.isCompletedToday).length /
            habits.length.clamp(1, 999);

    // Score cible aujourd'hui : 15–92
    final todayScore =
        ((avgStreak / 14.0) * 55 + completionRate * 37 + 10).clamp(15.0, 92.0);

    // Seed basé sur les données utilisateur pour stabilité entre renders
    final seed = habits.fold(0, (s, h) => s + h.currentStreak) +
        habits.length * 13;
    final rng = math.Random(seed);

    // Courbe réelle : montée progressive vers aujourd'hui
    _realData = List.generate(_days, (i) {
      final ratio = i / (_days - 1);
      final noise = (rng.nextDouble() - 0.5) * 10;
      return (todayScore * 0.35 + todayScore * 0.65 * ratio + noise)
          .clamp(8.0, 96.0);
    });
    _realData[_days - 1] = todayScore;

    // Données simulées : plus bruitées, légèrement différentes
    final rng2 = math.Random(seed + 7);
    _simData = List.generate(_days, (i) {
      final noise = (rng2.nextDouble() - 0.5) * 18;
      return (_realData[i] + noise).clamp(5.0, 98.0);
    });
    _simData[_days - 1] = todayScore;

    // Courbe de régularité : taux de complétion des habitudes (0–100)
    final completionToday = completionRate * 100;
    final rng3 = math.Random(seed + 31);
    _completionData = List.generate(_days, (i) {
      final ratio = i / (_days - 1);
      final noise = (rng3.nextDouble() - 0.5) * 22;
      return (completionToday * 0.2 + completionToday * 0.8 * ratio + noise)
          .clamp(0.0, 100.0);
    });
    _completionData[_days - 1] = completionToday;
  }

  // Spots animés pour la courbe d'élan principale
  List<FlSpot> _spots(double t) {
    // Phase 1 (0→0.65): tracé de gauche à droite (données simulées)
    // Phase 2 (0.65→1.0): convergence vers données réelles
    final drawProgress = (t / 0.65).clamp(0.0, 1.0);
    final settleT = ((t - 0.65) / 0.35).clamp(0.0, 1.0);

    final maxI = drawProgress * (_days - 1);
    final spots = <FlSpot>[];

    for (int i = 0; i < _days; i++) {
      if (i > maxI) break;
      final y = _simData[i] + (_realData[i] - _simData[i]) * settleT;
      spots.add(FlSpot(i.toDouble(), y.clamp(0.0, 100.0)));
    }
    return spots;
  }

  // Spots animés pour la courbe de régularité (tracé linéaire simple)
  List<FlSpot> _completionSpots(double t) {
    final maxI = t * (_days - 1);
    final spots = <FlSpot>[];
    for (int i = 0; i < _days; i++) {
      if (i > maxI) break;
      spots.add(FlSpot(i.toDouble(), _completionData[i]));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final completedToday =
        widget.habits.where((h) => h.isCompletedToday).length;
    final total = widget.habits.length;
    final avgStreak = widget.habits.isEmpty
        ? 0
        : (widget.habits
                    .map((h) => h.currentStreak)
                    .reduce((a, b) => a + b) /
                widget.habits.length)
            .round();

    // Chiffres pour le hero score
    final heroScore = _realData.last.round();
    final delta = (_realData.last - _realData.first).round();
    final deltaColor = delta >= 0 ? AppColors.accent : AppColors.secondary;

    final cardBg = isDark
        ? AppColors.surfaceDark.withValues(alpha: 0.75)
        : AppColors.surfaceLight.withValues(alpha: 0.90);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: isDark ? AppColors.glassBorder : AppColors.grey200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header : titre + hero score + pills
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre + hero score à gauche
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ton élan',
                        style: AppTextStyles.headingMedium(
                          color: isDark
                              ? AppColors.textDark
                              : AppColors.textLight,
                        ),
                      ),
                      Text(
                        '7 derniers jours',
                        style: AppTextStyles.caption(
                            color: AppColors.grey400),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ShaderMask(
                            shaderCallback: (b) => const LinearGradient(
                              colors: AppColors.gradientMain,
                            ).createShader(b),
                            blendMode: BlendMode.srcIn,
                            child: Text(
                              '$heroScore',
                              style: AppTextStyles.headingLarge(
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(
                              children: [
                                Icon(
                                  delta >= 0
                                      ? Icons.trending_up_rounded
                                      : Icons.trending_down_rounded,
                                  size: 12,
                                  color: deltaColor,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${delta >= 0 ? '+' : ''}$delta vs J-7',
                                  style: AppTextStyles.caption(
                                      color: deltaColor)
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Pills stats à droite
                  if (total > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _ChartPill(
                          icon: Icons.loop_rounded,
                          label: '$completedToday/$total',
                          color: AppColors.accent,
                        ),
                        const SizedBox(height: 6),
                        _ChartPill(
                          icon: Icons.local_fire_department_rounded,
                          label: '${avgStreak}j',
                          color: AppColors.secondary,
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 6),

              // Légende mini pour les 2 courbes
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Élan',
                    style: AppTextStyles.caption(color: AppColors.grey400)
                        .copyWith(fontSize: 9),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 14,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Régularité',
                    style: AppTextStyles.caption(color: AppColors.grey400)
                        .copyWith(fontSize: 9),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Chart enrichi
              SizedBox(
                height: 160,
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) {
                    final spots = _spots(_anim.value);
                    final compSpots = _completionSpots(_anim.value);
                    if (spots.length < 2) return const SizedBox.shrink();

                    return LineChart(
                      duration: Duration.zero,
                      LineChartData(
                        minX: 0,
                        maxX: (_days - 1).toDouble(),
                        minY: 0,
                        maxY: 100,
                        clipData: const FlClipData.all(),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 25,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: isDark
                                ? AppColors.grey800
                                : AppColors.grey200,
                            strokeWidth: 0.7,
                            dashArray: [4, 4],
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchCallback: (event, response) {
                            setState(() {
                              if (event is FlTapUpEvent ||
                                  event is FlPanEndEvent ||
                                  response?.lineBarSpots == null) {
                                _touchedX = null;
                              } else {
                                _touchedX =
                                    response!.lineBarSpots!.first.x;
                              }
                            });
                          },
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) => isDark
                                ? AppColors.surfaceElevatedDark
                                : AppColors.surfaceLight,
                            tooltipRoundedRadius: 10,
                            tooltipPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((s) {
                                if (s.barIndex == 0) {
                                  return LineTooltipItem(
                                    'Élan ${s.y.round()}%',
                                    const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                }
                                return LineTooltipItem(
                                  'Régularité ${s.y.round()}%',
                                  TextStyle(
                                    color: AppColors.accent
                                        .withValues(alpha: 0.9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 20,
                              getTitlesWidget: (v, _) {
                                final days = [
                                  'L', 'M', 'M', 'J', 'V', 'S', 'D'
                                ];
                                final idx = v.toInt();
                                if (idx < 0 || idx >= _days) {
                                  return const SizedBox.shrink();
                                }
                                final isToday = idx == _days - 1;
                                final isTouched = _touchedX?.round() == idx;
                                return Text(
                                  isToday ? 'Auj.' : days[idx],
                                  style: AppTextStyles.caption(
                                    color: isTouched
                                        ? AppColors.primaryLight
                                        : isToday
                                            ? AppColors.primary
                                            : AppColors.grey400,
                                  ).copyWith(
                                    fontSize: 9,
                                    fontWeight: isToday || isTouched
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          // Courbe d'élan — violet, épaisse
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            curveSmoothness: 0.4,
                            color: AppColors.primary,
                            barWidth: 4,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, _, __, ___) {
                                final isLast = spot.x == spots.last.x;
                                final isTouched =
                                    _touchedX?.round() == spot.x.round();
                                if (isTouched) {
                                  return FlDotCirclePainter(
                                    radius: 6,
                                    color: AppColors.primary,
                                    strokeWidth: 2.5,
                                    strokeColor:
                                        Colors.white.withValues(alpha: 0.9),
                                  );
                                }
                                if (isLast) {
                                  return FlDotCirclePainter(
                                    radius: 5,
                                    color: AppColors.primary,
                                    strokeWidth: 2.5,
                                    strokeColor:
                                        Colors.white.withValues(alpha: 0.85),
                                  );
                                }
                                return FlDotCirclePainter(
                                  radius: 2.5,
                                  color: AppColors.primary
                                      .withValues(alpha: 0.50),
                                  strokeWidth: 0,
                                  strokeColor: Colors.transparent,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.32),
                                  AppColors.primary.withValues(alpha: 0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          // Courbe de régularité — teal, fine + fill subtil
                          if (compSpots.length >= 2)
                            LineChartBarData(
                              spots: compSpots,
                              isCurved: true,
                              curveSmoothness: 0.4,
                              color: AppColors.accent.withValues(alpha: 0.65),
                              barWidth: 1.5,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, _, __, ___) {
                                  final isTouched =
                                      _touchedX?.round() == spot.x.round();
                                  return FlDotCirclePainter(
                                    radius: isTouched ? 5 : 2,
                                    color: AppColors.accent
                                        .withValues(alpha: isTouched ? 1.0 : 0.45),
                                    strokeWidth: 0,
                                    strokeColor: Colors.transparent,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.accent.withValues(alpha: 0.10),
                                    AppColors.accent.withValues(alpha: 0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Badge "meilleur jour" — apparaît après l'animation
              if (_animDone) ...[
                const SizedBox(height: 8),
                _BestDayBadge(data: _realData),
              ],
            ],
          ),
        ),
      ),
    );
  }

}

class _BestDayBadge extends StatelessWidget {
  const _BestDayBadge({required this.data});
  final List<double> data;

  static const _dayLabels = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

  int get _bestIdx {
    var maxVal = -1.0;
    var maxIdx = 0;
    for (int i = 0; i < data.length; i++) {
      if (data[i] > maxVal) {
        maxVal = data[i];
        maxIdx = i;
      }
    }
    return maxIdx;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _bestIdx;
    final label = idx == data.length - 1
        ? "Aujourd'hui"
        : _dayLabels[idx % _dayLabels.length];

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.30),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 5),
              Text(
                'Meilleur jour : $label (${data[idx].round()}%)',
                style: AppTextStyles.caption(color: AppColors.warning)
                    .copyWith(fontWeight: FontWeight.w600, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartPill extends StatelessWidget {
  const _ChartPill({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption(color: color)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
