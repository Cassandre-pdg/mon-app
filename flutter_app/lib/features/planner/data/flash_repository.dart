import 'package:supabase_flutter/supabase_flutter.dart';
import 'flash_model.dart';

class FlashRepository {
  final SupabaseClient _supabase;

  FlashRepository(this._supabase);

  String get _userId => _supabase.auth.currentUser!.id;

  // Retourne toutes les tâches non faites + celles faites aujourd'hui
  Future<List<FlashTask>> getAll() async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    final data = await _supabase
        .from('flash_tasks')
        .select('*, kanban_projects(name)')
        .eq('user_id', _userId)
        .or('is_done.eq.false,done_at.gte.$today')
        .order('created_at');

    return (data as List).map((e) => FlashTask.fromJson(e)).toList();
  }

  Future<FlashTask> addTask({
    required String title,
    required String category,
    required int estimatedMinutes,
    String? projectId,
  }) async {
    final data = await _supabase
        .from('flash_tasks')
        .insert({
          'user_id': _userId,
          'title': title,
          'category': category,
          'estimated_minutes': estimatedMinutes,
          'project_id': projectId,
          'is_done': false,
        })
        .select('*, kanban_projects(name)')
        .single();
    return FlashTask.fromJson(data);
  }

  Future<FlashTask> markDone(String id) async {
    final data = await _supabase
        .from('flash_tasks')
        .update({
          'is_done': true,
          'done_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', _userId)
        .select('*, kanban_projects(name)')
        .single();
    return FlashTask.fromJson(data);
  }

  Future<FlashTask> markUndone(String id) async {
    final data = await _supabase
        .from('flash_tasks')
        .update({'is_done': false, 'done_at': null})
        .eq('id', id)
        .eq('user_id', _userId)
        .select('*, kanban_projects(name)')
        .single();
    return FlashTask.fromJson(data);
  }

  Future<void> deleteTask(String id) async {
    await _supabase
        .from('flash_tasks')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }

  Future<void> clearDone() async {
    await _supabase
        .from('flash_tasks')
        .delete()
        .eq('user_id', _userId)
        .eq('is_done', true);
  }
}
