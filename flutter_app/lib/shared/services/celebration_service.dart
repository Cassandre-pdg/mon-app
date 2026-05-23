import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Types d'événements déclenchant une célébration in-app.
enum CelebrationEvent {
  taskCompleted,       // tâche prioritaire cochée (MIT)
  flashTaskDone,       // micro-tâche Flash validée (liste)
  flashBlocCompleted,  // bloc Flash terminé (toutes tâches faites)
  habitCompleted,      // habitude du jour cochée
  objectiveCompleted,  // objectif atteint à 100 %
  checkinDone,         // check-in matin ou soir complété
}

class CelebrationNotifier extends StateNotifier<CelebrationEvent?> {
  CelebrationNotifier() : super(null);

  void celebrate(CelebrationEvent event) => state = event;
  void dismiss() => state = null;
}

final celebrationProvider =
    StateNotifierProvider<CelebrationNotifier, CelebrationEvent?>(
  (ref) => CelebrationNotifier(),
);
