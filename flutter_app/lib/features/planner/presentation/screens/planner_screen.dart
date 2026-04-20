import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/constants/app_strings.dart';
import '../providers/planner_provider.dart';
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
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
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
              const SizedBox(height: 16),

              // ── Barre d'onglets scrollable ────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerHeight: 0,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.grey400,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: AppTextStyles.labelMedium()
                      .copyWith(fontWeight: FontWeight.w600),
                  unselectedLabelStyle: AppTextStyles.labelMedium(),
                  tabs: const [
                    Tab(text: '🎯  Priorités'),
                    Tab(text: '🌊  Flow'),
                    Tab(text: '🍅  Pomodoro'),
                    Tab(text: '⚡  Flash'),
                    Tab(text: '🧭  Matrice'),
                  ],
                ),
              ),

              // Séparateur sous la barre d'onglets
              Divider(
                height: 1,
                color: isDark
                    ? AppColors.grey400.withValues(alpha:0.2)
                    : AppColors.grey200,
              ),

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

                // Titre + priorité
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
                      Text(
                        'Priorité ${_priorityLabels[task.priority]}',
                        style: AppTextStyles.caption(color: color),
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
  final isEdit = task != null;
  final ctrl = TextEditingController(text: task?.title ?? '');
  int priority = task?.priority ?? 1;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? 'Modifier la priorité' : 'Nouvelle priorité',
              style: AppTextStyles.headingMedium(),
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
            Text('Niveau de priorité', style: AppTextStyles.labelMedium()),
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
                    child: Container(
                      margin: EdgeInsets.only(right: p < 3 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: priority == p
                            ? c.withValues(alpha: 0.15)
                            : Colors.transparent,
                        border: Border.all(
                          color: priority == p ? c : AppColors.grey200,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusMedium,
                        ),
                      ),
                      child: Text(
                        labels[p]!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall(
                          color: priority == p ? c : AppColors.grey400,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppConstants.spacing24),
            ElevatedButton(
              onPressed: () {
                if (ctrl.text.trim().isEmpty) return;
                if (isEdit) {
                  ref.read(plannerProvider.notifier).editTask(
                        task.id,
                        title: ctrl.text.trim(),
                        priority: priority,
                      );
                } else {
                  ref.read(plannerProvider.notifier).addTask(
                        title: ctrl.text.trim(),
                        priority: priority,
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
  );
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
              style:
                  AppTextStyles.bodyLarge(color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
