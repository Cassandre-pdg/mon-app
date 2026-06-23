-- ════════════════════════════════════════════════════════════════
-- Migration 009 — Table weekly_reviews
-- ════════════════════════════════════════════════════════════════
-- Stocke les revues hebdomadaires avec stats agrégées + réponses.
-- Fenêtre d'accès : vendredi 15h → lundi 9h (géré côté Flutter).
-- ════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS weekly_reviews (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Semaine concernée (lundi de la semaine)
  week_start          DATE NOT NULL,

  -- Stats agrégées (calculées côté Flutter, stockées pour l'historique)
  tasks_completed     INTEGER NOT NULL DEFAULT 0,
  tasks_total         INTEGER NOT NULL DEFAULT 0,
  focus_minutes       INTEGER NOT NULL DEFAULT 0,
  checkins_done       INTEGER NOT NULL DEFAULT 0,
  avg_mood            NUMERIC(3,1),       -- moyenne humeur 1-10 (nullable si pas de check-ins)
  avg_energy          NUMERIC(3,1),
  completion_rate     NUMERIC(4,1),       -- % complétion tâches (0-100)

  -- Badge auto-calculé
  badge               TEXT,               -- 'fire' | 'solid' | 'resilient' | 'gentle' | null

  -- Réponses qualitatives (optionnelles)
  best_moment         TEXT,               -- "Qu'est-ce qui t'a le plus aidé ?"
  main_blocker        TEXT,               -- "Qu'est-ce qui t'a freiné ?"

  -- Projection semaine suivante
  weekly_intention    TEXT,               -- phrase libre, cap de la semaine prochaine
  focus_habit         TEXT,               -- habitude à soigner la semaine prochaine

  -- Captures traitées (IDs marqués comme processed via cette revue)
  captures_processed  INTEGER NOT NULL DEFAULT 0,

  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Une seule revue par semaine par utilisateur
  UNIQUE (user_id, week_start)
);

-- Index pour requêtes historique
CREATE INDEX idx_weekly_reviews_user_week
  ON weekly_reviews (user_id, week_start DESC);

-- RLS obligatoire
ALTER TABLE weekly_reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_own_reviews" ON weekly_reviews
  FOR ALL USING (auth.uid() = user_id);
