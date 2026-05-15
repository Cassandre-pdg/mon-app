# 🧭 CLAUDE.md — Instructions pour Claude Code
*Ce fichier est lu par Claude Code à chaque session. Ne jamais le supprimer.*
*Dernière mise à jour : mai 2026 — dashboard Mon Espace mis à jour.*

---

## 🎯 QUI JE SUIS ET CE QU'ON CONSTRUIT

Je suis Cassandre, fondatrice solo de **Kolyb** — une application Flutter de bien-être, productivité et réseau social pour entrepreneurs indépendants.

**Le problème résolu :**
Les indépendants jonglent entre 5 apps différentes, s'isolent progressivement, et perdent le fil de leur progression. Kolyb réunit tout en un seul endroit.

**La promesse de l'app :**
> "Ton élan, au quotidien."

---

## 🛠️ STACK TECHNIQUE — NE JAMAIS DÉVIER DE ÇA

```
Mobile        → Flutter 3.x (Dart) — iOS + Android
State         → Riverpod 2.x (jamais Provider, jamais Bloc)
Base données  → Supabase (EU Frankfurt) — déjà configuré
Auth          → Supabase Auth
Notifications → Firebase Cloud Messaging — déjà configuré
Navigation    → go_router
Graphiques    → fl_chart
Paiements     → RevenueCat + Stripe (V2 uniquement)
CI/CD         → GitHub Actions
```

**URL Supabase :** `https://cpdwrzqamhxxkedwaifk.supabase.co`
**Hébergement :** EU uniquement (RGPD obligatoire)

---

## 📁 ARBORESCENCE RÉELLE DU PROJET — MAI 2026

> ⚠️ Cette arborescence reflète les fichiers qui EXISTENT VRAIMENT dans `flutter_app/lib/`.
> Ne jamais recréer un fichier qui existe déjà. Ne jamais changer la structure sans raison.

