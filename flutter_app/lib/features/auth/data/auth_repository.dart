import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

/// Repository Auth — tous les appels Supabase Auth
/// Jamais appelé directement depuis un widget
class AuthRepository {
  final SupabaseClient _supabase;
  final Logger _logger = Logger();

  AuthRepository(this._supabase);

  /// Utilisateur connecté actuellement
  User? get currentUser => _supabase.auth.currentUser;

  /// Stream de changement d'état de connexion
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Inscription email + mot de passe
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      _logger.i('Inscription réussie : ${response.user?.email}');
      return response;
    } catch (e) {
      _logger.e('Erreur inscription : $e');
      rethrow;
    }
  }

  /// Connexion email + mot de passe
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _logger.i('Connexion réussie : ${response.user?.email}');
      return response;
    } catch (e) {
      _logger.e('Erreur connexion : $e');
      rethrow;
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _logger.i('Déconnexion réussie');
    } catch (e) {
      _logger.e('Erreur déconnexion : $e');
      rethrow;
    }
  }

  /// Réinitialisation mot de passe
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  /// Vérifie si l'utilisateur est connecté
  bool get isSignedIn => currentUser != null;
}
