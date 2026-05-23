import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/services/celebration_service.dart';
import '../providers/flash_provider.dart';
import '../providers/kanban_provider.dart';

// ── Onglet Flash ⚡ ───────────────────────────────────────────
class FlashTab extends ConsumerWidget {
  const FlashTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashAsync = ref.watch(flashProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return flashAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Impossible de charger tes tâches Flash.',
          style: AppTextStyles.bodyMedium(color: AppColors.error),
        ),
      ),
      data: (tasks) {
        final pending = tasks.where((t) => !t.isDone).toList();
        final done    = tasks.where((t) => t.isDone).toList();

        final pendingByCategory = <String, List<FlashTask>>{};
        for (final t in pending) {
          pendingByCategory.putIfAbsent(t.category, () => []).add(t);
        }

        return Column(
          children: [
            // ── En-tête + bouton lancer bloc ─────────────────
            _FlashHeader(
              pendingCount: pending.length,
              onLaunchBloc: pending.isEmpty
                  ? null
                  : () => _showBlocMode(context, ref, pending),
              isDark: isDark,
            ),

            // ── Liste des tâches en attente par catégorie ────
            Expanded(
              child: pending.isEmpty && done.isEmpty
                  ? _FlashEmptyState()
                  : CustomScrollView(
                      slivers: [
                        if (pending.isEmpty)
                          SliverToBoxAdapter(
                            child: _AllDoneState(doneCount: done.length),
                          ),

                        // Tâches en attente groupées par catégorie
                        ..._buildCategorySliver(
                          context, ref,
                          categoryMap: pendingByCategory,
                          isDark: isDark,
                        ),

                        // Section "Terminées"
                        if (done.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Terminées ✅  ${done.length}',
                                    style: AppTextStyles.labelMedium(
                                        color: AppColors.grey400),
                                  ),
                                  GestureDetector(
                                    onTap: () => ref
                                        .read(flashProvider.notifier)
                                        .clearDone(),
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
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => _FlashTaskTile(
                                task: done[i], isDark: isDark,
                              ),
                              childCount: done.length,
                            ),
                          ),
                        ],

                        const SliverToBoxAdapter(
                            child: SizedBox(height: AppConstants.spacing24)),
                      ],
                    ),
            ),

            // ── Bouton ajouter ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: ElevatedButton.icon(
                onPressed: () => _showAddFlashSheet(context, ref),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Ajouter une tâche Flash'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.black87,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildCategorySliver(
    BuildContext context,
    WidgetRef ref, {
    required Map<String, List<FlashTask>> categoryMap,
    required bool isDark,
  }) {
    final result = <Widget>[];
    for (final entry in categoryMap.entries) {
      final catInfo = flashCategories.firstWhere(
        (c) => c.key == entry.key,
        orElse: () =>
            const FlashCategory(key: 'autre', emoji: '🔧', label: 'Divers'),
      );
      result.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(catInfo.emoji, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
                Text(catInfo.label,
                    style: AppTextStyles.labelMedium(
                        color: isDark ? AppColors.textDark : AppColors.textLight)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${entry.value.length}',
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
            (ctx, i) =>
                _FlashTaskTile(task: entry.value[i], isDark: isDark),
            childCount: entry.value.length,
          ),
        ),
      );
    }
    return result;
  }

  void _showBlocMode(
      BuildContext context, WidgetRef ref, List<FlashTask> pending) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => _FlashBlocMode(tasks: pending),
    );
  }

  void _showAddFlashSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => _AddFlashSheet(),
    );
  }
}

// ── En-tête avec CTA bloc ─────────────────────────────────────
class _FlashHeader extends StatelessWidget {
  final int pendingCount;
  final VoidCallback? onLaunchBloc;
  final bool isDark;