```
flutter_app/lib/
│
├── main.dart
│
├── features/
│   │
│   ├── auth/
│   │   ├── data/
│   │   │   └── auth_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       └── screens/
│   │           └── auth_screen.dart          ← email + Google + Apple Sign-In
│   │
│   ├── capture/                              ← bouton flottant "brain dump" (haut droite)
│   │   ├── data/
│   │   │   ├── capture_model.dart            ← CaptureItem {destination, destinationId}
│   │   │   └── capture_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── capture_provider.dart     ← pendingCapturesCountProvider (badge)
│   │       └── widgets/
│   │           └── capture_bottom_sheet.dart ← showCaptureSheet(context)
│   │
│   ├── checkin/
│   │   ├── data/
│   │   │   ├── checkin_model.dart
│   │   │   └── checkin_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── checkin_provider.dart
│   │       └── screens/
│   │           └── checkin_screen.dart       ← type: 'morning' | 'evening'
│   │
│   ├── community/                            ← "Le Salon" — 3 onglets
│   │   ├── data/
│   │   │   ├── challenge_model.dart          ← KolybChallenge (défi mensuel)
│   │   │   ├── community_model.dart          ← CommunityPost, PostType (6), ReactionType (4)
│   │   │   └── community_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── challenge_provider.dart
│   │       │   └── community_provider.dart   ← filteredPostsProvider, postTypeFilterProvider,
│   │       │                                    feedSortModeProvider, reactedPostsProvider,
│   │       │                                    pollVotedProvider, reportedPostsProvider
│   │       ├── screens/
│   │       │   └── community_screen.dart     ← Feed (filtres type + tri) + Groupes + Défis
│   │       │                                    PostCard : badge type, tag, 4 réactions, sondage
│   │       │                                    PostSheet : 2 étapes (type → rédaction + tag)
│   │       └── widgets/
│   │           └── salon_charter_modal.dart
│   │
│   ├── dashboard/                            ← "Mon Espace" — onglet 1
│   │   ├── data/
│   │   │   └── dashboard_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── dashboard_provider.dart
│   │       └── screens/
│   │           └── dashboard_screen.dart     ← ÉCRAN ENRICHI (mai 2026) — ordre des sections :
│   │                                            1. Streak card (violet, glow pulsant)
│   │                                            2. Suivi du jour : 3 anneaux Apple Watch
│   │                                               Focus (violet) · Habitudes (teal) · Check-ins (amber)
│   │                                               Curseur flashy visible même à 0%, track alpha 0.30
│   │                                               Animation entrée 1.2s + pulse curseur infini
│   │                                            3. Check-ins matin/soir : gradient contextuel,
│   │                                               taille dynamique selon l'heure (flex 3:2),
│   │                                               emoji géant fond semi-transparent, zéro bordure blanche
│   │                                            4. Mon Projet en cours : card premium fond sombre,
│   │                                               nom + pourquoi + barre % + stats tâches + J-X
│   │                                               utilise focusProjectProvider (projet épinglé Kanban)
│   │                                            5. Prendre soin de moi : Méditer (teal) + Respirer (violet)
│   │                                               côte à côte avec glow animé + Revue hebdo (amber)
│   │                                            6. Niveau + barre progression
│   │                                            7. Bandeau motivation contextuel (streak-aware)
│   │
│   ├── objectives/                           ← "Mes Objectifs" — onglet 2
│   │   ├── data/
│   │   │   ├── habit_model.dart
│   │   │   ├── habits_repository.dart
│   │   │   ├── objective_model.dart
│   │   │   └── objectives_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── habits_provider.dart
│   │       │   └── objectives_provider.dart
│   │       └── screens/
│   │           └── objectives_screen.dart    ← fl_chart LineChart, ProjectHubCard→Kanban,
│   │                                            suivi d'habitudes, lien objectifs↔tâches
│   │
│   ├── onboarding/
│   │   └── presentation/
│   │       └── screens/
│   │           └── onboarding_screen.dart    ← 4 écrans
│   │
│   ├── planner/                              ← "Ma Journée" — onglet 3
│   │   ├── data/
│   │   │   ├── flow_model.dart               ← FlowState, FlowTimerState
│   │   │   ├── kanban_model.dart             ← KanbanCard {objectiveId}, ProjectStatus
│   │   │   ├── kanban_repository.dart
│   │   │   ├── planner_model.dart            ← PlannerTask
│   │   │   └── planner_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── eisenhower_provider.dart
│   │       │   ├── flash_provider.dart
│   │       │   ├── flow_provider.dart
│   │       │   ├── kanban_provider.dart
│   │       │   └── planner_provider.dart
│   │       └── screens/
│   │           ├── planner_screen.dart       ← ÉCRAN PRINCIPAL : 5 onglets intégrés
│   │           │                               Priorités (MIT badge + liens Kanban/Revue)
│   │           │                               Flow · Pomodoro · Flash · Matrice
│   │           ├── flow_screen.dart          ← FlowTab + FlowScreen autonome (aurora, arc timer)
│   │           ├── pomodoro_screen.dart      ← PomodoroContent (timer 25/5)
│   │           ├── flash_screen.dart         ← FlashTab (micro-tâches < 5 min, par catégorie)
│   │           ├── eisenhower_screen.dart    ← EisenhowerTab (matrice urgence/importance)
│   │           ├── kanban_screen.dart        ← KanbanScreen (route /planner/kanban)
│   │           ├── priorities_screen.dart    ← PrioritiesScreen autonome (route dédiée)
│   │           ├── focus_block_screen.dart   ← Écran focus mode bloquant
│   │           └── weekly_review_screen.dart ← WeeklyReviewScreen (route /planner/weekly-review)
│   │
│   ├── profile/                              ← "Mon Profil" — onglet 5
│   │   ├── data/
│   │   │   ├── notification_settings_repository.dart
│   │   │   └── profile_repository.dart
│   │   ├── domain/
│   │   │   └── notification_settings_model.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── notification_settings_provider.dart
│   │       │   └── profile_provider.dart
│   │       └── screens/
│   │           ├── profile_screen.dart
│   │           └── notification_settings_screen.dart ← route /settings/notifications
│   │
│   ├── rewards/                              ← "Mes Badges" (sans nav bar — route dédiée)
│   │   ├── data/
│   │   │   └── badge_model.dart
│   │   ├── domain/
│   │   │   └── badge_service.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── rewards_provider.dart
│   │       └── screens/
│   │           └── rewards_screen.dart       ← route /rewards
│   │
│   ├── sleep/                                ← ⚠️ EXISTANT MAIS HORS NAV EN V1
│   │   ├── data/                               (pivot V1 : sommeil supprimé de la nav)
│   │   │   ├── sleep_model.dart                Ne pas ajouter dans la barre de navigation.
│   │   │   └── sleep_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── sleep_provider.dart
│   │       └── screens/
│   │           └── sleep_screen.dart
│   │
│   ├── subscription/                         ← Paywall (sans nav bar — route dédiée)
│   │   ├── data/
│   │   │   └── subscription_repository.dart
│   │   ├── domain/
│   │   │   └── subscription_status.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── subscription_provider.dart
│   │       └── screens/
│   │           └── paywall_screen.dart       ← route /paywall?dismissible=false
│   │
│   └── wellness/                             ← Méditation + Respiration (depuis dashboard)
│       ├── data/
│       │   └── models/
│       │       ├── breathing_exercise.dart
│       │       └── meditation.dart
│       └── presentation/
│           └── screens/
│               ├── breathing_exercise_screen.dart  ← route /wellness/breathing
│               ├── meditation_library_screen.dart  ← route /wellness/meditation
│               └── meditation_player_screen.dart   ← route /wellness/meditation/player
│
└── shared/
    ├── constants/
    │   ├── app_constants.dart    ← spacing, radius, durées d'animation, freeWeeklyPosts=3
    │   └── app_strings.dart      ← tous les textes de l'app (jamais hardcodé dans les widgets)
    ├── navigation/
    │   └── app_router.dart       ← GoRouter + AppRoutes + _ScaffoldWithNav (bouton capture)
    ├── services/
    │   ├── flow_notification_service.dart
    │   ├── focus_audio_service.dart
    │   ├── notification_service.dart
    │   ├── pomodoro_notification_service.dart
    │   └── share_service.dart
    ├── theme/
    │   ├── app_colors.dart       ← palette officielle Kolyb (source de vérité)
    │   ├── app_text_styles.dart  ← Inter uniquement, tous les styles nommés
    │   ├── app_theme.dart        ← ThemeData dark/light
    │   └── theme_provider.dart   ← toggle dark/light Riverpod
    └── widgets/
        ├── app_background.dart       ← fond global (gradient violet sombre)
        ├── aurora_background.dart    ← aurora animée (écrans Flow/Wellness)
        ├── focus_audio_toggle.dart   ← toggle musique focus
        ├── glass_card.dart           ← BackdropFilter glass morphism
        ├── kolyb_loader.dart         ← loading screen branded
        └── shareable_card.dart       ← carte partage réseaux sociaux
```

