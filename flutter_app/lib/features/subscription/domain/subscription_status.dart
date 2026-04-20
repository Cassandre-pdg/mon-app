/// Modèle domaine pur — sans import Flutter ni RevenueCat
/// Représente l'état d'abonnement d'un utilisateur Kolyb
class SubscriptionStatus {
  /// true si l'utilisateur a l'entitlement "pro" actif
  final bool isPro;

  /// Date d'expiration de l'abonnement (null si gratuit ou essai non commencé)
  final DateTime? expiresAt;

  /// true si l'utilisateur est en période d'essai gratuit
  final bool isTrialing;

  /// true si l'abonnement va se renouveler automatiquement
  final bool willRenew;

  const SubscriptionStatus({
    required this.isPro,
    this.expiresAt,
    this.isTrialing = false,
    this.willRenew  = false,
  });

  /// Utilisateur gratuit — état par défaut avant toute vérification
  const SubscriptionStatus.free()
      : isPro       = false,
        expiresAt   = null,
        isTrialing  = false,
        willRenew   = false;

  /// Helpers lisibles dans les widgets
  bool get isFree   => !isPro;
  bool get isActive => isPro;

  @override
  String toString() =>
      'SubscriptionStatus(isPro: $isPro, isTrialing: $isTrialing, willRenew: $willRenew, expiresAt: $expiresAt)';
}
