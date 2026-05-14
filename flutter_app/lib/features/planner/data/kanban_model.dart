import 'package:uuid/uuid.dart';

enum KanbanStatus { todo, inProgress, done }

extension KanbanStatusLabel on KanbanStatus {
  String get label {
    switch (this) {
      case KanbanStatus.todo:       return 'À faire';
      case KanbanStatus.inProgress: return 'En cours';
      case KanbanStatus.done:       return 'Terminé';
    }
  }

  String get emoji {
    switch (this) {
      case KanbanStatus.todo:       return '📋';
      case KanbanStatus.inProgress: return '⚡';
      case KanbanStatus.done:       return '✅';
    }
  }

  String get dbValue {
    switch (this) {
      case KanbanStatus.todo:       return 'todo';
      case KanbanStatus.inProgress: return 'in_progress';
      case KanbanStatus.done:       return 'done';
    }
  }

  static KanbanStatus fromDb(String value) {
    switch (value) {
      case 'in_progress': return KanbanStatus.inProgress;
      case 'done':        return KanbanStatus.done;
      default:            return KanbanStatus.todo;
    }
  }
}

// Statut du projet (cycle de vie)
enum ProjectStatus { active, paused, done }

extension ProjectStatusX on ProjectStatus {
  String get dbValue {
    switch (this) {
      case ProjectStatus.active: return 'active';
      case ProjectStatus.paused: return 'paused';
      case ProjectStatus.done:   return 'done';
    }
  }

  String get label {
    switch (this) {
      case ProjectStatus.active: return 'Actif';
      case ProjectStatus.paused: return 'En pause';
      case ProjectStatus.done:   return 'Terminé';
    }
  }

  String get emoji {
    switch (this) {
      case ProjectStatus.active: return '⚡';
      case ProjectStatus.paused: return '⏸️';
      case ProjectStatus.done:   return '🏁';
    }
  }

  static ProjectStatus fromDb(String value) {
    switch (value) {
      case 'paused': return ProjectStatus.paused;
      case 'done':   return ProjectStatus.done;
      default:       return ProjectStatus.active;
    }
  }
}

class KanbanTask {
  final String id;
  final String projectId;
  final String title;
  final KanbanStatus status;
  final DateTime? completedAt;
  final DateTime createdAt;

  const KanbanTask({
    required this.id,
    required this.projectId,
    required this.title,
    required this.status,
    this.completedAt,
    required this.createdAt,
  });

  factory KanbanTask.fromJson(Map<String, dynamic> json) => KanbanTask(
        id: json['id'] as String,
        projectId: json['project_id'] as String,
        title: json['title'] as String,
        status: KanbanStatusLabel.fromDb(json['status'] as String),
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  KanbanTask copyWith({String? title, KanbanStatus? status, DateTime? completedAt}) =>
      KanbanTask(
        id: id,
        projectId: projectId,
        title: title ?? this.title,
        status: status ?? this.status,
        completedAt: completedAt ?? this.completedAt,
        createdAt: createdAt,
      );
}

class KanbanProject {
  final String id;
  final String userId;
  final String name;
  final String? why;           // Ancrage motivationnel
  final DateTime? targetDate;  // Date cible
  final ProjectStatus projectStatus;
  final String? objectiveId;   // Objectif parent lié
  final bool isFocusProject;   // Projet mis en avant sur le dashboard
  final List<KanbanTask> tasks;
  final DateTime createdAt;

  const KanbanProject({
    required this.id,
    required this.userId,
    required this.name,
    this.why,
    this.targetDate,
    required this.projectStatus,
    this.objectiveId,
    required this.isFocusProject,
    required this.tasks,
    required this.createdAt,
  });

  factory KanbanProject.fromJson(
    Map<String, dynamic> json,
    List<KanbanTask> tasks,
  ) =>
      KanbanProject(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        why: json['why'] as String?,
        targetDate: json['target_date'] != null
            ? DateTime.parse(json['target_date'] as String)
            : null,
        projectStatus: ProjectStatusX.fromDb(json['status'] as String? ?? 'active'),
        objectiveId: json['objective_id'] as String?,
        isFocusProject: json['is_focus_project'] as bool? ?? false,
        tasks: tasks,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  KanbanProject copyWith({
    String? name,
    String? why,
    DateTime? targetDate,
    ProjectStatus? projectStatus,
    String? objectiveId,
    bool? isFocusProject,
    List<KanbanTask>? tasks,
  }) =>
      KanbanProject(
        id: id,
        userId: userId,
        name: name ?? this.name,
        why: why ?? this.why,
        targetDate: targetDate ?? this.targetDate,
        projectStatus: projectStatus ?? this.projectStatus,
        objectiveId: objectiveId ?? this.objectiveId,
        isFocusProject: isFocusProject ?? this.isFocusProject,
        tasks: tasks ?? this.tasks,
        createdAt: createdAt,
      );

  // Helpers progression
  int get todoCount       => tasks.where((t) => t.status == KanbanStatus.todo).length;
  int get inProgressCount => tasks.where((t) => t.status == KanbanStatus.inProgress).length;
  int get doneCount       => tasks.where((t) => t.status == KanbanStatus.done).length;

  double get progressPercent =>
      tasks.isEmpty ? 0.0 : doneCount / tasks.length;

  String get progressLabel =>
      tasks.isEmpty ? 'Aucune tâche' : '$doneCount/${tasks.length} terminées';

  // Nombre de jours restants avant la date cible
  int? get daysLeft {
    if (targetDate == null) return null;
    final diff = targetDate!.difference(DateTime.now()).inDays;
    return diff;
  }

  // Retourne true si le projet est en retard
  bool get isOverdue =>
      targetDate != null &&
      !isCompleted &&
      DateTime.now().isAfter(targetDate!);

  bool get isCompleted => projectStatus == ProjectStatus.done;
  bool get isActive    => projectStatus == ProjectStatus.active;

  static KanbanProject create(String userId, String name, {
    String? why,
    DateTime? targetDate,
    String? objectiveId,
  }) =>
      KanbanProject(
        id: const Uuid().v4(),
        userId: userId,
        name: name.trim(),
        why: why?.trim(),
        targetDate: targetDate,
        projectStatus: ProjectStatus.active,
        objectiveId: objectiveId,
        isFocusProject: false,
        tasks: [],
        createdAt: DateTime.now(),
      );
}