---

## 📱 NAVIGATION — 5 ONGLETS FIXES (V1 PIVOT)

> ⚠️ Le tracker sommeil a été retiré de la nav en V1. La nav est désormais :

```
Barre du bas (ShellRoute go_router) :
[ Mon Espace 🏠 ] [ Objectifs 🎯 ] [ Ma Journée ✅ ] [ Le Salon 👥 ] [ Mon Profil 👤 ]
       /home         /objectives       /planner         /community      /profile
```

**Toutes les routes go_router :**
```
/auth                              → AuthScreen (email + Google + Apple)
/onboarding                        → OnboardingScreen (4 écrans)
/home                              → DashboardScreen  ← onglet 1
/objectives                        → ObjectivesScreen ← onglet 2
/planner                           → PlannerScreen    ← onglet 3 (5 sous-onglets)
/community                         → CommunityScreen  ← onglet 4 (3 sous-onglets)
/profile                           → ProfileScreen    ← onglet 5
/checkin/morning                   → CheckinScreen(type: 'morning')
/checkin/evening                   → CheckinScreen(type: 'evening')
/planner/kanban                    → KanbanScreen
/planner/weekly-review             → WeeklyReviewScreen
/wellness/meditation               → MeditationLibraryScreen
/wellness/meditation/player        → MeditationPlayerScreen (extra: Meditation)
/wellness/breathing                → BreathingExerciseScreen
/rewards                           → RewardsScreen
/settings/notifications            → NotificationSettingsScreen
/paywall                           → PaywallScreen (?dismissible=false pour bloquer)
```

