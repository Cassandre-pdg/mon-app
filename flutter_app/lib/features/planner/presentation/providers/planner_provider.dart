import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/planner_repository.dart';
import '../../data/planner_model.dart';

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

  Future<void> addTask({required String title, required int priority}) async {
    final repo = ref.read(plannerRepositoryProvider);
    final newTask = await repo.createTask(title: title, priority: priority);
    state = AsyncData([...?state.value, newTask]
      ..sort((a, b) => a.priority.compareTo(b.priority)));
  }

  Future<void> completeTask(String id) async {
    final repo = ref.read(plannerRepositoryProvider);
    final updated = await repo.completeTask(id);
    state = AsyncData(state.value!
        .map((t) => t.id == id ? updated : t)
        .toList());
  }

  Future<void> editTask(
    String id, {
    required String title,
    required int priority,
  }) async {
    final updated = await ref
        .read(plannerRepositoryProvider)
        .updateTask(id, title: title, priority: priority);
    final list = state.value!.map((t) => t.id == id ? updated : t).toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
    state = AsyncData(list);
  }

  Future<void> deleteTask(String id) async {
    await ref.read(plannerRepositoryProvider).deleteTask(id);
    state = AsyncData(state.value!.where((t) => t.id != id).toList());
  }
}
