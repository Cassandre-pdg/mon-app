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
  Future<void> update(NotificationSettings settings) async {
    // Mise à jour optimiste de l'UI
    state = AsyncValue.data(settings);

    try {
      // Appliquer les planifications locales
      await _applySchedules(settings);
      // Persister dans Supabase
      await _repo.upsertSettings(settings);
      // Invalide le FutureProvider pour qu'il soit cohérent
      _ref.invalidate(notificationSettingsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Met à jour un seul toggle sans recharger tout l'écran
  Future<void> toggle({
    bool? morningCheckin,
    bool? eveningCheckin,
    bool? sleepReminder,
    bool? streakAlert,
    bool? flowSession,
    bool? community,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    await update(current.copyWith(
      morningCheckinEnabled: morningCheckin,
      eveningCheckinEnabled: eveningCheckin,
      sleepReminderEnabled: sleepReminder,
      streakAlertEnabled: streakAlert,
      flowSessionEnabled: flowSession,
      communityEnabled: community,
    ));
  }

  /// Met à jour l'heure d'une notification
  Future<void> updateTime({
    String? morningTime,
    String? eveningTime,
    String? sleepTime,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    await update(current.copyWith(
      morningTime: morningTime,
      eveningTime: eveningTime,
      sleepTime: sleepTime,
    ));
  }

  // ── Synchronise les notifications locales avec les préférences ─

  Future<void> _applySchedules(NotificationSettings s) async {
    final svc = NotificationService.instance;
    await svc.scheduleMorningCheckin(s.morningCheckinEnabled, s.morningTime);
    await svc.scheduleEveningCheckin(s.eveningCheckinEnabled, s.eveningTime);
    await svc.scheduleSleepReminder(s.sleepReminderEnabled, s.sleepTime);
  }
}
