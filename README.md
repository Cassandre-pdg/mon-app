# 🧭 Solo Pro — L'application compagnon de l'entrepreneur solitaire

> "L'entrepreneur qui avance seul va vite. L'entrepreneur bien accompagné va loin."

Application Flutter de bien-être, productivité et lien social pour entrepreneurs, traders, artisans et freelances. Un seul espace pour tenir mentalement, performer durablement, et ne jamais se sentir seul.

---

## 📌 Vision

Solo Pro accompagne chaque dimension du quotidien de l'indépendant :
- 🧠 **Mental & bien-être** — check-in émotionnel, journal, gestion du stress
- ⚡ **Productivité** — planification, focus, revue hebdomadaire
- 😴 **Sommeil & récupération** — suivi, routines, conseils adaptifs
- 🤝 **Réseau & lien social** — communauté, groupes métiers, matching pairs

---

## 🗂️ Structure du projet

```
solo-pro/
├── flutter_app/          → Application mobile Flutter (iOS + Android)
│   ├── lib/
│   │   ├── features/
│   │   │   ├── checkin/          → Check-in émotionnel quotidien
│   │   │   │   ├── data/         → Appels Supabase, modèles JSON
│   │   │   │   ├── domain/       → Logique métier pure
│   │   │   │   └── presentation/ → Widgets, screens, Riverpod providers
│   │   │   ├── planner/          → Planificateur 3 priorités (méthode MIT)
│   │   │   ├── sleep/            → Tracker sommeil & récupération
│   │   │   ├── community/        → Réseau, groupes, forum, matching
│   │   │   ├── dashboard/        → Vue 360° unifiée
│   │   │   └── onboarding/       → Parcours d'entrée personnalisé
│   │   ├── shared/               → Widgets communs, thème, constantes
│   │   └── main.dart
│   ├── test/
│   └── pubspec.yaml
├── backend/              → API REST Node.js + Express (V2)
│   ├── src/
│   │   ├── routes/
│   │   ├── controllers/
│   │   ├── models/
│   │   └── middleware/
│   ├── .env.example
│   └── server.js
├── .gitignore
└── README.md             → Ce fichier
```

---

## 🛠️ Stack technique

| Composant | Technologie | Coût |
|---|---|---|
| **UI / App mobile** | Flutter 3.x (Dart) | Gratuit |
| **State management** | Riverpod 2.x | Gratuit |
| **Backend as a Service** | Supabase (serveur EU — Frankfurt) | Gratuit phase 1 |
| **Authentification** | Supabase Auth (email, Google, Apple) | Gratuit |
| **Notifications push** | Firebase Cloud Messaging | Gratuit |
| **Analytics** | Mixpanel (plan free) | Gratuit |
| **Crash reporting** | Firebase Crashlytics | Gratuit |
| **IA suggestions (V2)** | OpenAI API GPT-4o-mini | 20–50 €/mois |
| **Paiements (V2)** | Stripe + RevenueCat | 1,5 % + 0 € fixe |
| **CI/CD** | GitHub Actions | Gratuit |

---

## 📦 Packages Flutter principaux

```yaml
dependencies:
  flutter_riverpod:        # State management
  supabase_flutter:        # Base de données + auth
  firebase_messaging:      # Notifications push
  go_router:               # Navigation déclarative
  fl_chart:                # Graphiques humeur, sommeil, productivité
  flutter_local_notifications: # Rappels sans connexion
  shared_preferences:      # Stockage local léger
  freezed:                 # Modèles immuables
  json_serializable:       # Sérialisation JSON
  purchases_flutter:       # RevenueCat — abonnements (V2)
```

---

## 🗄️ Base de données (Supabase)

Tables principales :

| Table | Description |
|---|---|
| `users` | Profils utilisateurs (secteur, objectifs, préférences) |
| `checkins` | Check-ins émotionnels quotidiens (score, humeur, notes) |
| `planner_tasks` | Tâches du jour (3 priorités, statut, taux de complétion) |
| `sleep_logs` | Suivi sommeil (coucher, lever, qualité 1–5) |
| `groups` | Groupes thématiques (Traders, Artisans, Tech…) |
| `posts` | Posts du forum communauté |
| `relations` | Liens entre utilisateurs (pairs, mentors) |
| `notifications_settings` | Préférences de rappels personnalisés |

> ⚠️ Row Level Security (RLS) activé sur **toutes** les tables dès le setup.
> Hébergement : **Supabase EU (Frankfurt)** — données en Europe, conformité RGPD.

---

## 🚀 Lancer le projet en local

