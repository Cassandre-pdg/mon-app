// Modèle de données pour l'onglet Flow (sessions de travail profond 90 min)

enum FlowTimerState { idle, running, paused, completed }

class FlowState {
  /// Durée d'une session Flow : 90 minutes
  static const int sessionDurationSeconds = 90 * 60;

  /// Nombre de sessions configurées par jour (1 ou 4)
  final int sessionsPerDay;

  /// Sessions complétées aujourd'hui
  final int completedToday;

  /// État courant du timer
  final FlowTimerState timerState;

  /// Secondes restantes dans la session en cours
  final int secondsLeft;

  /// Total de minutes de focus accumulées aujourd'hui
  final int totalFocusMinutesToday;

  const FlowState({
    this.sessionsPerDay = 1,
    this.completedToday = 0,
    this.timerState = FlowTimerState.idle,
    this.secondsLeft = sessionDurationSeconds,
    this.totalFocusMinutesToday = 0,
  });

  FlowState copyWith({
    int? sessionsPerDay,
    int? completedToday,
    FlowTimerState? timerState,
    int? secondsLeft,
    int? totalFocusMinutesToday,
  }) =>
      FlowState(
        sessionsPerDay: sessionsPerDay ?? this.sessionsPerDay,
        completedToday: completedToday ?? this.completedToday,
        timerState: timerState ?? this.timerState,
        secondsLeft: secondsLeft ?? this.secondsLeft,
        totalFocusMinutesToday:
            totalFocusMinutesToday ?? this.totalFocusMinutesToday,
      );

  /// Progression de la session (0.0 → 1.0)
  double get sessionProgress =>
      1.0 - secondsLeft / sessionDurationSeconds;

  /// Toutes les sessions du jour sont complètes
  bool get allSessionsDone => completedToday >= sessionsPerDay;

  /// Affichage mm:ss du timer
  String get timeDisplay {
    final m = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Heures de notifications selon le nombre de sessions
  /// - 1x/jour  → [09:00]
  /// - 4x/jour  → [09:00, 11:30, 14:00, 16:30]
  List<String> get notificationTimes {
    if (sessionsPerDay == 1) return ['09:00'];
    return ['09:00', '11:30', '14:00', '16:30'];
  }
}
