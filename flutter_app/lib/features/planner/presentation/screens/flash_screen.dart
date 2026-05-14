import 'dart:ui';
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
        // ── Bandeau explicatif glass ────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.28),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Si ça prend moins de 5 min, fais-le maintenant !',
                        style: AppTextStyles.bodySmall(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Liste tâches ────────────────────────────────────
        Expanded(
          child: !hasTasks
              ? const _FlashEmptyState()
              : CustomScrollView(
                  slivers: [
                    ..._buildCategorySliver(
                      context, ref,
                      categoryMap: pendingByCategory,
                      isDone: false,
                    ),

                    if (hasDone) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 22, 16, 8),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Terminées',
                                style: AppTextStyles.labelMedium(
                                  color: Colors.white.withValues(alpha: 0.40),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => ref
                                    .read(flashProvider.notifier)
                                    .clearDone(),
                                child: Text(
                                  'Effacer',
                                  style: AppTextStyles.caption(
                                    color: AppColors.error
                                        .withValues(alpha: 0.70),
                                  ),
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
                      ),
                    ],

                    const SliverToBoxAdapter(
                        child: SizedBox(height: AppConstants.spacing24)),
                  ],
                ),
        ),

        // ── Bouton ajouter ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: GestureDetector(
            onTap: () => _showAddFlashSheet(context, ref),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.warning, Color(0xFFFFD060)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warning.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Ajouter une tâche Flash',
                    style: AppTextStyles.labelMedium(color: Colors.white)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCategorySliver(
    BuildContext context,
    WidgetRef ref, {
    required Map<String, List<FlashTask>> categoryMap,
    required bool isDone,
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
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Text(catInfo.emoji,
                    style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
                Text(
                  catInfo.label,
                  style: AppTextStyles.labelMedium(
                    color: isDone
                        ? Colors.white.withValues(alpha: 0.30)
                        : Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: AppTextStyles.caption(
                        color: AppColors.warning),
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
            (ctx, i) => _FlashTaskTile(task: tasks[i]),
            childCount: tasks.length,
          ),
        ),
      );
    }

    return result;
  }

  void _showAddFlashSheet(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    String selectedCategory = 'email';
    int selectedMinutes = 2;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.92),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: StatefulBuilder(
              builder: (ctx, setState) => Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        const Text('⚡', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text('Nouvelle tâche Flash',
                            style: AppTextStyles.headingMedium(
                                color: AppColors.textDark)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Champ texte
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10)),
                      ),
                      child: TextField(
                        controller: ctrl,
                        autofocus: true,
                        textCapitalization: TextCapitalization.sentences,
                        style: AppTextStyles.bodyMedium(
                            color: AppColors.textDark),
                        decoration: InputDecoration(
                          hintText:
                              'Quelle micro-tâche tu veux expédier ?',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.28),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Catégorie
                    Text('Catégorie',
                        style: AppTextStyles.labelMedium(
                          color: Colors.white.withValues(alpha: 0.55),
                        )),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: flashCategories.map((cat) {
                        final isSelected =
                            selectedCategory == cat.key;
                        return GestureDetector(
                          onTap: () => setState(
                              () => selectedCategory = cat.key),
                          child: AnimatedContainer(
                            duration: AppConstants.animFast,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.warning.withValues(alpha: 0.18)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.warning
                                    : Colors.white.withValues(alpha: 0.15),
                              ),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${cat.emoji} ${cat.label}',
                              style: AppTextStyles.bodySmall(
                                color: isSelected
                                    ? AppColors.warning
                                    : Colors.white.withValues(alpha: 0.45),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Durée
                    Text('Durée estimée',
                        style: AppTextStyles.labelMedium(
                          color: Colors.white.withValues(alpha: 0.55),
                        )),
                    const SizedBox(height: 8),
                    Row(
                      children: [1, 2, 3, 5].map((min) {
                        final isSelected = selectedMinutes == min;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                                () => selectedMinutes = min),
                            child: Container(
                              margin: EdgeInsets.only(
                                  right: min < 5 ? 8 : 0),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                        .withValues(alpha: 0.18)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryLight
                                      : Colors.white
                                          .withValues(alpha: 0.15),
                                ),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${min}min',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodySmall(
                                  color: isSelected
                                      ? AppColors.primaryPale
                                      : Colors.white
                                          .withValues(alpha: 0.40),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    GestureDetector(
                      onTap: () {
                        if (ctrl.text.trim().isEmpty) return;
                        ref.read(flashProvider.notifier).addTask(
                              title: ctrl.text.trim(),
                              category: selectedCategory,
                              minutes: selectedMinutes,
                            );
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.warning,
                              Color(0xFFFFD060)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.warning.withValues(alpha: 0.30),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.bolt_rounded,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Ajouter',
                              style: AppTextStyles.labelMedium(
                                      color: Colors.white)
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tuile d'une tâche Flash ───────────────────────────────────
class _FlashTaskTile extends ConsumerWidget {
  const _FlashTaskTile({required this.task});
  final FlashTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Dismissible(
        key: Key(task.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_rounded, color: AppColors.error),
        ),
        onDismissed: (_) =>
            ref.read(flashProvider.notifier).deleteTask(task.id),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: AppConstants.animFast,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: task.isDone
                    ? AppColors.success.withValues(alpha: 0.08)
                    : AppColors.surfaceDark.withValues(alpha: 0.60),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: task.isDone
                      ? AppColors.success.withValues(alpha: 0.25)
                      : AppColors.warning.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: () => ref
                        .read(flashProvider.notifier)
                        .toggleDone(task.id),
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
                              : AppColors.warning.withValues(alpha: 0.70),
                          width: 1.8,
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
                                ? Colors.white.withValues(alpha: 0.30)
                                : Colors.white.withValues(alpha: 0.85),
                          ).copyWith(
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        Text(
                          '${task.estimatedMinutes} min',
                          style: AppTextStyles.caption(
                            color: Colors.white.withValues(alpha: 0.28),
                          ),
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
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        '⚡ ${task.estimatedMinutes}min',
                        style: AppTextStyles.caption(
                            color: AppColors.warning),
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

// ── État vide ─────────────────────────────────────────────────
class _FlashEmptyState extends StatelessWidget {
  const _FlashEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚡', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              'Tes micro-tâches Flash arrivent ici',
              style: AppTextStyles.headingSmall(
                color: Colors.white.withValues(alpha: 0.50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Si ça prend moins de 5 min, note-le\net expédie-le maintenant 🚀',
              style: AppTextStyles.bodyMedium(
                color: Colors.white.withValues(alpha: 0.32),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Écran Flash autonome ──────────────────────────────────────
class FlashScreen extends StatelessWidget {
  const FlashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, AppColors.warning],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(
            'Notes Flash',
            style: AppTextStyles.headingMedium(color: Colors.white),
          ),
        ),
        centerTitle: false,
      ),
      body: const SafeArea(child: FlashTab()),
    );
  }
}
