-- ============================================================
-- Migration 003 — Kanban Persistance Supabase
-- À exécuter dans Supabase > SQL Editor
-- ============================================================

-- ── TABLE : kanban_projects ─────────────────────────���────────
CREATE TABLE IF NOT EXISTS kanban_projects (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name       TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE kanban_projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "kanban_projects_user_isolation"
  ON kanban_projects FOR ALL
  USING  (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_kanban_projects_user
  ON kanban_projects (user_id);

-- ── TABLE : kanban_tasks ─────────────────────────────────────
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

CREATE POLICY "kanban_tasks_user_isolation"
  ON kanban_tasks FOR ALL
  USING  (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_kanban_tasks_project
  ON kanban_tasks (project_id);

CREATE INDEX IF NOT EXISTS idx_kanban_tasks_user_status
  ON kanban_tasks (user_id, status);
