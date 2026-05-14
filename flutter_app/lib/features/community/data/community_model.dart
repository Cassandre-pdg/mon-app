// Modèles de la communauté Kolyb — Le Salon

// ── Types de post ─────────────────────────────────────────────
// 'partage' n'existe plus dans le code mais peut exister en DB sur
// d'anciens posts — fromDb le redirige vers 'reflexion'.
enum PostType { question, debat, victoire, aide, reflexion, sondage }

extension PostTypeX on PostType {
  String get label {
    switch (this) {
      case PostType.question:  return 'Question';
      case PostType.debat:     return 'Débat';
      case PostType.victoire:  return 'Victoire';
      case PostType.aide:      return 'Aide';
      case PostType.reflexion: return 'Partage';
      case PostType.sondage:   return 'Sondage';
    }
  }

  String get emoji {
    switch (this) {
      case PostType.question:  return '🙋';
      case PostType.debat:     return '🔥';
      case PostType.victoire:  return '🏆';
      case PostType.aide:      return '🤝';
      case PostType.reflexion: return '💬';
      case PostType.sondage:   return '🗳️';
    }
  }

  String get placeholder {
    switch (this) {
      case PostType.question:  return 'Ta question pour les autres indépendants...';
      case PostType.debat:     return 'Pose le sujet, présente les deux côtés...';
      case PostType.victoire:  return 'Qu\'est-ce que tu as accompli ? Même petit, ça compte.';
      case PostType.aide:      return 'De quelle aide as-tu besoin ? Sois précis.';
      case PostType.reflexion: return 'Ce que tu as envie de partager avec Le Salon...';
      case PostType.sondage:   return 'Ta question pour le vote (ex: "Quel outil utilises-tu ?")';
    }
  }

  String get dbValue => name;

  static PostType fromDb(String? v) {
    if (v == 'partage') return PostType.reflexion; // rétrocompat anciens posts
    return PostType.values.firstWhere(
      (e) => e.name == v,
      orElse: () => PostType.reflexion,
    );
  }
}

// ── Types de réaction ─────────────────────────────────────────
enum ReactionType { utile, inspirant, merci, bravo }

extension ReactionTypeX on ReactionType {
  String get emoji {
    switch (this) {
      case ReactionType.utile:      return '💡';
      case ReactionType.inspirant:  return '🔥';
      case ReactionType.merci:      return '🙏';
      case ReactionType.bravo:      return '👏';
    }
  }

  String get label {
    switch (this) {
      case ReactionType.utile:      return 'Utile';
      case ReactionType.inspirant:  return 'Inspirant';
      case ReactionType.merci:      return 'Merci';
      case ReactionType.bravo:      return 'Bravo';
    }
  }

  String get dbColumn {
    switch (this) {
      case ReactionType.utile:      return 'reactions_utile';
      case ReactionType.inspirant:  return 'reactions_inspirant';
      case ReactionType.merci:      return 'reactions_merci';
      case ReactionType.bravo:      return 'reactions_bravo';
    }
  }
}

// ── Post du feed ──────────────────────────────────────────────
class CommunityPost {
  final String id;
  final String userId;
  final String authorName;
  final String content;
  final PostType postType;
  final String? postTag;
  final int repliesCount;
  final bool isFlagged;
  final int reactionsUtile;
  final int reactionsInspirant;
  final int reactionsMerci;
  final int reactionsBravo;
  // Sondage : null si le post n'est pas un sondage
  final List<String>? pollOptions;
  final List<int>? pollVotes;
  final DateTime createdAt;

  const CommunityPost({
    required this.id,
    required this.userId,
    required this.authorName,
    required this.content,
    required this.postType,
    this.postTag,
    this.repliesCount = 0,
    this.isFlagged = false,
    this.reactionsUtile = 0,
    this.reactionsInspirant = 0,
    this.reactionsMerci = 0,
    this.reactionsBravo = 0,
    this.pollOptions,
    this.pollVotes,
    required this.createdAt,
  });

  int get totalReactions =>
      reactionsUtile + reactionsInspirant + reactionsMerci + reactionsBravo;