**Bouton capture (brain dump) :**
Le bouton flottant 🖊️ en haut à droite est intégré dans `_ScaffoldWithNav` (app_router.dart).
Il appelle `showCaptureSheet(context)` depuis `capture_bottom_sheet.dart`.
Le badge rouge affiche `pendingCapturesCountProvider` (nombre de notes en attente).

---

## 🗄️ BASE DE DONNÉES SUPABASE — TABLES EXISTANTES

Tables déjà créées avec RLS activé :

```sql
users                  → profils utilisateurs
checkins               → check-ins émotionnels (matin + soir)
planner_tasks          → tâches du jour (3 priorités MIT)
sleep_logs             → suivi sommeil (V2)
groups                 → groupes thématiques communauté
posts                  → posts du forum (PostType, réactions x4, sondage)
relations              → liens entre utilisateurs (amis, mentors)
notification_settings  → préférences notifications
```

**Règle RGPD absolue :** Row Level Security activé sur TOUTES les tables. Ne jamais créer une table sans activer RLS immédiatement.

---

## 🎨 DESIGN SYSTEM — TOUJOURS RESPECTER CES VALEURS

### Couleurs — Palette Kolyb officielle

```dart
// ─── PRIMAIRES ───────────────────────────────────────────
primary:      Color(0xFF6D28D9),  // Violet profond — couleur structurante principale
primaryLight: Color(0xFF8B7FE8),  // Accent / hover / pills
primaryPale:  Color(0xFFC4B5FD),  // Textes sur fond sombre, labels

// ─── SECONDAIRES ─────────────────────────────────────────
secondary: Color(0xFFFF4D6A),  // Corail — énergie, alertes
accent:    Color(0xFF00D4C8),  // Teal — succès, graphiques

// ─── DONNÉES / GRAPHIQUES ────────────────────────────────
chartAmber:  Color(0xFFFFB800), // Amber — warnings, badges, 3e série
chartViolet: Color(0xFF8B7FE8), // Violet clair — 2e série, éléments actifs

// ─── FONDS DARK MODE (défaut) ────────────────────────────
backgroundDark:      Color(0xFF0D0B1E), // Fond principal
surfaceDark:         Color(0xFF1A1836), // Cards, panneaux
surfaceElevatedDark: Color(0xFF22204A), // Modals, bottom sheets, bordures

// ─── FONDS LIGHT MODE ────────────────────────────────────
backgroundLight: Color(0xFFF5F4FF), // Blanc cassé violet — jamais blanc pur
surfaceLight:    Color(0xFFFFFFFF), // Cards uniquement

// ─── TEXTE ───────────────────────────────────────────────
textDark:      Color(0xFFEDEDFF), // Blanc doux (sur fond dark)
textDarkMuted: Color(0x80EDEDED), // Blanc 50% — labels, captions
textLight:     Color(0xFF12122A), // Quasi-noir (sur fond light)

// ─── ÉTATS ───────────────────────────────────────────────
success: Color(0xFF00D4C8), // = accent teal
warning: Color(0xFFFFB800), // = amber
error:   Color(0xFFFF4D6A), // = corail

// ─── AURORA (écrans Flow / Wellness) ─────────────────────
auroraViolet: Color(0xFF6D28D9).withValues(alpha: 0.35)
auroraTeal:   Color(0xFF00D4C8).withValues(alpha: 0.25)
```

### Typographie — Inter uniquement

```dart
// Toute l'app utilise Inter (Google Fonts)
// Jamais de Plus Jakarta Sans, jamais d'autre police

brandName:    Inter 700, 28px, letterSpacing -0.02em  // "kolyb" (logo/splash)
brandSlogan:  Inter 500, 15px, letterSpacing +0.03em  // "Ton élan, au quotidien."
displayLarge: Inter 700, 32px, letterSpacing -0.5     // Grands titres
headingLarge: Inter 700, 24px, letterSpacing -0.3     // Titres de section
headingMedium:Inter 600, 20px                          // "Mon Espace"
headingSmall: Inter 600, 16px                          // Sous-titres
bodyLarge:    Inter 500, 16px                          // Corps principal
bodyMedium:   Inter 400, 14px, lineHeight 1.5          // Texte courant
bodySmall:    Inter 400, 13px
labelMedium:  Inter 500, 13px                          // Labels
caption:      Inter 400, 11px                          // "Aujourd'hui à 18h30"
heroNumber:   Inter 700, 52px                          // Chiffre centré (timer Flow)
```

