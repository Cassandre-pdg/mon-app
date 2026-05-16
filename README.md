# Kolyb — Ton élan, au quotidien.

> Application Flutter de bien-être, productivité et communauté pour entrepreneurs indépendants.

Les indépendants jonglent entre 5 apps différentes, s'isolent progressivement et perdent le fil de leur progression. Kolyb réunit tout en un seul endroit.

---

## 📱 Navigation — 5 onglets V1

```
[ Mon Espace 🏠 ] [ Mes Objectifs 🎯 ] [ Ma Journée ✅ ] [ Le Salon 👥 ] [ Mon Profil 👤 ]
      /home             /objectives           /planner          /community       /profile
```

---

## 🛠️ Stack technique

| Composant | Technologie |
|---|---|
| UI / App mobile | Flutter 3.x (Dart) — iOS + Android |
| State management | Riverpod 2.x |
| Base de données | Supabase (EU Frankfurt — RGPD) |
| Authentification | Supabase Auth (email, Google, Apple) |
| Notifications push | Firebase Cloud Messaging |
| Navigation | go_router |
| Graphiques | fl_chart |
| Paiements (V2) | RevenueCat + Stripe |
| CI/CD | GitHub Actions |

---

## 🗄️ Base de données Supabase

RLS activé sur toutes les tables. Hébergement EU uniquement.

| Table | Description |
|---|---|
| `users` | Profils utilisateurs |
| `checkins` | Check-ins émotionnels matin + soir |
| `planner_tasks` | Tâches du jour (3 priorités MIT) |
| `kanban_projects` | Projets Kanban (name, why, vision, success_criteria, target_date, status, is_focus_project, category, current_blocker) |
| `kanban_tasks` | Tâches Kanban (todo / in_progress / done) |
| `captures` | Notes brain dump (destination, is_processed) |
| `groups` | Groupes thématiques communauté |
| `posts` | Posts du forum (6 types, 4 réactions, sondages) |
| `relations` | Liens entre utilisateurs |
| `notification_settings` | Préférences notifications |
| `sleep_logs` | Suivi sommeil (V2 — hors nav V1) |

**Migrations Supabase :** `supabase/migrations/`
- `003_kanban_persistence.sql` — création kanban_projects + kanban_tasks
- `supabase_migration_enrichissement.sql` — why, target_date, status, is_focus_project, captures
- `005_kanban_vision_criteria.sql` — vision (TEXT) + success_criteria (TEXT[])
- `006_kanban_category_blocker.sql` — category (TEXT) + current_blocker (TEXT)

---

## ⚡ Features V1 codées

| Feature | Écran | État |
|---|---|---|
| Auth | `auth_screen.dart` | Email + Google + Apple |
| Onboarding | `onboarding_screen.dart` | 4 écrans |
| Dashboard | `dashboard_screen.dart` | Streak · Anneaux suivi · Check-ins · Card projet focus · Bien-être · Niveau |
| Check-in matin/soir | `checkin_screen.dart` | 3 questions + animation |
| Objectifs | `objectives_screen.dart` | Sections Objectifs/Projets/Habitudes/Suivi · ProjectConfigSheet partagé |
| Kanban | `kanban_screen.dart` | Colonnes todo/en cours/terminé · lien objectifs |
| Config projet | `shared/widgets/project_config_sheet.dart` | Nom → Catégorie → Pourquoi → Vision → Date cible → Critères (3 défaut + ajouter) → Blocage actuel · utilisé depuis Objectifs ET Kanban |
| Planner — Priorités | `planner_screen.dart` | 3 tâches MIT, liens Kanban/Revue |
| Planner — Flow | `flow_screen.dart` | Aurora, arc timer 90 min |
| Planner — Pomodoro | `pomodoro_screen.dart` | Timer 25/5, notifications |
| Planner — Flash | `flash_screen.dart` | Micro-tâches < 5 min |
| Planner — Matrice | `eisenhower_screen.dart` | 4 quadrants urgence/importance |
| Revue hebdo | `weekly_review_screen.dart` | Questions bilan |
| Le Salon | `community_screen.dart` | Feed · Groupes · Défis mensuels |
| Capture brain dump | `capture_bottom_sheet.dart` | Bouton haut-droite, badge pending |
| Badges | `rewards_screen.dart` | Streaks, niveaux, badges |
| Méditation | `meditation_library_screen.dart` + player | Bibliothèque + audio |
| Respiration | `breathing_exercise_screen.dart` | Exercices guidés |
| Profil + notifs | `profile_screen.dart` | Settings, toggle dark/light |

---

## 💰 Modèle économique

| Plan | Prix | Contenu |
|---|---|---|
| **Gratuit** | 0 € | Check-in · Dashboard · 3 priorités · Feed lecture · 3 posts/semaine · Badges · Flow · Méditation basique |
| **Pro** | 14,99 €/mois | Posts illimités · Groupes · PDF mensuel · Stats avancées · Webinaires · Historique illimité |

---

## 🚀 Lancer le projet en local

```bash
git clone https://github.com/Cassandre-pdg/mon-app.git
cd mon-app/flutter_app
flutter pub get
flutter run
```

**Variables d'environnement :** configurées dans `lib/main.dart` via les clés Supabase.

**iOS — si `pod install` échoue :**
```bash
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 pod install
```

---

## 🔒 RGPD

- RLS activé sur toutes les tables Supabase
- Hébergement EU uniquement (Frankfurt)
- Suppression compte + données dans Mon Profil > Paramètres
- Disclaimer : Kolyb est un outil de bien-être, pas un dispositif médical

---

## 👩‍💻 Auteur

**Cassandre** — Fondatrice Kolyb · [@Cassandre-pdg](https://github.com/Cassandre-pdg)

---

*Projet privé — tous droits réservés © 2026 Kolyb*
