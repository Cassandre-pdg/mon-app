import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'checkin_model.dart';

class CheckinRepository {
  final SupabaseClient _supabase;
  final Logger _logger = Logger();

  CheckinRepository(this._supabase);

  /// Créer un check-in
  Future<CheckinModel> createCheckin({
    required String type,
    required int moodScore,
    required int energyScore,
    required int focusScore,
    String? notes,
    String? wellbeingNote,
    String? focusProjectId,
    String? dailyIntention,
    String? dailySuccess,
    String? dailyVictory,
    String? dailyLearning,
    String? tomorrowIntention,
  }) async {
    try {
      final data = await _supabase
          .from('checkins')
          .insert({
            'user_id': _supabase.auth.currentUser!.id,
            'type': type,
            'mood_score': moodScore,
            'energy_score': energyScore,
            'focus_score': focusScore,
            if (notes != null && notes.isNotEmpty) 'notes': notes,
            if (wellbeingNote != null && wellbeingNote.isNotEmpty)
              'wellbeing_note': wellbeingNote,
            if (focusProjectId != null) 'focus_project_id': focusProjectId,
            if (dailyIntention != null && dailyIntention.isNotEmpty)
              'daily_intention': dailyIntention,
            if (dailySuccess != null && dailySuccess.isNotEmpty)
              'daily_success': dailySuccess,
            if (dailyVictory != null && dailyVictory.isNotEmpty)
              'daily_victory': dailyVictory,
            if (dailyLearning != null && dailyLearning.isNotEmpty)
              'daily_learning': dailyLearning,
            if (tomorrowIntention != null && tomorrowIntention.isNotEmpty)
              'tomorrow_intention': tomorrowIntention,
          })
          .select()
          .single();
      return CheckinModel.fromJson(data);
    } catch (e) {
      _logger.e('Erreur création check-in : $e');
      rethrow;
    }
  }

  /// Récupérer les check-ins du jour
  Future<Map<String, CheckinModel?>> getTodayCheckins() async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).toIso8601String();
    final end = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();

    final data = await _supabase
        .from('checkins')
        .select()
        .eq('user_id', _supabase.auth.currentUser!.id)
        .gte('created_at', start)
        .lte('created_at', end);

    final checkins = (data as List).map((e) => CheckinModel.fromJson(e)).toList();

    return {
      'morning': checkins.where((c) => c.type == 'morning').firstOrNull,
      'evening': checkins.where((c) => c.type == 'evening').firstOrNull,
    };
  }

  /// Récupérer la note "demain" du check-in soir d'hier (pense-bête matin)
  Future<String?> getLastEveningTomorrowNote() async {
    try {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final start = DateTime(yesterday.year, yesterday.month, yesterday.day)
          .toIso8601String();
      final end = DateTime(
              yesterday.year, yesterday.month, yesterday.day, 23, 59, 59)
          .toIso8601String();

      final data = await _supabase
          .from('checkins')
          .select('tomorrow_intention')
          .eq('user_id', _supabase.auth.currentUser!.id)
          .eq('type', 'evening')
          .gte('created_at', start)
          .lte('created_at', end)
          .limit(1)
          .maybeSingle();

      final note = data?['tomorrow_intention'] as String?;
      return (note != null && note.isNotEmpty) ? note : null;
    } catch (e) {
      _logger.e('Erreur récupération note soir : $e');
      return null;
    }
  }

  /// Récupérer les derniers N check-ins
  Future<List<CheckinModel>> getRecentCheckins({int limit = 14}) async {
    final data = await _supabase
        .from('checkins')
        .select()
        .eq('user_id', _supabase.auth.currentUser!.id)
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List).map((e) => CheckinModel.fromJson(e)).toList();
  }
}