### Règles UI

MODE           → Dark par défaut. Toggle dark/light dans Mon Profil > Paramètres.
               → Light mode : fond #F5F4FF jamais #FFFFFF pur comme fond de page.
               → Cards en light : fond blanc #FFFFFF avec bordure 0.5px subtile.

CARDS          → BorderRadius.circular(16) — coins généreux, jamais anguleux
               → Séparation entre cards : espacement 12px minimum, jamais de ligne dure
               → Fond dark : #1A1836 avec bordure #22204A (alpha 0.12)
               → Fond light : #FFFFFF avec bordure grey200

BOUTONS        → Pill complet : StadiumBorder() — JAMAIS carré
               → CTA principal : background violet #6D28D9, texte blanc
               → CTA secondaire : background rgba(255,255,255,0.10), texte blanc doux
               → Bouton destructif : corail #FF4D6A

GRAPHIQUES     → fl_chart, fond sombre, trait/barre fin
               → Couleurs dans l'ordre : violet → teal → amber → corail
               → Ring/donut chart pour la progression globale

TAGS / PILLS   → BorderRadius.circular(20)
               → Violet : AppColors.primary.withValues(alpha:0.18) / texte primaryLight
               → Teal   : AppColors.accent.withValues(alpha:0.15)  / texte accent
               → Amber  : AppColors.chartAmber.withValues(alpha:0.15) / texte chartAmber
               → Corail : AppColors.secondary.withValues(alpha:0.15) / texte secondary

AURORA         → Utilisé dans FlowTab, FlowScreen, completion overlays
               → _FlowAuroraPainter : CustomPainter avec orbes floutées violet/teal
               → Animation 8s repeat(reverse:true)

ESPACEMENT     → Multiples de 8 : 8, 16, 24, 32, 48
               → Constantes : AppConstants.spacing8/12/16/24/32/48

---

## ✍️ CHARTE ÉDITORIALE — TEXTES DE L'APP

### Ton obligatoire
- Bienveillant + motivant, jamais moralisateur
- Tutoiement TOUJOURS ("tu", jamais "vous")
- Ami expert qui tire vers le haut sans juger
- Phrases courtes, directes, positives

### Ponctuation INTERDITE dans tous les textes visibles
```
❌ — (tiret long / em dash) → remplacer par : ou , ou . selon le contexte
```

### Mots INTERDITS
```
❌ performer / optimiser / hustle / grind / productivité maximale
❌ crush / dominer / side hustle / killer / beast mode / réussir à tout prix
```

### Mots OBLIGATOIRES (à privilégier)
```
✅ avancer · ensemble · à ton rythme · aujourd'hui · progresser
✅ prendre soin de toi · à ton image · compagnon
```

### Nom des sections (ne jamais changer)
```
Dashboard    → "Mon Espace"
Objectifs    → "Mes Objectifs"
Check-in     → "Mon Check-in"
Productivité → "Ma Journée"
Communauté   → "Le Salon"
Profil       → "Mon Profil"
Récompenses  → "Mes Badges"
```

---

## ⚡ ÉTAT DES FEATURES V1 — CE QUI EST CODÉ

### ✅ FAIT — ne pas recréer, ne pas écraser

