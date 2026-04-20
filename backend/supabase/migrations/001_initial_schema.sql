-- ============================================================
-- Solo Pro — Migration initiale
-- Toutes les tables avec RLS activé immédiatement (RGPD)
-- ============================================================

-- Extension UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── PROFILES ────────────────────────────────────────────────
-- Note : "users" entre en conflit avec auth.users de Supabase → renommé profiles
CREATE TABLE IF NOT EXISTS profiles (
  id                        UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email                     TEXT NOT NULL UNIQUE,
  full_name                 TEXT,
  avatar_url                TEXT,
  activity_type             TEXT,
  experience_years          INTEGER DEFAULT 0,
  goals                     TEXT[],
  notification_time_morning TEXT DEFAULT '07:30',
  notification_time_evening TEXT DEFAULT '18:30',
  level                     INTEGER DEFAULT 1,
  total_points              INTEGER DEFAULT 0,
  current_streak            INTEGER DEFAULT 0,
  longest_streak            INTEGER DEFAULT 0,
  show_in_leaderboard       BOOLEAN DEFAULT FALSE,
  fcm_token                 TEXT,
  created_at                TIMESTAMPTZ DEFAULT NOW(),
  updated_at                TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Utilisateur voit uniquement son profil"
  ON profiles FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Utilisateur modifie uniquement son profil"
  ON profiles FOR UPDATE USING (auth.uid() = id);

-- ─── CHECKINS ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS checkins (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type          TEXT NOT NULL CHECK (type IN ('morning', 'evening')),
  mood_score    INTEGER NOT NULL CHECK (mood_score BETWEEN 1 AND 5),
  energy_score  INTEGER NOT NULL CHECK (energy_score BETWEEN 1 AND 5),
  focus_score   INTEGER NOT NULL CHECK (focus_score BETWEEN 1 AND 5),
  notes         TEXT,  -- chiffré côté client avant stockage
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE checkins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Checkins privés par utilisateur"
  ON checkins FOR ALL USING (auth.uid() = user_id);

-- ─── PLANNER TASKS ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS planner_tasks (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id        UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title          TEXT NOT NULL,
  priority       INTEGER NOT NULL CHECK (priority IN (1, 2, 3)),
  is_completed   BOOLEAN DEFAULT FALSE,
  completed_at   TIMESTAMPTZ,
  planned_date   DATE NOT NULL DEFAULT CURRENT_DATE,
  pomodoro_count INTEGER DEFAULT 0,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE planner_tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Tâches privées par utilisateur"
  ON planner_tasks FOR ALL USING (auth.uid() = user_id);

-- ─── SLEEP LOGS ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sleep_logs (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id          UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  sleep_date       DATE NOT NULL,
  bedtime          TIME NOT NULL,
  wake_time        TIME NOT NULL,
  duration_minutes INTEGER,
  quality_score    INTEGER CHECK (quality_score BETWEEN 1 AND 5),
  notes            TEXT,  -- chiffré côté client avant stockage
  source           TEXT DEFAULT 'manual' CHECK (source IN ('manual', 'apple_health')),
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE sleep_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Sommeil privé par utilisateur"
  ON sleep_logs FOR ALL USING (auth.uid() = user_id);

-- ─── COMMUNITY GROUPS ────────────────────────────────────────
-- Note : "groups" est un mot réservé PostgreSQL → renommé community_groups
CREATE TABLE IF NOT EXISTS community_groups (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name         TEXT NOT NULL,
  description  TEXT,
  category     TEXT,
  member_count INTEGER DEFAULT 0,
  is_public    BOOLEAN DEFAULT TRUE,
  created_by   UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE community_groups ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Groupes publics visibles par tous"
  ON community_groups FOR SELECT USING (is_public = TRUE);

-- ─── POSTS ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS posts (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id        UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  group_id       UUID REFERENCES community_groups(id) ON DELETE SET NULL,
  content        TEXT NOT NULL,
  likes_count    INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  created_at     TIMESTAMPTZ DEFAULT NOW(),
  updated_at     TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Posts visibles par tous les membres"
  ON posts FOR SELECT USING (TRUE);

CREATE POLICY "Auteur peut modifier/supprimer son post"
  ON posts FOR ALL USING (auth.uid() = user_id);

-- ─── USER RELATIONS ──────────────────────────────────────────
-- Note : "relations" est un mot réservé PostgreSQL → renommé user_relations
CREATE TABLE IF NOT EXISTS user_relations (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  follower_id  UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  following_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type         TEXT DEFAULT 'friend' CHECK (type IN ('friend', 'mentor')),
  status       TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'blocked')),
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (follower_id, following_id)
);

ALTER TABLE user_relations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Relations visibles par les deux parties"
  ON user_relations FOR SELECT USING (auth.uid() = follower_id OR auth.uid() = following_id);

CREATE POLICY "Utilisateur gère ses propres relations"
  ON user_relations FOR ALL USING (auth.uid() = follower_id);

-- ─── NOTIFICATION SETTINGS ───────────────────────────────────
CREATE TABLE IF NOT EXISTS notification_settings (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id           UUID NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  morning_checkin   BOOLEAN DEFAULT TRUE,   -- opt-in explicite RGPD
  evening_checkin   BOOLEAN DEFAULT TRUE,
  planner_reminder  BOOLEAN DEFAULT FALSE,
  streak_alert      BOOLEAN DEFAULT TRUE,
  community_activity BOOLEAN DEFAULT FALSE,
  weekly_summary    BOOLEAN DEFAULT TRUE,
  created_at        TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE notification_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Paramètres notifs privés par utilisateur"
  ON notification_settings FOR ALL USING (auth.uid() = user_id);
