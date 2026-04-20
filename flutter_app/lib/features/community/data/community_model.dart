// Modèles de la communauté Kolyb

// ── Post du feed ──────────────────────────────────────────────
class CommunityPost {
  final String id;
  final String userId;
  final String authorName;
  final String content;
  final int likesCount;
  final DateTime createdAt;

  const CommunityPost({
    required this.id,
    required this.userId,
    required this.authorName,
    required this.content,
    required this.likesCount,
    required this.createdAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      authorName: (json['author_name'] as String?) ?? 'Anonyme',
      content: json['content'] as String,
      likesCount: (json['likes_count'] as int?) ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  CommunityPost copyWith({int? likesCount}) {
    return CommunityPost(
      id: id,
      userId: userId,
      authorName: authorName,
      content: content,
      likesCount: likesCount ?? this.likesCount,
      createdAt: createdAt,
    );
  }
}

// ── Groupe thématique ─────────────────────────────────────────
class CommunityGroup {
  final String id;
  final String emoji;
  final String name;
  final String description;
  final int membersCount;
  bool isJoined;

  CommunityGroup({
    required this.id,
    required this.emoji,
    required this.name,
    required this.description,
    required this.membersCount,
    this.isJoined = false,
  });
}

/// Groupes thématiques prédéfinis pour la V1
/// La création de groupes est réservée à la V2 Pro
final predefinedGroups = [
  CommunityGroup(
    id: 'freelance-tech',
    emoji: '💻',
    name: 'Freelance Tech',
    description: 'Développeurs, designers, data — partage tes galères et réussites.',
    membersCount: 342,
  ),
  CommunityGroup(
    id: 'creatifs',
    emoji: '🎨',
    name: 'Créatifs',
    description: 'Graphistes, photographes, vidéastes — l\'art au service de ta liberté.',
    membersCount: 218,
  ),
  CommunityGroup(
    id: 'conseil-coaching',
    emoji: '🧠',
    name: 'Conseil & Coaching',
    description: 'Consultants, coachs, formateurs — partage tes méthodes.',
    membersCount: 185,
  ),
  CommunityGroup(
    id: 'commerce-vente',
    emoji: '📈',
    name: 'Commerce & Vente',
    description: 'Commerciaux indépendants, e-commerçants — tes stratégies qui marchent.',
    membersCount: 156,
  ),
  CommunityGroup(
    id: 'bien-etre-sante',
    emoji: '🌿',
    name: 'Bien-être & Santé',
    description: 'Thérapeutes, coachs sportifs, praticiens — prends soin des autres et de toi.',
    membersCount: 203,
  ),
  CommunityGroup(
    id: 'redaction-com',
    emoji: '✍️',
    name: 'Rédaction & Com',
    description: 'Rédacteurs, community managers, journalistes — les mots font ta force.',
    membersCount: 127,
  ),
];
