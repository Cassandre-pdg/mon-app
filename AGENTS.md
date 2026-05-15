# 🧭 AGENTS.md — Instructions pour Codex
*Ce fichier est lu par Codex à chaque session. Ne jamais le supprimer.*

---

## 🎯 QUI JE SUIS ET CE QU'ON CONSTRUIT

Je suis Cassandre, fondatrice solo de **Kolyb** — une application Flutter de productivité, structuration et communauté pour entrepreneurs indépendants.

**Le problème résolu :**
Les indépendants jonglent entre 5 apps différentes, s'isolent progressivement, et perdent le fil de leurs objectifs. Kolyb leur donne une structure quotidienne claire et une communauté pour avancer ensemble.

**Le focus V1 — trois piliers :**
1. **Se structurer** : objectifs, habitudes, tâches quotidiennes, planificateur
2. **Être plus productif** : check-in matin/soir, Pomodoro, revue de semaine, kanban
3. **Ne pas avancer seul** : Le Salon, espace de discussion et débat entre indépendants

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

## 📁 STRUCTURE DES DOSSIERS — TOUJOURS RESPECTER ÇA

```
flutter_app/
└── lib/
    ├── main.dart
    ├── features/                    → une feature = un dossier
    │   ├── onboarding/
    │   │   ├── data/               → appels Supabase, modèles JSON
    │   │   ├── domain/             → logique métier pure, sans Flutter
    │   │   └── presentation/       → widgets, screens, providers Riverpod
    │   ├── checkin/                → check-in matin + soir
    │   ├── dashboard/              → "Mon Espace"
    │   ├── objectives/             → "Mes Objectifs" + habitudes
    │   ├── planner/                → "Ma Journée" + Pomodoro + Kanban + Focus
    │   ├── wellness/               → méditations + respirations (V1 léger)
    │   ├── community/              → "Le Salon" — discussions + débats
    │   ├── profile/                → "Mon Profil" + paramètres
    │   ├── auth/                   → inscription / connexion
    │   └── rewards/                → badges, streaks, niveaux
    │
    │   ❌ sleep/ — supprimé en V1. Tracker sommeil déplacé en V2.
    └── shared/
        ├── theme/                  → couleurs, polices, styles globaux
        ├── widgets/                → widgets réutilisables
        ├── constants/              → constantes de l'app
        └── utils/                  → fonctions utilitaires
```

**Règle absolue :** Chaque feature est indépendante. On ne fait jamais d'import croisé entre features. On passe par `shared/` si quelque chose est partagé.

---

## 🗄️ BASE DE DONNÉES SUPABASE — TABLES EXISTANTES

Tables déjà créées avec RLS activé :

```sql
users                  → profils utilisateurs
checkins               → check-ins émotionnels (matin + soir)
planner_tasks          → tâches du jour (3 priorités)
objectives             → objectifs court/moyen/long terme
habits                 → habitudes récurrentes (daily/weekly/custom)
habit_completions      → suivi des completions d'habitudes
kanban_projects        → projets kanban
kanban_tasks           → cartes kanban (todo/in_progress/done)
groups                 → groupes thématiques communauté
posts                  → posts du forum / Le Salon
relations              → liens entre utilisateurs (amis, mentors)
notification_settings  → préférences notifications
```

> ❌ `sleep_logs` — table NON créée en V1. Tracker sommeil reporté en V2.

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
```

### Typographie — Inter uniquement

```dart
// Toute l'app utilise Inter (Google Fonts)
// Jamais de Plus Jakarta Sans, jamais d'autre police