| Feature | Écran principal | État |
|---------|----------------|------|
| Auth | `auth_screen.dart` | Email + Google + Apple |
| Onboarding | `onboarding_screen.dart` | 4 écrans |
| Check-in matin/soir | `checkin_screen.dart` | 3 questions + animation |
| Dashboard | `dashboard_screen.dart` | Streak · Anneaux suivi (Focus/Habitudes/Check-ins) · Check-ins gradient · Card projet · Bien-être · Niveau |
| Objectifs | `objectives_screen.dart` | fl_chart, habitudes, lien Kanban |
| Planner — Priorités | `planner_screen.dart` | MIT badge, 3 tâches, Kanban/Revue links |
| Planner — Flow | `flow_screen.dart` | Aurora, arc timer 90min, overlay, config |
| Planner — Pomodoro | `pomodoro_screen.dart` | Timer 25/5, notifications |
| Planner — Flash | `flash_screen.dart` | Micro-tâches < 5min, par catégorie |
| Planner — Matrice | `eisenhower_screen.dart` | Eisenhower 4 quadrants |
| Kanban | `kanban_screen.dart` | Colonnes, lien objectifs (objectiveId) |
| Revue hebdo | `weekly_review_screen.dart` | Questions bilan |
| Le Salon — Feed | `community_screen.dart` | Filtres 6 types, tri, question semaine |
| Le Salon — PostCard | `community_screen.dart` | Badge type, tag, 4 réactions, sondage |
| Le Salon — PostSheet | `community_screen.dart` | 2 étapes : type → texte + tag + poll |
| Le Salon — Groupes | `community_screen.dart` | 5 groupes V1, rejoindre/quitter |
| Le Salon — Défis | `community_screen.dart` | Défi mensuel, barre progression |
| Profil | `profile_screen.dart` | Infos utilisateur |
| Notifs settings | `notification_settings_screen.dart` | 6 types de notifs |
| Capture brain-dump | `capture_bottom_sheet.dart` | Bouton haut-droite, badge pending |
| Badges/Récompenses | `rewards_screen.dart` | Streaks, niveaux, badges |
| Paywall | `paywall_screen.dart` | Pro V2 (affiché sans fonctionnel) |
| Méditation | `meditation_library_screen.dart` | Bibliothèque |
| Player méditation | `meditation_player_screen.dart` | Player avec audio |
| Respiration | `breathing_exercise_screen.dart` | Exercices guidés |
| Dark/Light mode | `theme_provider.dart` | Toggle Riverpod |

### ❌ NE PAS CODER EN V1 (réservé V2)
- Matching mentor/mentoré
- Webinaires et événements live
- Rapport PDF mensuel
- Statistiques avancées IA
- Messagerie de groupe
- RevenueCat / paiements réels
- Création de groupe (admin)
- Tracker sommeil dans la nav (les fichiers existent, la feature est hors nav)

---

## 🏆 GAMIFICATION — RÈGLES PRÉCISES

### Streaks
```
3 jours   → badge 🔥 "3 jours de suite"
7 jours   → badge 🔥🔥 "Une semaine !"
14 jours  → badge ⭐ "2 semaines"
30 jours  → badge 🏆 "1 mois"
100 jours → badge 💎 "100 jours"
365 jours → badge 👑 "1 an"
```
**Si streak cassé :** Message encourageant JAMAIS punitif. Badge "Relevé 💪" si reprise dans les 48h.

### Niveaux
```
Niveau 1 → Explorateur  (0-100 pts)
Niveau 2 → Indépendant  (101-300 pts)
Niveau 3 → Entrepreneur (301-600 pts)
Niveau 4 → Bâtisseur    (601-1000 pts)
Niveau 5 → Visionnaire  (1001+ pts)
```

### Points
```
Check-in matin/soir complété → +5 pts chacun
3 tâches complétées          → +10 pts
Post dans Le Salon           → +2 pts
Ami ajouté                   → +5 pts
Streak maintenu              → +2 pts/jour
Se relever après échec       → +15 pts (bonus bienveillance)
```

---

## 💰 MODÈLE ÉCONOMIQUE

### Gratuit (toujours accessible)
Check-in illimité · Dashboard · 3 priorités · Capture brain-dump · Feed Le Salon (lecture) · 3 posts/semaine · Badges & streaks · Pomodoro · Flow · Méditation basique

### Pro 14,99 €/mois (V2 uniquement)
Posts illimités · Création de groupe · Rapport PDF · Méditations Pro · Musiques focus · Statistiques avancées · Webinaires · Historique illimité

### Règle paywall
- **Jamais** de pop-up intrusif
- Cadenas discret sur les features Pro
- Nudge contextuel : "Tu as posté 3 fois — avec Pro, c'est illimité 🚀"

---

## 🔒 RÈGLES RGPD — NON NÉGOCIABLES

1. **RLS activé** sur chaque nouvelle table Supabase IMMÉDIATEMENT
2. **Jamais** de données stockées hors EU
3. **Chiffrement** pour check-ins et données sensibles
4. **Bouton suppression** compte dans Paramètres (effacement 30j)
5. **Disclaimer** : "Kolyb est un outil de bien-être, pas un dispositif médical"
6. **Aucune revente** de données
7. **Opt-in explicite** pour chaque type de notification

