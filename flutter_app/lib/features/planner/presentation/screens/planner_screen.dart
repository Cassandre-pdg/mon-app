import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/constants/app_strings.dart';
import '../../../../shared/widgets/pill_tab_bar.dart';
import '../providers/planner_provider.dart';
import '../providers/kanban_provider.dart';
import '../../data/planner_model.dart';
import 'pomodoro_screen.dart';
import 'flash_screen.dart';
import 'eisenhower_screen.dart';
import 'flow_screen.dart';

// ── Écran principal "Ma Journée" avec sous-menu 4 onglets ─────
class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── En-tête ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Text(
                  AppStrings.navPlanner,
                  style: AppTextStyles.headingLarge(
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Bandeau projet focus ──────────────────────
              const _FocusProjectBanner(),

              // ── Barre d'onglets pill scrollable ──────────
              PillTabBar(
                scrollable: true,
                tabs: const [
                  '🎯  Priorités',
                  '🌊  Flow',
                  '🍅  Pomodoro',
                  '⚡  Flash',
                  '🧭  Matrice',
                ],
              ),
              const SizedBox(height: 8),

              // ── Contenu des onglets ──────────────────────
              const Expanded(
                child: TabBarView(
                  children: [
                    _PrioritesTab(),   // Onglet 1 : 3 priorités du jour
                    FlowTab(),         // Onglet 2 : sessions Flow 90 min
                    PomodoroContent(), // Onglet 3 : timer Pomodoro
                    FlashTab(),        // Onglet 4 : micro-tâches < 5 min
                    EisenhowerTab(),   // Onglet 5 : matrice urgence/importance
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

// ── Onglet 1 : 3 Priorités du jour ───────────────────────────
class _PrioritesTab extends ConsumerWidget {
  const _PrioritesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(plannerProvider);
    final isDark     = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            'Tes 3 priorités du jour',
            style: AppTextStyles.bodyMedium(color: AppColors.grey400),
          ),
        ),

        // Liste des tâches
        Expanded(
          child: tasksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                AppStrings.errorGeneric,
                style: AppTextStyles.bodyMedium(color: AppColors.error),
              ),
            ),
            data: (tasks) => tasks.isEmpty
                ? _EmptyState()
                : _TaskList(tasks: tasks, isDark: isDark),
          ),
        ),

        // Bouton ajouter (si < 3 tâches)
        tasksAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (tasks) => tasks.length < AppConstants.maxDailyTasks
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: _AddTaskButton(),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Text(
                    AppStrings.plannerMaxTasks,
                    style: AppTextStyles.bodySmall(color: AppColors.grey400),
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
      ],
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
              color: AppColors.error.withValues(alpha:0.15),
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
                  ? AppColors.success.withValues(alpha:0.08)
                  : isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
              border: Border.all(
                color: task.isCompleted
                    ? AppColors.success
                    : color.withValues(alpha:0.3),
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
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
                        color: task.isCompleted ? AppColors.success : color,
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
                                color: AppColors.primary.withValues(alpha: 0.12),
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

// ── Sheet partagé : ajouter OU modifier une tâche ────────────
void _showTaskSheet(
  BuildContext context,
  WidgetRef ref, {
  PlannerTask? task,
}) {
  final isEdit       = task != null;
  final ctrl         = TextEditingController(text: task?.title ?? '');
  int priority       = task?.priority ?? 1;
  String? projectId  = task?.projectId;
  final activeProjects =
      ref.read(activeProjectsProvider);

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
                left: 24, right: 24, top: 16,
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
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.grey400.withValues(alpha: 0.35),
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
                            margin:
                                EdgeInsets.only(right: p < 3 ? 8 : 0),
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
    return ElevatedButton.icon(
      onPressed: () => _showTaskSheet(context, ref),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Ajouter une priorité'),
    );
  }
}

// ── État vide ─────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              AppStrings.plannerEmptyState,
              style: AppTextStyles.bodyLarge(color: AppColors.grey400),
              textAlign: TextAlign.center,
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysLeft = project.daysLeft;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
          ),
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
                      color: isDark ? AppColors.textDark : AppColors.textLight,
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
            // Mini barre progression
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