  const _FlashHeader({
    required this.pendingCount,
    required this.onLaunchBloc,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'File Flash',
            style: AppTextStyles.headingSmall(
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Accumule tes micro-tâches, puis expédie-les en bloc.',
            style: AppTextStyles.bodySmall(color: AppColors.grey400),
          ),
          if (onLaunchBloc != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onLaunchBloc,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.warning.withValues(alpha: 0.85),
                      AppColors.warning.withValues(alpha: 0.60),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.warning.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lancer un bloc Flash',
                            style: AppTextStyles.bodyLarge(
                              color: Colors.black87,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '$pendingCount tâche${pendingCount > 1 ? 's' : ''} à expédier',
                            style: AppTextStyles.bodySmall(
                                color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.black54),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Mode bloc d'exécution ─────────────────────────────────────
class _FlashBlocMode extends ConsumerStatefulWidget {
  final List<FlashTask> tasks;
  const _FlashBlocMode({required this.tasks});

  @override
  ConsumerState<_FlashBlocMode> createState() => _FlashBlocModeState();
}

class _FlashBlocModeState extends ConsumerState<_FlashBlocMode> {
  late List<FlashTask> _remaining;
  int _doneCount = 0;
  late Timer _elapsedTimer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remaining = List.from(widget.tasks);
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    _elapsedTimer.cancel();
    super.dispose();
  }

  String get _elapsedDisplay {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _markDone() async {
    final task = _remaining.first;
    final isLastTask = _remaining.length == 1;
    await ref.read(flashProvider.notifier).toggleDone(task.id);
    setState(() {
      _remaining.removeAt(0);
      _doneCount++;
    });
    ref.read(celebrationProvider.notifier).celebrate(
      isLastTask
          ? CelebrationEvent.flashBlocCompleted
          : CelebrationEvent.flashTaskDone,
    );
  }

  void _skip() {
    setState(() {
      final task = _remaining.removeAt(0);
      _remaining.add(task);
    });
  }

  Future<void> _delete() async {
    final task = _remaining.first;
    await ref.read(flashProvider.notifier).deleteTask(task.id);
    setState(() => _remaining.removeAt(0));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = widget.tasks.length;
    final progress = total == 0 ? 1.0 : _doneCount / total;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey400.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Header ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bloc Flash ⚡',
                      style: AppTextStyles.headingMedium(
                        color: isDark ? AppColors.textDark : AppColors.textLight,
                      ),
                    ),
                    Text(
                      '$_doneCount/$total · $_elapsedDisplay',
                      style: AppTextStyles.caption(color: AppColors.grey400),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.grey400.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 18, color: AppColors.grey400),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Barre de progression ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.warning.withValues(alpha: 0.15),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.warning),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Contenu : tâche courante ou bilan ──────────────
          Expanded(
            child: _remaining.isEmpty
                ? _BlocBilan(doneCount: _doneCount, elapsedSeconds: _elapsedSeconds)
                : _BlocTaskCard(
                    task: _remaining.first,
                    remaining: _remaining.length,
                    isDark: isDark,
                    onDone: _markDone,
                    onSkip: _remaining.length > 1 ? _skip : null,
                    onDelete: _delete,
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Carte de tâche en mode bloc ───────────────────────────────
class _BlocTaskCard extends StatelessWidget {
  final FlashTask task;
  final int remaining;
  final bool isDark;
  final VoidCallback onDone;
  final VoidCallback? onSkip;
  final VoidCallback onDelete;

  const _BlocTaskCard({
    required this.task,
    required this.remaining,
    required this.isDark,
    required this.onDone,
    required this.onSkip,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final catInfo = flashCategories.firstWhere(
      (c) => c.key == task.category,
      orElse: () =>
          const FlashCategory(key: 'autre', emoji: '🔧', label: 'Divers'),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tâche restante
          Text(
            '$remaining restante${remaining > 1 ? 's' : ''}',
            style: AppTextStyles.caption(color: AppColors.grey400),
          ),
          const SizedBox(height: 20),

          // Card principale
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.spacing24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(catInfo.emoji,
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      catInfo.label,
                      style: AppTextStyles.caption(color: AppColors.warning),
                    ),
                    if (task.projectName != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              AppColors.primary.withValues(alpha: 0.12),
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
                const SizedBox(height: 16),
                Text(
                  task.title,
                  style: AppTextStyles.headingMedium(
                    color:
                        isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '⏱ ${task.estimatedMinutes} min',
                  style: AppTextStyles.caption(color: AppColors.grey400),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Actions
          Row(
            children: [
              // Supprimer
              _BlocAction(
                emoji: '🗑',
                label: 'Supprimer',
                color: AppColors.error,
                onTap: onDelete,
              ),
              const SizedBox(width: 12),

              // Passer
              if (onSkip != null) ...[
                _BlocAction(
                  emoji: '→',
                  label: 'Passer',
                  color: AppColors.grey400,
                  onTap: onSkip!,
                ),
                const SizedBox(width: 12),
              ],

              // Fait !
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: onDone,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_rounded,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'C\'est fait !',
                          style: AppTextStyles.bodyLarge(
                              color: Colors.white)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BlocAction extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BlocAction({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption(color: color)),
          ],
        ),
      ),
    );
  }
}

// ── Bilan fin de bloc ─────────────────────────────────────────
class _BlocBilan extends StatelessWidget {
  final int doneCount;
  final int elapsedSeconds;

  const _BlocBilan({required this.doneCount, required this.elapsedSeconds});

  @override
  Widget build(BuildContext context) {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    final timeStr = minutes > 0
        ? '${minutes}min ${seconds}s'
        : '${seconds}s';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 20),
            Text(
              'Bloc Flash terminé !',
              style: AppTextStyles.headingLarge(color: AppColors.warning),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '$doneCount tâche${doneCount > 1 ? 's' : ''} expédiée${doneCount > 1 ? 's' : ''}\nen $timeStr',
              style: AppTextStyles.bodyLarge(color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.black87,
              ),
              child: const Text('Super, merci !'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tuile tâche Flash ─────────────────────────────────────────
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
            color: AppColors.error.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          ),
          child: const Icon(Icons.delete_rounded, color: AppColors.error),
        ),
        onDismissed: (_) =>
            ref.read(flashProvider.notifier).deleteTask(task.id),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacing12),
          decoration: BoxDecoration(
            color: task.isDone
                ? AppColors.success.withValues(alpha: 0.06)
                : isDark
                    ? AppColors.surfaceDark
                    : AppColors.surfaceLight,
            border: Border.all(
              color: task.isDone
                  ? AppColors.success.withValues(alpha: 0.3)
                  : AppColors.warning.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (!task.isDone) {
                    ref
                        .read(celebrationProvider.notifier)
                        .celebrate(CelebrationEvent.flashTaskDone);
                  }
                  ref.read(flashProvider.notifier).toggleDone(task.id);
                },
                child: AnimatedContainer(
                  duration: AppConstants.animFast,
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isDone ? AppColors.success : Colors.transparent,
                    border: Border.all(
                      color: task.isDone ? AppColors.success : AppColors.warning,
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
                    if (task.projectName != null)
                      Text(
                        task.projectName!,
                        style: AppTextStyles.caption(
                            color: AppColors.primaryLight),
                      ),
                  ],
                ),
              ),
              if (!task.isDone)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                  child: Text(
                    '⚡ ${task.estimatedMinutes}min',
                    style: AppTextStyles.caption(color: AppColors.warning),
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
              'Ta file Flash est vide',
              style: AppTextStyles.headingSmall(color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Note ici tout ce qui prend moins de 5 min.\nQuand tu as un créneau, lance un bloc Flash !',
              style: AppTextStyles.bodyMedium(color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AllDoneState extends StatelessWidget {
  final int doneCount;
  const _AllDoneState({required this.doneCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacing32),
      child: Column(
        children: [
          const Text('✅', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'File Flash vide !',
            style: AppTextStyles.headingSmall(color: AppColors.success),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '$doneCount tâche${doneCount > 1 ? 's' : ''} expédiée${doneCount > 1 ? 's' : ''}. Bien joué !',
            style: AppTextStyles.bodyMedium(color: AppColors.grey400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Sheet d'ajout d'une tâche Flash ──────────────────────────
class _AddFlashSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddFlashSheet> createState() => _AddFlashSheetState();
}

class _AddFlashSheetState extends ConsumerState<_AddFlashSheet> {
  final _ctrl = TextEditingController();
  String _selectedCategory = 'email';
  int _selectedMinutes = 2;
  String? _selectedProjectId;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectsAsync = ref.watch(kanbanProvider);
    final activeProjects = projectsAsync.value
            ?.where((p) => p.isActive)
            .toList() ??
        [];

    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey400.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Titre
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('⚡', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Nouvelle tâche Flash',
                    style: AppTextStyles.headingMedium(
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Champ texte
              TextField(
                controller: _ctrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Quelle micro-tâche tu veux expédier ?',
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Catégorie
              Text('Catégorie',
                  style: AppTextStyles.labelMedium(color: AppColors.grey400)),
              const SizedBox(height: 8),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.4,
                physics: const NeverScrollableScrollPhysics(),
                children: flashCategories.map((cat) {
                  final isSel = _selectedCategory == cat.key;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategory = cat.key),
                    child: AnimatedContainer(
                      duration: AppConstants.animFast,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppColors.warning.withValues(alpha: 0.18)
                            : (isDark
                                ? AppColors.surfaceDark
                                : AppColors.grey100),
                        border: Border.all(
                          color: isSel
                              ? AppColors.warning
                              : AppColors.grey400.withValues(alpha: 0.2),
                          width: isSel ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(cat.emoji,
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              cat.label,
                              style: AppTextStyles.caption(
                                color: isSel
                                    ? AppColors.warning
                                    : AppColors.grey400,
                              ).copyWith(
                                fontWeight: isSel
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Durée
              Text('Durée estimée',
                  style: AppTextStyles.labelMedium(color: AppColors.grey400)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [1, 2, 3, 5].map((min) {
                    final isSel = _selectedMinutes == min;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedMinutes = min),
                        child: AnimatedContainer(
                          duration: AppConstants.animFast,
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppColors.warning.withValues(alpha: 0.18)
                                : Colors.transparent,
                            border: isSel
                                ? Border.all(
                                    color: AppColors.warning
                                        .withValues(alpha: 0.4),
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${min}min',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.labelMedium(
                              color: isSel
                                  ? AppColors.warning
                                  : AppColors.grey400,
                            ).copyWith(
                              fontWeight: isSel
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Lien projet (optionnel)
              if (activeProjects.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacing16),
                Text('Projet lié (optionnel)',
                    style:
                        AppTextStyles.labelMedium(color: AppColors.grey400)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ProjectPill(
                        label: 'Aucun',
                        isSelected: _selectedProjectId == null,
                        onTap: () =>
                            setState(() => _selectedProjectId = null),
                      ),
                      const SizedBox(width: 8),
                      ...activeProjects.map((p) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _ProjectPill(
                              label: p.name,
                              isSelected: _selectedProjectId == p.id,
                              onTap: () => setState(
                                  () => _selectedProjectId = p.id),
                            ),
                          )),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppConstants.spacing24),

              ElevatedButton.icon(
                onPressed: () {
                  if (_ctrl.text.trim().isEmpty) return;
                  ref.read(flashProvider.notifier).addTask(
                        title: _ctrl.text.trim(),
                        category: _selectedCategory,
                        minutes: _selectedMinutes,
                        projectId: _selectedProjectId,
                      );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.bolt_rounded),
                label: const Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProjectPill({
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
            color:
                isSelected ? AppColors.primaryLight : AppColors.grey400,
          ).copyWith(
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