---

## 🧪 RÈGLES DE CODE — QUALITÉ

### Toujours faire
```dart
// ✅ Gestion des erreurs sur chaque appel Supabase
// ✅ 3 états partout : loading / data / error
// ✅ Empty state avec message bienveillant
// ✅ Commentaires en français sur la logique métier
// ✅ Noms de variables en anglais (convention Dart)
// ✅ Tester dark mode ET light mode
```

### Ne jamais faire
```dart
// ❌ Logique métier dans les widgets
// ❌ Appel Supabase direct dans un widget
// ❌ setState dans un écran Riverpod
// ❌ Couleurs hardcodées hors AppColors
// ❌ Textes hardcodés hors AppStrings
// ❌ Feature V2 en V1
// ❌ print() en production (utiliser logger)
// ❌ Import croisé entre features (passer par shared/)
```

### Patterns clés établis dans le projet

**Provider Riverpod type :**
```dart
final myProvider = StateNotifierProvider<MyNotifier, AsyncValue<List<MyModel>>>(
  (ref) => MyNotifier(ref.watch(myRepositoryProvider)),
);

class MyNotifier extends StateNotifier<AsyncValue<List<MyModel>>> {
  MyNotifier(this._repo) : super(const AsyncValue.loading()) { _load(); }
  final MyRepository _repo;
  Future<void> _load() async { /* ... */ }
}
```

**Navigation sans import circulaire (depuis un écran feature) :**
```dart
// Ne pas importer app_router.dart depuis une feature (cycle)
// Utiliser les strings directement :
context.push('/planner/kanban');
context.push('/planner/weekly-review');
```

**ConsumerStatefulWidget pour les modals Riverpod :**
```dart
// Pour les ModalBottomSheet qui ont besoin de ref :
builder: (ctx) => MyConsumerStatefulSheet(...)
// Et dans la classe : extends ConsumerStatefulWidget
```

---

## 🍎 BUILD IOS — NOTES IMPORTANTES

Le simulateur fonctionne. L'iPhone physique nécessite Xcode direct.

**En cas de problème pod install :**
```bash
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 pod install
```

**En cas de CodeSign error sur les frameworks :**
```bash
find /Users/cassandre/Desktop/mon-app/flutter_app -name "*.framework" -exec xattr -cr {} \;
```

**Le Podfile** (`ios/Podfile`) a `CODE_SIGNING_ALLOWED=NO` sur tous les targets pods — ne pas y toucher.

**Profile.xcconfig** (`ios/Flutter/Profile.xcconfig`) doit exister avec :
```
#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.profile.xcconfig"
#include "Generated.xcconfig"
```

---

## 🚨 RÈGLES ABSOLUES POUR CLAUDE CODE

1. **Toujours** lire un fichier avant de le modifier
2. **Toujours** respecter l'arborescence réelle ci-dessus — ne jamais recréer ce qui existe
3. **Toujours** utiliser les couleurs de AppColors, jamais de hardcode
4. **Toujours** utiliser le tutoiement dans tous les textes
5. **Jamais** coder une fonctionnalité V2 en V1
6. **Jamais** créer une table Supabase sans RLS
7. **Jamais** écraser un fichier qui contient du travail existant sans le lire d'abord
8. **Toujours** gérer les 3 états : loading / data / error
9. **Toujours** prévoir un empty state avec message bienveillant
10. **Jamais** toucher à la navigation (5 onglets fixes) sans confirmation explicite
11. **Après chaque modification** : lancer `flutter analyze` pour vérifier zéro erreur

---

## 📞 CONTEXTE PROJET

- **Fondatrice :** Cassandre (dev solo, première app Flutter)
- **Budget :** < 10 000 €
- **Cible beta :** Mai/Juin 2025 — décalée à 2026
- **GitHub :** https://github.com/Cassandre-pdg/mon-app
- **Supabase :** https://cpdwrzqamhxxkedwaifk.supabase.co
- **Localisation :** France — RGPD obligatoire
- **Branding :** dossier `Brands/` à la racine — icône, palette, guidelines officiels
