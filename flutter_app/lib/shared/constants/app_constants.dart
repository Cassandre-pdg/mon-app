/// Constantes globales de Kolyb
class AppConstants {
  AppConstants._();

  // Nom de l'app
  static const String appName = 'Kolyb';
  static const String appTagline = 'Ton élan, au quotidien.';

  // RevenueCat — remplacer par tes clés depuis app.revenuecat.com
  // iOS  : App Settings → API Keys → Public (commence par "appl_")
  // Android : App Settings → API Keys → Public (commence par "goog_")
  static const String revenueCatApiKeyIos     = 'appl_REMPLACER_PAR_TA_CLE_IOS';
  static const String revenueCatApiKeyAndroid = 'goog_REMPLACER_PAR_TA_CLE_ANDROID';

  // Identifiant de l'entitlement Pro dans le dashboard RevenueCat
  static const String rcEntitlementPro = 'Kolyb Pro'; // doit correspondre exactement à l'identifier RevenueCat

  // Identifiant de l'offering actif (défaut RevenueCat = "default")
  static const String rcOfferingId = 'default';

  // Identifiants produits (doivent correspondre exactement à App Store Connect / Google Play)
  static const String rcProductMonthly = 'kolyb_pro_monthly'; // 9,99 €/mois
  static const String rcProductAnnual  = 'kolyb_pro_annual';  // 79 €/an

  // Prix de référence (fallback si RevenueCat non disponible)
  static const String priceMonthly       = '9,99\u202f€';
  static const String priceAnnual        = '79\u202f€\u202f/\u202fan';
  static const String priceAnnualMonthly = '6,58\u202f€\u202f/\u202fmois';

  // Supabase
  static const String supabaseUrl = 'https://cpdwrzqamhxxkedwaifk.supabase.co';
  // clé anon publique — sans danger côté client
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNwZHdyenFhbWh4eGtlZHdhaWZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ5ODk3ODUsImV4cCI6MjA5MDU2NTc4NX0.Hba0I_uUUdKBTsLZ8aFgb-SticB4f7ssqPYu51PQgAs';

  // Espacement (multiples de 8 — règle design system)
  static const double spacing4  = 4.0;
  static const double spacing8  = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;

  // Arrondis
  static const double radiusSmall  = 10.0;
  static const double radiusMedium = 16.0;  // cards secondaires
  static const double radiusLarge  = 20.0;  // cards principales
  static const double radiusXL     = 28.0;  // sheets, overlays
  static const double radiusPill   = 100.0; // boutons pill style Apple

  // Boutons — largeur contrainte (jamais plein écran)
  static const double buttonMaxWidth = 320.0;
  static const double buttonMinWidth = 180.0;

  // Animations (jamais > 400ms sauf récompenses)
  static const Duration animFast    = Duration(milliseconds: 150);
  static const Duration animNormal  = Duration(milliseconds: 250);
  static const Duration animSlow    = Duration(milliseconds: 400);
  static const Duration animReward  = Duration(milliseconds: 800);

  // Gamification
  static const int pointsMorningCheckin = 5;
  static const int pointsEveningCheckin = 5;
  static const int points3Tasks         = 10;
  static const int pointsSleep          = 3;
  static const int pointsPost           = 2;
  static const int pointsFriend         = 5;
  static const int pointsStreakBonus    = 2;
  static const int pointsComeback       = 15; // "Relevé 💪"

  // Limites freemium
  static const int freeWeeklyPosts = 3;
  static const int maxDailyTasks   = 3;

  // Horaires notifications par défaut
  static const String defaultMorningTime = '07:30';
  static const String defaultEveningTime = '18:30';
}
