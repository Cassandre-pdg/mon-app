-- ╔══════════════════════════════════════════════════════════════╗
-- ║  MIGRATION KOLYB — Enrichissement projets + Brain dump      ║
-- ║  À exécuter dans Supabase > SQL Editor                      ║
-- ╚══════════════════════════════════════════════════════════════╝

-- ── 1. Enrichissement de kanban_projects ─────────────────────
ALTER TABLE kanban_projects
  ADD COLUMN IF NOT EXISTS why          TEXT,
  ADD COLUMN IF NOT EXISTS target_date  DATE,
  ADD COLUMN IF NOT EXISTS status       TEXT NOT NULL DEFAULT 'active',
  ADD COLUMN IF NOT EXISTS objective_id UUID REFERENCES objectives(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS is_focus_project BOOLEAN NOT NULL DEFAULT false;

-- Contrainte : un seul projet focus par utilisateur
-- (géré côté app, pas de contrainte DB pour la simplicité)

-- ── 2. Enrichissement de kanban_tasks (date de complétion) ───
ALTER TABLE kanban_tasks
  ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;

-- ── 3. Enrichissement des check-ins ──────────────────────────
ALTER TABLE checkins
  ADD COLUMN IF NOT EXISTS wellbeing_note    TEXT,
  ADD COLUMN IF NOT EXISTS focus_project_id  UUID REFERENCES kanban_projects(id) ON DELETE SET NULL;

-- ── 4. Table captures (brain dump) ───────────────────────────
CREATE TABLE IF NOT EXISTS captures (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content      TEXT        NOT NULL,
  is_processed BOOLEAN     NOT NULL DEFAULT false,
  destination  TEXT,        -- 'project' | 'objective' | 'habit' | 'ignore' | null
  destination_id UUID,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE captures ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own captures"
  ON captures FOR ALL
  USING  (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ── 5. Index pour les requêtes fréquentes ────────────────────
CREATE INDEX IF NOT EXISTS idx_captures_user_processed
  ON captures (user_id, is_processed, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_kanban_projects_focus
  ON kanban_projects (user_id, is_focus_project)
  WHERE is_focus_project = true;
