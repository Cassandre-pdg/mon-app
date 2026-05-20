import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/notification_settings_repository.dart';
import '../../domain/notification_settings_model.dart';
import '../../../../shared/services/notification_service.dart';

/// Repository injecté via Riverpod
final notificationSettingsRepositoryProvider =
    Provider<NotificationSettingsRepository>(
  (ref) => NotificationSettingsRepository(),
);

/// Charge les préférences de notifications depuis Supabase
final notificationSettingsProvider =
    FutureProvider<NotificationSettings>((ref) async {
  return ref.read(notificationSettingsRepositoryProvider).getSettings();
});

/// Notifier pour modifier et persister les préférences
final notificationSettingsNotifierProvider =
    StateNotifierProvider<NotificationSettingsNotifier, AsyncValue<NotificationSettings>>(
  (ref) => NotificationSettingsNotifier(
    ref.watch(notificationSettingsRepositoryProvider),
    ref,
  ),
);

class NotificationSettingsNotifier
    extends StateNotifier<AsyncValue<NotificationSettings>> {
  final NotificationSettingsRepository _repo;
  final Ref _ref;

  NotificationSettingsNotifier(this._repo, this._ref)
      : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final settings = await _repo.getSettings();
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Met à jour les préférences localement, planifie les notifications,
  /// puis persiste dans Supabase.
  /// Si Supabase échoue, l'état local est conservé (pas de crash UI).
  Future<void> update(NotificationSettings settings) async {
    // Mise à jour optimiste — l'UI reflète le changement immédiatement
    state = AsyncValue.data(settings);

    try {
      await _applySchedules(settings);
      await _repo.upsertSettings(settings);
      _ref.invalidate(notificationSettingsProvider);
    } catch (_) {
      // Supabase indisponible : on garde l'état local, pas de crash
    }
  }

  /// Met à jour un seul toggle sans recharger tout l'écran
  Future<void> toggle({
    bool? morningCheckin,
    bool? eveningCheckin,
    bool? streakAlert,
    bool? flowSession,
    bool? community,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    await update(current.copyWith(
      morningCheckinEnabled: morningCheckin,
      eveningCheckinEnabled: eveningCheckin,
      streakAlertEnabled: streakAlert,
      flowSessionEnabled: flowSession,
      communityEnabled: community,
    ));
  }

  /// Met à jour l'heure d'un rappel check-in
  Future<void> updateTime({
    String? morningTime,
    String? eveningTime,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    await update(current.copyWith(
      morningTime: morningTime,
      eveningTime: eveningTime,
    ));
  }

  // ── Synchronise les notifications locales avec les préférences ─

  Future<void> _applySchedules(NotificationSettings s) async {
    final svc = NotificationService.instance;
    await svc.scheduleMorningCheckin(s.morningCheckinEnabled, s.morningTime);
    await svc.scheduleEveningCheckin(s.eveningCheckinEnabled, s.eveningTime);
  }
}
