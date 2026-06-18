import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

/// Données du profil — stats gamification + infos utilisateur
class ProfileStats {
  final String? fullName;
  final String email;
  final String? jobTitle;
  final String? company;
  final String? tagline;
  final int currentStreak;
  final int longestStreak;
  final int totalPoints;
  final int level;
  final String levelLabel;

  const ProfileStats({
    required this.fullName,
    required this.email,
    this.jobTitle,
    this.company,
    this.tagline,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalPoints,
    required this.level,
    required this.levelLabel,
  });
}

/// Repository Profil — jamais appelé directement depuis un widget
class ProfileRepository {
  final SupabaseClient _supabase;
  final Logger _logger = Logger();

  static const _levelLabels = {
    1: 'Explorateur',
    2: 'Indépendant',
    3: 'Entrepreneur',
    4: 'Bâtisseur',
    5: 'Visionnaire',
  };

  ProfileRepository(this._supabase);

  // 📸 MODE CAPTURES APP STORE — mettre à false avant de soumettre
  static const bool screenshotMode = false;

  /// Récupère les stats de progression depuis la table profiles
  Future<ProfileStats> getProfileStats() async {
    if (screenshotMode) {
      final user = _supabase.auth.currentUser!;
      final meta = user.userMetadata ?? {};
      return ProfileStats(
        fullName:     meta['full_name'] as String? ?? 'Cassandre',
        email:        user.email ?? '',
        jobTitle:     meta['job_title'] as String? ?? 'Designer & Fondatrice',
        company:      meta['company'] as String? ?? 'Studio Indep',
        tagline:      'Construire à mon rythme, avancer chaque jour.',
        currentStreak: 12,
        longestStreak: 21,
        totalPoints:   340,
        level:         2,
        levelLabel:    'Indépendant',
      );
    }
    try {
      final user = _supabase.auth.currentUser!;
      final data = await _supabase
          .from('profiles')
          .select('current_streak, longest_streak, total_points, level')
          .eq('id', user.id)
          .single();

      final level = (data['level'] as int?) ?? 1;
      final meta = user.userMetadata ?? {};
      return ProfileStats(
        fullName: meta['full_name'] as String?,
        email: user.email ?? '',
        jobTitle: meta['job_title'] as String?,
        company: meta['company'] as String?,
        tagline: meta['tagline'] as String?,
        currentStreak: (data['current_streak'] as int?) ?? 0,
        longestStreak: (data['longest_streak'] as int?) ?? 0,
        totalPoints: (data['total_points'] as int?) ?? 0,
        level: level,
        levelLabel: _levelLabels[level] ?? 'Explorateur',
      );
    } catch (e) {
      _logger.e('Erreur chargement profil : $e');
      rethrow;
    }
  }

  /// Met à jour le nom affiché dans les métadonnées Supabase Auth
  Future<void> updateName(String name) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(data: {'full_name': name}),
      );
      _logger.i('Nom mis à jour : $name');
    } catch (e) {
      _logger.e('Erreur mise à jour nom : $e');
      rethrow;
    }
  }

  /// Met à jour l'identité complète (nom, métier, entreprise, tagline)
  Future<void> updateProfile({
    required String fullName,
    required String jobTitle,
    required String company,
    required String tagline,
  }) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(data: {
          'full_name': fullName,
          'job_title': jobTitle,
          'company': company,
          'tagline': tagline,
        }),
      );
      _logger.i('Profil mis à jour');
    } catch (e) {
      _logger.e('Erreur mise à jour profil : $e');
      rethrow;
    }
  }

  /// Envoie un email de réinitialisation de mot de passe
  Future<void> resetPassword() async {
    try {
      final email = _supabase.auth.currentUser?.email;
      if (email == null) return;
      await _supabase.auth.resetPasswordForEmail(email);
      _logger.i('Email de réinitialisation envoyé à $email');
    } catch (e) {
      _logger.e('Erreur réinitialisation mot de passe : $e');
      rethrow;
    }
  }

  /// Suppression du compte (RGPD) — efface les données puis déconnecte
  Future<void> deleteAccount() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      // Suppression des données utilisateur (RLS garantit que seul le proprio peut)
      await _supabase.from('checkins').delete().eq('user_id', userId);
      await _supabase.from('planner_tasks').delete().eq('user_id', userId);
      await _supabase.from('profiles').delete().eq('id', userId);
      await _supabase.auth.signOut();
      _logger.i('Compte supprimé pour $userId');
    } catch (e) {
      _logger.e('Erreur suppression compte : $e');
      rethrow;
    }
  }
}
