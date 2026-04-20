/// Tous les textes de l'app — jamais de hardcode dans les widgets
/// Charte éditoriale : tutoiement, bienveillant, motivant
class AppStrings {
  AppStrings._();

  // ── NAVIGATION ──────────────────────────────────────────────
  static const String navHome      = 'Mon Espace';
  static const String navPlanner   = 'Ma Journée';
  static const String navCommunity = 'Le Salon';
  static const String navSleep     = 'Mon Sommeil';
  static const String navProfile   = 'Mon Profil';
  static const String navBadges    = 'Mes Badges';

  // ── ONBOARDING ──────────────────────────────────────────────
  static const String onboardingTagline =
      'kolyb, ton compagnon de route.\nTon élan, au quotidien, à ton rythme, jamais seul.';

  // ── CHECK-IN ────────────────────────────────────────────────
  static const String checkinMorningTitle   = 'Bonjour 👋';
  static const String checkinMorningSubtitle = 'Comment tu démarres ta journée ?';
  static const String checkinEveningTitle   = 'Bonne soirée 🌙';
  static const String checkinEveningSubtitle = 'Comment s\'est passée ta journée ?';
  static const String checkinDone           = 'Belle avancée ! ✅';

  // Questions check-in matin
  static const String morningQ1 = 'Comment tu te sens ce matin ?';
  static const String morningQ2 = 'Quel est ton niveau d\'énergie ?';
  static const String morningQ3 = 'Sur quoi tu vas te concentrer aujourd\'hui ?';

  // Questions check-in soir
  static const String eveningQ1 = 'Comment s\'est passée ta journée ?';
  static const String eveningQ2 = 'Quel est ton niveau d\'énergie ce soir ?';
  static const String eveningQ3 = 'Tu es satisfait(e) de ta journée ?';

  // ── PLANNER ─────────────────────────────────────────────────
  static const String plannerTitle         = 'Ma Journée';
  static const String plannerEmptyState    = 'Ajoute tes 3 priorités du jour, à ton rythme 🎯';
  static const String plannerTaskDone      = 'Belle avancée ! ✅';
  static const String plannerAllDone       = 'Journée accomplie — tu avances 🚀';
  static const String plannerMaxTasks      = 'Concentre-toi sur tes 3 priorités du jour !';

  // ── STREAKS ─────────────────────────────────────────────────
  static const String streakBroken =
      'Pas grave, tout le monde a des jours sans. Reprends aujourd\'hui 💪';
  static const String streakComeback = 'Tu es de retour, belle énergie 💪';

  // ── GAMIFICATION ────────────────────────────────────────────
  static const String level1 = 'Explorateur';
  static const String level2 = 'Indépendant';
  static const String level3 = 'Entrepreneur';
  static const String level4 = 'Bâtisseur';
  static const String level5 = 'Visionnaire';

  // ── ÉTATS VIDES (bienveillants) ─────────────────────────────
  static const String emptyCheckins  = 'Commence ton premier check-in — ça prend 1 minute 🌱';
  static const String emptyCommunity = 'Le Salon t\'attend, dis bonjour 👋';
  static const String emptySleep     = 'Note ton sommeil pour suivre ton énergie 😴';
  static const String emptyBadges    = 'Tes premiers badges arrivent — continue comme ça 🔥';

  // ── ERREURS ─────────────────────────────────────────────────
  static const String errorGeneric     = 'Oops, quelque chose s\'est mal passé. Réessaie !';
  static const String errorNetwork     = 'Pas de connexion — vérifie ton réseau.';
  static const String errorAuth        = 'Connexion impossible. Vérifie tes identifiants.';

  // ── PAYWALL ───────────────────────────────────────────────────
  static const String paywallNudgePost =
      'Tu as posté 3 fois — avec Pro, c\'est illimité 🚀';

  static const String paywallTitle    = 'Kolyb Pro';
  static const String paywallSubtitle =
      'Les outils et la communauté pour ne plus avancer seul.';

  // Mensuel
  static const String paywallPriceMonthly        = '9,99\u202f€';
  static const String paywallPriceMonthlyCaption  = '0,33\u202f€ par jour — moins qu\'un café';

  // Annuel
  static const String paywallPriceAnnual         = '79\u202f€\u202f/\u202fan';
  static const String paywallPriceAnnualMonthly  = '6,58\u202f€\u202f/\u202fmois';
  static const String paywallPriceAnnualSaving   = '\u221234\u202f%';

  // Actions
  static const String paywallCtaPro      = 'Commencer avec Pro';
  static const String paywallCtaFree     = 'Continuer en gratuit';
  static const String paywallRestoreLink = 'Restaurer un achat';
  static const String paywallLegal       =
      'Sans engagement. Résiliable à tout moment depuis les paramètres de ton app store.';

  // Erreurs
  static const String paywallErrorGeneric =
      'L\'achat n\'a pas abouti. Réessaie dans quelques instants.';
  static const String paywallErrorRestore =
      'Aucun achat à restaurer sur ce compte.';

  // Succès
  static const String paywallSuccessTitle    = 'Bienvenue dans Kolyb Pro\u202f!';
  static const String paywallSuccessSubtitle = 'Tout est débloqué. Tu avances\u202f🚀';

  // ── RGPD ─────────────────────────────────────────────────────
  static const String rgpdDisclaimer =
      'Kolyb est un outil de bien-être, pas un dispositif médical.';
}
