import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/weekly_review_model.dart';
import '../../data/weekly_review_repository.dart';

final weeklyReviewRepositoryProvider = Provider<WeeklyReviewRepository>((ref) {
  return WeeklyReviewRepository(Supabase.instance.client);
});

// ── Provider principal : revue de la semaine courante ────────────
final currentWeekReviewProvider =
    AsyncNotifierProvider<CurrentWeekReviewNotifier, WeeklyReview?>(
  CurrentWeekReviewNotifier.new,
);

class CurrentWeekReviewNotifier extends AsyncNotifier<WeeklyReview?> {
  @override
  Future<WeeklyReview?> build() async {
    return ref.watch(weeklyReviewRepositoryProvider).getCurrentWeekReview();
  }

  Future<void> save(WeeklyReview review) async {
    final saved = await ref.read(weeklyReviewRepositoryProvider).saveReview(review);
    state = AsyncData(saved);
  }
}

// ── Résumé agrégé de la semaine courante ─────────────────────────
final currentWeekSummaryProvider =
    FutureProvider<WeeklySummary>((ref) async {
  final repo = ref.watch(weeklyReviewRepositoryProvider);
  final weekStart = WeeklyReviewRepository.weekStartFor(DateTime.now());
  return repo.computeWeeklySummary(weekStart);
});

// ── Historique des revues ─────────────────────────────────────────
final reviewHistoryProvider =
    FutureProvider<List<WeeklyReview>>((ref) async {
  return ref.watch(weeklyReviewRepositoryProvider).getHistory();
});

// ── Fenêtre ouverte ? ─────────────────────────────────────────────
final reviewWindowOpenProvider = Provider<bool>((ref) {
  return WeeklyReviewRepository.isReviewWindowOpen();
});
