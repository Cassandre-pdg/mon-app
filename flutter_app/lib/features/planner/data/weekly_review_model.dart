// Modèle de revue hebdomadaire

enum ReviewBadge {
  fire,       // ≥90% complétion
  solid,      // ≥80%
  resilient,  // humeur basse mais forte avancée
  gentle,     // semaine douce
}

extension ReviewBadgeX on ReviewBadge {
  String get emoji {
    switch (this) {
      case ReviewBadge.fire:      return '⚡';
      case ReviewBadge.solid:     return '🏆';
      case ReviewBadge.resilient: return '💪';
      case ReviewBadge.gentle:    return '🌱';
    }
  }

  String get label {
    switch (this) {
      case ReviewBadge.fire:      return 'Semaine de feu';
      case ReviewBadge.solid:     return 'Semaine solide';
      case ReviewBadge.resilient: return 'Semaine résiliente';
      case ReviewBadge.gentle:    return 'Semaine douce';
    }
  }

  String get message {
    switch (this) {
      case ReviewBadge.fire:
        return 'Tu as tout déchiré cette semaine. C\'est rare, profites-en.';
      case ReviewBadge.solid:
        return 'Semaine bien menée. Tu avances à ton rythme.';
      case ReviewBadge.resilient:
        return 'Tu as avancé malgré la fatigue. Tu es plus solide que tu ne le crois.';
      case ReviewBadge.gentle:
        return 'Tu as pris soin de toi cette semaine. C\'est aussi du progrès.';
    }
  }
}

class WeeklySummary {
  final int tasksCompleted;
  final int tasksTotal;
  final int focusMinutes;
  final int checkinsDone;
  final double? avgMood;
  final double? avgEnergy;
  final double completionRate;
  final ReviewBadge badge;

  // Stats par jour (lundi=0 … dimanche=6)
  final List<int> tasksByDay;        // tâches complétées par jour
  final List<double?> moodByDay;     // humeur moyenne par jour (null si pas de check-in)
  final List<double?> energyByDay;

  const WeeklySummary({
    required this.tasksCompleted,
    required this.tasksTotal,
    required this.focusMinutes,
    required this.checkinsDone,
    required this.avgMood,
    required this.avgEnergy,
    required this.completionRate,
    required this.badge,
    required this.tasksByDay,
    required this.moodByDay,
    required this.energyByDay,
  });

  static ReviewBadge computeBadge({
    required double completionRate,
    required double? avgMood,
    required int focusMinutes,
  }) {
    final focusScore = (focusMinutes / 300).clamp(0.0, 1.0);
    final score = completionRate / 100 * 0.6 + focusScore * 0.4;

    if (score >= 0.9) return ReviewBadge.fire;
    if (score >= 0.8) return ReviewBadge.solid;
    // Résiliente : bonne avancée malgré humeur basse
    if (score >= 0.6 && avgMood != null && avgMood <= 5) return ReviewBadge.resilient;
    return ReviewBadge.gentle;
  }
}

class WeeklyReview {
  final String? id;
  final String userId;
  final DateTime weekStart;
  final int tasksCompleted;
  final int tasksTotal;
  final int focusMinutes;
  final int checkinsDone;
  final double? avgMood;
  final double? avgEnergy;
  final double completionRate;
  final ReviewBadge? badge;
  final String? bestMoment;
  final String? mainBlocker;
  final String? weeklyIntention;
  final String? focusHabit;
  final int capturesProcessed;
  final DateTime createdAt;

  const WeeklyReview({
    this.id,
    required this.userId,
    required this.weekStart,
    required this.tasksCompleted,
    required this.tasksTotal,
    required this.focusMinutes,
    required this.checkinsDone,
    this.avgMood,
    this.avgEnergy,
    required this.completionRate,
    this.badge,
    this.bestMoment,
    this.mainBlocker,
    this.weeklyIntention,
    this.focusHabit,
    required this.capturesProcessed,
    required this.createdAt,
  });

  factory WeeklyReview.fromJson(Map<String, dynamic> j) {
    ReviewBadge? badge;
    if (j['badge'] != null) {
      badge = ReviewBadge.values.firstWhere(
        (b) => b.name == j['badge'],
        orElse: () => ReviewBadge.gentle,
      );
    }
    return WeeklyReview(
      id: j['id'] as String?,
      userId: j['user_id'] as String,
      weekStart: DateTime.parse(j['week_start'] as String),
      tasksCompleted: (j['tasks_completed'] as num).toInt(),
      tasksTotal: (j['tasks_total'] as num).toInt(),
      focusMinutes: (j['focus_minutes'] as num).toInt(),
      checkinsDone: (j['checkins_done'] as num).toInt(),
      avgMood: j['avg_mood'] != null ? (j['avg_mood'] as num).toDouble() : null,
      avgEnergy: j['avg_energy'] != null ? (j['avg_energy'] as num).toDouble() : null,
      completionRate: (j['completion_rate'] as num?)?.toDouble() ?? 0,
      badge: badge,
      bestMoment: j['best_moment'] as String?,
      mainBlocker: j['main_blocker'] as String?,
      weeklyIntention: j['weekly_intention'] as String?,
      focusHabit: j['focus_habit'] as String?,
      capturesProcessed: (j['captures_processed'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(j['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'week_start': weekStart.toIso8601String().split('T').first,
    'tasks_completed': tasksCompleted,
    'tasks_total': tasksTotal,
    'focus_minutes': focusMinutes,
    'checkins_done': checkinsDone,
    'avg_mood': avgMood,
    'avg_energy': avgEnergy,
    'completion_rate': completionRate,
    'badge': badge?.name,
    'best_moment': bestMoment,
    'main_blocker': mainBlocker,
    'weekly_intention': weeklyIntention,
    'focus_habit': focusHabit,
    'captures_processed': capturesProcessed,
  };

  WeeklyReview copyWith({
    String? bestMoment,
    String? mainBlocker,
    String? weeklyIntention,
    String? focusHabit,
  }) => WeeklyReview(
    id: id,
    userId: userId,
    weekStart: weekStart,
    tasksCompleted: tasksCompleted,
    tasksTotal: tasksTotal,
    focusMinutes: focusMinutes,
    checkinsDone: checkinsDone,
    avgMood: avgMood,
    avgEnergy: avgEnergy,
    completionRate: completionRate,
    badge: badge,
    bestMoment: bestMoment ?? this.bestMoment,
    mainBlocker: mainBlocker ?? this.mainBlocker,
    weeklyIntention: weeklyIntention ?? this.weeklyIntention,
    focusHabit: focusHabit ?? this.focusHabit,
    capturesProcessed: capturesProcessed,
    createdAt: createdAt,
  );
}
