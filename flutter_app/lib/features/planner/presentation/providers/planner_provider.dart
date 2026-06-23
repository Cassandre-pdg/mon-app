import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/planner_repository.dart';
import '../../data/planner_model.dart';
import '../../data/kanban_model.dart';
import 'kanban_provider.dart';

final plannerRepositoryProvider = Provider<PlannerRepository>((ref) {
  return PlannerRepository(Supabase.instance.client);
});

final plannerProvider =
    AsyncNotifierProvider<PlannerNotifier, List<PlannerTask>>(PlannerNotifier.new);

class PlannerNotifier extends AsyncNotifier<List<PlannerTask>> {
  @override
  Future<List<PlannerTask>> build() async {
    return ref.watch(plannerRepositoryProvider).getTodayTasks();
  }

  Future<void> addTask({
    required String title,
    required int priority,
    String? projectId,
    String? kanbanTaskId,
  }) async {
    final repo = ref.read(plannerRepositoryProvider);
    final newTask = await repo.createTask(
      title: title,
      priority: priority,
      projectId: projectId,
      kanbanTaskId: kanbanTaskId,
    );
    state = AsyncData([...?state.value, newTask]
      ..sort((a, b) => a.priority.compareTo(b.priority)));
  }

  Future<void> completeTask(String id) async {
    final repo = ref.read(plannerRepositoryProvider);
    // Récupère la tâche avant de la compléter pour accéder à kanbanTaskId
    final task = (state.value ?? []).firstWhere((t) => t.id == id);
    final updated = await repo.completeTask(id);
    state = AsyncData(
        (state.value ?? []).map((t) => t.id == id ? updated : t).toList());

    // Coche automatiquement la tâche Kanban liée si présente
    if (task.kanbanTaskId != null) {
      try {
        await ref
            .read(kanbanRepositoryProvider)
            .moveTask(task.kanbanTaskId!, KanbanStatus.done);
        // Rafraîchit le kanban pour que l'UI reflète le changement
        ref.invalidate(kanbanProvider);
      } catch (_) {
        // Fail silencieux — la priorité est cochée, le kanban sera sync au prochain chargement
      }
    }
  }

  Future<void> editTask(
    String id, {
    required String title,
    required int priority,
    String? projectId,
    String? kanbanTaskId,
    bool clearProject = false,
    bool clearKanbanTask = false,
  }) async {
    final updated = await ref.read(plannerRepositoryProvider).updateTask(
          id,
          title: title,
          priority: priority,
          projectId: projectId,
          kanbanTaskId: kanbanTaskId,
          clearProject: clearProject,
          clearKanbanTask: clearKanbanTask,
        );
    final list = (state.value ?? []).map((t) => t.id == id ? updated : t).toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
    state = AsyncData(list);
  }

  Future<void> deleteTask(String id) async {
    await ref.read(plannerRepositoryProvider).deleteTask(id);
    state = AsyncData(state.value?.where((t) => t.id != id).toList() ?? []);
  }
}
