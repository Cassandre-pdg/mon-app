class TribuMember {
  final String id;
  final String prenom;
  final String metier;
  final String emoji;
  final int streak;
  final int level;
  final bool isOnline;
  final bool isFriend;
  final bool hasPendingRequest;
  final String? bio;

  const TribuMember({
    required this.id,
    required this.prenom,
    required this.metier,
    required this.emoji,
    required this.streak,
    required this.level,
    this.isOnline = false,
    this.isFriend = false,
    this.hasPendingRequest = false,
    this.bio,
  });
}

enum PostType { text, achievement, tip, question }

class TribuPost {
  final String id;
  final TribuMember author;
  final String content;
  final PostType type;
  final DateTime createdAt;
  int likes;
  bool likedByMe;
  final List<TribuComment> comments;
  final String? groupId;

  TribuPost({
    required this.id,
    required this.author,
    required this.content,
    required this.type,
    required this.createdAt,
    this.likes = 0,
    this.likedByMe = false,
    this.comments = const [],
    this.groupId,
  });
}

class TribuComment {
  final TribuMember author;
  final String content;
  final DateTime createdAt;

  const TribuComment({
    required this.author,
    required this.content,
    required this.createdAt,
  });
}

class TribuGroup {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int memberCount;
  final bool joined;
  final List<TribuPost> posts;

  const TribuGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.memberCount,
    this.joined = false,
    this.posts = const [],
  });
}

extension PostTypeExt on PostType {
  String get emoji {
    switch (this) {
      case PostType.achievement: return '🏆';
      case PostType.tip: return '💡';
      case PostType.question: return '🙋';
      case PostType.text: return '💬';
    }
  }

  String get label {
    switch (this) {
      case PostType.achievement: return 'Victoire';
      case PostType.tip: return 'Astuce';
      case PostType.question: return 'Question';
      case PostType.text: return 'Post';
    }
  }
}

// ─── Mock data ────────────────────────────────────────────────────────────────

final TribuMember me = TribuMember(
  id: 'me',
  prenom: 'Alex',
  metier: 'Freelance',
  emoji: '🧑',
  streak: 3,
  level: 2,
  isOnline: true,
);

final List<TribuMember> mockMembers = [
  TribuMember(
    id: 'm1',
    prenom: 'Sarah',
    metier: 'Designer UX',
    emoji: '👩',
    streak: 12,
    level: 5,
    isOnline: true,
    isFriend: true,
    bio: 'Designeuse UX freelance passionnée par les interfaces centrées utilisateur.',
  ),
  TribuMember(
    id: 'm2',
    prenom: 'Thomas',
    metier: 'Développeur',
    emoji: '👨‍💻',
    streak: 7,
    level: 4,
    isOnline: false,
    isFriend: true,
    bio: 'Dev fullstack, fan de Clean Code et de productivité.',
  ),
  TribuMember(
    id: 'm3',
    prenom: 'Camille',
    metier: 'Coach',
    emoji: '🧘',
    streak: 21,
    level: 7,
    isOnline: true,
    bio: 'Coach de vie et thérapeute. Je t\'aide à trouver ton équilibre.',
  ),
  TribuMember(
    id: 'm4',
    prenom: 'Lucas',
    metier: 'Consultant',
    emoji: '👔',
    streak: 5,
    level: 3,
    isOnline: false,
    hasPendingRequest: true,
    bio: 'Consultant en stratégie. Cherche à optimiser son temps.',
  ),
  TribuMember(
    id: 'm5',
    prenom: 'Julie',
    metier: 'Content Creator',
    emoji: '🎨',
    streak: 9,
    level: 4,
    isOnline: true,
    bio: 'Créatrice de contenu sur la productivité et le bien-être.',
  ),
];

