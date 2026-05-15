-- ============================================================
-- Migration 005 — Kanban : vision + critères de réussite
-- À exécuter dans Supabase > SQL Editor
-- (si ce n'est pas déjà fait — utilise IF NOT EXISTS)
-- ============================================================

ALTER TABLE kanban_projects
  ADD COLUMN IF NOT EXISTS vision           TEXT,
  ADD COLUMN IF NOT EXISTS success_criteria TEXT[];

-- Index optionnel pour les projets qui ont des critères
CREATE INDEX IF NOT EXISTS idx_kanban_projects_has_criteria
  ON kanban_projects (user_id)
  WHERE success_criteria IS NOT NULL;