  int get totalPollVotes =>
      pollVotes?.fold<int>(0, (sum, v) => sum + v) ?? 0;

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id:                 json['id'] as String,
      userId:             json['user_id'] as String,
      authorName:         (json['author_name'] as String?) ?? 'Anonyme',
      content:            json['content'] as String,
      postType:           PostTypeX.fromDb(json['post_type'] as String?),
      postTag:            json['post_tag'] as String?,
      repliesCount:       (json['replies_count'] as int?) ?? 0,
      isFlagged:          (json['is_flagged'] as bool?) ?? false,
      reactionsUtile:     (json['reactions_utile'] as int?) ?? 0,
      reactionsInspirant: (json['reactions_inspirant'] as int?) ?? 0,
      reactionsMerci:     (json['reactions_merci'] as int?) ?? 0,
      reactionsBravo:     (json['reactions_bravo'] as int?) ?? 0,
      pollOptions: json['poll_options'] != null
          ? (json['poll_options'] as List).map((e) => e.toString()).toList()
          : null,
      pollVotes: json['poll_votes'] != null
          ? (json['poll_votes'] as List).map((e) => (e as num).toInt()).toList()
          : null,
      createdAt:          DateTime.parse(json['created_at'] as String),
    );
  }

  CommunityPost copyWith({
    int? reactionsUtile,
    int? reactionsInspirant,
    int? reactionsMerci,
    int? reactionsBravo,
    int? repliesCount,
    bool? isFlagged,
    List<int>? pollVotes,
  }) {
    return CommunityPost(
      id:                 id,
      userId:             userId,
      authorName:         authorName,
      content:            content,
      postType:           postType,
      postTag:            postTag,
      repliesCount:       repliesCount ?? this.repliesCount,
      isFlagged:          isFlagged ?? this.isFlagged,
      reactionsUtile:     reactionsUtile ?? this.reactionsUtile,
      reactionsInspirant: reactionsInspirant ?? this.reactionsInspirant,
      reactionsMerci:     reactionsMerci ?? this.reactionsMerci,
      reactionsBravo:     reactionsBravo ?? this.reactionsBravo,
      pollOptions:        pollOptions,
      pollVotes:          pollVotes ?? this.pollVotes,
      createdAt:          createdAt,
    );
  }
}

// ── Tags prédéfinis (20 tags V1 — jamais de saisie libre) ─────
const salonTags = [
  '#facturation',  '#clients',     '#prospection',  '#organisation',
  '#outils',       '#contrats',    '#bien-etre',    '#motivation',
  '#freelance',    '#agence',      '#tarifs',       '#teletravail',
  '#productivite', '#compta',      '#juridique',    '#communication',
  '#projet',       '#reseau',      '#formation',    '#pricing',
];

