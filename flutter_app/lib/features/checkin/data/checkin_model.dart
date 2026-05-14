/// Modèle d'un check-in — correspond à la table `checkins` Supabase
class CheckinModel {
  final String id;
  final String userId;
  final String type; // 'morning' | 'evening'
  final int moodScore;
  final int energyScore;
  final int focusScore;
  final String? notes;
  final String? wellbeingNote;
  final String? focusProjectId;

  // Champs texte libre — refonte check-in matin/soir
  final String? dailyIntention;    // Matin Q3 : priorité du jour
  final String? dailySuccess;      // Matin Q4 : ce qui rendrait la journée réussie
  final String? dailyVictory;      // Soir Q2  : victoire du jour
  final String? dailyLearning;     // Soir Q3  : aurais fait différemment
  final String? tomorrowIntention; // Soir Q4  : intention pour demain

  final DateTime createdAt;

  const CheckinModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.moodScore,
    required this.energyScore,
    required this.focusScore,
    this.notes,
    this.wellbeingNote,
    this.focusProjectId,
    this.dailyIntention,
    this.dailySuccess,
    this.dailyVictory,
    this.dailyLearning,
    this.tomorrowIntention,
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
        wellbeingNote: json['wellbeing_note'] as String?,
        focusProjectId: json['focus_project_id'] as String?,
        dailyIntention: json['daily_intention'] as String?,
        dailySuccess: json['daily_success'] as String?,
        dailyVictory: json['daily_victory'] as String?,
        dailyLearning: json['daily_learning'] as String?,
        tomorrowIntention: json['tomorrow_intention'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'type': type,
        'mood_score': moodScore,
        'energy_score': energyScore,
        'focus_score': focusScore,
        if (notes != null) 'notes': notes,
        if (wellbeingNote != null && wellbeingNote!.isNotEmpty)
          'wellbeing_note': wellbeingNote,
        if (focusProjectId != null) 'focus_project_id': focusProjectId,
        if (dailyIntention != null && dailyIntention!.isNotEmpty)
          'daily_intention': dailyIntention,
        if (dailySuccess != null && dailySuccess!.isNotEmpty)
          'daily_success': dailySuccess,
        if (dailyVictory != null && dailyVictory!.isNotEmpty)
          'daily_victory': dailyVictory,
        if (dailyLearning != null && dailyLearning!.isNotEmpty)
          'daily_learning': dailyLearning,
        if (tomorrowIntention != null && tomorrowIntention!.isNotEmpty)
          'tomorrow_intention': tomorrowIntention,
      };

  bool get isMorning => type == 'morning';
}
