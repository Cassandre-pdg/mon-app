class PlannerTask {
  final String id;
  final String userId;
  final String title;
  final int priority; // 1, 2, 3
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime plannedDate;
  final int pomodoroCount;
  final DateTime createdAt;

  const PlannerTask({
    required this.id,
    required this.userId,
    required this.title,
    required this.priority,
    required this.isCompleted,
    this.completedAt,
    required this.plannedDate,
    required this.pomodoroCount,
    required this.createdAt,
  });

  factory PlannerTask.fromJson(Map<String, dynamic> json) => PlannerTask(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String,
        priority: json['priority'] as int,
        isCompleted: json['is_completed'] as bool,
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        plannedDate: DateTime.parse(json['planned_date'] as String),
        pomodoroCount: (json['pomodoro_count'] as int?) ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  PlannerTask copyWith({
    String? title,
    int? priority,
    bool? isCompleted,
    DateTime? completedAt,
  }) =>
      PlannerTask(
        id: id,
        userId: userId,
        title: title ?? this.title,
        priority: priority ?? this.priority,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt ?? this.completedAt,
        plannedDate: plannedDate,
        pomodoroCount: pomodoroCount,
        createdAt: createdAt,
      );
}
