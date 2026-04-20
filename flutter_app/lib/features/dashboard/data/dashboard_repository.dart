import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardData {
  final int currentStreak;
  final int longestStreak;
  final int totalPoints;
  final int level;
  final String levelLabel;
  final bool morningDone;
  final bool eveningDone;

  // Suivi général
  final int focusMinutes;        // temps focus du jour (onglet Flow — placeholder)
  final int focusGoalMinutes;    // objectif focus du jour (défaut 120 min)
  final int habitsCompleted;     // tâches complétées aujourd'hui
  final int habitsTotalToday;    // total tâches du jour
  final int? sleepQualityScore;  // qualité sommeil dernière nuit (1–5)
  final int sleepDurationMinutes; // durée sommeil dernière nuit

  const DashboardData({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalPoints,
    required this.level,
    required this.levelLabel,
    required this.morningDone,
    required this.eveningDone,
    this.focusMinutes = 0,
    this.focusGoalMinutes = 120,
    this.habitsCompleted = 0,
    this.habitsTotalToday = 0,
    this.sleepQualityScore,
    this.sleepDurationMinutes = 0,
  });

  DashboardData copyWith({int? focusMinutes}) => DashboardData(
        currentStreak:        currentStreak,
        longestStreak:        longestStreak,
        totalPoints:          totalPoints,
        level:                level,
        levelLabel:           levelLabel,
        morningDone:          morningDone,
        eveningDone:          eveningDone,
        focusMinutes:         focusMinutes ?? this.focusMinutes,
        focusGoalMinutes:     focusGoalMinutes,
        habitsCompleted:      habitsCompleted,
        habitsTotalToday:     habitsTotalToday,
        sleepQualityScore:    sleepQualityScore,
        sleepDurationMinutes: sleepDurationMinutes,
      );
}

class DashboardRepository {
  final SupabaseClient _supabase;

  DashboardRepository(this._supabase);

  static const _levelLabels = {
    1: 'Explorateur', 2: 'Indépendant', 3: 'Entrepreneur',
    4: 'Bâtisseur',   5: 'Visionnaire',
  };

  Future<DashboardData> getDashboardData() async {
    final userId = _supabase.auth.currentUser!.id;

    // Appels parallèles typés explicitement
    final profileFuture  = _supabase
        .from('profiles')
        .select('current_streak, longest_streak, total_points, level')
        .eq('id', userId)
        .single();
    final checkinsFuture = _getTodayCheckinStatus(userId);
    final tasksFuture    = _getTodayTasksStats(userId);
    final sleepFuture    = _getLastNightSleep(userId);

    final profile  = await profileFuture;
    final checkins = await checkinsFuture;
    final tasks    = await tasksFuture;
    final sleep    = await sleepFuture;
    final level    = (profile['level'] as int?) ?? 1;

    return DashboardData(
      currentStreak:      (profile['current_streak'] as int?) ?? 0,
      longestStreak:      (profile['longest_streak'] as int?) ?? 0,
      totalPoints:        (profile['total_points'] as int?) ?? 0,
      level:              level,
      levelLabel:         _levelLabels[level] ?? 'Explorateur',
      morningDone:        checkins['morning'] ?? false,
      eveningDone:        checkins['evening'] ?? false,
      focusMinutes:       0, // connecté à l'onglet Flow (V1 — placeholder)
      focusGoalMinutes:   120,
      habitsCompleted:    tasks['completed'] ?? 0,
      habitsTotalToday:   tasks['total'] ?? 0,
      sleepQualityScore:  sleep['quality'] as int?,
      sleepDurationMinutes: (sleep['duration'] as int?) ?? 0,
    );
  }

  /// Tâches du jour : complétées / total
  Future<Map<String, int>> _getTodayTasksStats(String userId) async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      final rows = await _supabase
          .from('planner_tasks')
          .select('is_completed')
          .eq('user_id', userId)
          .eq('task_date', todayStr);

      final list = rows as List;
      final completed = list.where((r) => r['is_completed'] == true).length;
      return {'completed': completed, 'total': list.length};
    } catch (_) {
      return {'completed': 0, 'total': 0};
    }
  }

  /// Sommeil de la dernière nuit
  Future<Map<String, dynamic>> _getLastNightSleep(String userId) async {
    try {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final yStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      final tStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final rows = await _supabase
          .from('sleep_logs')
          .select('quality_score, duration_minutes')
          .eq('user_id', userId)
          .gte('sleep_date', yStr)
          .lte('sleep_date', tStr)
          .order('created_at', ascending: false)
          .limit(1);

      final list = rows as List;
      if (list.isEmpty) return {'quality': null, 'duration': null};
      return {
        'quality':  list[0]['quality_score'],
        'duration': list[0]['duration_minutes'],
      };
    } catch (_) {
      return {'quality': null, 'duration': null};
    }
  }

  Future<Map<String, bool>> _getTodayCheckinStatus(String userId) async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).toIso8601String();
    final end   = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();

    final data = await _supabase
        .from('checkins')
        .select('type')
        .eq('user_id', userId)
        .gte('created_at', start)
        .lte('created_at', end);

    final types = (data as List).map((e) => e['type'] as String).toList();
    return {
      'morning': types.contains('morning'),
      'evening': types.contains('evening'),
    };
  }
}