### Prérequis
- Flutter 3.x installé → `flutter --version`
- Un compte Supabase → [supabase.com](https://supabase.com)
- Un compte Firebase → [firebase.google.com](https://firebase.google.com)

### Installation

```bash
# 1. Cloner le repo
git clone https://github.com/Cassandre-pdg/mon-app.git
cd mon-app

# 2. Installer les dépendances Flutter
cd flutter_app
flutter pub get

# 3. Configurer les variables d'environnement
cp .env.example .env
# → Remplir SUPABASE_URL, SUPABASE_ANON_KEY, etc.

# 4. Lancer l'app
flutter run
```

---

## 📱 Fonctionnalités V1 (MVP)

| Feature | Description | Critère de succès |
|---|---|---|
| **Check-in quotidien** | 3 questions matin, score énergie 1–5, emoji humeur, graphique semaine | 60 % des users le font 5j/7 |
| **Planificateur 3 tâches** | Saisie 3 priorités du jour, check le soir, taux de complétion | 50 % complètent 2 tâches/jour |
| **Tracker sommeil** | Heure coucher/lever, qualité 1–5, corrélation humeur | 40 % le remplissent 4j/7 |
| **Aperçu communauté** | Feed lecture seule, bouton "Rejoindre" avec teaser | 30 % cliquent sur Rejoindre |
| **Onboarding** | 3 écrans : profil métier, objectif, premier check-in guidé | 80 % finissent l'onboarding |
| **Dashboard unifié** | Vue du jour : humeur + tâches + sommeil + streak | Session > 3 min en moyenne |
| **Notifications push** | Rappel matin check-in, rappel soir tâches. Heure personnalisable. | Taux opt-in > 60 % |

---

## 💎 Fonctionnalités V2 Pro (après validation V1)

- Forum & groupes actifs (poster, répondre, créer un groupe)
- Journal IA (analyse tendances, alertes burn-out, suggestions personnalisées)
- Matching pairs / mentor selon profil + objectifs
- Sommeil avancé (routine guidée, alarme progressive, Apple Health / Google Fit)
- Productivité avancée (revue hebdo guidée, objectifs long terme, intégration calendrier)
- Rapports PDF mensuels exportables
- Événements live (webinaires, cafés pro, ateliers)

---

## 💰 Modèle économique

| Plan | Prix | Contenu |
|---|---|---|
| **Gratuit** | 0 € | Check-in, journal 7j, Pomodoro basique, forum lecture, 1 groupe |
| **Pro** | 9,99 €/mois ou 84,99 €/an | Tout gratuit + journal IA illimité, tous modules, groupes illimités, matching, stats avancées |
| **Early adopter** | 5,99 €/mois | Pour les 500 premiers abonnés Pro |

---

## 🗓️ Road Map

| Phase | Période | Objectif |
|---|---|---|
| **Phase 0** — Cadrage | S1–S8 | 20 entretiens users, maquettes Figma, landing page, 300 emails |
| **Phase 1** — Dev V1 | S9–S20 | 7 features codées, beta 50 testeurs, CGU validées |
| **Phase 2** — Lancement V1 | S21–S28 | App Store + Play Store, 1 000 MAU, rétention J30 > 40 % |
| **Phase 3** — Dev V2 Pro | S29–S40 | Modules Pro, RevenueCat, 50 abonnés beta |
| **Phase 4** — Lancement Pro | S41–S48 | 200 abonnés Pro, MRR > 2 000 € |
| **Phase 5** — Croissance | M13–M18 | 10 000 MAU, 1 200 abonnés Pro, MRR > 12 000 € |

---

## 🎯 KPIs cibles (M6 post-lancement)

| Indicateur | Cible |
|---|---|
| Rétention J7 (beta) | > 50 % |
| Rétention J30 | > 45 % |
| DAU / MAU ratio | > 40 % |
| Sessions / user / semaine | > 5 |
| NPS | > 50 |
| Conversion Free → Pro | > 12 % |

---

## 🔒 Sécurité & RGPD

- ✅ **Row Level Security** activé sur toutes les tables Supabase
- ✅ **Hébergement EU** (Frankfurt) — données en Europe
- ✅ **Chiffrement** des données sensibles (journal, émotions)
- ✅ **Bouton suppression compte** + toutes les données (obligatoire RGPD)
- ✅ **CGU + Politique de confidentialité** relues par avocat spécialisé
- ✅ **Disclaimer** : Solo Pro est un outil de bien-être, pas un dispositif médical

---

## 👩‍💻 Auteur

**Cassandre** — Fondatrice Solo Pro
- GitHub : [@Cassandre-pdg](https://github.com/Cassandre-pdg)

---

## 📄 Licence

Projet privé — tous droits réservés © 2025 Solo Pro
