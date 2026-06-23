import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/objective_model.dart';
import '../../data/objectives_repository.dart';

final objectivesRepositoryProvider = Provider<ObjectivesRepository>((ref) {
  return ObjectivesRepository(Supabase.instance.client);
});

final objectivesProvider =
    AsyncNotifierProvider<ObjectivesNotifier, List<Objective>>(
  ObjectivesNotifier.new,
);

class ObjectivesNotifier extends AsyncNotifier<List<Objective>> {
  @override
  Future<List<Objective>> build() async {
    return ref.watch(objectivesRepositoryProvider).getAll();
  }

  Future<void> add({
    required String title,
    required ObjectiveHorizon horizon,
    String? description,
    DateTime? targetDate,
  }) async {
    final repo = ref.read(objectivesRepositoryProvider);
    final created = await repo.create(
      title: title,
      horizon: horizon,
      description: description,
      targetDate: targetDate,
    );
    state = AsyncData([...?state.value, created]);
  }

  Future<void> updateProgress(String id, double progress) async {
    final updated =
        await ref.read(objectivesRepositoryProvider).updateProgress(id, progress);
    _replaceInState(updated);
  }

  Future<void> complete(String id) async {
    final updated = await ref.read(objectivesRepositoryProvider).complete(id);
    _replaceInState(updated);
  }

  Future<void> edit(
    String id, {
    String? title,
    String? description,
    DateTime? targetDate,
  }) async {
    final updated = await ref.read(objectivesRepositoryProvider).update(
          id,
          title: title,
          description: description,
          targetDate: targetDate,
        );
    _replaceInState(updated);
  }

  Future<void> delete(String id) async {
    await ref.read(objectivesRepositoryProvider).delete(id);
    state = AsyncData(state.value?.where((o) => o.id != id).toList() ?? []);
  }

  void _replaceInState(Objective updated) {
    state = AsyncData(
      (state.value ?? []).map((o) => o.id == updated.id ? updated : o).toList(),
    );
  }
}

// Provider filtré par horizon — pratique pour afficher chaque section
final objectivesByHorizonProvider = Provider.family<List<Objective>, ObjectiveHorizon>(
  (ref, horizon) {
    final all = ref.watch(objectivesProvider).valueOrNull ?? [];
    return all.where((o) => o.horizon == horizon && !o.isCompleted).toList();
  },
);

// Compte total des objectifs actifs par horizon
final objectivesCountProvider = Provider<Map<ObjectiveHorizon, int>>((ref) {
  final all = ref.watch(objectivesProvider).valueOrNull ?? [];
  return {
    for (final h in ObjectiveHorizon.values)
      h: all.where((o) => o.horizon == h && !o.isCompleted).length,
  };
});
