/// Modèle d'un check-in — correspond à la table `checkins` Supabase
class CheckinModel {
  final String id;
  final String userId;
  final String type; // 'morning' | 'evening'
  final int moodScore;
  final int energyScore;
  final int focusScore;
  final String? notes;
  final DateTime createdAt;

  const CheckinModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.moodScore,
    required this.energyScore,
    required this.focusScore,
    this.notes,
    required this.createdAt,
  });

  factory CheckinModel.fromJson(Map<String, dynamic> json) => CheckinModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        type: json['type'] as String,
        moodScore: json['mood_score'] as int,
        energyScore: json['energy_score'] as int,
        focusScore: json['focus_score'] as int,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'type': type,
        'mood_score': moodScore,
        'energy_score': energyScore,
        'focus_score': focusScore,
        if (notes != null) 'notes': notes,
      };

  bool get isMorning => type == 'morning';
}
