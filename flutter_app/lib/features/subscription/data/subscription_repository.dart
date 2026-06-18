import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

import '../../../shared/constants/app_constants.dart';
import '../domain/subscription_status.dart';

/// Toutes les interactions avec RevenueCat + Supabase pour les abonnements.
/// Jamais appelé directement depuis un widget : passer par subscription_provider.dart
class SubscriptionRepository {
  SubscriptionRepository._();
  static final SubscriptionRepository instance = SubscriptionRepository._();

  final _log = Logger();
  SupabaseClient get _db => Supabase.instance.client;

  // ── Configuration ────────────────────────────────────────────

  Future<void> init({String? userId}) async {
    if (kIsWeb) return;

    final apiKey = Platform.isIOS
        ? AppConstants.revenueCatApiKeyIos
        : AppConstants.revenueCatApiKeyAndroid;

    await Purchases.setLogLevel(LogLevel.info);
    final config = PurchasesConfiguration(apiKey);
    await Purchases.configure(config);

    if (userId != null) {
      await identifyUser(userId);
    }

    _log.i('[RevenueCat] initialisé : userId: ${userId ?? "anonyme"}');
  }

  Future<void> identifyUser(String userId) async {
    if (kIsWeb) return;
    try {
      await Purchases.logIn(userId);
      _log.i('[RevenueCat] utilisateur identifié: $userId');
    } catch (e) {
      _log.w('[RevenueCat] identifyUser error: $e');
    }
  }

  Future<void> logOut() async {
    if (kIsWeb) return;
    try {
      await Purchases.logOut();
      _log.i('[RevenueCat] utilisateur déconnecté');
    } catch (e) {
      _log.w('[RevenueCat] logOut error: $e');
    }
  }

  // ── Lecture de l'état ────────────────────────────────────────

  Future<SubscriptionStatus> getStatus() async {
    if (kIsWeb) return const SubscriptionStatus.free();
    try {
      final info = await Purchases.getCustomerInfo();
      final baseStatus = _mapToStatus(info);

      // Si pas encore Pro via RevenueCat, vérifie le trial étendu Supabase
      if (!baseStatus.isPro) {
        final extendedUntil = await getTrialExtendedUntil();
        if (extendedUntil != null && extendedUntil.isAfter(DateTime.now())) {
          return SubscriptionStatus(
            isPro: true,
            expiresAt: extendedUntil,
            isTrialing: true,
            willRenew: false,
          );
        }
      }

      return baseStatus;
    } catch (e) {
      _log.w('[RevenueCat] getStatus error: $e');
      return const SubscriptionStatus.free();
    }
  }

  Future<Offering?> getOffering() async {
    if (kIsWeb) return null;
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.getOffering(AppConstants.rcOfferingId)
          ?? offerings.current;
    } catch (e) {
      _log.e('[RevenueCat] getOffering error: $e');
      return null;
    }
  }

  // ── Actions d'achat ──────────────────────────────────────────

  Future<SubscriptionStatus> purchase(Package package) async {
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _log.i('[RevenueCat] achat réussi: ${package.identifier}');
      return _mapToStatus(result.customerInfo);
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        _log.i('[RevenueCat] achat annulé par l\'utilisateur');
        return const SubscriptionStatus.free();
      }
      _log.e('[RevenueCat] purchase error: $e');
      rethrow;
    }
  }

  Future<SubscriptionStatus> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      _log.i('[RevenueCat] restauration effectuée');
      return _mapToStatus(info);
    } catch (e) {
      _log.e('[RevenueCat] restorePurchases error: $e');
      rethrow;
    }
  }

  // ── Trial étendu — Supabase ───────────────────────────────────
  // Migration SQL à exécuter dans Supabase (si pas encore fait) :
  //
  // ALTER TABLE users
  //   ADD COLUMN IF NOT EXISTS trial_extended_until TIMESTAMPTZ,
  //   ADD COLUMN IF NOT EXISTS trial_nudge_shown_at TIMESTAMPTZ;

  /// Retourne la date jusqu'à laquelle le trial est étendu, ou null
  Future<DateTime?> getTrialExtendedUntil() async {
    try {
      final userId = _db.auth.currentUser?.id;
      if (userId == null) return null;

      final row = await _db
          .from('profiles')
          .select('trial_extended_until')
          .eq('id', userId)
          .maybeSingle();

      final raw = row?['trial_extended_until'] as String?;
      return raw != null ? DateTime.tryParse(raw) : null;
    } catch (e) {
      _log.w('[Trial] getTrialExtendedUntil error: $e');
      return null;
    }
  }

  /// Accorde 7 jours supplémentaires à partir de maintenant
  Future<void> grantTrialExtension() async {
    try {
      final userId = _db.auth.currentUser?.id;
      if (userId == null) return;

      final until = DateTime.now().add(const Duration(days: 7));
      await _db.from('profiles').update({
        'trial_extended_until': until.toIso8601String(),
      }).eq('id', userId);

      _log.i('[Trial] extension accordée jusqu\'au $until');
    } catch (e) {
      _log.w('[Trial] grantTrialExtension error: $e');
    }
  }

  /// Vérifie si le nudge d'avis a déjà été affiché à cet utilisateur
  Future<bool> isNudgeAlreadyShown() async {
    try {
      final userId = _db.auth.currentUser?.id;
      if (userId == null) return true; // sécurité : ne pas afficher si inconnu

      final row = await _db
          .from('profiles')
          .select('trial_nudge_shown_at')
          .eq('id', userId)
          .maybeSingle();

      return row?['trial_nudge_shown_at'] != null;
    } catch (e) {
      _log.w('[Trial] isNudgeAlreadyShown error: $e');
      return true;
    }
  }

  /// Marque le nudge comme affiché (idempotent)
  Future<void> markNudgeShown() async {
    try {
      final userId = _db.auth.currentUser?.id;
      if (userId == null) return;

      await _db.from('profiles').update({
        'trial_nudge_shown_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      _log.w('[Trial] markNudgeShown error: $e');
    }
  }

  // ── Mapping interne ──────────────────────────────────────────

  SubscriptionStatus _mapToStatus(CustomerInfo info) {
    final entitlement = info.entitlements.active[AppConstants.rcEntitlementPro];

    if (entitlement == null) return const SubscriptionStatus.free();

    return SubscriptionStatus(
      isPro:          true,
      expiresAt:      entitlement.expirationDate != null
          ? DateTime.tryParse(entitlement.expirationDate!)
          : null,
      isTrialing:     entitlement.periodType == PeriodType.trial,
      willRenew:      entitlement.willRenew,
      trialStartDate: DateTime.tryParse(entitlement.originalPurchaseDate),
    );
  }
}