// ── Question hebdomadaire du Salon (52 semaines, rotation annuelle) ──
const _weeklyQuestions = [
  "Quel outil ou rituel t'a fait gagner le plus de temps ce mois-ci ?",
  "Comment tu gères les périodes creuses entre deux missions ?",
  "Quelle est ta règle non négociable avec tes clients ?",
  "Comment tu as trouvé ton premier vrai client ?",
  "Qu'est-ce que tu aurais voulu savoir avant de te lancer ?",
  "Comment tu fixes ton tarif journalier ou tes prix ?",
  "Quel est ton plus grand défi en ce moment en tant qu'indépendant ?",
  "Comment tu organises ta semaine pour rester efficace ?",
  "Quelle ressource t'a le plus aidé à progresser cette année ?",
  "Comment tu gères la solitude du travail indépendant ?",
  "Quelle erreur tu ne referais plus dans ta relation client ?",
  "Comment tu te motives les jours où rien ne va ?",
  "Quel aspect administratif t'a pris le plus de temps à maîtriser ?",
  "Comment tu trouves l'équilibre entre travail et vie perso ?",
  "Quelle compétence t'a permis d'augmenter tes revenus ?",
  "Comment tu gères les clients qui ne payent pas à temps ?",
  "Quel projet t'a le plus appris cette année ?",
  "Comment tu restes concentré face aux distractions ?",
  "Quelle est ta stratégie pour fidéliser tes clients ?",
  "Comment tu prends soin de ta santé mentale en tant qu'indépendant ?",
  "Quel outil de gestion de projet utilises-tu et pourquoi ?",
  "Comment tu présentes ta valeur à un prospect sans te brader ?",
  "Quelle routine du matin t'aide à bien démarrer ta journée ?",
  "Comment tu as géré ton premier gros refus ou échec ?",
  "Quelle décision professionnelle semblait risquée mais s'est révélée juste ?",
  "Comment tu te démarques dans un marché saturé ?",
  "Quel aspect de ton travail te donne le plus d'énergie ?",
  "Comment tu gères une mission qui se passe mal ?",
  "Quelle est ta méthode pour ne rien oublier au quotidien ?",
  "Comment tu as appris à dire non sans perdre un client ?",
  "Quel secteur ou type de client t'a le plus surpris positivement ?",
  "Comment tu construis ta réputation en ligne ?",
  "Quelle limite as-tu du mal à poser avec tes clients ?",
  "Comment tu prépares et conduis tes entretiens commerciaux ?",
  "Quel aspect de la gestion financière tu maîtrises le moins ?",
  "Comment tu restes curieux et tu continues à progresser ?",
  "Quelle question tu te poses chaque semaine pour avancer ?",
  "Comment tu choisis tes missions et tu filtres les mauvais clients ?",
  "Quelle est ta plus grande fierté depuis que tu es indépendant ?",
  "Comment tu gères le stress des fins de mois difficiles ?",
  "Quel est ton rapport à la concurrence dans ton secteur ?",
  "Comment tu bâtis un réseau professionnel sans te forcer ?",
  "Quelle est la première chose que tu fais quand tu décroches un nouveau client ?",
  "Comment tu évalues si une mission en vaut vraiment la peine ?",
  "Quel équipement ou espace de travail t'a le plus changé la vie ?",
  "Comment tu te prépares mentalement pour les négociations ?",
  "Quelle est ta vision de ton activité dans 3 ans ?",
  "Comment tu gardes le plaisir dans ton travail sur la durée ?",
  "Quel conseil tu donnerais à quelqu'un qui veut se lancer cette année ?",
  "Comment tu fais le bilan de ton année professionnelle ?",
  "Quelle est ta résolution principale pour l'année qui vient ?",
  "Quel mot résume le mieux ton année d'indépendant ?",
];

String get currentWeeklyQuestion {
  final now = DateTime.now();
  final weekOfYear =
      now.difference(DateTime(now.year, 1, 1)).inDays ~/ 7;
  return _weeklyQuestions[weekOfYear.clamp(0, 51)];
}


// ── Groupe thématique ─────────────────────────────────────────
class CommunityGroup {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int membersCount;
  final bool isJoined;

  const CommunityGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.membersCount,
    this.isJoined = false,
  });

  CommunityGroup copyWith({bool? isJoined}) => CommunityGroup(
        id: id,
        name: name,
        description: description,
        emoji: emoji,
        membersCount: membersCount,
        isJoined: isJoined ?? this.isJoined,
      );
}

// Groupes V1 — statiques, rejoindre/quitter en local uniquement
const v1CommunityGroups = [
  CommunityGroup(
    id: 'freelances',
    name: 'Freelances & Consultants',
    description: 'Missions, clients, tarifs, contrats. Tout ce qui fait le quotidien du freelance.',
    emoji: '💼',
    membersCount: 142,
  ),
  CommunityGroup(
    id: 'creatifs',
    name: 'Créatifs & Makers',
    description: 'Designers, développeurs, artisans. Ceux qui créent de leurs mains ou de leur tête.',
    emoji: '🎨',
    membersCount: 87,
  ),
  CommunityGroup(
    id: 'bien-etre',
    name: 'Bien-être & Énergie',
    description: 'Charge mentale, sport, sommeil, routines. Prendre soin de soi pour avancer mieux.',
    emoji: '🧘',
    membersCount: 203,
  ),
  CommunityGroup(
    id: 'business',
    name: 'Business & Revenus',
    description: 'Monétisation, pricing, croissance. Pour ceux qui veulent structurer et développer.',
    emoji: '📈',
    membersCount: 119,
  ),
  CommunityGroup(
    id: 'debutants',
    name: 'Débutants & Reconversions',
    description: 'Tu démarres ou tu te réinventes ? C\'est ici. Aucune question n\'est stupide.',
    emoji: '🌱',
    membersCount: 76,
  ),
];
