enum QuestionType { emojiScale, choice }

class CheckinQuestion {
  final String question;
  final String subtitle;
  final QuestionType type;
  final List<String> emojis;
  final List<String>? choiceLabels; // uniquement pour type choice
  final String Function(int answer) soloMessage;

  const CheckinQuestion({
    required this.question,
    required this.subtitle,
    required this.type,
    required this.emojis,
    required this.soloMessage,
    this.choiceLabels,
  });
}

class CheckinEntry {
  final DateTime date;
  final bool isMorning;
  final List<int> answers; // valeurs 1–5 (ou 1–3 pour choice)
  final double energyScore; // 1–10

  const CheckinEntry({
    required this.date,
    required this.isMorning,
    required this.answers,
    required this.energyScore,
  });
}

// ─── Questions matin ──────────────────────────────────────────────────────────

const List<CheckinQuestion> morningQuestions = [
  CheckinQuestion(
    question: 'Comment tu te sens en énergie ?',
    subtitle: 'Évalue ton niveau dès le réveil',
    type: QuestionType.emojiScale,
    emojis: ['😴', '😔', '😐', '😊', '🚀'],
    soloMessage: _morningEnergyMessage,
  ),
  CheckinQuestion(
    question: 'Comment est ton humeur ce matin ?',
    subtitle: 'Sois honnête, c\'est juste pour toi',
    type: QuestionType.emojiScale,
    emojis: ['😤', '😟', '😐', '🙂', '😁'],
    soloMessage: _morningMoodMessage,
  ),
  CheckinQuestion(
    question: 'Comment as-tu dormi cette nuit ?',
    subtitle: 'Qualité de ton sommeil',
    type: QuestionType.emojiScale,
    emojis: ['💀', '😩', '😐', '😌', '🌟'],
    soloMessage: _morningSleepMessage,
  ),
];

// ─── Questions soir ───────────────────────────────────────────────────────────

const List<CheckinQuestion> eveningQuestions = [
  CheckinQuestion(
    question: 'Comment s\'est passée ta journée ?',
    subtitle: 'Dans l\'ensemble, bonne ou mauvaise ?',
    type: QuestionType.emojiScale,
    emojis: ['💀', '😩', '😐', '😊', '🌟'],
    soloMessage: _eveningDayMessage,
  ),
  CheckinQuestion(
    question: 'As-tu accompli tes priorités ?',
    subtitle: 'Tes 3 tâches clés du jour',
    type: QuestionType.choice,
    emojis: ['❌', '🤏', '✅'],
    choiceLabels: ['Pas vraiment', 'En partie', 'Oui, tout !'],
    soloMessage: _eveningTasksMessage,
  ),
  CheckinQuestion(
    question: 'Quel était ton niveau de stress ?',
    subtitle: 'Ressenti global de la journée',
    type: QuestionType.emojiScale,
    emojis: ['🤯', '😰', '😐', '😌', '🧘'],
    soloMessage: _eveningStressMessage,
  ),
];

// ─── Messages de Solo ─────────────────────────────────────────────────────────

String _morningEnergyMessage(int v) {
  if (v <= 2) return 'Ouf, dur réveil. Vas-y doucement ce matin 💙';
  if (v == 3) return 'Pas mal ! Un café et c\'est parti 😄';
  return 'Tu es en feu ! Belle journée en perspective 🚀';
}

String _morningMoodMessage(int v) {
  if (v <= 2) return 'L\'humeur ça se travaille. Respire 🌬️';
  if (v == 3) return 'Neutre, c\'est déjà bien. La journée peut tout changer !';
  return 'Super humeur ! Ça se verra dans ta productivité 😊';
}

String _morningSleepMessage(int v) {
  if (v <= 2) return 'Sommeil difficile… Note-le, on analysera ça 📊';
  if (v == 3) return 'Sommeil moyen. Tâche de récupérer ce soir.';
  return 'Belle nuit de sommeil ! Ton cerveau est rechargé 🌟';
}

String _eveningDayMessage(int v) {
  if (v <= 2) return 'Journée difficile. Ça arrive, tu t\'en es sorti(e) 💪';
  if (v == 3) return 'Une journée correcte. Demain sera mieux !';
  return 'Excellent ! Cette énergie positive se construit 🙌';
}

String _eveningTasksMessage(int v) {
  if (v == 1) return 'Pas grave, demain tu repars plus fort(e) 💙';
  if (v == 2) return 'C\'est un début ! La régularité fait la différence.';
  return 'Bravo ! Tu as tenu tes engagements du jour ✅';
}

String _eveningStressMessage(int v) {
  if (v <= 2) return 'Beaucoup de stress aujourd\'hui. Déconnecte ce soir 🌙';
  if (v == 3) return 'Stress modéré. Un peu de détente ce soir ?';
  return 'Super zen ! Tu gères ton stress comme un pro 🧘';
}

// ─── Calcul du score énergie (1–10) ──────────────────────────────────────────

double computeEnergyScore(List<int> answers) {
  if (answers.isEmpty) return 0;
  final sum = answers.fold<int>(0, (a, b) => a + b);
  final avg = sum / answers.length; // 1–5
  return double.parse(((avg / 5) * 10).toStringAsFixed(1));
}

// Mock data historique (7 derniers jours)
final List<CheckinEntry> mockHistory = [
  CheckinEntry(date: DateTime.now().subtract(const Duration(days: 6)), isMorning: true, answers: [3, 4, 3], energyScore: 6.7),
  CheckinEntry(date: DateTime.now().subtract(const Duration(days: 5)), isMorning: true, answers: [4, 4, 5], energyScore: 8.7),
  CheckinEntry(date: DateTime.now().subtract(const Duration(days: 4)), isMorning: true, answers: [2, 3, 2], energyScore: 4.7),
  CheckinEntry(date: DateTime.now().subtract(const Duration(days: 3)), isMorning: true, answers: [5, 5, 4], energyScore: 9.3),
  CheckinEntry(date: DateTime.now().subtract(const Duration(days: 2)), isMorning: true, answers: [3, 3, 4], energyScore: 6.7),
  CheckinEntry(date: DateTime.now().subtract(const Duration(days: 1)), isMorning: true, answers: [4, 5, 5], energyScore: 9.3),
];
