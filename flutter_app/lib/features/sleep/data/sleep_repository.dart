import 'package:supabase_flutter/supabase_flutter.dart';
import 'sleep_model.dart';

class SleepRepository {
  final SupabaseClient _supabase;

  SleepRepository(this._supabase);

  String get _userId => _supabase.auth.currentUser!.id;

  int _calcDuration(String bedtime, String wakeTime) {
    final bp = bedtime.split(':');
    final wp = wakeTime.split(':');
    int bed  = int.parse(bp[0]) * 60 + int.parse(bp[1]);
    int wake = int.parse(wp[0]) * 60 + int.parse(wp[1]);
    if (wake < bed) wake += 24 * 60;
    return wake - bed;
  }

  Future<List<SleepLog>> getRecentLogs({int days = 7}) async {
    final from = DateTime.now().subtract(Duration(days: days));
    final data = await _supabase
        .from('sleep_logs')
        .select()
        .eq('user_id', _userId)
        .gte('sleep_date', from.toIso8601String().split('T')[0])
        .order('sleep_date', ascending: false);
    return (data as List).map((e) => SleepLog.fromJson(e)).toList();
  }

  Future<SleepLog> createLog({
    required String sleepDate,
    required String bedtime,
    required String wakeTime,
    int? qualityScore,
    String? notes,
  }) async {
    final duration = _calcDuration(bedtime, wakeTime);
    final data = await _supabase
        .from('sleep_logs')
        .insert({
          'user_id': _userId,
          'sleep_date': sleepDate,
          'bedtime': bedtime,
          'wake_time': wakeTime,
          'duration_minutes': duration,
          if (qualityScore != null) 'quality_score': qualityScore,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          'source': 'manual',
        })
        .select()
        .single();
    return SleepLog.fromJson(data);
  }
}
