// Modèle FlashTask persisté en Supabase

class FlashTask {
  final String id;
  final String userId;
  final String title;
  final String category;
  final int estimatedMinutes;
  final bool isDone;
  final String? projectId;
  final String? projectName;
  final DateTime? doneAt;
  final DateTime createdAt;

  const FlashTask({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.estimatedMinutes,
    required this.isDone,
    this.projectId,
    this.projectName,
    this.doneAt,
    required this.createdAt,
  });

  factory FlashTask.fromJson(Map<String, dynamic> json) => FlashTask(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String,
        category: json['category'] as String? ?? 'autre',
        estimatedMinutes: json['estimated_minutes'] as int? ?? 2,
        isDone: json['is_done'] as bool? ?? false,
        projectId: json['project_id'] as String?,
        projectName: json['kanban_projects'] != null
            ? (json['kanban_projects'] as Map<String, dynamic>)['name'] as String?
            : null,
        doneAt: json['done_at'] != null
            ? DateTime.parse(json['done_at'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  FlashTask copyWith({bool? isDone, DateTime? doneAt}) => FlashTask(
        id: id,
        userId: userId,
        title: title,
        category: category,
        estimatedMinutes: estimatedMinutes,
        isDone: isDone ?? this.isDone,
        projectId: projectId,
        projectName: projectName,
        doneAt: doneAt ?? this.doneAt,
        createdAt: createdAt,
      );
}

// ── Catégories disponibles ────────────────────────────────────
class FlashCategory {
  final String key;
  final String emoji;
  final String label;

  const FlashCategory({
    required this.key,
    required this.emoji,
    required this.label,
  });
}

const flashCategories = [
  FlashCategory(key: 'email',    emoji: '📧', label: 'Email'),
  FlashCategory(key: 'appel',    emoji: '📞', label: 'Appel'),
  FlashCategory(key: 'admin',    emoji: '📋', label: 'Admin'),
  FlashCategory(key: 'facture',  emoji: '💰', label: 'Facturation'),
  FlashCategory(key: 'message',  emoji: '💬', label: 'Message'),
  FlashCategory(key: 'autre',    emoji: '🔧', label: 'Divers'),
];
