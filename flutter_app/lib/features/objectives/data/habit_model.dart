import 'package:uuid/uuid.dart';

enum HabitFrequency { daily, weekly, custom }

extension HabitFrequencyX on HabitFrequency {
  String get value {
    switch (this) {
      case HabitFrequency.daily:   return 'daily';
      case HabitFrequency.weekly:  return 'weekly';
      case HabitFrequency.custom:  return 'custom';
    }
  }

  String get label {
    switch (this) {
      case HabitFrequency.daily:  return 'Chaque jour';
      case HabitFrequency.weekly: return 'Chaque semaine';
      case HabitFrequency.custom: return 'Personnalisé';
    }
  }

  static HabitFrequency fromValue(String value) {
    switch (value) {
      case 'weekly': return HabitFrequency.weekly;
      case 'custom': return HabitFrequency.custom;
      default:       return HabitFrequency.daily;
    }
  }
}

// Jours 1=Lundi ... 7=Dimanche
const kDayLabels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

class Habit {
  final String id;
  final String userId;
  final String title;
  final String emoji;
  final HabitFrequency frequency;
  final List<int> daysOfWeek; // vide = tous les jours si daily
  final int currentStreak;
  final bool isCompletedToday; // calculé côté app, pas en base
  final DateTime createdAt;
  final DateTime updatedAt;

  const Habit({
    required this.id,
    required this.userId,
    required this.title,
    required this.emoji,
    required this.frequency,
    required this.daysOfWeek,
    required this.currentStreak,
    required this.isCompletedToday,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    bool isCompletedToday = false,
  }) =>
      Habit(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String,
        emoji: (json['emoji'] as String?) ?? '🔁',
        frequency: HabitFrequencyX.fromValue(
            (json['frequency'] as String?) ?? 'daily'),
        daysOfWeek: ((json['days_of_week'] as List?)
                ?.map((e) => e as int)
                .toList()) ??
            [],
        currentStreak: (json['current_streak'] as int?) ?? 0,
        isCompletedToday: isCompletedToday,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Habit copyWith({
    String? title,
    String? emoji,
    HabitFrequency? frequency,
    List<int>? daysOfWeek,
    int? currentStreak,
    bool? isCompletedToday,
  }) =>
      Habit(
        id: id,
        userId: userId,
        title: title ?? this.title,
        emoji: emoji ?? this.emoji,
        frequency: frequency ?? this.frequency,
        daysOfWeek: daysOfWeek ?? this.daysOfWeek,
        currentStreak: currentStreak ?? this.currentStreak,
        isCompletedToday: isCompletedToday ?? this.isCompletedToday,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

  static Habit create({
    required String userId,
    required String title,
    String emoji = '🔁',
    HabitFrequency frequency = HabitFrequency.daily,
    List<int> daysOfWeek = const [],
  }) {
    final now = DateTime.now();
    return Habit(
      id: const Uuid().v4(),
      userId: userId,
      title: title.trim(),
      emoji: emoji,
      frequency: frequency,
      daysOfWeek: daysOfWeek,
      currentStreak: 0,
      isCompletedToday: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Vérifie si l'habitude est prévue aujourd'hui
  bool isDueToday() {
    if (frequency == HabitFrequency.daily) return true;
    final todayWeekday = DateTime.now().weekday; // 1=Lundi, 7=Dimanche
    return daysOfWeek.contains(todayWeekday);
  }
}