// ─── HIÉRARCHIE ──────────────────────────────────────────
brandName:    Inter 700, 28px, letterSpacing -0.02em  // "kolyb" (logo/splash)
brandSlogan:  Inter 500, 15px, letterSpacing +0.03em  // "Ton élan, au quotidien."
displayLarge: Inter 700, 32px, letterSpacing -0.5     // Grands titres
headingLarge: Inter 700, 24px, letterSpacing -0.3     // Titres de section
headingMedium:Inter 600, 20px                          // "Mon Espace"
headingSmall: Inter 600, 16px                          // Sous-titres
bodyMedium:   Inter 400, 14px, lineHeight 1.5          // Texte courant
labelMedium:  Inter 500, 13px                          // Labels
caption:      Inter 400, 11px                          // "Aujourd'hui à 18h30"
```

### Règles UI

- **Jamais** de design plat et générique — style friendly pro, rounded

MODE           → Dark par défaut. Toggle dark/light dans Mon Profil > Paramètres.
               → Light mode : fond #F8F7FF jamais #FFFFFF pur comme fond de page.
               → Cards en light : fond blanc #FFFFFF avec bordure 0.5px subtile.

CARDS          → BorderRadius.circular(16) — coins généreux, jamais anguleux
               → Séparation entre cards : espacement 12px minimum, jamais de ligne dure
               → Fond dark : #1A1836 avec bordure #22204A
               → Fond light : #FFFFFF avec bordure rgba(0,0,0,0.08)

BOUTONS        → Pill complet : StadiumBorder() Flutter / border-radius: 9999px web — JAMAIS carré
               → JAMAIS pleine largeur du conteneur (pas de w-full hors contexte formulaire)
               → Largeur : fit-content, min 140px, max 320px — même famille visuelle partout
               → CTA principal : background violet #6D28D9, texte blanc
               → CTA secondaire : background rgba(255,255,255,0.10), texte blanc doux
               → Bouton destructif : corail #FF4D6A
               → Dans un formulaire : .btn-block (centré, max 360px) — pas w-full pleine page

GRAPHIQUES     → Fond sombre, trait/barre fin(e) — une couleur d'accent par série
               → Couleurs graphiques dans l'ordre : violet → teal → amber → corail
               → Zéro surcharge : légende minimale, axe discret
               → Ring/donut chart pour la progression globale (inspiré Kolyb + Revolut)

FORMULAIRES    → Une question à la fois, centrée, pleine hauteur (inspiré Headspace)
               → Progress indicator discret en haut (ex. "3/7")
               → Radio buttons avec sélection visuelle immédiate (point violet)
               → CTA unique pleine largeur ancré en bas
               → Jamais de page scrollable avec plusieurs questions

CHECK-IN       → Bimodal matin/soir : deux cards côte à côte (inspiré Stoic)
               → Card matin : fond light/neutre, texte inspirant, ton frais
               → Card soir : fond #0D0B1E, texte violet, plus introspectif
               → Les deux ont leur propre bouton "Commencer"

FEEDBACK       → Écran de complétion centré (inspiré Brilliant) : illustration + chiffre + bouton
               → Animations max 400ms sauf récompenses spéciales (max 800ms)
               → Badge de streak : tag pill violet avec emoji fire

TAGS / BADGES  → Pills arrondies BorderRadius.circular(20)
               → Violet : rgba(109,40,217,0.18) / texte #8B7FE8
               → Teal   : rgba(0,212,200,0.15)  / texte #00D4C8
               → Amber  : rgba(255,184,0,0.15)  / texte #FFB800
               → Corail : rgba(255,77,106,0.15) / texte #FF4D6A

ICÔNES         → Style rounded stroke, cohérent dans toute l'app
               → Jamais filled/solid sauf état actif dans la tab bar

ESPACEMENT     → Multiples de 8 : 8, 16, 24, 32, 48
               → Padding interne des cards : 16px horizontal, 14px vertical
               → Badge → titre/texte en dessous : min 16px margin entre les deux
               → Icône → titre en dessous : min 16px margin entre les deux
               → Elements dans une section : toujours espacés, jamais collés aux bords
               → FAQ : padding bouton min px-8 py-6, réponse min px-8 pb-7, gap min 16px

GRADIENT TEXT  → Classes prédéfinies à utiliser — jamais de gradient inline :
               Web (CSS class) :
                 .gradient-text    → violet clair → teal : titres hero, mots impactants
                 .gradient-violet  → violet profond → violet pâle : accents doux, sections
                 .gradient-energy  → corail → amber : CTA, mots d'action, élan
               App Flutter (ShaderMask avec mêmes couleurs) :
                 gradientMain   → [#8B7FE8, #C4B5FD, #00D4C8]
                 gradientViolet → [#6D28D9, #C4B5FD]
                 gradientEnergy → [#FF4D6A, #FFB800]

COMMUNAUTÉ     → "Le Salon" : espace de discussion, débat, partage entre indépendants
               → Inspiré Discord simplifié : channels/groupes thématiques
               → Format posts longs + réponses — pas de messagerie instantanée (anti-WhatsApp)
               → Ton du salon : débats sur l'entrepreneuriat, partage d'expériences, entraide
               → Pas de profil CV (anti-LinkedIn)
               → Profil : option public / privé dans les paramètres
               → Profil public : minimaliste, prénom + avatar + bio courte + niveau
               → Aucun compteur de followers affiché publiquement
               → Modération : signalement de contenu, admin par groupe
---

## 📱 NAVIGATION — 5 ONGLETS FIXES

```
Barre du bas :
[ Mon Espace 🏠 ] [ Objectifs 🎯 ] [ Ma Journée ✅ ] [ Le Salon 👥 ] [ Mon Profil 👤 ]
```

> ❌ "Mon Sommeil 😴" supprimé de la nav en V1 — tracker sommeil reporté en V2.

**Routes go_router :**
```
/                          → splash
/onboarding                → onboarding (4 écrans)
/home                      → dashboard "Mon Espace"
/objectives                → "Mes Objectifs" + habitudes
/planner                   → "Ma Journée"
/planner/priorities        → 3 priorités du jour
/planner/kanban            → kanban projets
/planner/pomodoro          → timer Pomodoro
/planner/focus-block       → bloc de focus
/planner/flow              → mode Flow
/planner/flash             → flash sessions
/planner/weekly-review     → revue de semaine
/community                 → "Le Salon"
/profile                   → "Mon Profil"
/checkin/morning           → check-in matin
/checkin/evening           → check-in soir
/settings                  → paramètres
/settings/notifications    → préférences notifications
/rewards                   → "Mes Badges"
/paywall                   → offre Pro
/wellness/meditation       → bibliothèque méditations
/wellness/breathing        → exercices de respiration
```

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
   Exemples :
     "avancer — à ton rythme"  →  "avancer, à ton rythme"
     "partenariat — toutes"    →  "partenariat : toutes"
     "jours sans — reprends"   →  "jours sans. Reprends"
```

