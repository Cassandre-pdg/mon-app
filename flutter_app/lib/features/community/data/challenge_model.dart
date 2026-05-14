// ── Modèle de défi communautaire mensuel ──────────────────────
class KolybChallenge {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final String rewardLabel;
  final DateTime startDate;
  final DateTime endDate;
  final int targetDays;
  final int participantsCount;
  final int userProgressDays;
  final bool isJoined;

  const KolybChallenge({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.rewardLabel,
    required this.startDate,
    required this.endDate,
    required this.targetDays,
    required this.participantsCount,
    required this.userProgressDays,
    required this.isJoined,
  });

  double get progressRatio =>
      targetDays > 0 ? (userProgressDays / targetDays).clamp(0.0, 1.0) : 0.0;

  bool get isActive =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);

  bool get isCompleted => userProgressDays >= targetDays;

  int get daysRemaining =>
      endDate.difference(DateTime.now()).inDays.clamp(0, 999);

  KolybChallenge copyWith({
    bool? isJoined,
    int? userProgressDays,
    int? participantsCount,
  }) =>
      KolybChallenge(
        id: id,
        emoji: emoji,
        title: title,
        description: description,
        rewardLabel: rewardLabel,
        startDate: startDate,
        endDate: endDate,
        targetDays: targetDays,
        participantsCount: participantsCount ?? this.participantsCount,
        userProgressDays: userProgressDays ?? this.userProgressDays,
        isJoined: isJoined ?? this.isJoined,
      );
}

// ── Générateur du défi mensuel courant ────────────────────────
KolybChallenge buildCurrentChallenge({
  required bool isJoined,
  required int progressDays,
  required int communityCount,
}) {
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, 1);
  // Dernier jour du mois courant
  final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  const monthData = {
    1: ('🌅', 'Rituel Matin', '21 matins de check-in consécutifs pour démarrer l\'année en force'),
    2: ('💜', 'Auto-compassion', '14 jours de check-in complet, matin et soir, sans te juger'),
    3: ('🌱', 'Printemps du Focus', '21 sessions de Focus complétées pour cultiver ta concentration'),
    4: ('⚡', 'Élan d\'Avril', '21 jours de rituel matin : construis une habitude durable'),
    5: ('🔥', 'Mai en Flammes', '21 jours de rituel matin consécutifs, ensemble dans la tribu'),
    6: ('🌞', 'Été Actif', '14 jours de bien-être complet : check-in matin et soir'),
    7: ('🏖️', 'Rythme d\'Été', '14 matins de check-in, même en vacances, pour garder l\'élan'),
    8: ('💪', 'Retour en Force', '21 jours de rituel complet pour reprendre l\'élan après l\'été'),
    9: ('📚', 'Rentrée Kolyb', '21 jours de régularité pour ancrer ta rentrée dans de bonnes bases'),
    10: ('🍂', 'Ancrage d\'Automne', '21 jours de présence quotidienne avant l\'arrivée de l\'hiver'),
    11: ('✨', 'Gratitude', '14 soirs de check-in pour cultiver la gratitude en cette fin d\'année'),
    12: ('🎁', 'Bilan de l\'Année', '21 jours pour finir l\'année en beauté et préparer la suivante'),
  };

  final (emoji, name, desc) =
      monthData[now.month] ?? ('🔥', 'Défi Mensuel', '21 jours de régularité dans la communauté');

  return KolybChallenge(
    id: 'challenge_${now.year}_${now.month}',
    emoji: emoji,
    title: name,
    description: desc,
    rewardLabel: 'Badge "Défi complété" 🏅',
    startDate: startDate,
    endDate: endDate,
    targetDays: 21,
    participantsCount: communityCount,
    userProgressDays: progressDays,
    isJoined: isJoined,
  );
}
