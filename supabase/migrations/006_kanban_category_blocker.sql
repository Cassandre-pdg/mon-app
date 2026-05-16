-- Migration 006 : catégorie et blocage actuel sur kanban_projects
-- Appliquée manuellement via Supabase Dashboard > SQL Editor

ALTER TABLE kanban_projects
  ADD COLUMN IF NOT EXISTS category       TEXT CHECK (category IN ('produit','marketing','admin','reseau','personnel')),
  ADD COLUMN IF NOT EXISTS current_blocker TEXT;

COMMENT ON COLUMN kanban_projects.category        IS 'Catégorie du projet : produit | marketing | admin | reseau | personnel';
COMMENT ON COLUMN kanban_projects.current_blocker IS 'Ce qui bloque l''utilisateur en ce moment (optionnel, texte libre)';
