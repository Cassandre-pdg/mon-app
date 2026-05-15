import 'package:supabase_flutter/supabase_flutter.dart';
import 'kanban_model.dart';

class KanbanRepository {
  final SupabaseClient _supabase;

  KanbanRepository(this._supabase);

  String get _userId => _supabase.auth.currentUser!.id;

  // Récupère tous les projets avec leurs tâches (actifs + en pause par défaut)
  Future<List<KanbanProject>> getAll({bool includeArchived = false}) async {
    var query = _supabase
        .from('kanban_projects')
        .select()
        .eq('user_id', _userId);

    if (!includeArchived) {
      query = query.neq('status', 'done');
    }

    final projects = await query.order('is_focus_project', ascending: false)
        .order('created_at');

    if ((projects as List).isEmpty) return [];

    final projectIds = projects.map((p) => p['id'] as String).toList();

    final tasks = await _supabase
        .from('kanban_tasks')
        .select()
        .inFilter('project_id', projectIds)
        .order('created_at');

    final tasksByProject = <String, List<KanbanTask>>{};
    for (final t in (tasks as List)) {
      final task = KanbanTask.fromJson(t);
      tasksByProject.putIfAbsent(task.projectId, () => []).add(task);
    }

    return projects
        .map((p) => KanbanProject.fromJson(
              p,
              tasksByProject[p['id'] as String] ?? [],
            ))
        .toList();
  }

  Future<KanbanProject> createProject({
    required String name,
    String? why,
    String? vision,
    List<String> successCriteria = const [],
    DateTime? targetDate,
    String? objectiveId,
  }) async {
    final data = await _supabase
        .from('kanban_projects')
        .insert({
          'user_id':           _userId,
          'name':              name.trim(),
          'why':               why?.trim(),
          'vision':            vision?.trim(),
          'success_criteria':  successCriteria.isEmpty ? null : successCriteria,
          'target_date':       targetDate?.toIso8601String().split('T')[0],
          'objective_id':      objectiveId,
          'status':            'active',
        })
        .select()
        .single();
    return KanbanProject.fromJson(data, []);
  }

  Future<KanbanProject> updateProject({
    required String id,
    String? name,
    String? why,
    String? vision,
    List<String>? successCriteria,
    DateTime? targetDate,
    ProjectStatus? projectStatus,
    String? objectiveId,
    bool? isFocusProject,
    // Flags pour mise à null explicite
    bool clearWhy = false,
    bool clearVision = false,
    bool clearTargetDate = false,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) { updates['name'] = name.trim(); }
    if (clearWhy) { updates['why'] = null; }
    else if (why != null) { updates['why'] = why.trim(); }
    if (clearVision) { updates['vision'] = null; }
    else if (vision != null) { updates['vision'] = vision.trim(); }
    if (successCriteria != null) {
      updates['success_criteria'] =
          successCriteria.isEmpty ? null : successCriteria;
    }
    if (clearTargetDate) { updates['target_date'] = null; }
    else if (targetDate != null) {
      updates['target_date'] = targetDate.toIso8601String().split('T')[0];
    }
    if (projectStatus != null) { updates['status'] = projectStatus.dbValue; }
    if (objectiveId != null) { updates['objective_id'] = objectiveId; }
    if (isFocusProject != null) { updates['is_focus_project'] = isFocusProject; }

    final data = await _supabase
        .from('kanban_projects')
        .update(updates)
        .eq('id', id)
        .eq('user_id', _userId)
        .select()
        .single();

    // On recharge les tâches pour retourner un projet complet
    final tasks = await _supabase
        .from('kanban_tasks')
        .select()
        .eq('project_id', id)
        .order('created_at');

    return KanbanProject.fromJson(
      data,
      (tasks as List).map((t) => KanbanTask.fromJson(t)).toList(),
    );
  }

  // Définit un projet comme "projet du moment" et retire ce flag des autres
  Future<void> setFocusProject(String projectId) async {
    await _supabase
        .from('kanban_projects')
        .update({'is_focus_project': false})
        .eq('user_id', _userId);

    await _supabase
        .from('kanban_projects')
        .update({'is_focus_project': true})
        .eq('id', projectId)
        .eq('user_id', _userId);
  }

  Future<void> clearFocusProject() async {
    await _supabase
        .from('kanban_projects')
        .update({'is_focus_project': false})
        .eq('user_id', _userId);
  }

  Future<void> deleteProject(String id) async {
    await _supabase
        .from('kanban_projects')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }

  Future<KanbanTask> createTask({
    required String projectId,
    required String title,
    required KanbanStatus status,
  }) async {
    final data = await _supabase
        .from('kanban_tasks')
        .insert({
          'project_id': projectId,
          'user_id':    _userId,
          'title':      title.trim(),
          'status':     status.dbValue,
        })
        .select()
        .single();
    return KanbanTask.fromJson(data);
  }

  Future<KanbanTask> moveTask(String taskId, KanbanStatus newStatus) async {
    final updates = <String, dynamic>{'status': newStatus.dbValue};
    if (newStatus == KanbanStatus.done) {
      updates['completed_at'] = DateTime.now().toIso8601String();
    } else {
      updates['completed_at'] = null;
    }

    final data = await _supabase
        .from('kanban_tasks')
        .update(updates)
        .eq('id', taskId)
        .eq('user_id', _userId)
        .select()
        .single();
    return KanbanTask.fromJson(data);
  }

  Future<void> deleteTask(String taskId) async {
    await _supabase
        .from('kanban_tasks')
        .delete()
        .eq('id', taskId)
        .eq('user_id', _userId);
  }
}
