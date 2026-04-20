import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// ── Quadrants de la matrice d'Eisenhower ─────────────────────
enum EisenhowerQuadrant {
  doNow,    // Urgent + Important
  schedule, // Pas urgent + Important
  delegate, // Urgent + Pas important
  eliminate // Pas urgent + Pas important
}

extension EisenhowerQuadrantInfo on EisenhowerQuadrant {
  String get title {
    switch (this) {
      case EisenhowerQuadrant.doNow:    return 'À faire maintenant';
      case EisenhowerQuadrant.schedule: return 'À planifier';
      case EisenhowerQuadrant.delegate: return 'À déléguer';
      case EisenhowerQuadrant.eliminate:return 'À éliminer';
    }
  }

  String get subtitle {
    switch (this) {
      case EisenhowerQuadrant.doNow:    return 'Urgent + Important';
      case EisenhowerQuadrant.schedule: return 'Important, pas urgent';
      case EisenhowerQuadrant.delegate: return 'Urgent, pas important';
      case EisenhowerQuadrant.eliminate:return 'Ni urgent ni important';
    }
  }

  String get emoji {
    switch (this) {
      case EisenhowerQuadrant.doNow:    return '🔴';
      case EisenhowerQuadrant.schedule: return '🔵';
      case EisenhowerQuadrant.delegate: return '🟠';
      case EisenhowerQuadrant.eliminate:return '⚪';
    }
  }
}

// ── Modèle d'une tâche Eisenhower ────────────────────────────
class EisenhowerTask {
  final String id;
  final String title;
  final EisenhowerQuadrant quadrant;
  final bool isDone;

  const EisenhowerTask({
    required this.id,
    required this.title,
    required this.quadrant,
    this.isDone = false,
  });

  EisenhowerTask copyWith({bool? isDone}) => EisenhowerTask(
        id: id,
        title: title,
        quadrant: quadrant,
        isDone: isDone ?? this.isDone,
      );
}

// ── Notifier Riverpod ─────────────────────────────────────────
class EisenhowerNotifier extends StateNotifier<List<EisenhowerTask>> {
  EisenhowerNotifier() : super([]);

  void addTask({
    required String title,
    required EisenhowerQuadrant quadrant,
  }) {
    state = [
      ...state,
      EisenhowerTask(
        id: const Uuid().v4(),
        title: title,
        quadrant: quadrant,
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
}

final eisenhowerProvider =
    StateNotifierProvider<EisenhowerNotifier, List<EisenhowerTask>>(
  (_) => EisenhowerNotifier(),
);
