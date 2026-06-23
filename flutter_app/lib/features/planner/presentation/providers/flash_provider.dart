import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/flash_model.dart';
import '../../data/flash_repository.dart';

export '../../data/flash_model.dart' show FlashTask, FlashCategory, flashCategories;

final flashRepositoryProvider = Provider<FlashRepository>((ref) {
  return FlashRepository(Supabase.instance.client);
});

final flashProvider =
    AsyncNotifierProvider<FlashNotifier, List<FlashTask>>(FlashNotifier.new);

class FlashNotifier extends AsyncNotifier<List<FlashTask>> {
  @override
  Future<List<FlashTask>> build() async {
    return ref.watch(flashRepositoryProvider).getAll();
  }

  Future<void> addTask({
    required String title,
    required String category,
    required int minutes,
    String? projectId,
  }) async {
    final repo = ref.read(flashRepositoryProvider);
    final task = await repo.addTask(
      title: title,
      category: category,
      estimatedMinutes: minutes,
      projectId: projectId,
    );
    state = AsyncData([...?state.value, task]);
  }

  Future<void> toggleDone(String id) async {
    final current = state.value?.firstWhere((t) => t.id == id);
    if (current == null) return;
    final repo = ref.read(flashRepositoryProvider);
    final updated = current.isDone
        ? await repo.markUndone(id)
        : await repo.markDone(id);
    state = AsyncData(
      state.value?.map((t) => t.id == id ? updated : t).toList() ?? [],
    );
  }

  Future<void> deleteTask(String id) async {
    await ref.read(flashRepositoryProvider).deleteTask(id);
    state = AsyncData(state.value?.where((t) => t.id != id).toList() ?? []);
  }

  Future<void> clearDone() async {
    await ref.read(flashRepositoryProvider).clearDone();
    state = AsyncData(state.value?.where((t) => !t.isDone).toList() ?? []);
  }

  // Nombre de tâches en attente (pour badge)
  int get pendingCount =>
      state.value?.where((t) => !t.isDone).length ?? 0;
}

// Badge count pour affichage externe
final flashPendingCountProvider = Provider<int>((ref) {
  final async = ref.watch(flashProvider);
  return async.value?.where((t) => !t.isDone).length ?? 0;
});
