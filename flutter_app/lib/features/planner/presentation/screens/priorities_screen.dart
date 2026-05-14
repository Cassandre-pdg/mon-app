import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../providers/planner_provider.dart';
import '../../data/planner_model.dart';
import '../../../../shared/widgets/kolyb_loader.dart';

// ── Écran Priorités du jour — méthode MIT (3 tâches max) ──────
class PrioritiesScreen extends ConsumerWidget {
  const PrioritiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final tasksAsync = ref.watch(plannerProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mes Priorités',
          style: AppTextStyles.headingMedium(
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Sous-titre ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusPill),
                ),
                child: Text(
                  'Méthode MIT : 3 tâches les plus importantes du jour',
                  style: AppTextStyles.caption(color: AppColors.primaryLight),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),

            // ── Liste des tâches ────────────────────────────────
            Expanded(
              child: tasksAsync.when(
                loading: () => const KolybLoaderScreen(),
                error: (e, _) => Center(
                  child: Text(
                    'Impossible de charger tes priorités.',
                    style: AppTextStyles.bodyMedium(color: AppColors.error),
                  ),
                ),
                data: (tasks) => tasks.isEmpty
                    ? _EmptyPriorities()
                    : _TaskList(tasks: tasks, isDark: isDark),
              ),
            ),

            // ── Bouton ajouter ──────────────────────────────────
            tasksAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (tasks) => Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: tasks.length < AppConstants.maxDailyTasks
                    ? _AddTaskButton()
                    : Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusMedium),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🎉',
                                style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(
                              'Tes 3 priorités sont définies, à toi de jouer !',
                              style: AppTextStyles.bodySmall(
                                  color: AppColors.success),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
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
  static const _priorityLabels = {
    1: '🔴 Haute',
    2: '🟡 Moyenne',
    3: '🟢 Basse',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: tasks.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppConstants.spacing12),
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
                    ? AppColors.success.withValues(alpha: 0.6)
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
                        'Priorité ${_priorityLabels[task.priority]?.split(' ').last}',
                        style: AppTextStyles.caption(color: color),
                      ),
                    ],
                  ),
                ),

                if (task.isCompleted)
                  const Text('✅', style: TextStyle(fontSize: 18))
                else
                  GestureDetector(
                    onTap: () =>
                        _showTaskSheet(context, ref, task: task),
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

// ── Sheet ajouter / modifier une priorité ─────────────────────
void _showTaskSheet(
  BuildContext context,
  WidgetRef ref, {
  PlannerTask? task,
}) {
  final isEdit = task != null;
  final ctrl   = TextEditingController(text: task?.title ?? '');
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
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Sur quoi tu vas avancer aujourd\'hui ?',
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            Text('Niveau de priorité',
                style: AppTextStyles.labelMedium()),
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
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: priority == p
                            ? c.withValues(alpha: 0.15)
                            : Colors.transparent,
                        border: Border.all(
                          color:
                              priority == p ? c : AppColors.grey200,
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

// ── Bouton ajouter ────────────────────────────────────────────
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
class _EmptyPriorities extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 64)),
            const SizedBox(height: AppConstants.spacing24),
            Text(
              'Définis tes 3 priorités du jour',
              style: AppTextStyles.headingSmall(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'La méthode MIT : identifie ce qui compte vraiment aujourd\'hui et avance pas à pas.',
              style: AppTextStyles.bodyMedium(color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
