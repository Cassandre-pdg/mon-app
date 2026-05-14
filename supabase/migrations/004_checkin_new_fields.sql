-- Migration 004 : Nouveaux champs check-in (refonte matin/soir)
-- Ajoute les colonnes texte libre pour les nouvelles questions

ALTER TABLE checkins
  ADD COLUMN IF NOT EXISTS daily_intention    TEXT,
  ADD COLUMN IF NOT EXISTS daily_success      TEXT,
  ADD COLUMN IF NOT EXISTS daily_victory      TEXT,
  ADD COLUMN IF NOT EXISTS daily_learning     TEXT,
  ADD COLUMN IF NOT EXISTS tomorrow_intention TEXT;
