# 🧭 CLAUDE.md — Instructions pour Claude Code
*Ce fichier est lu par Claude Code à chaque session. Ne jamais le supprimer.*

---

## 🎯 QUI JE SUIS ET CE QU'ON CONSTRUIT

Je suis Cassandre, fondatrice solo de **Solo Pro** — une application Flutter de bien-être, productivité et réseau social pour entrepreneurs indépendants.

**Le problème résolu :**
Les indépendants jonglent entre 5 apps différentes, s'isolent progressivement, et perdent le fil de leur progression. Solo Pro réunit tout en un seul endroit.

**La promesse de l'app :**
> "Avance chaque jour, sans jamais te sentir seul."

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
    │   ├── planner/                → "Ma Journée" + outils focus
    │   ├── sleep/                  → "Mon Sommeil"
    │   ├── community/              → "Ma Tribu"
    │   ├── profile/                → "Mon Profil" + paramètres
    │   ├── auth/                   → inscription / connexion
    │   └── rewards/                → badges, streaks, niveaux
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
sleep_logs             → suivi sommeil
groups                 → groupes thématiques communauté
posts                  → posts du forum
relations              → liens entre utilisateurs (amis, mentors)
notification_settings  → préférences notifications
```

**Règle RGPD absolue :** Row Level Security activé sur TOUTES les tables. Ne jamais créer une table sans activer RLS immédiatement.

---

## 🎨 DESIGN SYSTEM — TOUJOURS RESPECTER CES VALEURS

### Couleurs

```dart
// Primaire
primary: Color(0xFF6C47FF),        // Violet profond
secondary: Color(0xFFFF6B6B),      // Corail énergisant
accent: Color(0xFF4ECDC4),         // Vert succès

// Fond Dark Mode
backgroundDark: Color(0xFF0F0F1A), // Presque noir
surfaceDark: Color(0xFF1A1A2E),    // Carte dark

// Fond Light Mode
backgroundLight: Color(0xFFF8F7FF), // Blanc cassé
surfaceLight: Color(0xFFFFFFFF),    // Blanc pur

// Texte
textDark: Color(0xFFE8E8F0),       // Blanc doux (sur fond dark)
textLight: Color(0xFF2D2D3A),      // Gris foncé (sur fond light)

// États
success: Color(0xFF4ECDC4),
warning: Color(0xFFFFBE0B),
error: Color(0xFFFF6B6B),
```

### Typographie

```dart
// Titres → Plus Jakarta Sans
// Corps  → Inter
// Ne jamais utiliser d'autre police
```

### Règles UI

- **Toujours** proposer dark mode ET light mode
- **Jamais** de design plat et générique — style friendly pro, rounded
- **Arrondis :** BorderRadius.circular(16) pour les cartes, 12 pour les boutons
- **Espacement :** multiples de 8 (8, 16, 24, 32, 48)
- **Animations :** subtiles, jamais > 400ms sauf récompenses spéciales
- **Icônes :** style rounded stroke, cohérent dans toute l'app

---

## 📱 NAVIGATION — 5 ONGLETS FIXES

```
Barre du bas :
[ Mon Espace 🏠 ] [ Ma Journée ✅ ] [ Ma Tribu 👥 ] [ Mon Sommeil 😴 ] [ Mon Profil 👤 ]
```

**Routes go_router :**
```
/                   → splash
/onboarding         → onboarding (4 écrans)
/home               → dashboard "Mon Espace"
/planner            → "Ma Journée"
/community          → "Ma Tribu"
/sleep              → "Mon Sommeil"
/profile            → "Mon Profil"
/checkin/morning    → check-in matin
/checkin/evening    → check-in soir
/settings           → paramètres
```

---

## ✍️ CHARTE ÉDITORIALE — TEXTES DE L'APP

### Ton obligatoire
- Bienveillant + motivant, jamais moralisateur
- Tutoiement TOUJOURS ("tu", jamais "vous")
- Ami expert qui tire vers le haut sans juger
- Phrases courtes, directes, positives

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
Productivité → "Ma Journée"
Sommeil      → "Mon Sommeil"
Communauté   → "Ma Tribu"
Profil       → "Mon Profil"
Récompenses  → "Mes Badges"
```

