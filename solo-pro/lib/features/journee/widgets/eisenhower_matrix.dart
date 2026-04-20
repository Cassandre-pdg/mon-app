import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/task_model.dart';

class EisenhowerMatrix extends StatefulWidget {
  const EisenhowerMatrix({super.key});

  @override
  State<EisenhowerMatrix> createState() => _EisenhowerMatrixState();
}

class _EisenhowerMatrixState extends State<EisenhowerMatrix> {
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = List.from(mockTasks);
  }

  List<Task> _tasksFor(EisenhowerQuadrant q) =>
      _tasks.where((t) => t.quadrant == q).toList();

  List<Task> get _unclassified =>
      _tasks.where((t) => t.quadrant == null).toList();

  void _setQuadrant(Task task, EisenhowerQuadrant q) {
    setState(() => task.quadrant = q);
  }

  void _showAddTask(EisenhowerQuadrant quadrant) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.textLight,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(quadrant.emoji,
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Text('Ajouter dans "${quadrant.title}"',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Nouvelle tâche...',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final label = ctrl.text.trim();
                    if (label.isEmpty) return;
                    setState(() {
                      _tasks.add(Task(
                        id: DateTime.now()
                            .millisecondsSinceEpoch
                            .toString(),
                        label: label,
                        quadrant: quadrant,
                      ));
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Ajouter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // En-tête axes
          Row(
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _AxisLabel('URGENT', true),
                    _AxisLabel('PAS URGENT', true),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label axe vertical
              SizedBox(
                width: 20,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _AxisLabel('IMPORTANT', false),
                      _AxisLabel('PAS IMPORTANT', false),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Grille 2x2
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _QuadrantCard(
                            quadrant: EisenhowerQuadrant.urgentImportant,
                            tasks: _tasksFor(EisenhowerQuadrant.urgentImportant),
                            onAdd: () => _showAddTask(EisenhowerQuadrant.urgentImportant),
                            onToggle: (t) => setState(() => t.done = !t.done),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _QuadrantCard(
                            quadrant: EisenhowerQuadrant.notUrgentImportant,
                            tasks: _tasksFor(EisenhowerQuadrant.notUrgentImportant),
                            onAdd: () => _showAddTask(EisenhowerQuadrant.notUrgentImportant),
                            onToggle: (t) => setState(() => t.done = !t.done),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _QuadrantCard(
                            quadrant: EisenhowerQuadrant.urgentNotImportant,
                            tasks: _tasksFor(EisenhowerQuadrant.urgentNotImportant),
                            onAdd: () => _showAddTask(EisenhowerQuadrant.urgentNotImportant),
                            onToggle: (t) => setState(() => t.done = !t.done),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _QuadrantCard(
                            quadrant: EisenhowerQuadrant.notUrgentNotImportant,
                            tasks: _tasksFor(EisenhowerQuadrant.notUrgentNotImportant),
                            onAdd: () => _showAddTask(EisenhowerQuadrant.notUrgentNotImportant),
                            onToggle: (t) => setState(() => t.done = !t.done),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Tâches non classées
          if (_unclassified.isNotEmpty) ...[
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('À classer (${_unclassified.length})',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      fontSize: 13)),
            ),
            const SizedBox(height: 8),
            ..._unclassified.map((t) => _UnclassifiedTile(
                  task: t,
                  onQuadrant: (q) => _setQuadrant(t, q),
                )),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AxisLabel extends StatelessWidget {
  final String text;
  final bool horizontal;

  const _AxisLabel(this.text, this.horizontal);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        color: AppColors.textLight,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _QuadrantCard extends StatelessWidget {
  final EisenhowerQuadrant quadrant;
  final List<Task> tasks;
  final VoidCallback onAdd;
  final ValueChanged<Task> onToggle;

  const _QuadrantCard({
    required this.quadrant,
    required this.tasks,
    required this.onAdd,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 130),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: quadrant.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: quadrant.color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(quadrant.emoji,
                  style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  quadrant.title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: quadrant.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...tasks.map((t) => _TaskChip(task: t, onToggle: onToggle)),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.add,
                      size: 13,
                      color: quadrant.color.withValues(alpha: 0.6)),
                  const SizedBox(width: 3),
                  Text('Ajouter',
                      style: TextStyle(
                          fontSize: 10,
                          color: quadrant.color.withValues(alpha: 0.6))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskChip extends StatelessWidget {
  final Task task;
  final ValueChanged<Task> onToggle;

  const _TaskChip({required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: task.done
              ? Colors.grey.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              task.done ? Icons.check_circle : Icons.circle_outlined,
              size: 12,
              color: task.done
                  ? AppColors.accentGreen
                  : AppColors.textLight,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                task.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: task.done
                      ? AppColors.textLight
                      : AppColors.textPrimary,
                  decoration:
                      task.done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnclassifiedTile extends StatelessWidget {
  final Task task;
  final ValueChanged<EisenhowerQuadrant> onQuadrant;

  const _UnclassifiedTile({required this.task, required this.onQuadrant});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textLight.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.label,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: EisenhowerQuadrant.values.map((q) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => onQuadrant(q),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: q.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      q.emoji,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
