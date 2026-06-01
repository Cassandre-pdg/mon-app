import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

/// Service de notifications locales pour les sessions Pomodoro.
/// Envoie un rappel 15 minutes avant chaque session configurée.
///
/// IDs réservés : 200–207 (8 sessions max)
class PomodoroNotificationService {
  PomodoroNotificationService._();
  static final PomodoroNotificationService instance =
      PomodoroNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId   = 'kolyb_pomodoro';
  static const _channelName = 'Sessions Pomodoro';
  static const _baseId      = 200;
  static const _maxSessions = 8;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  /// Planifie les notifications 15 min avant chaque session.
  /// [sessionTimes] : liste de chaînes "HH:MM" (max 8)
  Future<void> scheduleNotifications(List<String> sessionTimes) async {
    await cancelAll();

    for (var i = 0; i < sessionTimes.length && i < _maxSessions; i++) {
      final parts  = sessionTimes[i].split(':');
      final hour   = int.tryParse(parts.isNotEmpty ? parts[0] : '9') ?? 9;
      final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

      // -15 minutes
      final totalMinutes = hour * 60 + minute - 15;
      if (totalMinutes < 0) continue;

      await _scheduleDaily(
        id:    _baseId + i,
        hour:  totalMinutes ~/ 60,
        min:   totalMinutes % 60,
        title: '🍅 Ton Pomodoro commence bientôt !',
        body:  'Dans 15 min, prépare ton espace et ferme tes distractions.',
      );
    }
  }

  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int min,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, min);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Rappels 15 min avant tes sessions Pomodoro',
      importance: Importance.high,
      priority:   Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details    =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAll() async {
    for (var i = 0; i < _maxSessions; i++) {
      await _plugin.cancel(_baseId + i);
    }
  }

  /// Calcule l'heure de notification (= heure session - 15 min) pour l'affichage
  static String notifTimeFor(String sessionTime) {
    final parts  = sessionTime.split(':');
    final hour   = int.tryParse(parts.isNotEmpty ? parts[0] : '9') ?? 9;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final total  = hour * 60 + minute - 15;
    if (total < 0) return '--:--';
    final h = total ~/ 60;
    final m = total % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  /// Temps par défaut pour la session [index] (09:00 + index × 90 min)
  static String defaultSessionTime(int index) {
    final total = 9 * 60 + index * 90;
    final h     = total ~/ 60;
    final m     = total % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}
