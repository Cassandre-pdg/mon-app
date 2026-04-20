class SleepLog {
  final String id;
  final String userId;
  final DateTime sleepDate;
  final String bedtime;
  final String wakeTime;
  final int durationMinutes;
  final int? qualityScore;
  final String? notes;
  final DateTime createdAt;

  const SleepLog({
    required this.id,
    required this.userId,
    required this.sleepDate,
    required this.bedtime,
    required this.wakeTime,
    required this.durationMinutes,
    this.qualityScore,
    this.notes,
    required this.createdAt,
  });

  factory SleepLog.fromJson(Map<String, dynamic> json) => SleepLog(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        sleepDate: DateTime.parse(json['sleep_date'] as String),
        bedtime: (json['bedtime'] as String).substring(0, 5),
        wakeTime: (json['wake_time'] as String).substring(0, 5),
        durationMinutes: (json['duration_minutes'] as int?) ?? 0,
        qualityScore: json['quality_score'] as int?,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  String get durationDisplay {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m > 0 ? '${h}h${m.toString().padLeft(2, '0')}' : '${h}h';
  }
}
