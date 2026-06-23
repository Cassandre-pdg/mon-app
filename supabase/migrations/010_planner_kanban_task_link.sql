-- Migration 010 — Lien tâche priorité ↔ tâche Kanban
-- Permet de choisir une tâche Kanban comme priorité du jour
-- et de la cocher automatiquement dans le Kanban quand on la complète

ALTER TABLE planner_tasks
  ADD COLUMN IF NOT EXISTS kanban_task_id UUID REFERENCES kanban_tasks(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_planner_tasks_kanban_task
  ON planner_tasks (kanban_task_id)
  WHERE kanban_task_id IS NOT NULL;
