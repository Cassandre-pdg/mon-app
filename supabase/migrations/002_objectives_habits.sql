-- ============================================================
-- Migration 002 — Objectifs & Habitudes
-- À exécuter dans Supabase > SQL Editor
-- ============================================================

-- ── TABLE : objectives ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS objectives (
  id               UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id          UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title            TEXT NOT NULL,
  description      TEXT,
  horizon          TEXT NOT NULL
                   CHECK (horizon IN ('short_term', 'medium_term', 'long_term')),
  progress_percent DECIMAL(4,3) DEFAULT 0.0
                   CHECK (progress_percent >= 0 AND progress_percent <= 1),
  is_completed     BOOLEAN DEFAULT FALSE NOT NULL,
  target_date      DATE,
  created_at       TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at       TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- RLS obligatoire
ALTER TABLE objectives ENABLE ROW LEVEL SECURITY;

CREATE POLICY "objectives_user_isolation"
  ON objectives FOR ALL
  USING  (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Index performances
CREATE INDEX IF NOT EXISTS idx_objectives_user_horizon
  ON objectives (user_id, horizon);

-- ── TABLE : habits ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS habits (
  id             UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id        UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title          TEXT NOT NULL,
  emoji          TEXT DEFAULT '🔁',
  frequency      TEXT NOT NULL DEFAULT 'daily'
                 CHECK (frequency IN ('daily', 'weekly', 'custom')),
  days_of_week   INTEGER[] DEFAULT '{}',
  current_streak INTEGER DEFAULT 0 NOT NULL,
  created_at     TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at     TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE habits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "habits_user_isolation"
  ON habits FOR ALL
  USING  (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_habits_user
  ON habits (user_id);

-- ── TABLE : habit_completions ────────────────────────────────
CREATE TABLE IF NOT EXISTS habit_completions (
  id             UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  habit_id       UUID REFERENCES habits(id) ON DELETE CASCADE NOT NULL,
  user_id        UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  completed_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at     TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  UNIQUE (habit_id, completed_date)
);

ALTER TABLE habit_completions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "habit_completions_user_isolation"
  ON habit_completions FOR ALL
  USING  (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_habit_completions_user_date
  ON habit_completions (user_id, completed_date);

-- ── FONCTIONS : streak management ───────────────────────────
-- Incrémente le streak d'une habitude
CREATE OR REPLACE FUNCTION increment_habit_streak(
  p_habit_id UUID,
  p_user_id  UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE habits
  SET current_streak = current_streak + 1,
      updated_at = NOW()
  WHERE id = p_habit_id
    AND user_id = p_user_id;
END;
$$;

-- Décrémente le streak d'une habitude (min 0)
CREATE OR REPLACE FUNCTION decrement_habit_streak(
  p_habit_id UUID,
  p_user_id  UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE habits
  SET current_streak = GREATEST(current_streak - 1, 0),
      updated_at = NOW()
  WHERE id = p_habit_id
    AND user_id = p_user_id;
END;
$$;

-- ── TRIGGER : updated_at automatique ────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER objectives_updated_at
  BEFORE UPDATE ON objectives
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER habits_updated_at
  BEFORE UPDATE ON habits
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
