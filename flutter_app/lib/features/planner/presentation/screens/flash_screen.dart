import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../providers/flash_provider.dart';

// ── Onglet Flash ⚡ — micro-tâches < 5 minutes ────────────────
class FlashTab extends ConsumerWidget {
  const FlashTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(flashProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Grouper par catégorie (uniquement tâches non faites + 1 si déjà faites)
    final pendingByCategory = <String, List<FlashTask>>{};
    final doneByCategory    = <String, List<FlashTask>>{};

    for (final t in tasks) {
      if (t.isDone) {
        doneByCategory.putIfAbsent(t.category, () => []).add(t);
      } else {
        pendingByCategory.putIfAbsent(t.category, () => []).add(t);
      }
    }

    final hasTasks = tasks.isNotEmpty;
    final hasDone  = tasks.any((t) => t.isDone);

    return Column(
      children: [
        // ── Bandeau explicatif ──────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacing12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              border: Border.all(color: AppColors.warning.withValues(alpha:0.3)),
            ),
            child: Row(
              children: [
                const Text('⚡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Si ça prend moins de 5 min — fais-le maintenant !',
                    style: AppTextStyles.bodySmall(
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Liste des tâches groupées ────────────────────────
        Expanded(
          child: !hasTasks
              ? _FlashEmptyState()
              : CustomScrollView(
                  slivers: [
                    // Tâches en attente, groupées par catégorie
                    ..._buildCategorySliver(
                      context, ref,
                      categoryMap: pendingByCategory,
                      isDone: false,
                      isDark: isDark,
                    ),

                    // Section "Terminées" (optionnel)
                    if (hasDone) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Terminées ✅',
                                style: AppTextStyles.labelMedium(
                                    color: AppColors.grey400),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    ref.read(flashProvider.notifier).clearDone(),
                                child: Text(
                                  'Effacer',
                                  style: AppTextStyles.caption(
                                      color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ..._buildCategorySliver(
                        context, ref,
                        categoryMap: doneByCategory,
                        isDone: true,
                        isDark: isDark,
                      ),
                    ],

                    const SliverToBoxAdapter(
                        child: SizedBox(height: AppConstants.spacing24)),
                  ],
                ),
        ),

        // ── Bouton ajouter ───────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: ElevatedButton.icon(
            onPressed: () => _showAddFlashSheet(context, ref),
            icon: const Icon(Icons.bolt_rounded),
            label: const Text('Ajouter une tâche Flash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
          ),
        ),
      ],
    );
  }

  // ── Construit les slivers par catégorie ────────────────────
  List<Widget> _buildCategorySliver(
    BuildContext context,
    WidgetRef ref, {
    required Map<String, List<FlashTask>> categoryMap,
    required bool isDone,
    required bool isDark,
  }) {
    final result = <Widget>[];

    for (final entry in categoryMap.entries) {
      final categoryKey = entry.key;
      final tasks       = entry.value;
      final catInfo     = flashCategories.firstWhere(
        (c) => c.key == categoryKey,
        orElse: () => const FlashCategory(
            key: 'autre', emoji: '🔧', label: 'Divers'),
      );

      result.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(catInfo.emoji,
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  catInfo.label,
                  style: AppTextStyles.labelMedium(
                    color: isDone
                        ? AppColors.grey400
                        : isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: AppTextStyles.caption(color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      result.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => _FlashTaskTile(
              task: tasks[i],
              isDark: isDark,
            ),
            childCount: tasks.length,
          ),
        ),
      );
    }

    return result;
  }

  // ── Modal d'ajout d'une micro-tâche ────────────────────────
  void _showAddFlashSheet(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    String selectedCategory = 'email';
    int selectedMinutes = 2;

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
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text('Nouvelle tâche Flash',
                      style: AppTextStyles.headingMedium()),
                ],
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Champ texte
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Quelle micro-tâche tu veux expédier ?',
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Catégorie
              Text('Catégorie', style: AppTextStyles.labelMedium()),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: flashCategories.map((cat) {
                  final isSelected = selectedCategory == cat.key;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => selectedCategory = cat.key),
                    child: AnimatedContainer(
                      duration: AppConstants.animFast,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.warning.withValues(alpha:0.15)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.warning
                              : AppColors.grey200,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMedium),
                      ),
                      child: Text(
                        '${cat.emoji} ${cat.label}',
                        style: AppTextStyles.bodySmall(
                          color: isSelected
                              ? AppColors.warning
                              : AppColors.grey400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Durée estimée
              Text('Durée estimée', style: AppTextStyles.labelMedium()),
              const SizedBox(height: 8),
              Row(
                children: [1, 2, 3, 5].map((min) {
                  final isSelected = selectedMinutes == min;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => selectedMinutes = min),
                      child: Container(
                        margin: EdgeInsets.only(
                            right: min < 5 ? 8 : 0),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha:0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.grey200,
                          ),
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusMedium),
                        ),
                        child: Text(
                          '${min}min',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.grey400,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.spacing24),

              // Bouton valider
              ElevatedButton.icon(
                onPressed: () {
                  if (ctrl.text.trim().isEmpty) return;
                  ref.read(flashProvider.notifier).addTask(
                        title: ctrl.text.trim(),
                        category: selectedCategory,
                        minutes: selectedMinutes,
                      );
                  Navigator.pop(ctx);
                },
                icon: const Icon(Icons.bolt_rounded),
                label: const Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tuile d'une tâche Flash ───────────────────────────────────
class _FlashTaskTile extends ConsumerWidget {
  final FlashTask task;
  final bool isDark;

  const _FlashTaskTile({required this.task, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Dismissible(
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
            ref.read(flashProvider.notifier).deleteTask(task.id),
        child: AnimatedContainer(
          duration: AppConstants.animFast,
          padding: const EdgeInsets.all(AppConstants.spacing12),
          decoration: BoxDecoration(
            color: task.isDone
                ? AppColors.success.withValues(alpha:0.06)
                : isDark
                    ? AppColors.surfaceDark
                    : AppColors.surfaceLight,
            border: Border.all(
              color: task.isDone
                  ? AppColors.success.withValues(alpha:0.3)
                  : AppColors.warning.withValues(alpha:0.2),
            ),
            borderRadius:
                BorderRadius.circular(AppConstants.radiusLarge),
          ),
          child: Row(
            children: [
              // Checkbox rond
              GestureDetector(
                onTap: () =>
                    ref.read(flashProvider.notifier).toggleDone(task.id),
                child: AnimatedContainer(
                  duration: AppConstants.animFast,
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isDone
                        ? AppColors.success
                        : Colors.transparent,
                    border: Border.all(
                      color: task.isDone
                          ? AppColors.success
                          : AppColors.warning,
                      width: 2,
                    ),
                  ),
                  child: task.isDone
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 16)
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // Titre + durée
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTextStyles.bodyMedium(
                        color: task.isDone
                            ? AppColors.grey400
                            : isDark
                                ? AppColors.textDark
                                : AppColors.textLight,
                      ).copyWith(
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    Text(
                      '${task.estimatedMinutes} min',
                      style: AppTextStyles.caption(
                          color: AppColors.grey400),
                    ),
                  ],
                ),
              ),

              if (!task.isDone)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha:0.12),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                  child: Text(
                    '⚡ ${task.estimatedMinutes}min',
                    style:
                        AppTextStyles.caption(color: AppColors.warning),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── État vide ─────────────────────────────────────────────────
class _FlashEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚡', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              'Tes micro-tâches Flash arrivent ici',
              style: AppTextStyles.headingSmall(
                  color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Si ça prend moins de 5 min, note-le\net expédie-le maintenant 🚀',
              style: AppTextStyles.bodyMedium(color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
