/// Modèle domaine pur — sans import Flutter ni RevenueCat
/// Représente l'état d'abonnement d'un utilisateur Kolyb
class SubscriptionStatus {
  /// true si l'utilisateur a l'entitlement "pro" actif (RevenueCat ou trial étendu)
  final bool isPro;

  /// Date d'expiration de l'abonnement (null si gratuit)
  final DateTime? expiresAt;

  /// true si l'utilisateur est en période d'essai gratuit RevenueCat
  final bool isTrialing;

  /// true si l'abonnement va se renouveler automatiquement
  final bool willRenew;

  /// Date de début du trial (originalPurchaseDate RevenueCat)
  final DateTime? trialStartDate;

  const SubscriptionStatus({
    required this.isPro,
    this.expiresAt,
    this.isTrialing = false,
    this.willRenew  = false,
    this.trialStartDate,
  });

  /// Utilisateur gratuit — état par défaut avant toute vérification
  const SubscriptionStatus.free()
      : isPro          = false,
        expiresAt      = null,
        isTrialing     = false,
        willRenew      = false,
        trialStartDate = null;

  /// Helpers lisibles dans les widgets
  bool get isFree   => !isPro;
  bool get isActive => isPro;

  /// Nombre de jours écoulés depuis le début du trial (null si pas en trial)
  int? get trialDaysElapsed {
    if (!isTrialing || trialStartDate == null) return null;
    return DateTime.now().difference(trialStartDate!).inDays;
  }

  @override
  String toString() =>
      'SubscriptionStatus(isPro: $isPro, isTrialing: $isTrialing, willRenew: $willRenew, expiresAt: $expiresAt)';
}
