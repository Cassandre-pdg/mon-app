import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// ── Modèle d'une micro-tâche Flash (< 5 minutes) ─────────────
class FlashTask {
  final String id;
  final String title;
  final String category;
  final int estimatedMinutes; // 1 à 5 min
  final bool isDone;
  final DateTime createdAt;

  const FlashTask({
    required this.id,
    required this.title,
    required this.category,
    required this.estimatedMinutes,
    this.isDone = false,
    required this.createdAt,
  });

  FlashTask copyWith({bool? isDone}) => FlashTask(
        id: id,
        title: title,
        category: category,
        estimatedMinutes: estimatedMinutes,
        isDone: isDone ?? this.isDone,
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

// ── Notifier Riverpod ─────────────────────────────────────────
class FlashNotifier extends StateNotifier<List<FlashTask>> {
  FlashNotifier() : super([]);

  void addTask({
    required String title,
    required String category,
    required int minutes,
  }) {
    state = [
      ...state,
      FlashTask(
        id: const Uuid().v4(),
        title: title,
        category: category,
        estimatedMinutes: minutes,
        createdAt: DateTime.now(),
      ),
    ];
  }

  void toggleDone(String id) {
    state = state
        .map((t) => t.id == id ? t.copyWith(isDone: !t.isDone) : t)
        .toList();
  }

  void deleteTask(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  // Supprimer toutes les tâches terminées
  void clearDone() {
    state = state.where((t) => !t.isDone).toList();
  }
}

final flashProvider =
    StateNotifierProvider<FlashNotifier, List<FlashTask>>(
  (_) => FlashNotifier(),
);
