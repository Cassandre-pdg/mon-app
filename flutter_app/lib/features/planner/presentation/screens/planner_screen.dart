import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/constants/app_strings.dart';
import '../../../../shared/widgets/aurora_background.dart';
import '../providers/planner_provider.dart';
import '../providers/kanban_provider.dart';
import '../providers/flash_provider.dart';
import '../providers/flow_provider.dart';
import '../../data/planner_model.dart';
import 'pomodoro_screen.dart';
import 'flash_screen.dart';
import 'eisenhower_screen.dart';
import 'flow_screen.dart';

// ── Écran principal "Ma Journée" ─────────────────────────────
// Architecture : un seul Scaffold transparent.
// Quand une section est active, le body bascule vers la section
// (remplacement complet — pas de Stack/Positioned.fill pour éviter
// les contraintes loose qui bloquent les Expanded internes).
class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  // null = dashboard  |  'flow' | 'pomodoro' | 'flash' | 'matrice'
  String? _activeSection;

  void _openSection(String section) =>
      setState(() => _activeSection = section);

  void _closeSection() => setState(() => _activeSection = null);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Section active : remplace le dashboard entièrement ──────
    if (_activeSection != null) {
      return _buildSectionView(_activeSection!, isDark);
    }

    // ── Dashboard ─────────────────────────────────────────────
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.navPlanner,
                      style: AppTextStyles.displayLarge(
                        color: isDark ? AppColors.textDark : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      () {
                        try {
                          return DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now());
                        } catch (_) {
                          return DateFormat('EEEE d MMMM').format(DateTime.now());
                        }
                      }(),
                      style: AppTextStyles.bodySmall(color: AppColors.grey400)
                          .copyWith(letterSpacing: 0.1),
                    ),
                  ],
                ),
              ),

              // Bandeau projet focus
              const _FocusProjectBanner(),
              const SizedBox(height: 20),

              // Mes 3 priorités du jour
              const _PrioritiesSection(),
              const SizedBox(height: 32),

              // Séparateur section "Outils focus"
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: _SectionLabel(label: 'Outils focus'),
              ),

              // Cards Flow + Pomodoro côte à côte
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _FlowCard(
                        onTap: () => _openSection('flow'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PomodoroCard(
                        onTap: () => _openSection('pomodoro'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Card Flash
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _FlashCard(
                  onTap: () => _openSection('flash'),
                ),
              ),
              const SizedBox(height: 20),

              // Matrice Eisenhower — lien discret
              _MatriceLink(
                onTap: () => _openSection('matrice'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Construction de la vue section ────────────────────────────
  // Retourne un Scaffold complet pour remplacer le dashboard.
  // Le Scaffold reçoit des contraintes tight du ShellRoute parent →
  // SafeArea + Column + Expanded fonctionnent sans ambiguïté.
  Widget _buildSectionView(String section, bool isDark) {
    final String title;
    final Color accentColor;
    final Widget content;

    switch (section) {
      case 'flow':
        title       = 'Flow';
        accentColor = AppColors.primary;
        content     = const FlowTab();
      case 'pomodoro':
        title       = 'Pomodoro';
        accentColor = AppColors.secondary;
        content     = const PomodoroContent();
      case 'flash':
        title       = 'Flash';
        accentColor = AppColors.warning;
        content     = const FlashTab();
      case 'matrice':
        title       = 'Matrice Eisenhower';
        accentColor = AppColors.accent;
        content     = const EisenhowerTab();
      default:
        title       = '';
        accentColor = AppColors.primary;
        content     = const SizedBox.expand();
    }

    final header = _SectionHeader(
      title: title,
      accentColor: accentColor,
      onBack: _closeSection,
      isDark: isDark,
    );

    // Flow : fond aurora animé
    if (section == 'flow') {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: AuroraBackground(
          child: SafeArea(
            child: Column(
              children: [
                header,
                const Expanded(child: FlowTab()),
              ],
            ),
          ),
        ),
      );
    }

    // Sections standard : fond uni
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            header,
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}

// ── Header des sections ───────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color accentColor;
  final VoidCallback onBack;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.accentColor,
    required this.onBack,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 24, 8),
      child: Row(
        children: [
          // Bouton retour
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.grey400.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: AppColors.grey400,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Barre couleur accent
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: AppTextStyles.headingMedium(
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Label de section ──────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          label,
          style: AppTextStyles.labelMedium(
            color: isDark
                ? AppColors.textDarkMuted
                : AppColors.textLight.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

// ── Section Priorités (inline dans la page) ───────────────────
class _PrioritiesSection extends ConsumerWidget {
  const _PrioritiesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(plannerProvider);
    final isDark     = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre section
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(label: "Priorités du jour"),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    'Mes 3 priorités',
                    style: AppTextStyles.headingMedium(
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  tasksAsync.whenData((tasks) {
                    final done = tasks.where((t) => t.isCompleted).length;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$done/${tasks.length}',
                        style: AppTextStyles.caption(
                            color: AppColors.primaryLight),
                      ),
                    );
                  }).value ?? const SizedBox.shrink(),
                ],
              ),
            ],
          ),
        ),

        // Liste des tâches
        tasksAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(AppStrings.errorGeneric,
                style: AppTextStyles.bodyMedium(color: AppColors.error)),
          ),
          data: (tasks) => tasks.isEmpty
              ? _EmptyState()
              : _TaskList(tasks: tasks, isDark: isDark),
        ),

        // Bouton ajouter
        tasksAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (tasks) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: tasks.length < AppConstants.maxDailyTasks
                ? _AddTaskButton()
                : Text(
                    AppStrings.plannerMaxTasks,
                    style:
                        AppTextStyles.bodySmall(color: AppColors.grey400),
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ],
    );
  }
}

