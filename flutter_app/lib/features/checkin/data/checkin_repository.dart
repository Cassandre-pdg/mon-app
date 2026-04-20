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