final List<TribuPost> mockFeed = [
  TribuPost(
    id: 'p1',
    author: mockMembers[2], // Camille
    content: '21 jours de streak ! 🔥 La régularité, c\'est vraiment la clé. Peu importe si ce n\'est que 5 min, l\'essentiel c\'est de ne pas rater deux jours consécutifs.',
    type: PostType.achievement,
    createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
    likes: 14,
    likedByMe: false,
    comments: [
      TribuComment(
        author: mockMembers[0],
        content: 'Bravo Camille ! Tu m\'inspires 💪',
        createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
    ],
  ),
  TribuPost(
    id: 'p2',
    author: mockMembers[0], // Sarah
    content: '💡 Astuce Design / Productivité : j\'utilise la règle du "2 minutes" pour tout ce qui arrive dans mes messages. Si ça prend moins de 2 min → je le fais tout de suite. Sinon → dans Notion.',
    type: PostType.tip,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    likes: 23,
    likedByMe: true,
    comments: [],
  ),
  TribuPost(
    id: 'p3',
    author: mockMembers[1], // Thomas
    content: 'Question : vous utilisez quoi pour tracker votre temps sur vos projets ? J\'ai essayé Toggl mais c\'est un peu lourd. Une alternative plus légère ?',
    type: PostType.question,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    likes: 8,
    likedByMe: false,
    comments: [
      TribuComment(
        author: mockMembers[4],
        content: 'Clockify ! Gratuit et très simple.',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      TribuComment(
        author: mockMembers[2],
        content: 'J\'utilise juste un Google Sheet perso, ça suffit pour moi.',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ],
  ),
  TribuPost(
    id: 'p4',
    author: mockMembers[4], // Julie
    content: 'Nouvelle vidéo dispo sur ma chaîne : "Comment j\'ai structuré ma semaine pour passer de 4h à 6h de travail focalisé par jour" 🎯 Lien en bio !',
    type: PostType.text,
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    likes: 31,
    likedByMe: false,
    comments: [],
  ),
  TribuPost(
    id: 'p5',
    author: mockMembers[3], // Lucas
    content: 'Premier check-in du matin fait 🎉 C\'est tout petit mais ça fait du bien de commencer à structurer ses journées. Merci la communauté pour la motivation !',
    type: PostType.achievement,
    createdAt: DateTime.now().subtract(const Duration(hours: 24)),
    likes: 19,
    likedByMe: false,
    comments: [],
  ),
];

final List<TribuGroup> mockGroups = [
  TribuGroup(
    id: 'g1',
    name: 'Freelances & Indépendants',
    description: 'La communauté des solopreneurs qui gèrent tout seuls.',
    emoji: '💼',
    memberCount: 342,
    joined: true,
  ),
  TribuGroup(
    id: 'g2',
    name: 'Productivité & Focus',
    description: 'Méthodes, outils et astuces pour travailler mieux.',
    emoji: '⚡',
    memberCount: 218,
    joined: true,
  ),
  TribuGroup(
    id: 'g3',
    name: 'Bien-être & Équilibre',
    description: 'Prendre soin de soi tout en restant performant.',
    emoji: '🌿',
    memberCount: 156,
    joined: false,
  ),
  TribuGroup(
    id: 'g4',
    name: 'Tech & Développeurs',
    description: 'Pour les devs et techies qui bossent à leur compte.',
    emoji: '💻',
    memberCount: 89,
    joined: false,
  ),
  TribuGroup(
    id: 'g5',
    name: 'Créatifs & Artistes',
    description: 'Designers, illustrateurs, créateurs de contenu.',
    emoji: '🎨',
    memberCount: 127,
    joined: false,
  ),
  TribuGroup(
    id: 'g6',
    name: 'Matinaux & Early Birds',
    description: 'Pour ceux qui commencent leur journée avant 7h.',
    emoji: '🌅',
    memberCount: 74,
    joined: false,
  ),
];

String timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
  if (diff.inDays == 1) return 'hier';
  return 'il y a ${diff.inDays}j';
}
