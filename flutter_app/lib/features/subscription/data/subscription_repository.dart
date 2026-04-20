import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:logger/logger.dart';

import '../../../shared/constants/app_constants.dart';
import '../domain/subscription_status.dart';

/// Toutes les interactions avec le SDK RevenueCat
/// Jamais appelé directement depuis un widget — passer par subscription_provider.dart
class SubscriptionRepository {
  SubscriptionRepository._();
  static final SubscriptionRepository instance = SubscriptionRepository._();

  final _log = Logger();

  // ── Configuration ────────────────────────────────────────────

  /// Initialiser RevenueCat au démarrage de l'app (appelé dans main.dart)
  Future<void> init({String? userId}) async {
    if (kIsWeb) return; // RevenueCat = mobile uniquement

    final apiKey = Platform.isIOS
        ? AppConstants.revenueCatApiKeyIos
        : AppConstants.revenueCatApiKeyAndroid;

    await Purchases.setLogLevel(LogLevel.info);
    final config = PurchasesConfiguration(apiKey);
    await Purchases.configure(config);

    // Associe l'utilisateur Supabase à RevenueCat dès que possible
    if (userId != null) {
      await identifyUser(userId);
    }

    _log.i('[RevenueCat] initialisé — userId: ${userId ?? "anonyme"}');
  }

  /// Associe un userId Supabase à RevenueCat (à appeler après login)
  Future<void> identifyUser(String userId) async {
    if (kIsWeb) return;
    try {
      await Purchases.logIn(userId);
      _log.i('[RevenueCat] utilisateur identifié: $userId');
    } catch (e) {
      _log.w('[RevenueCat] identifyUser error: $e');
    }
  }

  /// Réinitialise l'identité (à appeler après logout)
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

  /// Vérifie si l'utilisateur a l'entitlement Pro actif
  Future<SubscriptionStatus> getStatus() async {
    if (kIsWeb) return const SubscriptionStatus.free();
    try {
      final info = await Purchases.getCustomerInfo();
      return _mapToStatus(info);
    } catch (e) {
      _log.w('[RevenueCat] getStatus error: $e');
      return const SubscriptionStatus.free();
    }
  }

  /// Récupère l'offering actif (packages disponibles à l'achat)
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

  /// Lance l'achat d'un package RevenueCat
  /// Retourne le nouveau statut ou lance une exception en cas d'erreur
  Future<SubscriptionStatus> purchase(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      _log.i('[RevenueCat] achat réussi: ${package.identifier}');
      return _mapToStatus(result.customerInfo);
    } on PurchasesErrorCode catch (e) {
      // Annulation volontaire par l'utilisateur — pas une vraie erreur
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        _log.i('[RevenueCat] achat annulé par l\'utilisateur');
        return const SubscriptionStatus.free();
      }
      _log.e('[RevenueCat] purchase error: $e');
      rethrow;
    }
  }

  /// Restaure les achats précédents (obligatoire App Store / Play Store)
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

  // ── Mapping interne ──────────────────────────────────────────

  SubscriptionStatus _mapToStatus(CustomerInfo info) {
    final entitlement = info.entitlements.active[AppConstants.rcEntitlementPro];

    if (entitlement == null) return const SubscriptionStatus.free();

    return SubscriptionStatus(
      isPro:      true,
      expiresAt:  entitlement.expirationDate != null
          ? DateTime.tryParse(entitlement.expirationDate!)
          : null,
      isTrialing: entitlement.periodType == PeriodType.trial,
      willRenew:  entitlement.willRenew,
    );
  }
}
