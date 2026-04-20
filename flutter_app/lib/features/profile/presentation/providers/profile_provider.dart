import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/profile_repository.dart';

/// Repository injecté via Riverpod
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

/// Stats de profil chargées depuis Supabase
final profileStatsProvider = FutureProvider<ProfileStats>((ref) async {
  return ref.watch(profileRepositoryProvider).getProfileStats();
});

/// Notifier pour les actions sur le compte (modifier nom, reset mdp, supprimer)
final profileActionsProvider =
    StateNotifierProvider<ProfileActionsNotifier, AsyncValue<void>>((ref) {
  return ProfileActionsNotifier(ref.watch(profileRepositoryProvider), ref);
});

class ProfileActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final ProfileRepository _repo;
  final Ref _ref;

  ProfileActionsNotifier(this._repo, this._ref)
      : super(const AsyncValue.data(null));

  /// Met à jour le nom affiché
  Future<void> updateName(String name) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updateName(name);
      // Force le rechargement des stats pour refléter le nouveau nom
      _ref.invalidate(profileStatsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Envoie l'email de réinitialisation de mot de passe
  Future<void> resetPassword() async {
    state = const AsyncValue.loading();
    try {
      await _repo.resetPassword();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Supprime le compte (RGPD)
  Future<void> deleteAccount() async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteAccount();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() => state = const AsyncValue.data(null);
}
