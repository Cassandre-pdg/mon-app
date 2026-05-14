import 'package:supabase_flutter/supabase_flutter.dart';
import 'objective_model.dart';

class ObjectivesRepository {
  final SupabaseClient _supabase;

  ObjectivesRepository(this._supabase);

  String get _userId => _supabase.auth.currentUser!.id;

  Future<List<Objective>> getAll() async {
    final data = await _supabase
        .from('objectives')
        .select()
        .eq('user_id', _userId)
        .order('created_at');
    return (data as List).map((e) => Objective.fromJson(e)).toList();
  }

  Future<List<Objective>> getByHorizon(ObjectiveHorizon horizon) async {
    final data = await _supabase
        .from('objectives')
        .select()
        .eq('user_id', _userId)
        .eq('horizon', horizon.value)
        .order('created_at');
    return (data as List).map((e) => Objective.fromJson(e)).toList();
  }

  Future<Objective> create({
    required String title,
    required ObjectiveHorizon horizon,
    String? description,
    DateTime? targetDate,
  }) async {
    final data = await _supabase
        .from('objectives')
        .insert({
          'user_id': _userId,
          'title': title.trim(),
          'description': description?.trim(),
          'horizon': horizon.value,
          'progress_percent': 0.0,
          'is_completed': false,
          'target_date':
              targetDate?.toIso8601String().split('T')[0],
        })
        .select()
        .single();
    return Objective.fromJson(data);
  }

  Future<Objective> updateProgress(String id, double progress) async {
    final data = await _supabase
        .from('objectives')
        .update({
          'progress_percent': progress.clamp(0.0, 1.0),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', _userId)
        .select()
        .single();
    return Objective.fromJson(data);
  }

  Future<Objective> complete(String id) async {
    final data = await _supabase
        .from('objectives')
        .update({
          'is_completed': true,
          'progress_percent': 1.0,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', _userId)
        .select()
        .single();
    return Objective.fromJson(data);
  }

  Future<Objective> update(
    String id, {
    String? title,
    String? description,
    DateTime? targetDate,
  }) async {
    final data = await _supabase
        .from('objectives')
        .update({
          if (title != null) 'title': title.trim(),
          if (description != null) 'description': description.trim(),
          if (targetDate != null)
            'target_date': targetDate.toIso8601String().split('T')[0],
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', _userId)
        .select()
        .single();
    return Objective.fromJson(data);
  }

  Future<void> delete(String id) async {
    await _supabase
        .from('objectives')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }
}