### Mots INTERDITS dans tous les textes de l'app
```
❌ performer / performance
❌ optimiser / optimisation
❌ hustle / grind
❌ productivité maximale
❌ crush / dominer
❌ side hustle / killer
❌ beast mode
❌ réussir à tout prix
```

### Mots OBLIGATOIRES (à privilégier)
```
✅ avancer
✅ ensemble / communauté
✅ à ton rythme
✅ aujourd'hui
✅ progresser
✅ prendre soin de toi
✅ à ton image
✅ compagnon
```

### Nom des sections (ne jamais changer)
```
Dashboard    → "Mon Espace"
Check-in     → "Mon Check-in"
Objectifs    → "Mes Objectifs"
Productivité → "Ma Journée"
Communauté   → "Le Salon"
Profil       → "Mon Profil"
Récompenses  → "Mes Badges"
```

> ❌ "Mon Sommeil" — retiré de la nav V1. Ne pas créer de screen ni de route `/sleep`.

### Messages clés
```
Onboarding   → "kolyb, ton compagnon de route. Ton élan, au quotidien, à ton rythme, jamais seul."
Streak cassé → "Pas grave, tout le monde a des jours sans. Reprends aujourd'hui 💪"
Tâche cochée → "Belle avancée ! ✅"
Check-in fait → animation badge + phrase inspirante du jour
```

---

## ⚡ FONCTIONNALITÉS V1 — CE QU'ON CODE

### ✅ À coder en V1 — les 3 piliers

**Pilier 1 — Se structurer**
1. Authentification (email + Google + Apple)
2. Onboarding 4 écrans
3. Dashboard "Mon Espace" avec streak + score du jour
4. Objectifs court / moyen / long terme
5. Habitudes récurrentes (daily/weekly) avec streak personnel
6. Système de badges et streaks

**Pilier 2 — Être plus productif**
7. Check-in matin (7h30) — 3 questions
8. Check-in soir (18h30) — 3 questions
9. Planificateur 3 priorités du jour
10. Kanban projets (todo / in_progress / done)
11. Outil Pomodoro (25 min / 5 min)
12. Bloc de focus + mode Flow
13. Revue de semaine
14. Notifications push (6 types)
15. Dark mode / Light mode

