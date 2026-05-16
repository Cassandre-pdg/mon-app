-- Migration 007 : Flash tasks (persistance Supabase) + lien projet sur planner_tasks

-- ── Table flash_tasks ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS flash_tasks (
  id                 UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id            UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title              TEXT        NOT NULL,
  category           TEXT        NOT NULL DEFAULT 'autre',
  estimated_minutes  INT         NOT NULL DEFAULT 2,
  is_done            BOOLEAN     NOT NULL DEFAULT false,
  project_id         UUID        REFERENCES kanban_projects(id) ON DELETE SET NULL,
  done_at            TIMESTAMPTZ,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE flash_tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users own flash tasks"
  ON flash_tasks FOR ALL
  USING  (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ── Lien projet sur planner_tasks ────────────────────────────────────────────
ALTER TABLE planner_tasks
  ADD COLUMN IF NOT EXISTS project_id UUID REFERENCES kanban_projects(id) ON DELETE SET NULL;
