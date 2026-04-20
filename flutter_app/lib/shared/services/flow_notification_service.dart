import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

/// Service de notifications locales pour les sessions Flow.
///
/// Setup natif requis :
///  iOS  → Info.plist : NSUserNotificationsUsageDescription
///  Android → AndroidManifest.xml : SCHEDULE_EXACT_ALARM permission
class FlowNotificationService {
  FlowNotificationService._();
  static final FlowNotificationService instance = FlowNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId   = 'kolyb_flow';
  static const _channelName = 'Sessions Flow';
  static const _baseId      = 100; // IDs 100–103 réservés aux sessions Flow

  /// Initialise le plugin (à appeler dans main.dart)
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

  /// Demande les permissions (iOS / Android 13+)
  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Planifie les notifications quotidiennes selon le nombre de sessions.
  /// - 1x/jour  → 09:00
  /// - 4x/jour  → 09:00, 11:30, 14:00, 16:30
  Future<void> scheduleFlowNotifications(int sessionsPerDay) async {
    await cancelAll();

    final times = sessionsPerDay == 1
        ? [_TimeOfDaySimple(9, 0)]
        : [
            _TimeOfDaySimple(9,  0),
            _TimeOfDaySimple(11, 30),
            _TimeOfDaySimple(14, 0),
            _TimeOfDaySimple(16, 30),
          ];

    for (var i = 0; i < times.length; i++) {
      await _scheduleDaily(
        id:    _baseId + i,
        hour:  times[i].hour,
        min:   times[i].minute,
        title: '⚡ C\'est l\'heure de ton Flow !',
        body:  '90 min pour avancer vraiment — à toi de jouer.',
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
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, min);
    // Si l'heure est déjà passée aujourd'hui, planifier demain
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Rappels pour démarrer une session Flow',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // répète chaque jour
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Annule toutes les notifications Flow
  Future<void> cancelAll() async {
    for (var i = 0; i < 4; i++) {
      await _plugin.cancel(_baseId + i);
    }
  }
}

class _TimeOfDaySimple {
  final int hour;
  final int minute;
  const _TimeOfDaySimple(this.hour, this.minute);
}
