import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/kanban_model.dart';
import '../../data/kanban_repository.dart';

final kanbanRepositoryProvider = Provider<KanbanRepository>((ref) {
  return KanbanRepository(Supabase.instance.client);
});

final kanbanProvider =
    AsyncNotifierProvider<KanbanNotifier, List<KanbanProject>>(
  KanbanNotifier.new,
);

class KanbanNotifier extends AsyncNotifier<List<KanbanProject>> {
  @override
  Future<List<KanbanProject>> build() async {
    return ref.watch(kanbanRepositoryProvider).getAll();
  }

  Future<void> addProject({
    required String name,
    String? why,
    String? vision,
    List<String> successCriteria = const [],
    DateTime? targetDate,
    String? objectiveId,
  }) async {
    final repo = ref.read(kanbanRepositoryProvider);
    final created = await repo.createProject(
      name: name,
      why: why,
      vision: vision,
      successCriteria: successCriteria,
      targetDate: targetDate,
      objectiveId: objectiveId,
    );
    state = AsyncData([...?state.value, created]);
  }

  Future<void> updateProject({
    required String projectId,
    String? name,
    String? why,
    String? vision,
    List<String>? successCriteria,
    DateTime? targetDate,
    ProjectStatus? projectStatus,
    String? objectiveId,
    bool? isFocusProject,
    bool clearWhy = false,
    bool clearVision = false,
    bool clearTargetDate = false,
  }) async {
    final updated = await ref.read(kanbanRepositoryProvider).updateProject(
      id: projectId,
      name: name,
      why: why,
      vision: vision,
      successCriteria: successCriteria,
      targetDate: targetDate,
      projectStatus: projectStatus,
      objectiveId: objectiveId,
      isFocusProject: isFocusProject,
      clearWhy: clearWhy,
      clearVision: clearVision,
      clearTargetDate: clearTargetDate,
    );
    state = AsyncData(
      state.value!.map((p) => p.id == projectId ? updated : p).toList(),
    );
  }

  Future<void> setFocusProject(String projectId) async {
    // Mise à jour optimiste
    state = AsyncData(
      state.value!.map((p) => p.copyWith(isFocusProject: p.id == projectId)).toList(),
    );
    await ref.read(kanbanRepositoryProvider).setFocusProject(projectId);
  }

  Future<void> clearFocusProject() async {
    state = AsyncData(
      state.value!.map((p) => p.copyWith(isFocusProject: false)).toList(),
    );
    await ref.read(kanbanRepositoryProvider).clearFocusProject();
  }

  Future<void> deleteProject(String projectId) async {
    await ref.read(kanbanRepositoryProvider).deleteProject(projectId);
    state = AsyncData(
      state.value!.where((p) => p.id != projectId).toList(),
    );
  }

  Future<void> addTask(
    String projectId,
    String title,
    KanbanStatus status,
  ) async {
    final task = await ref.read(kanbanRepositoryProvider).createTask(
          projectId: projectId,
          title: title,
          status: status,
        );
    _updateProject(projectId, (p) => p.copyWith(tasks: [...p.tasks, task]));
  }

  Future<void> moveTask(
    String projectId,
    String taskId,
    KanbanStatus newStatus,
  ) async {
    // Mise à jour optimiste immédiate
    _updateProject(
      projectId,
      (p) => p.copyWith(
        tasks: p.tasks
            .map((t) => t.id == taskId ? t.copyWith(status: newStatus) : t)
            .toList(),
      ),
    );
    await ref.read(kanbanRepositoryProvider).moveTask(taskId, newStatus);
  }

  Future<void> deleteTask(String projectId, String taskId) async {
    _updateProject(
      projectId,
      (p) => p.copyWith(tasks: p.tasks.where((t) => t.id != taskId).toList()),
    );
    await ref.read(kanbanRepositoryProvider).deleteTask(taskId);
  }

  void _updateProject(
    String projectId,
    KanbanProject Function(KanbanProject) update,
  ) {
    state = AsyncData(
      state.value!
          .map((p) => p.id == projectId ? update(p) : p)
          .toList(),
    );
  }
}

// Projet du moment (focus)
final focusProjectProvider = Provider<KanbanProject?>((ref) {
  final projects = ref.watch(kanbanProvider).valueOrNull ?? [];
  try {
    return projects.firstWhere((p) => p.isFocusProject);
  } catch (_) {
    return null;
  }
});

// Projets actifs uniquement
final activeProjectsProvider = Provider<List<KanbanProject>>((ref) {
  final projects = ref.watch(kanbanProvider).valueOrNull ?? [];
  return projects.where((p) => p.isActive).toList();
});

// Stats globales pour le hub Objectifs
final kanbanStatsProvider =
    Provider<({int projects, int inProgress, int todo})>((ref) {
  final projects = ref.watch(kanbanProvider).valueOrNull ?? [];
  return (
    projects: projects.length,
    inProgress: projects.fold(0, (s, p) => s + p.inProgressCount),
    todo: projects.fold(0, (s, p) => s + p.todoCount),
  );
});
