import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/habit_model.dart';
import '../../data/habits_repository.dart';

final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  return HabitsRepository(Supabase.instance.client);
});

final habitsProvider =
    AsyncNotifierProvider<HabitsNotifier, List<Habit>>(HabitsNotifier.new);

class HabitsNotifier extends AsyncNotifier<List<Habit>> {
  @override
  Future<List<Habit>> build() async {
    return ref.watch(habitsRepositoryProvider).getAll();
  }

  Future<void> add({
    required String title,
    String emoji = '🔁',
    HabitFrequency frequency = HabitFrequency.daily,
    List<int> daysOfWeek = const [],
  }) async {
    final created = await ref.read(habitsRepositoryProvider).create(
          title: title,
          emoji: emoji,
          frequency: frequency,
          daysOfWeek: daysOfWeek,
        );
    state = AsyncData([...?state.value, created]);
  }

  Future<void> toggle(String id) async {
    final habits = state.value ?? [];
    final habit = habits.firstWhere((h) => h.id == id);
    final nowDone = await ref
        .read(habitsRepositoryProvider)
        .toggleToday(id, habit.isCompletedToday);

    final newStreak = nowDone
        ? habit.currentStreak + 1
        : (habit.currentStreak - 1).clamp(0, 9999);

    state = AsyncData(
      habits
          .map((h) => h.id == id
              ? h.copyWith(
                  isCompletedToday: nowDone,
                  currentStreak: newStreak,
                )
              : h)
          .toList(),
    );
  }

  Future<void> edit(
    String id, {
    String? title,
    String? emoji,
    HabitFrequency? frequency,
    List<int>? daysOfWeek,
  }) async {
    final updated = await ref.read(habitsRepositoryProvider).update(
          id,
          title: title,
          emoji: emoji,
          frequency: frequency,
          daysOfWeek: daysOfWeek,
        );
    state = AsyncData(
      state.value!.map((h) => h.id == id ? updated : h).toList(),
    );
  }

  Future<void> delete(String id) async {
    await ref.read(habitsRepositoryProvider).delete(id);
    state = AsyncData(state.value!.where((h) => h.id != id).toList());
  }
}

// Habitudes prévues aujourd'hui uniquement
final habitsDueTodayProvider = Provider<List<Habit>>((ref) {
  final all = ref.watch(habitsProvider).valueOrNull ?? [];
  return all.where((h) => h.isDueToday()).toList();
});

// Compte des habitudes du jour et complétées
final habitsTodaySummaryProvider = Provider<({int total, int done})>((ref) {
  final due = ref.watch(habitsDueTodayProvider);
  return (total: due.length, done: due.where((h) => h.isCompletedToday).length);
});