### Messages clés
```
Onboarding   → "Solo Pro, ton compagnon de route. Chaque jour, un pas de plus — à ton rythme, jamais seul."
Streak cassé → "Pas grave, tout le monde a des jours sans — reprends aujourd'hui 💪"
Tâche cochée → "Belle avancée ! ✅"
Check-in fait → animation badge + phrase inspirante du jour
```

---

## ⚡ FONCTIONNALITÉS V1 — CE QU'ON CODE

### ✅ À coder en V1
1. Authentification (email + Google + Apple)
2. Onboarding 4 écrans
3. Check-in matin (7h30) — 3 questions
4. Check-in soir (18h30) — 3 questions
5. Dashboard "Mon Espace" avec streak + score
6. Planificateur 3 priorités
7. Outil Pomodoro (25 min / 5 min)
8. Tracker sommeil (manuel + Apple Health optionnel iOS)
9. Feed communauté (lecture + 3 posts/semaine gratuit)
10. Messagerie privée basique + personnage "Solo"
11. Profil utilisateur
12. Système de badges et streaks
13. Notifications push (6 types)
14. Dark mode / Light mode

### ❌ NE PAS coder en V1 (réservé V2)
- Matching mentor/mentoré
- Webinaires et événements live
- Eisenhower matrix
- Deep Work avancé
- Rapport PDF mensuel
- Création de groupe (Pro V2)
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
Sommeil renseigné          → +3 pts
Post dans la communauté    → +2 pts
Ami ajouté                 → +5 pts
Streak maintenu            → +2 pts/jour
Se relever après échec     → +15 pts (bonus bienveillance)
```

### Classement
- **Optionnel** — l'utilisateur choisit d'y participer dans les paramètres
- Classement par groupe thématique, jamais global
- Basé sur la régularité, pas les résultats absolus

---

## 💰 MODÈLE ÉCONOMIQUE — RÈGLES DE CODAGE

### Gratuit (toujours accessible, jamais retiré)
- Check-in matin + soir illimité
- Dashboard basique
- Planificateur 3 tâches
- Tracker sommeil
- Note brouillon
- Feed communauté (lecture + like)
- 3 posts/semaine dans les groupes
- Messagerie privée
- Badges & streaks
- Pomodoro

### Pro (14,99 €/mois — à intégrer en V2)
- Posts illimités communauté
- Création de groupe
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
3. **Chiffrement** pour check-ins et données sommeil (données sensibles)
4. **Bouton suppression** compte dans Paramètres → effacement total 30j
5. **Disclaimer** visible : "Solo Pro est un outil de bien-être, pas un dispositif médical"
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
SPRINT 1 — Fondations (Semaine 1)
├── [ ] Setup pubspec.yaml + tous les packages
├── [ ] Thème global (couleurs, polices, dark/light)
├── [ ] Structure de navigation go_router
└── [ ] Authentification (email + Google)

SPRINT 2 — Cœur de l'app (Semaine 2-3)
├── [ ] Onboarding (4 écrans)
├── [ ] Check-in matin (3 questions + animation)
├── [ ] Check-in soir (3 questions + animation)
└── [ ] Dashboard "Mon Espace"

SPRINT 3 — Productivité (Semaine 4)
├── [ ] Planificateur 3 tâches
├── [ ] Outil Pomodoro
└── [ ] Revue de semaine

SPRINT 4 — Bien-être (Semaine 5)
├── [ ] Tracker sommeil
└── [ ] Notifications push (6 types)

SPRINT 5 — Social (Semaine 6-7)
├── [ ] Feed communauté
├── [ ] Groupes thématiques
├── [ ] Profil utilisateur
└── [ ] Messagerie privée + personnage "Solo"

SPRINT 6 — Finitions (Semaine 8)
├── [ ] Badges & streaks complets
├── [ ] Paramètres (dark/light mode, notifications)
├── [ ] Tests unitaires
└── [ ] Préparation beta TestFlight + Play Beta
```

---

## 🚨 RÈGLES ABSOLUES POUR CLAUDE CODE

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
