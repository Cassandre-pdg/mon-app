import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../data/subscription_repository.dart';
import '../../domain/subscription_status.dart';

// ── Accès au repo ─────────────────────────────────────────────
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (_) => SubscriptionRepository.instance,
);

// ── Statut d'abonnement courant ───────────────────────────────
/// Charge l'état Pro/Free depuis RevenueCat au démarrage
final subscriptionStatusProvider =
    StateNotifierProvider<SubscriptionNotifier, AsyncValue<SubscriptionStatus>>(
  (ref) => SubscriptionNotifier(ref.watch(subscriptionRepositoryProvider)),
);

class SubscriptionNotifier
    extends StateNotifier<AsyncValue<SubscriptionStatus>> {
  final SubscriptionRepository _repo;

  SubscriptionNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final status = await _repo.getStatus();
      state = AsyncValue.data(status);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Recharge l'état (après achat, restauration, login)
  Future<void> refresh() => _load();

  /// Lance l'achat d'un package et met à jour l'état
  Future<void> purchase(Package package) async {
    state = const AsyncValue.loading();
    try {
      final status = await _repo.purchase(package);
      state = AsyncValue.data(status);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Restaure les achats et met à jour l'état
  Future<void> restorePurchases() async {
    state = const AsyncValue.loading();
    try {
      final status = await _repo.restorePurchases();
      state = AsyncValue.data(status);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// ── Helper rapide "isPro" ──────────────────────────────────────
/// Utilise ce provider dans les widgets pour afficher/masquer les cadenas
final isProProvider = Provider<bool>((ref) {
  return ref
      .watch(subscriptionStatusProvider)
      .maybeWhen(data: (s) => s.isPro, orElse: () => false);
});

// ── Offering actif (packages à afficher dans le paywall) ──────
final activeOfferingProvider = FutureProvider<Offering?>((ref) async {
  return ref.watch(subscriptionRepositoryProvider).getOffering();
});
