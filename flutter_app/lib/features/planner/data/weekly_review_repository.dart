import 'package:supabase_flutter/supabase_flutter.dart';
import 'weekly_review_model.dart';

class WeeklyReviewRepository {
  WeeklyReviewRepository(this._client);
  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  // Lundi de la semaine contenant [date]
  static DateTime weekStartFor(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  // ── Revue existante pour la semaine courante ──────────────────
  Future<WeeklyReview?> getCurrentWeekReview() async {
    final ws = weekStartFor(DateTime.now());
    final data = await _client
        .from('weekly_reviews')
        .select()
        .eq('user_id', _uid)
        .eq('week_start', ws.toIso8601String().split('T').first)
        .maybeSingle();
    return data == null ? null : WeeklyReview.fromJson(data);
  }

  // ── Historique complet ────────────────────────────────────────
  Future<List<WeeklyReview>> getHistory({int limit = 52}) async {
    final data = await _client
        .from('weekly_reviews')
        .select()
        .eq('user_id', _uid)
        .order('week_start', ascending: false)
        .limit(limit);
    return (data as List).map((j) => WeeklyReview.fromJson(j)).toList();
  }

  // ── Agrégation des données de la semaine ─────────────────────
  Future<WeeklySummary> computeWeeklySummary(DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 7));
    final ws = weekStart.toIso8601String().split('T').first;
    final we = weekEnd.toIso8601String().split('T').first;

    // Tâches planner complétées
    final tasks = await _client
        .from('planner_tasks')
        .select('is_done, completed_at, created_at')
        .eq('user_id', _uid)
        .gte('created_at', ws)
        .lt('created_at', we);

    // Flash tasks complétées
    final flash = await _client
        .from('flash_tasks')
        .select('is_done, done_at, created_at')
        .eq('user_id', _uid)
        .gte('created_at', ws)
        .lt('created_at', we);

    // Sessions focus
    final sessions = await _client
        .from('timer_sessions')
        .select('duration_minutes, completed_at')
        .eq('user_id', _uid)
        .gte('completed_at', ws)
        .lt('completed_at', we);

    // Check-ins
    final checkins = await _client
        .from('checkins')
        .select('mood, energy, created_at')
        .eq('user_id', _uid)
        .gte('created_at', ws)
        .lt('created_at', we);

    // Calculs
    final allTasks = [...(tasks as List), ...(flash as List)];
    final totalTasks = allTasks.length;
    final completedTasks = allTasks.where((t) =>
      t['is_done'] == true || t['completed_at'] != null).length;

    final focusMinutes = (sessions as List)
        .fold<int>(0, (sum, s) => sum + ((s['duration_minutes'] as num?)?.toInt() ?? 0));

    final checkinList = checkins as List;
    final avgMood = checkinList.isEmpty ? null :
        checkinList.map((c) => (c['mood'] as num?)?.toDouble() ?? 5.0).reduce((a, b) => a + b) / checkinList.length;
    final avgEnergy = checkinList.isEmpty ? null :
        checkinList.map((c) => (c['energy'] as num?)?.toDouble() ?? 5.0).reduce((a, b) => a + b) / checkinList.length;

    final completionRate = totalTasks == 0 ? 0.0 : completedTasks / totalTasks * 100;

    // Stats par jour (lun=0 … dim=6)
    final tasksByDay = List<int>.filled(7, 0);
    final moodSumByDay = List<double>.filled(7, 0);
    final moodCountByDay = List<int>.filled(7, 0);
    final energySumByDay = List<double>.filled(7, 0);
    final energyCountByDay = List<int>.filled(7, 0);

    for (final t in allTasks) {
      final dateStr = t['completed_at'] ?? t['done_at'] ?? t['created_at'];
      if (dateStr == null) continue;
      final d = DateTime.tryParse(dateStr as String);
      if (d == null) continue;
      final day = d.weekday - 1; // lun=0
      if (day >= 0 && day < 7 && (t['is_done'] == true || t['completed_at'] != null)) {
        tasksByDay[day]++;
      }
    }

    for (final c in checkinList) {
      final d = DateTime.tryParse(c['created_at'] as String? ?? '');
      if (d == null) continue;
      final day = d.weekday - 1;
      if (day >= 0 && day < 7) {
        final mood = (c['mood'] as num?)?.toDouble();
        final energy = (c['energy'] as num?)?.toDouble();
        if (mood != null) { moodSumByDay[day] += mood; moodCountByDay[day]++; }
        if (energy != null) { energySumByDay[day] += energy; energyCountByDay[day]++; }
      }
    }

    final moodByDay = List<double?>.generate(7, (i) =>
        moodCountByDay[i] > 0 ? moodSumByDay[i] / moodCountByDay[i] : null);
    final energyByDay = List<double?>.generate(7, (i) =>
        energyCountByDay[i] > 0 ? energySumByDay[i] / energyCountByDay[i] : null);

    final badge = WeeklySummary.computeBadge(
      completionRate: completionRate,
      avgMood: avgMood,
      focusMinutes: focusMinutes,
    );

    return WeeklySummary(
      tasksCompleted: completedTasks,
      tasksTotal: totalTasks,
      focusMinutes: focusMinutes,
      checkinsDone: checkinList.length,
      avgMood: avgMood,
      avgEnergy: avgEnergy,
      completionRate: completionRate,
      badge: badge,
      tasksByDay: tasksByDay,
      moodByDay: moodByDay,
      energyByDay: energyByDay,
    );
  }

  // ── Sauvegarder / mettre à jour la revue ─────────────────────
  Future<WeeklyReview> saveReview(WeeklyReview review) async {
    final json = review.toJson()..['user_id'] = _uid;
    final data = await _client
        .from('weekly_reviews')
        .upsert(json, onConflict: 'user_id,week_start')
        .select()
        .single();
    return WeeklyReview.fromJson(data);
  }

  // ── Fenêtre d'accès ───────────────────────────────────────────
  // Vendredi 15h → Lundi 9h
  static bool isReviewWindowOpen() {
    final now = DateTime.now();
    final weekday = now.weekday; // lun=1 … dim=7
    final hour = now.hour;

    if (weekday == 5 && hour >= 15) return true; // vendredi 15h+
    if (weekday == 6) return true;                // samedi entier
    if (weekday == 7) return true;                // dimanche entier
    if (weekday == 1 && hour < 9) return true;   // lundi avant 9h
    return false;
  }
}
