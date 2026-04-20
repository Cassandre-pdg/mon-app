import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

/// Handler Firebase exécuté en arrière-plan — doit être une fonction top-level.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Les notifications FCM en background sont affichées automatiquement par le SDK.
}

/// Service central de notifications Kolyb.
///
/// Gère :
///   - FCM (Firebase Cloud Messaging) — push server-side
///   - Notifications locales planifiées — check-in matin/soir, sommeil, streak
///
/// Setup natif requis :
///   Android → POST_NOTIFICATIONS permission + SCHEDULE_EXACT_ALARM dans AndroidManifest.xml
///   iOS     → Push Notifications capability dans Xcode + UNUserNotificationCenterDelegate
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ── Canaux Android ──────────────────────────────────────────
  static const _channelCheckin = AndroidNotificationChannel(
    'kolyb_checkin',
    'Check-ins',
    description: 'Rappels pour tes check-ins matin et soir',
    importance: Importance.high,
  );
  static const _channelSleep = AndroidNotificationChannel(
    'kolyb_sleep',
    'Rappel sommeil',
    description: 'Rappels pour renseigner ton sommeil',
    importance: Importance.defaultImportance,
  );
  static const _channelStreak = AndroidNotificationChannel(
    'kolyb_streak',
    'Alertes streak',
    description: 'Notifications pour protéger ton streak',
    importance: Importance.high,
  );

  // ── IDs réservés (Flow = 100-103 dans FlowNotificationService) ──
  static const int _idMorningCheckin = 1;
  static const int _idEveningCheckin = 2;
  static const int _idSleepReminder  = 3;
  static const int _idStreakAlert    = 4;

  /// Initialise Firebase Messaging + le plugin local.
  /// À appeler une seule fois dans main().
  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    // Créer les canaux Android (no-op sur iOS)
    final androidPlugin = _localPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channelCheckin);
    await androidPlugin?.createNotificationChannel(_channelSleep);
    await androidPlugin?.createNotificationChannel(_channelStreak);

    // Init plugin local — permissions demandées séparément via requestPermissions()
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localPlugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Écoute les messages FCM quand l'app est au premier plan
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handler pour les messages reçus en arrière-plan
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

    _initialized = true;
  }

  /// Demande les permissions (iOS et Android 13+).
  /// Retourne true si l'utilisateur a accepté.
  Future<bool> requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _localPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _localPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Récupère le FCM token pour enregistrer l'appareil côté serveur.
  /// Retourne null sur simulateur iOS (normal).
  Future<String?> getFcmToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  // ── Planification notifications locales ─────────────────────

  /// Planifie (ou annule) la notification du check-in matin.
  Future<void> scheduleMorningCheckin(bool enabled, String time) async {
    await _localPlugin.cancel(_idMorningCheckin);
    if (!enabled) return;
    await _scheduleDaily(
      id: _idMorningCheckin,
      channelId: _channelCheckin.id,
      channelName: _channelCheckin.name,
      hour: _parseHour(time),
      minute: _parseMinute(time),
      title: 'Bonjour ! ☀️ Comment tu démarres ?',
      body: 'Prends 2 min pour ton check-in du matin — à ton rythme.',
    );
  }

  /// Planifie (ou annule) la notification du check-in soir.
  Future<void> scheduleEveningCheckin(bool enabled, String time) async {
    await _localPlugin.cancel(_idEveningCheckin);
    if (!enabled) return;
    await _scheduleDaily(
      id: _idEveningCheckin,
      channelId: _channelCheckin.id,
      channelName: _channelCheckin.name,
      hour: _parseHour(time),
      minute: _parseMinute(time),
      title: 'Fin de journée 🌙 — comment ça s\'est passé ?',
      body: 'Ton check-in du soir t\'attend — 2 min pour faire le point.',
    );
  }

  /// Planifie (ou annule) le rappel de suivi sommeil.
  Future<void> scheduleSleepReminder(bool enabled, String time) async {
    await _localPlugin.cancel(_idSleepReminder);
    if (!enabled) return;
    await _scheduleDaily(
      id: _idSleepReminder,
      channelId: _channelSleep.id,
      channelName: _channelSleep.name,
      hour: _parseHour(time),
      minute: _parseMinute(time),
      title: 'Bonne nuit 😴',
      body: 'N\'oublie pas de renseigner ton sommeil avant de dormir.',
    );
  }

  /// Affiche immédiatement une alerte streak (à déclencher depuis le check-in).
  Future<void> showStreakAlert() async {
    await _localPlugin.show(
      _idStreakAlert,
      'Ton streak est en danger 🔥',
      'Tu n\'as pas encore fait ton check-in aujourd\'hui — reprends vite !',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'kolyb_streak',
          'Alertes streak',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Annule toutes les notifications locales Kolyb (hors Flow, IDs 100-103).
  Future<void> cancelAll() async {
    await _localPlugin.cancel(_idMorningCheckin);
    await _localPlugin.cancel(_idEveningCheckin);
    await _localPlugin.cancel(_idSleepReminder);
    await _localPlugin.cancel(_idStreakAlert);
  }

  // ── Gestion messages FCM au premier plan ────────────────────

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // Affiche une notification locale pour les messages FCM reçus en foreground
    final channelId = message.data['channel'] as String? ?? _channelCheckin.id;
    final channelName = message.data['channel_name'] as String? ?? _channelCheckin.name;

    await _localPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────

  Future<void> _scheduleDaily({
    required int id,
    required String channelId,
    required String channelName,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute,
    );
    // Si l'heure est déjà passée aujourd'hui, planifier demain
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _localPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // répète chaque jour
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  int _parseHour(String time) => int.parse(time.split(':')[0]);
  int _parseMinute(String time) => int.parse(time.split(':')[1]);
}
