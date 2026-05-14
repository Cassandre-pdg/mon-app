import 'package:supabase_flutter/supabase_flutter.dart';
import 'habit_model.dart';

class HabitsRepository {
  final SupabaseClient _supabase;

  HabitsRepository(this._supabase);

  String get _userId => _supabase.auth.currentUser!.id;
  String get _today => DateTime.now().toIso8601String().split('T')[0];

  Future<List<Habit>> getAll() async {
    final habits = await _supabase
        .from('habits')
        .select()
        .eq('user_id', _userId)
        .order('created_at');

    // Récupère les completions du jour en une seule requête
    final completions = await _supabase
        .from('habit_completions')
        .select('habit_id')
        .eq('user_id', _userId)
        .eq('completed_date', _today);

    final completedIds = (completions as List)
        .map((e) => e['habit_id'] as String)
        .toSet();

    return (habits as List)
        .map((e) => Habit.fromJson(
              e,
              isCompletedToday: completedIds.contains(e['id'] as String),
            ))
        .toList();
  }

  Future<Habit> create({
    required String title,
    String emoji = '🔁',
    HabitFrequency frequency = HabitFrequency.daily,
    List<int> daysOfWeek = const [],
  }) async {
    final data = await _supabase
        .from('habits')
        .insert({
          'user_id': _userId,
          'title': title.trim(),
          'emoji': emoji,
          'frequency': frequency.value,
          'days_of_week': daysOfWeek,
          'current_streak': 0,
        })
        .select()
        .single();
    return Habit.fromJson(data);
  }

  Future<bool> toggleToday(String habitId, bool currentlyDone) async {
    if (currentlyDone) {
      // Supprimer la completion du jour
      await _supabase
          .from('habit_completions')
          .delete()
          .eq('habit_id', habitId)
          .eq('user_id', _userId)
          .eq('completed_date', _today);

      // Décrémente le streak si > 0
      await _supabase.rpc('decrement_habit_streak', params: {
        'p_habit_id': habitId,
        'p_user_id': _userId,
      });
      return false;
    } else {
      // Ajouter la completion
      await _supabase.from('habit_completions').upsert({
        'habit_id': habitId,
        'user_id': _userId,
        'completed_date': _today,
      });

      // Incrémente le streak
      await _supabase.rpc('increment_habit_streak', params: {
        'p_habit_id': habitId,
        'p_user_id': _userId,
      });
      return true;
    }
  }

  Future<Habit> update(
    String id, {
    String? title,
    String? emoji,
    HabitFrequency? frequency,
    List<int>? daysOfWeek,
  }) async {
    final data = await _supabase
        .from('habits')
        .update({
          if (title != null) 'title': title.trim(),
          if (emoji != null) 'emoji': emoji,
          if (frequency != null) 'frequency': frequency.value,
          if (daysOfWeek != null) 'days_of_week': daysOfWeek,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', _userId)
        .select()
        .single();
    return Habit.fromJson(data);
  }

  Future<void> delete(String id) async {
    await _supabase
        .from('habits')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }
}
