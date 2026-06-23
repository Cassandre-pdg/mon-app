class PlannerTask {
  final String id;
  final String userId;
  final String title;
  final int priority; // 1, 2, 3
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime plannedDate;
  final int pomodoroCount;
  final String? projectId;
  final String? projectName;
  final String? kanbanTaskId;  // tâche Kanban liée (cochée automatiquement)
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
    this.projectId,
    this.projectName,
    this.kanbanTaskId,
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
        projectId: json['project_id'] as String?,
        projectName: json['kanban_projects'] != null
            ? (json['kanban_projects'] as Map<String, dynamic>)['name']
                as String?
            : null,
        kanbanTaskId: json['kanban_task_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  PlannerTask copyWith({
    String? title,
    int? priority,
    bool? isCompleted,
    DateTime? completedAt,
    String? projectId,
    String? kanbanTaskId,
    bool clearProject = false,
    bool clearKanbanTask = false,
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
        projectId: clearProject ? null : (projectId ?? this.projectId),
        projectName: clearProject ? null : projectName,
        kanbanTaskId: clearKanbanTask ? null : (kanbanTaskId ?? this.kanbanTaskId),
        createdAt: createdAt,
      );
}