// ── Card Flow ─────────────────────────────────────────────────
class _FlowCard extends ConsumerWidget {
  final VoidCallback onTap;
  const _FlowCard({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(flowProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B1B8E), Color(0xFF6D28D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Orbe décorative fond
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom + durée
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Flow',
                        style: AppTextStyles.headingMedium(
                            color: Colors.white),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '90 min',
                          style: AppTextStyles.caption(
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Focus profond sans interruption',
                    style: AppTextStyles.bodySmall(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Stats + flèche
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sessions pills
                      Row(
                        children: List.generate(
                          math.min(flow.sessionsPerDay, 4),
                          (i) {
                            final done = i < flow.completedToday;
                            return Container(
                              margin: const EdgeInsets.only(right: 5),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: done
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: done
                                  ? const Icon(Icons.check_rounded,
                                      size: 12,
                                      color: Color(0xFF6D28D9))
                                  : null,
                            );
                          },
                        ),
                      ),
                      // Flèche
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Card Pomodoro ─────────────────────────────────────────────
class _PomodoroCard extends StatelessWidget {
  final VoidCallback onTap;
  const _PomodoroCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B1A2F), Color(0xFFFF4D6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Orbe décorative fond
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom + durée
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Pomodoro',
                          style: AppTextStyles.headingMedium(
                              color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '25 min',
                          style: AppTextStyles.caption(
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Travail par intervalles courts',
                    style: AppTextStyles.bodySmall(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Infos + flèche — Flexible évite le débordement horizontal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Pause 5 min entre chaque',
                          style: AppTextStyles.caption(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Card Flash ────────────────────────────────────────────────
class _FlashCard extends ConsumerWidget {
  final VoidCallback onTap;
  const _FlashCard({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashAsync = ref.watch(flashProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pendingTasks = flashAsync.value
            ?.where((t) => !t.isDone)
            .toList() ??
        [];
    final count = pendingTasks.length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.warning.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône colorée
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.bolt_rounded,
                  color: AppColors.warning, size: 24),
            ),
            const SizedBox(width: 14),

            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Flash',
                        style: AppTextStyles.headingSmall(
                          color: isDark
                              ? AppColors.textDark
                              : AppColors.textLight,
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$count',
                            style: AppTextStyles.caption(
                              color: Colors.black87,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    count == 0
                        ? 'Micro-tâches de moins de 5 min'
                        : pendingTasks
                            .take(2)
                            .map((t) => t.title)
                            .join(' · '),
                    style: AppTextStyles.bodySmall(
                        color: AppColors.grey400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Flèche
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.grey400.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Lien Matrice Eisenhower ───────────────────────────────────
class _MatriceLink extends StatelessWidget {
  final VoidCallback onTap;
  const _MatriceLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDark.withValues(alpha: 0.6)
                : AppColors.surfaceLight,
            borderRadius:
                BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(
              color: AppColors.grey400.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.grid_view_rounded,
                size: 18,
                color: AppColors.grey400.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 10),
              Text(
                'Matrice Eisenhower',
                style: AppTextStyles.bodyMedium(
                    color: AppColors.grey400),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: AppColors.grey400.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ── Widgets logique (inchangés) ───────────────────────────────
// ─────────────────────────────────────────────────────────────

// ── Liste de tâches ───────────────────────────────────────────
class _TaskList extends ConsumerWidget {
  final List<PlannerTask> tasks;
  final bool isDark;

  const _TaskList({required this.tasks, required this.isDark});

  static const _priorityColors = {
    1: AppColors.error,
    2: AppColors.warning,
    3: AppColors.accent,
  };
  static const _priorityLabels = {1: 'Haute', 2: 'Moyenne', 3: 'Basse'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final task  = tasks[i];
        final color = _priorityColors[task.priority] ?? AppColors.primary;

        return Dismissible(
          key: Key(task.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusLarge),
            ),
            child: const Icon(Icons.delete_rounded, color: AppColors.error),
          ),
          onDismissed: (_) =>
              ref.read(plannerProvider.notifier).deleteTask(task.id),
          child: AnimatedContainer(
            duration: AppConstants.animFast,
            padding: const EdgeInsets.all(AppConstants.spacing16),
            decoration: BoxDecoration(
              color: task.isCompleted
                  ? AppColors.success.withValues(alpha: 0.08)
                  : isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
              border: Border.all(
                color: task.isCompleted
                    ? AppColors.success
                    : color.withValues(alpha: 0.3),
              ),
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusLarge),
            ),
            child: Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: task.isCompleted
                      ? null
                      : () => ref
                          .read(plannerProvider.notifier)
                          .completeTask(task.id),
                  child: AnimatedContainer(
                    duration: AppConstants.animFast,
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? AppColors.success
                          : Colors.transparent,
                      border: Border.all(
                        color:
                            task.isCompleted ? AppColors.success : color,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),

                // Titre + priorité + projet
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: AppTextStyles.bodyLarge(
                          color: task.isCompleted
                              ? AppColors.grey400
                              : isDark
                                  ? AppColors.textDark
                                  : AppColors.textLight,
                        ).copyWith(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Priorité ${_priorityLabels[task.priority]}',
                            style: AppTextStyles.caption(color: color),
                          ),
                          if (task.projectName != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                task.projectName!,
                                style: AppTextStyles.caption(
                                    color: AppColors.primaryLight),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                if (task.isCompleted)
                  const Text('✅', style: TextStyle(fontSize: 18))
                else
                  GestureDetector(
                    onTap: () => _showTaskSheet(context, ref, task: task),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: AppColors.grey400,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Sheet partagé : ajouter OU modifier une tâche ─────────────
void _showTaskSheet(
  BuildContext context,
  WidgetRef ref, {
  PlannerTask? task,
}) {
  final isEdit      = task != null;
  final ctrl        = TextEditingController(text: task?.title ?? '');
  int priority      = task?.priority ?? 1;
  String? projectId = task?.projectId;
  final activeProjects = ref.read(activeProjectsProvider);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      return StatefulBuilder(
        builder: (ctx, setState) => Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceElevatedDark
                : AppColors.surfaceLight,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            AppColors.grey400.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    isEdit ? 'Modifier la priorité' : 'Nouvelle priorité',
                    style: AppTextStyles.headingMedium(
                      color: isDark
                          ? AppColors.textDark
                          : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing16),
                  TextField(
                    controller: ctrl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Sur quoi tu vas avancer ?',
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing16),

                  // Niveau de priorité
                  Text('Niveau de priorité',
                      style: AppTextStyles.labelMedium(
                          color: AppColors.grey400)),
                  const SizedBox(height: 8),
                  Row(
                    children: [1, 2, 3].map((p) {
                      const colors = {
                        1: AppColors.error,
                        2: AppColors.warning,
                        3: AppColors.accent,
                      };
                      const labels = {
                        1: '🔴 Haute',
                        2: '🟡 Moyenne',
                        3: '🟢 Basse',
                      };
                      final c = colors[p]!;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => priority = p),
                          child: AnimatedContainer(
                            duration: AppConstants.animFast,
                            margin: EdgeInsets.only(right: p < 3 ? 8 : 0),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                            decoration: BoxDecoration(
                              color: priority == p
                                  ? c.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              border: Border.all(
                                color: priority == p
                                    ? c
                                    : AppColors.grey400
                                        .withValues(alpha: 0.3),
                              ),
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusMedium),
                            ),
                            child: Text(
                              labels[p]!,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall(
                                color: priority == p
                                    ? c
                                    : AppColors.grey400,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Projet lié (optionnel)
                  if (activeProjects.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.spacing16),
                    Text('Projet lié (optionnel)',
                        style: AppTextStyles.labelMedium(
                            color: AppColors.grey400)),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _PriorityProjectPill(
                            label: 'Aucun',
                            isSelected: projectId == null,
                            onTap: () =>
                                setState(() => projectId = null),
                          ),
                          const SizedBox(width: 8),
                          ...activeProjects.map((p) => Padding(
                                padding:
                                    const EdgeInsets.only(right: 8),
                                child: _PriorityProjectPill(
                                  label: p.name,
                                  isSelected: projectId == p.id,
                                  onTap: () => setState(
                                      () => projectId = p.id),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: AppConstants.spacing24),
                  ElevatedButton(
                    onPressed: () {
                      if (ctrl.text.trim().isEmpty) return;
                      if (isEdit) {
                        ref.read(plannerProvider.notifier).editTask(
                              task.id,
                              title: ctrl.text.trim(),
                              priority: priority,
                              projectId: projectId,
                              clearProject: projectId == null,
                            );
                      } else {
                        ref.read(plannerProvider.notifier).addTask(
                              title: ctrl.text.trim(),
                              priority: priority,
                              projectId: projectId,
                            );
                      }
                      Navigator.pop(ctx);
                    },
                    child: Text(isEdit ? 'Enregistrer' : 'Ajouter'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

// ── Pill projet dans le sheet ─────────────────────────────────
class _PriorityProjectPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriorityProjectPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.18)
              : AppColors.primary.withValues(alpha: 0.06),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption(
            color: isSelected
                ? AppColors.primaryLight
                : AppColors.grey400,
          ).copyWith(
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ── Bouton ajouter une tâche ──────────────────────────────────
class _AddTaskButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showTaskSheet(context, ref),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('Ajouter une priorité'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

// ── État vide ─────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            const Text('🎯', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppStrings.plannerEmptyState,
                style: AppTextStyles.bodyMedium(color: AppColors.grey400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bandeau projet focus ──────────────────────────────────────
class _FocusProjectBanner extends ConsumerWidget {
  const _FocusProjectBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(focusProjectProvider);
    if (project == null) return const SizedBox.shrink();

    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final daysLeft  = project.daysLeft;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('📌', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: AppTextStyles.labelMedium(
                      color: isDark
                          ? AppColors.textDark
                          : AppColors.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    daysLeft != null
                        ? '${(project.progressPercent * 100).round()}% · J-$daysLeft'
                        : '${(project.progressPercent * 100).round()}% avancé',
                    style: AppTextStyles.caption(
                        color: AppColors.primaryLight),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 48,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: project.progressPercent,
                  minHeight: 5,
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
