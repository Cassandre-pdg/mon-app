import 'package:flutter/material.dart';

enum TaskPriority { high, medium, low }

enum EisenhowerQuadrant { urgentImportant, notUrgentImportant, urgentNotImportant, notUrgentNotImportant }

class Task {
  final String id;
  String label;
  bool done;
  TaskPriority priority;
  EisenhowerQuadrant? quadrant;
  Duration? estimatedTime;

  Task({
    required this.id,
    required this.label,
    this.done = false,
    this.priority = TaskPriority.medium,
    this.quadrant,
    this.estimatedTime,
  });

  Task copyWith({
    String? label,
    bool? done,
    TaskPriority? priority,
    EisenhowerQuadrant? quadrant,
  }) {
    return Task(
      id: id,
      label: label ?? this.label,
      done: done ?? this.done,
      priority: priority ?? this.priority,
      quadrant: quadrant ?? this.quadrant,
      estimatedTime: estimatedTime,
    );
  }
}

extension TaskPriorityExt on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.high: return 'Haute';
      case TaskPriority.medium: return 'Moyenne';
      case TaskPriority.low: return 'Basse';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.high: return const Color(0xFFFF6B6B);
      case TaskPriority.medium: return const Color(0xFFFFD93D);
      case TaskPriority.low: return const Color(0xFF4CAF50);
    }
  }

  String get emoji {
    switch (this) {
      case TaskPriority.high: return '🔴';
      case TaskPriority.medium: return '🟡';
      case TaskPriority.low: return '🟢';
    }
  }
}

extension EisenhowerExt on EisenhowerQuadrant {
  String get title {
    switch (this) {
      case EisenhowerQuadrant.urgentImportant: return 'Faire maintenant';
      case EisenhowerQuadrant.notUrgentImportant: return 'Planifier';
      case EisenhowerQuadrant.urgentNotImportant: return 'Déléguer';
      case EisenhowerQuadrant.notUrgentNotImportant: return 'Éliminer';
    }
  }

  String get emoji {
    switch (this) {
      case EisenhowerQuadrant.urgentImportant: return '🔥';
      case EisenhowerQuadrant.notUrgentImportant: return '📅';
      case EisenhowerQuadrant.urgentNotImportant: return '🤝';
      case EisenhowerQuadrant.notUrgentNotImportant: return '🗑️';
    }
  }

  Color get color {
    switch (this) {
      case EisenhowerQuadrant.urgentImportant: return const Color(0xFFFF6B6B);
      case EisenhowerQuadrant.notUrgentImportant: return const Color(0xFF6C63FF);
      case EisenhowerQuadrant.urgentNotImportant: return const Color(0xFFFFD93D);
      case EisenhowerQuadrant.notUrgentNotImportant: return const Color(0xFF9E9E9E);
    }
  }
}

// Mock data
List<Task> mockTasks = [
  Task(id: '1', label: 'Finaliser la proposition client', priority: TaskPriority.high, quadrant: EisenhowerQuadrant.urgentImportant),
  Task(id: '2', label: 'Répondre aux emails importants', priority: TaskPriority.medium, done: true, quadrant: EisenhowerQuadrant.urgentNotImportant),
  Task(id: '3', label: 'Préparer la réunion de demain', priority: TaskPriority.high, quadrant: EisenhowerQuadrant.notUrgentImportant),
];
