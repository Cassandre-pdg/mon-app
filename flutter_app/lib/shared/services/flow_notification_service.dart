import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

/// Service de notifications locales pour les sessions Flow.
/// Envoie un rappel 15 minutes avant chaque session configurée.
///
/// Setup natif requis :
///  iOS  → Info.plist : NSUserNotificationsUsageDescription
///  Android → AndroidManifest.xml : SCHEDULE_EXACT_ALARM permission
///
/// IDs réservés : 100–103 (4 sessions max)
class FlowNotificationService {
  FlowNotificationService._();
  static final FlowNotificationService instance = FlowNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId   = 'kolyb_flow';
  static const _channelName = 'Sessions Flow';
  static const _baseId      = 100;
  static const _maxSessions = 4;

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

  /// Planifie les notifications 15 min avant chaque session.
  /// [sessionTimes] : liste de chaînes "HH:MM"
  /// Si vide, utilise les horaires par défaut selon [sessionsPerDay].
  Future<void> scheduleFlowNotifications(
    int sessionsPerDay, {
    List<String>? sessionTimes,
  }) async {
    await cancelAll();

    final times = sessionTimes ?? _defaultTimes(sessionsPerDay);

    for (var i = 0; i < times.length && i < _maxSessions; i++) {
      final parts  = times[i].split(':');
      final hour   = int.tryParse(parts.isNotEmpty ? parts[0] : '9') ?? 9;
      final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

      // -15 minutes
      final totalMinutes = hour * 60 + minute - 15;
      if (totalMinutes < 0) continue;

      await _scheduleDaily(
        id:    _baseId + i,
        hour:  totalMinutes ~/ 60,
        min:   totalMinutes % 60,
        title: '⚡ Ton Flow démarre dans 15 min !',
        body:  'Prépare ton espace, 90 min de focus profond t\'attendent.',
      );
    }
  }

  List<String> _defaultTimes(int sessionsPerDay) {
    if (sessionsPerDay == 1) return ['09:00'];
    return ['09:00', '11:30', '14:00', '16:30'];
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
      channelDescription: 'Rappels 15 min avant tes sessions Flow',
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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

  /// Horaires par défaut pour Flow selon sessionsPerDay
  static List<String> defaultTimes(int sessionsPerDay) {
    if (sessionsPerDay == 1) return ['09:00'];
    return ['09:00', '11:30', '14:00', '16:30'];
  }
}
