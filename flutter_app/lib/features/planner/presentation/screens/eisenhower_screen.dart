import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../providers/eisenhower_provider.dart';

// ── Onglet Matrice d'Eisenhower ───────────────────────────────
class EisenhowerTab extends ConsumerWidget {
  const EisenhowerTab({super.key});

  // Couleur de fond par quadrant
  static Color _quadrantColor(EisenhowerQuadrant q) {
    switch (q) {
      case EisenhowerQuadrant.doNow:    return AppColors.error;
      case EisenhowerQuadrant.schedule: return AppColors.primary;
      case EisenhowerQuadrant.delegate: return AppColors.warning;
      case EisenhowerQuadrant.eliminate:return AppColors.grey400;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks  = ref.watch(eisenhowerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ── En-tête explicatif ────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacing12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha:0.08),
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusMedium),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha:0.2)),
            ),
            child: Row(
              children: [
                const Text('🧭', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Structure tes projets à moyen terme — classe chaque tâche selon son urgence et son importance.',
                    style: AppTextStyles.bodySmall(
                      color: isDark
                          ? AppColors.textDark
                          : AppColors.textLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Matrice 2×2 ──────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              children: [
                // Axes légendes (horizontal)
                Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: Center(
                        child: Text(
                          '⏰ URGENT',
                          style:
                              AppTextStyles.caption(color: AppColors.error),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'PAS URGENT',
                          style: AppTextStyles.caption(
                              color: AppColors.grey400),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Row(
                    children: [
                      // Axe vertical légende
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _VerticalLabel(
                              label: '⭐ IMPORTANT',
                              color: AppColors.primary),
                          _VerticalLabel(
                              label: 'PAS IMPORTANT',
                              color: AppColors.grey400),
                        ],
                      ),
                      const SizedBox(width: 4),
                      // 4 quadrants
                      Expanded(
                        child: Column(
                          children: [
                            // Ligne 1 : Q1 + Q2
                            Expanded(
                              child: Row(
                                children: [
                                  _QuadrantCard(
                                    quadrant: EisenhowerQuadrant.doNow,
                                    tasks: tasks
                                        .where((t) =>
                                            t.quadrant ==
                                            EisenhowerQuadrant.doNow)
                                        .toList(),
                                    color: _quadrantColor(
                                        EisenhowerQuadrant.doNow),
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 8),
                                  _QuadrantCard(
                                    quadrant: EisenhowerQuadrant.schedule,
                                    tasks: tasks
                                        .where((t) =>
                                            t.quadrant ==
                                            EisenhowerQuadrant.schedule)
                                        .toList(),
                                    color: _quadrantColor(
                                        EisenhowerQuadrant.schedule),
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Ligne 2 : Q3 + Q4
                            Expanded(
                              child: Row(
                                children: [
                                  _QuadrantCard(
                                    quadrant: EisenhowerQuadrant.delegate,
                                    tasks: tasks
                                        .where((t) =>
                                            t.quadrant ==
                                            EisenhowerQuadrant.delegate)
                                        .toList(),
                                    color: _quadrantColor(
                                        EisenhowerQuadrant.delegate),
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 8),
                                  _QuadrantCard(
                                    quadrant:
                                        EisenhowerQuadrant.eliminate,
                                    tasks: tasks
                                        .where((t) =>
                                            t.quadrant ==
                                            EisenhowerQuadrant.eliminate)
                                        .toList(),
                                    color: _quadrantColor(
                                        EisenhowerQuadrant.eliminate),
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacing16),
      ],
    );
  }
}

// ── Carte d'un quadrant ────────────────────────────────────────
class _QuadrantCard extends ConsumerWidget {
  final EisenhowerQuadrant quadrant;
  final List<EisenhowerTask> tasks;
  final Color color;
  final bool isDark;

  const _QuadrantCard({
    required this.quadrant,
    required this.tasks,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _showAddSheet(context, ref),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha:isDark ? 0.1 : 0.07),
            border: Border.all(color: color.withValues(alpha:0.3)),
            borderRadius:
                BorderRadius.circular(AppConstants.radiusLarge),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête du quadrant
              Row(
                children: [
                  Text(quadrant.emoji,
                      style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      quadrant.title,
                      style: AppTextStyles.caption(color: color)
                          .copyWith(fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(height: 10),

              // Liste des tâches du quadrant
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Text(
                          '+ Ajouter',
                          style: AppTextStyles.caption(
                              color: color.withValues(alpha:0.6)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (ctx, i) => _EisenhowerTaskTile(
                          task: tasks[i],
                          color: color,
                          isDark: isDark,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre modal
            Row(
              children: [
                Text(quadrant.emoji,
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(quadrant.title,
                          style: AppTextStyles.headingMedium()),
                      Text(
                        quadrant.subtitle,
                        style: AppTextStyles.caption(color: color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),

            // Champ texte
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Quelle tâche tu veux placer ici ?',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: color),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMedium),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacing24),

            // Bouton valider
            ElevatedButton(
              onPressed: () {
                if (ctrl.text.trim().isEmpty) return;
                ref.read(eisenhowerProvider.notifier).addTask(
                      title: ctrl.text.trim(),
                      quadrant: quadrant,
                    );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: color),
              child: const Text('Ajouter dans ce quadrant'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tuile d'une tâche Eisenhower ──────────────────────────────
class _EisenhowerTaskTile extends ConsumerWidget {
  final EisenhowerTask task;
  final Color color;
  final bool isDark;

  const _EisenhowerTaskTile({
    required this.task,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha:0.15),
          borderRadius:
              BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: const Padding(
          padding: EdgeInsets.only(right: 8),
          child: Icon(Icons.delete_rounded,
              color: AppColors.error, size: 16),
        ),
      ),
      onDismissed: (_) =>
          ref.read(eisenhowerProvider.notifier).deleteTask(task.id),
      child: GestureDetector(
        onTap: () =>
            ref.read(eisenhowerProvider.notifier).toggleDone(task.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              AnimatedContainer(
                duration: AppConstants.animFast,
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isDone ? color : Colors.transparent,
                  border: Border.all(color: color, width: 1.5),
                ),
                child: task.isDone
                    ? Icon(Icons.check_rounded,
                        color: Colors.white, size: 10)
                    : null,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  task.title,
                  style: AppTextStyles.caption(
                    color: task.isDone
                        ? AppColors.grey400
                        : isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
                  ).copyWith(
                    decoration: task.isDone
                        ? TextDecoration.lineThrough
                        : null,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Label axe vertical ─────────────────────────────────────────
class _VerticalLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _VerticalLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 3,
      child: Text(
        label,
        style: AppTextStyles.caption(color: color)
            .copyWith(fontSize: 9),
        textAlign: TextAlign.center,
      ),
    );
  }
}
