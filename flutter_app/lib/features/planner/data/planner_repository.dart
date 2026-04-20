import 'package:supabase_flutter/supabase_flutter.dart';
import 'planner_model.dart';

class PlannerRepository {
  final SupabaseClient _supabase;

  PlannerRepository(this._supabase);

  String get _today => DateTime.now().toIso8601String().split('T')[0];
  String get _userId => _supabase.auth.currentUser!.id;

  Future<List<PlannerTask>> getTodayTasks() async {
    final data = await _supabase
        .from('planner_tasks')
        .select()
        .eq('user_id', _userId)
        .eq('planned_date', _today)
        .order('priority');
    return (data as List).map((e) => PlannerTask.fromJson(e)).toList();
  }

  Future<PlannerTask> createTask({
    required String title,
    required int priority,
  }) async {
    final data = await _supabase
        .from('planner_tasks')
        .insert({
          'user_id': _userId,
          'title': title,
          'priority': priority,
          'planned_date': _today,
          'is_completed': false,
          'pomodoro_count': 0,
        })
        .select()
        .single();
    return PlannerTask.fromJson(data);
  }

  Future<PlannerTask> completeTask(String id) async {
    final data = await _supabase
        .from('planner_tasks')
        .update({
          'is_completed': true,
          'completed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', _userId)
        .select()
        .single();
    return PlannerTask.fromJson(data);
  }

  Future<PlannerTask> updateTask(
    String id, {
    required String title,
    required int priority,
  }) async {
    final data = await _supabase
        .from('planner_tasks')
        .update({'title': title, 'priority': priority})
        .eq('id', id)
        .eq('user_id', _userId)
        .select()
        .single();
    return PlannerTask.fromJson(data);
  }

  Future<void> deleteTask(String id) async {
    await _supabase
        .from('planner_tasks')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }
}
