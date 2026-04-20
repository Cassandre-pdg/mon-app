import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_routes.dart';
import '../models/task_model.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = List.from(mockTasks);
  }

  int get _doneTasks => _tasks.where((t) => t.done).length;
  double get _progress => _tasks.isEmpty ? 0 : _doneTasks / _tasks.length;

  void _toggleTask(int index) {
    HapticFeedback.lightImpact();
    setState(() => _tasks[index].done = !_tasks[index].done);
  }

  void _deleteTask(int index) {
    setState(() => _tasks.removeAt(index));
  }

  void _showAddTask() {
    final ctrl = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Nouvelle tâche',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Que dois-tu accomplir ?',
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Priorité',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: TaskPriority.values.map((p) {
                    final isSelected = selectedPriority == p;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setModal(() => selectedPriority = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? p.color.withValues(alpha: 0.15)
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? Border.all(color: p.color, width: 2)
                                : null,
                          ),
                          child: Column(
                            children: [
                              Text(p.emoji,
                                  style: const TextStyle(fontSize: 18)),
                              const SizedBox(height: 2),
                              Text(p.label,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? p.color
                                          : AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final label = ctrl.text.trim();
                      if (label.isEmpty) return;
                      setState(() {
                        _tasks.add(Task(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          label: label,
                          priority: selectedPriority,
                        ));
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Ajouter la tâche',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingTasks = _tasks.where((t) => !t.done).toList();
    final doneTasks = _tasks.where((t) => t.done).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: _tasks.isEmpty
                  ? _buildEmptyState()
                  : ReorderableListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final task = _tasks.removeAt(oldIndex);
                          _tasks.insert(newIndex, task);
                        });
                      },
                      children: [
                        if (pendingTasks.isNotEmpty) ...[
                          _sectionLabel('À faire', pendingTasks.length,
                              key: const ValueKey('section-pending')),
                          ...pendingTasks.map((t) => _buildTaskTile(
                              t, _tasks.indexOf(t),
                              key: ValueKey(t.id))),
                        ],
                        if (doneTasks.isNotEmpty) ...[
                          _sectionLabel('Terminé ✅', doneTasks.length,
                              key: const ValueKey('section-done')),
                          ...doneTasks.map((t) => _buildTaskTile(
                              t, _tasks.indexOf(t),
                              key: ValueKey('done-${t.id}'))),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tasks.length < 10
          ? FloatingActionButton.extended(
              onPressed: _showAddTask,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Ajouter',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ma journée',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              Text('$_doneTasks/${_tasks.length} tâches accomplies',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
          // Bouton outil focus
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.focusTool),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Text('🎯', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 6),
                  Text('Focus',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Barre de progression ─────────────────────────────────────────────────

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                _progress == 1.0
                    ? AppColors.accentGreen
                    : AppColors.primary,
              ),
            ),
          ),
          if (_progress == 1.0 && _tasks.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('🎉 Toutes les tâches terminées !',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentGreen)),
          ],
        ],
      ),
    );
  }

  // ─── Label section ────────────────────────────────────────────────────────

  Widget _sectionLabel(String title, int count, {required Key key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary)),
          const SizedBox(width: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$count',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  // ─── Tile tâche ───────────────────────────────────────────────────────────

  Widget _buildTaskTile(Task task, int index, {required Key key}) {
    return Dismissible(
      key: Key('dismissible-${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline,
            color: AppColors.accent, size: 22),
      ),
      onDismissed: (_) => _deleteTask(index),
      child: GestureDetector(
        key: key,
        onTap: () => _toggleTask(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: task.done
                ? AppColors.accentGreen.withValues(alpha: 0.06)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: task.done
                  ? AppColors.accentGreen.withValues(alpha: 0.25)
                  : AppColors.textLight.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: task.done
                      ? AppColors.accentGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: task.done
                        ? AppColors.accentGreen
                        : AppColors.textLight,
                    width: 2,
                  ),
                ),
                child: task.done
                    ? const Icon(Icons.check,
                        size: 13, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              // Point priorité
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: task.priority.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  task.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: task.done
                        ? AppColors.textLight
                        : AppColors.textPrimary,
                    decoration: task.done
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
              // Handle réordonner
              const Icon(Icons.drag_handle,
                  size: 18, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }

  // ─── État vide ────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📋', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text('Aucune tâche pour aujourd\'hui',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text(
              'Ajoute tes 3 priorités du jour.\nConcentre-toi sur l\'essentiel.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddTask,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une tâche'),
            ),
          ],
        ),
      ),
    );
  }
}
