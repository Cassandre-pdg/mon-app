/// Préférences de notifications de l'utilisateur.
///
/// Correspond à la table `notification_settings` Supabase.
/// RLS activé — chaque utilisateur ne voit que ses propres réglages.
class NotificationSettings {
  final bool morningCheckinEnabled;
  final bool eveningCheckinEnabled;
  final bool sleepReminderEnabled;
  final bool streakAlertEnabled;
  final bool flowSessionEnabled;
  final bool communityEnabled;

  /// Format HH:MM — ex. "07:30"
  final String morningTime;
  final String eveningTime;
  final String sleepTime;

  /// Token FCM de l'appareil (null sur simulateur iOS)
  final String? fcmToken;

  const NotificationSettings({
    this.morningCheckinEnabled = true,
    this.eveningCheckinEnabled = true,
    this.sleepReminderEnabled = true,
    this.streakAlertEnabled = true,
    this.flowSessionEnabled = true,
    this.communityEnabled = true,
    this.morningTime = '07:30',
    this.eveningTime = '18:30',
    this.sleepTime = '22:00',
    this.fcmToken,
  });

  /// Valeurs par défaut (opt-in à tout)
  static const defaults = NotificationSettings();

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        morningCheckinEnabled:
            json['morning_checkin_enabled'] as bool? ?? true,
        eveningCheckinEnabled:
            json['evening_checkin_enabled'] as bool? ?? true,
        sleepReminderEnabled:
            json['sleep_reminder_enabled'] as bool? ?? true,
        streakAlertEnabled:
            json['streak_alert_enabled'] as bool? ?? true,
        flowSessionEnabled:
            json['flow_session_enabled'] as bool? ?? true,
        communityEnabled:
            json['community_enabled'] as bool? ?? true,
        morningTime: json['morning_time'] as String? ?? '07:30',
        eveningTime: json['evening_time'] as String? ?? '18:30',
        sleepTime:   json['sleep_time']   as String? ?? '22:00',
        fcmToken:    json['fcm_token']    as String?,
      );

  Map<String, dynamic> toJson() => {
        'morning_checkin_enabled': morningCheckinEnabled,
        'evening_checkin_enabled': eveningCheckinEnabled,
        'sleep_reminder_enabled':  sleepReminderEnabled,
        'streak_alert_enabled':    streakAlertEnabled,
        'flow_session_enabled':    flowSessionEnabled,
        'community_enabled':       communityEnabled,
        'morning_time': morningTime,
        'evening_time': eveningTime,
        'sleep_time':   sleepTime,
        if (fcmToken != null) 'fcm_token': fcmToken,
      };

  NotificationSettings copyWith({
    bool? morningCheckinEnabled,
    bool? eveningCheckinEnabled,
    bool? sleepReminderEnabled,
    bool? streakAlertEnabled,
    bool? flowSessionEnabled,
    bool? communityEnabled,
    String? morningTime,
    String? eveningTime,
    String? sleepTime,
    String? fcmToken,
  }) =>
      NotificationSettings(
        morningCheckinEnabled:
            morningCheckinEnabled ?? this.morningCheckinEnabled,
        eveningCheckinEnabled:
            eveningCheckinEnabled ?? this.eveningCheckinEnabled,
        sleepReminderEnabled:
            sleepReminderEnabled ?? this.sleepReminderEnabled,
        streakAlertEnabled:  streakAlertEnabled ?? this.streakAlertEnabled,
        flowSessionEnabled:  flowSessionEnabled  ?? this.flowSessionEnabled,
        communityEnabled:    communityEnabled    ?? this.communityEnabled,
        morningTime: morningTime ?? this.morningTime,
        eveningTime: eveningTime ?? this.eveningTime,
        sleepTime:   sleepTime   ?? this.sleepTime,
        fcmToken:    fcmToken    ?? this.fcmToken,
      );
}
