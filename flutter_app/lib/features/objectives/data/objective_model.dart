import 'package:uuid/uuid.dart';

enum ObjectiveHorizon { shortTerm, mediumTerm, longTerm }

extension ObjectiveHorizonX on ObjectiveHorizon {
  String get value {
    switch (this) {
      case ObjectiveHorizon.shortTerm:  return 'short_term';
      case ObjectiveHorizon.mediumTerm: return 'medium_term';
      case ObjectiveHorizon.longTerm:   return 'long_term';
    }
  }

  String get label {
    switch (this) {
      case ObjectiveHorizon.shortTerm:  return 'Court terme';
      case ObjectiveHorizon.mediumTerm: return 'Moyen terme';
      case ObjectiveHorizon.longTerm:   return 'Long terme';
    }
  }

  String get detail {
    switch (this) {
      case ObjectiveHorizon.shortTerm:  return '1 à 4 semaines';
      case ObjectiveHorizon.mediumTerm: return '1 à 6 mois';
      case ObjectiveHorizon.longTerm:   return '6 mois et plus';
    }
  }

  String get emoji {
    switch (this) {
      case ObjectiveHorizon.shortTerm:  return '🌱';
      case ObjectiveHorizon.mediumTerm: return '🚀';
      case ObjectiveHorizon.longTerm:   return '🏆';
    }
  }

  static ObjectiveHorizon fromValue(String value) {
    switch (value) {
      case 'short_term':  return ObjectiveHorizon.shortTerm;
      case 'medium_term': return ObjectiveHorizon.mediumTerm;
      case 'long_term':   return ObjectiveHorizon.longTerm;
      default:            return ObjectiveHorizon.shortTerm;
    }
  }
}

class Objective {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final ObjectiveHorizon horizon;
  final double progressPercent; // 0.0 à 1.0
  final bool isCompleted;
  final DateTime? targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Objective({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.horizon,
    required this.progressPercent,
    required this.isCompleted,
    this.targetDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Objective.fromJson(Map<String, dynamic> json) => Objective(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        horizon: ObjectiveHorizonX.fromValue(json['horizon'] as String),
        progressPercent:
            (json['progress_percent'] as num?)?.toDouble() ?? 0.0,
        isCompleted: json['is_completed'] as bool? ?? false,
        targetDate: json['target_date'] != null
            ? DateTime.parse(json['target_date'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'horizon': horizon.value,
        'progress_percent': progressPercent,
        'is_completed': isCompleted,
        'target_date': targetDate?.toIso8601String().split('T')[0],
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Objective copyWith({
    String? title,
    String? description,
    ObjectiveHorizon? horizon,
    double? progressPercent,
    bool? isCompleted,
    DateTime? targetDate,
  }) =>
      Objective(
        id: id,
        userId: userId,
        title: title ?? this.title,
        description: description ?? this.description,
        horizon: horizon ?? this.horizon,
        progressPercent: progressPercent ?? this.progressPercent,
        isCompleted: isCompleted ?? this.isCompleted,
        targetDate: targetDate ?? this.targetDate,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

  static Objective create({
    required String userId,
    required String title,
    required ObjectiveHorizon horizon,
    String? description,
    DateTime? targetDate,
  }) {
    final now = DateTime.now();
    return Objective(
      id: const Uuid().v4(),
      userId: userId,
      title: title.trim(),
      description: description?.trim(),
      horizon: horizon,
      progressPercent: 0.0,
      isCompleted: false,
      targetDate: targetDate,
      createdAt: now,
      updatedAt: now,
    );
  }
}
