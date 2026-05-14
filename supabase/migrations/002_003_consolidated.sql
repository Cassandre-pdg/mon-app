-- ============================================================
-- MIGRATIONS 002 + 003 — Consolidees
-- Coller dans Supabase > SQL Editor > Run
-- Idempotent : peut etre reexecute sans erreur
-- ============================================================

-- ============================================================
-- 002 — Objectifs & Habitudes
-- ============================================================

CREATE TABLE IF NOT EXISTS objectives (
  id               UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id          UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title            TEXT NOT NULL,
  description      TEXT,
  horizon          TEXT NOT NULL
                     CHECK (horizon IN ('short_term', 'medium_term', 'long_term')),
  progress_percent NUMERIC(5,4) DEFAULT 0.0
                     CHECK (progress_percent >= 0 AND progress_percent <= 1),
  is_completed     BOOLEAN DEFAULT FALSE NOT NULL,
  target_date      DATE,
  created_at       TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at       TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE objectives ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'objectives' AND policyname = 'objectives_user_isolation'
  ) THEN
    CREATE POLICY objectives_user_isolation
      ON objectives FOR ALL
      USING  (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_objectives_user_horizon
  ON objectives (user_id, horizon);

-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS habits (
  id             UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id        UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title          TEXT NOT NULL,
  emoji          TEXT DEFAULT '🔁',
  frequency      TEXT NOT NULL DEFAULT 'daily'
                   CHECK (frequency IN ('daily', 'weekly', 'custom')),
  days_of_week   INTEGER[] DEFAULT ARRAY[]::INTEGER[],
  current_streak INTEGER DEFAULT 0 NOT NULL,
  created_at     TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at     TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE habits ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'habits' AND policyname = 'habits_user_isolation'
  ) THEN
    CREATE POLICY habits_user_isolation
      ON habits FOR ALL
      USING  (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_habits_user ON habits (user_id);

-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS habit_completions (
  id             UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  habit_id       UUID REFERENCES habits(id) ON DELETE CASCADE NOT NULL,
  user_id        UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  completed_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at     TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  UNIQUE (habit_id, completed_date)
);

ALTER TABLE habit_completions ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'habit_completions' AND policyname = 'habit_completions_user_isolation'
  ) THEN
    CREATE POLICY habit_completions_user_isolation
      ON habit_completions FOR ALL
      USING  (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_habit_completions_user_date
  ON habit_completions (user_id, completed_date);

-- ── Fonctions streak ─────────────────────────────────────────

CREATE OR REPLACE FUNCTION increment_habit_streak(
  p_habit_id UUID,
  p_user_id  UUID
)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE habits
     SET current_streak = current_streak + 1,
         updated_at = NOW()
   WHERE id = p_habit_id AND user_id = p_user_id;
END;
$$;

CREATE OR REPLACE FUNCTION decrement_habit_streak(
  p_habit_id UUID,
  p_user_id  UUID
)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE habits
     SET current_streak = GREATEST(current_streak - 1, 0),
         updated_at = NOW()
   WHERE id = p_habit_id AND user_id = p_user_id;
END;
$$;

-- ── Trigger updated_at ────────────────────────────────────────

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS objectives_updated_at ON objectives;
CREATE TRIGGER objectives_updated_at
  BEFORE UPDATE ON objectives
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS habits_updated_at ON habits;
CREATE TRIGGER habits_updated_at
  BEFORE UPDATE ON habits
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- 003 — Kanban Persistance
-- ============================================================

CREATE TABLE IF NOT EXISTS kanban_projects (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name       TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE kanban_projects ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'kanban_projects' AND policyname = 'kanban_projects_user_isolation'
  ) THEN
    CREATE POLICY kanban_projects_user_isolation
      ON kanban_projects FOR ALL
      USING  (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_kanban_projects_user
  ON kanban_projects (user_id);

-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS kanban_tasks (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id UUID REFERENCES kanban_projects(id) ON DELETE CASCADE NOT NULL,
  user_id    UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title      TEXT NOT NULL,
  status     TEXT NOT NULL DEFAULT 'todo'
               CHECK (status IN ('todo', 'in_progress', 'done')),
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE kanban_tasks ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'kanban_tasks' AND policyname = 'kanban_tasks_user_isolation'
  ) THEN
    CREATE POLICY kanban_tasks_user_isolation
      ON kanban_tasks FOR ALL
      USING  (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_kanban_tasks_project
  ON kanban_tasks (project_id);

CREATE INDEX IF NOT EXISTS idx_kanban_tasks_user_status
  ON kanban_tasks (user_id, status);