**Pilier 3 — Ne pas avancer seul**
16. Le Salon : feed communauté thématique (lecture + 3 posts/semaine gratuit)
17. Groupes thématiques (débat, partage, entraide entrepreneurs)
18. Messagerie privée basique + personnage "Kolyb"
19. Profil utilisateur

### ❌ NE PAS coder en V1 (réservé V2)
- **Tracker sommeil** — supprimé de V1, reporté en V2
- Matching mentor/mentoré
- Webinaires et événements live
- Eisenhower matrix
- Deep Work avancé
- Rapport PDF mensuel
- Création de groupe personnalisé (Pro V2)
- RevenueCat / paiements
- Statistiques avancées IA
- Messagerie de groupe

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

**Si streak cassé :** Message encourageant JAMAIS punitif. Badge spécial "Relevé 💪" si reprise dans les 48h.

### Niveaux
```
Niveau 1 → Explorateur     (0-100 pts)
Niveau 2 → Indépendant     (101-300 pts)
Niveau 3 → Entrepreneur    (301-600 pts)
Niveau 4 → Bâtisseur       (601-1000 pts)
Niveau 5 → Visionnaire     (1001+ pts)
```

### Points gagnés
```
Check-in matin complété    → +5 pts
Check-in soir complété     → +5 pts
3 tâches complétées        → +10 pts
Habitude complétée         → +3 pts
Objectif atteint           → +20 pts
Post dans le Salon         → +2 pts
Ami ajouté                 → +5 pts
Streak maintenu            → +2 pts/jour
Se relever après échec     → +15 pts (bonus bienveillance)
```

> ❌ "Sommeil renseigné → +3 pts" supprimé — feature sommeil reportée en V2.

### Classement
- **Optionnel** — l'utilisateur choisit d'y participer dans les paramètres
- Classement par groupe thématique, jamais global
- Basé sur la régularité, pas les résultats absolus

---

## 💰 MODÈLE ÉCONOMIQUE — RÈGLES DE CODAGE

### Gratuit (toujours accessible, jamais retiré)
- Check-in matin + soir illimité
- Dashboard basique
- Objectifs (3 max en gratuit)
- Habitudes (5 max en gratuit)
- Planificateur 3 tâches du jour
- Kanban (1 projet en gratuit)
- Pomodoro
- Feed Le Salon (lecture + like)
- 3 posts/semaine dans les groupes
- Messagerie privée
- Badges & streaks

### Pro (9,99 €/mois — à intégrer en V2)
- Objectifs illimités
- Habitudes illimitées
- Kanban projets illimités
- Posts illimités dans Le Salon
- Création de groupe personnalisé
- Tracker sommeil
- Rapport mensuel PDF
- Méditations entrepreneurs
- Musiques focus + Deep Work
- Eisenhower matrix
- Statistiques avancées
- Webinaires & événements
- Historique illimité

### Règle d'affichage du paywall
- **Jamais** de pop-up intrusif
- **Toujours** un cadenas discret sur les fonctionnalités Pro
- **Nudge contextuel** uniquement : "Tu as posté 3 fois — avec Pro, c'est illimité 🚀"
- Bannière douce après J+7 d'utilisation uniquement

---

## 🔒 RÈGLES RGPD — NON NÉGOCIABLES

1. **RLS activé** sur chaque nouvelle table Supabase IMMÉDIATEMENT
2. **Jamais** de données stockées hors EU
3. **Chiffrement** pour check-ins (données sensibles)
4. **Bouton suppression** compte dans Paramètres → effacement total 30j
5. **Disclaimer** visible : "Kolyb est un outil de bien-être, pas un dispositif médical"
6. **Aucune revente** de données — jamais
7. **Opt-in explicite** pour chaque type de notification

---

## 🧪 RÈGLES DE CODE — QUALITÉ

### Toujours faire
```dart
// ✅ Tests unitaires sur chaque feature dès sa completion
// ✅ Gestion des erreurs sur chaque appel Supabase
// ✅ États de chargement (loading) sur chaque écran
// ✅ États vides (empty state) avec message encourageant
// ✅ Mode offline : fonctions essentielles sans connexion
// ✅ Commentaires en français sur la logique métier
// ✅ Noms de variables explicites en anglais (convention Dart)
```

