import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/notification_settings_model.dart';

/// Accès à la table `notification_settings` Supabase.
/// RLS garantit que chaque utilisateur ne voit que ses propres réglages.
class NotificationSettingsRepository {
  final _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Charge les préférences — retourne les valeurs par défaut si aucune entrée.
  Future<NotificationSettings> getSettings() async {
    final userId = _userId;
    if (userId == null) return NotificationSettings.defaults;

    final data = await _client
        .from('notification_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) return NotificationSettings.defaults;
    return NotificationSettings.fromJson(data);
  }

  /// Persiste les préférences (insert ou update selon user_id).
  Future<void> upsertSettings(NotificationSettings settings) async {
    final userId = _userId;
    if (userId == null) return;

    await _client.from('notification_settings').upsert(
      {
        'user_id': userId,
        ...settings.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id',
    );
  }

  /// Enregistre le FCM token de l'appareil côté Supabase.
  /// Utilisé pour cibler les push côté serveur si besoin.
  Future<void> saveFcmToken(String token) async {
    final userId = _userId;
    if (userId == null) return;

    await _client.from('notification_settings').upsert(
      {
        'user_id': userId,
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id',
    );
  }
}
