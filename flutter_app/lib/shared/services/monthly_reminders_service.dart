import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Service de rappels mensuels pour les obligations auto-entrepreneur.
///
/// Rappels planifiés :
///   ID 30 — 1er du mois  9h00 : Déclaration URSSAF
///   ID 31 — 15 du mois   9h00 : Suivi recettes & compta
class MonthlyRemindersService {
  MonthlyRemindersService._();
  static final MonthlyRemindersService instance = MonthlyRemindersService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'kolyb_monthly',
    'Rappels mensuels',
    description: 'Obligations et gestion pour ton activité',
    importance: Importance.high,
  );

  // IDs réservés (30-39)
  static const int _idUrssaf = 30;
  static const int _idCompta = 31;

  Future<void> init() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);
  }

  /// Planifie les rappels actifs. Annule les précédents avant de replanifier.
  Future<void> scheduleAll({
    bool urssaf = true,
    bool compta = true,
  }) async {
    await _plugin.cancel(_idUrssaf);
    await _plugin.cancel(_idCompta);

    if (urssaf) {
      await _scheduleMonthly(
        id: _idUrssaf,
        dayOfMonth: 1,
        hour: 9,
        minute: 0,
        title: '📋 Déclaration URSSAF',
        body: 'N\'oublie pas ta déclaration mensuelle. Tu as jusqu\'au 15 !',
      );
    }

    if (compta) {
      await _scheduleMonthly(
        id: _idCompta,
        dayOfMonth: 15,
        hour: 9,
        minute: 0,
        title: '📊 Suivi recettes & compta',
        body:
            'Mi-mois : vérifie tes recettes, devis en cours et factures impayées.',
      );
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancel(_idUrssaf);
    await _plugin.cancel(_idCompta);
  }

  Future<void> _scheduleMonthly({
    required int id,
    required int dayOfMonth,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    // Prochain occurrence du jour J du mois
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      dayOfMonth,
      hour,
      minute,
    );

    // Si la date est déjà passée ce mois-ci, passer au mois suivant
    if (scheduled.isBefore(now)) {
      final nextMonth =
          now.month == 12 ? 1 : now.month + 1;
      final nextYear = now.month == 12 ? now.year + 1 : now.year;
      scheduled = tz.TZDateTime(
        tz.local,
        nextYear,
        nextMonth,
        dayOfMonth,
        hour,
        minute,
      );
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Répète chaque mois au même jour
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