### Ne jamais faire
```dart
// ❌ Jamais de logique métier dans les widgets
// ❌ Jamais d'appel Supabase direct dans un widget
// ❌ Jamais de setState dans un écran connecté à Riverpod
// ❌ Jamais de hardcode de couleurs hors du thème
// ❌ Jamais de texte hardcodé hors des constantes
// ❌ Jamais de feature V2 codée en V1
// ❌ Jamais de print() en production (utiliser logger)
```

### Structure d'un provider Riverpod type
```dart
// Dans features/checkin/presentation/providers/checkin_provider.dart
@riverpod
class CheckinNotifier extends _$CheckinNotifier {
  @override
  AsyncValue<List<Checkin>> build() => const AsyncValue.loading();

  Future<void> loadCheckins() async {
    state = const AsyncValue.loading();
    try {
      final data = await ref.read(checkinRepositoryProvider).getCheckins();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
```

---

## 📋 ORDRE DE DÉVELOPPEMENT V1

Suivre impérativement cet ordre :

```
SPRINT 1 — Fondations ✅ (terminé)
├── [x] Setup pubspec.yaml + tous les packages
├── [x] Thème global Kolyb (couleurs, polices, dark/light)
├── [x] Structure de navigation go_router (5 onglets)
└── [x] Authentification (email + Google)

SPRINT 2 — Cœur de l'app ✅ (terminé)
├── [x] Onboarding (4 écrans)
├── [x] Check-in matin (3 questions + animation)
├── [x] Check-in soir (3 questions + animation)
└── [x] Dashboard "Mon Espace"

SPRINT 3 — Se structurer (en cours)
├── [x] Objectifs court/moyen/long terme
├── [x] Habitudes récurrentes + streak
├── [ ] Finitions écran Objectifs (empty state, animations)
└── [ ] Lier habitudes au dashboard (score du jour)

SPRINT 4 — Productivité (en cours)
├── [x] Planificateur 3 tâches du jour
├── [x] Kanban projets
├── [x] Outil Pomodoro
├── [x] Mode Flow + Flash sessions
├── [x] Bloc de focus
├── [ ] Revue de semaine (finitions)
└── [ ] Notifications push (6 types)

SPRINT 5 — Le Salon (à coder)
├── [ ] Feed Le Salon (posts + groupes thématiques)
├── [ ] Système de discussion / réponses
├── [ ] Profil utilisateur public/privé
└── [ ] Messagerie privée + personnage "Kolyb"

SPRINT 6 — Finitions & beta (à coder)
├── [ ] Badges & streaks complets
├── [ ] Paramètres (dark/light mode, notifications)
├── [ ] Tests unitaires par feature
└── [ ] Préparation beta TestFlight + Play Beta

> ❌ Sprint "Tracker sommeil" supprimé — reporté en V2.
```

---

## 🚨 RÈGLES ABSOLUES POUR Codex

1. **Toujours** demander confirmation avant de modifier un fichier existant
2. **Toujours** respecter la structure de dossiers définie ci-dessus
3. **Toujours** utiliser les couleurs du design system, jamais de hardcode
4. **Toujours** utiliser le tutoiement dans tous les textes de l'app
5. **Jamais** coder une fonctionnalité V2 pendant la V1
6. **Jamais** créer une table Supabase sans RLS
7. **Jamais** stocker des données sensibles en clair
8. **Toujours** gérer les 3 états : loading / data / error
9. **Toujours** prévoir un état vide (empty state) avec message bienveillant
10. **Toujours** tester sur dark mode ET light mode

---

## 📞 CONTEXTE PROJET

- **Fondatrice :** Cassandre (dev solo, première app Flutter)
- **Budget :** < 10 000 €
- **Cible beta :** Mai/Juin 2025
- **GitHub :** https://github.com/Cassandre-pdg/mon-app
- **Supabase :** https://cpdwrzqamhxxkedwaifk.supabase.co
- **Localisation :** France — RGPD obligatoire
- **Document de référence :** SOLO_PRO_CONCEPT.md (à la racine du projet)
- **Branding :** dossier `Brands/` à la racine — icône, palette, guidelines officiels
