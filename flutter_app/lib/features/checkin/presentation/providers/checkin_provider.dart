import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/checkin_repository.dart';
import '../../data/checkin_model.dart';

final checkinRepositoryProvider = Provider<CheckinRepository>((ref) {
  return CheckinRepository(Supabase.instance.client);
});

/// Check-ins du jour (morning + evening)
final todayCheckinsProvider =
    FutureProvider<Map<String, CheckinModel?>>((ref) async {
  return ref.watch(checkinRepositoryProvider).getTodayCheckins();
});

/// Notifier pour créer un check-in
final checkinNotifierProvider =
    StateNotifierProvider<CheckinNotifier, AsyncValue<CheckinModel?>>((ref) {
  return CheckinNotifier(ref.watch(checkinRepositoryProvider), ref);
});

class CheckinNotifier extends StateNotifier<AsyncValue<CheckinModel?>> {
  final CheckinRepository _repo;
  final Ref _ref;

  CheckinNotifier(this._repo, this._ref) : super(const AsyncValue.data(null));

  Future<void> submit({
    required String type,
    required int moodScore,
    required int energyScore,
    required int focusScore,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final checkin = await _repo.createCheckin(
        type: type,
        moodScore: moodScore,
        energyScore: energyScore,
        focusScore: focusScore,
        notes: notes,
      );
      state = AsyncValue.data(checkin);
      // Rafraîchit les check-ins du jour
      _ref.invalidate(todayCheckinsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() => state = const AsyncValue.data(null);
}
