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
  // Sommeil (optionnel — non implémenté en V1)
  final int? sleepQualityScore;  // 1-5
  final int sleepDurationMinutes;

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
        currentStreak:    currentStreak,
        longestStreak:    longestStreak,
        totalPoints:      totalPoints,
        level:            level,
        levelLabel:       levelLabel,
        morningDone:      morningDone,
        eveningDone:      eveningDone,
        focusMinutes:        focusMinutes ?? this.focusMinutes,
        focusGoalMinutes:    focusGoalMinutes,
        habitsCompleted:     habitsCompleted,
        habitsTotalToday:    habitsTotalToday,
        sleepQualityScore:   sleepQualityScore,
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

  // 📸 MODE CAPTURES APP STORE — mettre à false avant de soumettre sur l'App Store
  static const bool screenshotMode = false;

  Future<DashboardData> getDashboardData() async {
    if (screenshotMode) {
      return const DashboardData(
        currentStreak:    12,
        longestStreak:    21,
        totalPoints:      340,
        level:            2,
        levelLabel:       'Indépendant',
        morningDone:      true,
        eveningDone:      false,
        focusMinutes:     72,
        focusGoalMinutes: 120,
        habitsCompleted:  2,
        habitsTotalToday: 3,
      );
    }

    final userId = _supabase.auth.currentUser!.id;

    // Appels parallèles typés explicitement
    final profileFuture  = _supabase
        .from('profiles')
        .select('current_streak, longest_streak, total_points, level')
        .eq('id', userId)
        .single();
    final checkinsFuture = _getTodayCheckinStatus(userId);
    final tasksFuture    = _getTodayTasksStats(userId);

    final profile  = await profileFuture;
    final checkins = await checkinsFuture;
    final tasks    = await tasksFuture;
    final level    = (profile['level'] as int?) ?? 1;

    return DashboardData(
      currentStreak:    (profile['current_streak'] as int?) ?? 0,
      longestStreak:    (profile['longest_streak'] as int?) ?? 0,
      totalPoints:      (profile['total_points'] as int?) ?? 0,
      level:            level,
      levelLabel:       _levelLabels[level] ?? 'Explorateur',
      morningDone:      checkins['morning'] ?? false,
      eveningDone:      checkins['evening'] ?? false,
      focusMinutes:     0,
      focusGoalMinutes: 120,
      habitsCompleted:  tasks['completed'] ?? 0,
      habitsTotalToday: tasks['total'] ?? 0,
    );
  }

  /// Habitudes du jour : complétées / dues aujourd'hui
  Future<Map<String, int>> _getTodayTasksStats(String userId) async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final weekday = today.weekday; // 1=Lun … 7=Dim

    try {
      final habits = await _supabase
          .from('habits')
          .select('id, frequency, days_of_week')
          .eq('user_id', userId);

      final completions = await _supabase
          .from('habit_completions')
          .select('habit_id')
          .eq('user_id', userId)
          .eq('completed_date', todayStr);

      final completedIds = (completions as List)
          .map((c) => c['habit_id'] as String)
          .toSet();

      int total = 0;
      int completed = 0;
      for (final h in habits as List) {
        final freq = h['frequency'] as String? ?? 'daily';
        final days = (h['days_of_week'] as List?)?.cast<int>() ?? [];
        final isDue = freq == 'daily' ||
            (freq == 'weekly' && days.contains(weekday)) ||
            (freq == 'custom' && days.contains(weekday));
        if (isDue) {
          total++;
          if (completedIds.contains(h['id'] as String)) completed++;
        }
      }
      return {'completed': completed, 'total': total};
    } catch (_) {
      return {'completed': 0, 'total': 0};
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
