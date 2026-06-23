-- ════════════════════════════════════════════════════════════════
-- Migration 008 — Trigger streak et points sur les check-ins
-- ════════════════════════════════════════════════════════════════
-- Problème résolu : current_streak, longest_streak, total_points et level
-- dans profiles n'étaient jamais mis à jour lors des check-ins.
--
-- Logique :
--   • 1er check-in du jour  → streak + 1 (ou 1 si rupture), +5 pts + +2 bonus streak
--   • 2e check-in du jour   → +5 pts uniquement (matin + soir = 2 check-ins = 10 pts/jour max)
--   • Pas de check-in hier  → streak repart à 1
--   • longest_streak mis à jour si current_streak > longest_streak
--   • Level recalculé à chaque update selon les paliers CLAUDE.md
--
-- Dates calculées en Europe/Paris pour que minuit soit correct pour les utilisateurs FR.
-- ════════════════════════════════════════════════════════════════

-- ── Fonction principale ───────────────────────────────────────
CREATE OR REPLACE FUNCTION handle_checkin_streak()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_today              DATE;
  v_yesterday          DATE;
  v_had_today_already  BOOLEAN;
  v_had_yesterday      BOOLEAN;
  v_current_streak     INTEGER;
  v_longest_streak     INTEGER;
  v_total_points       INTEGER;
  v_new_streak         INTEGER;
  v_new_points         INTEGER;
  v_new_level          INTEGER;
BEGIN
  -- Dates en heure française pour éviter les problèmes de minuit UTC
  v_today     := (NEW.created_at AT TIME ZONE 'Europe/Paris')::DATE;
  v_yesterday := v_today - INTERVAL '1 day';

  -- Y avait-il déjà un check-in aujourd'hui AVANT celui-ci ?
  SELECT EXISTS (
    SELECT 1 FROM checkins
    WHERE user_id = NEW.user_id
      AND id      != NEW.id
      AND (created_at AT TIME ZONE 'Europe/Paris')::DATE = v_today
  ) INTO v_had_today_already;

  -- Récupérer les valeurs actuelles du profil
  SELECT current_streak, longest_streak, total_points
  INTO   v_current_streak, v_longest_streak, v_total_points
  FROM   profiles
  WHERE  id = NEW.user_id;

  IF NOT v_had_today_already THEN
    -- ── Premier check-in du jour ─────────────────────────────
    -- Y avait-il un check-in hier ?
    SELECT EXISTS (
      SELECT 1 FROM checkins
      WHERE user_id = NEW.user_id
        AND (created_at AT TIME ZONE 'Europe/Paris')::DATE = v_yesterday
    ) INTO v_had_yesterday;

    -- Calculer le nouveau streak
    IF v_had_yesterday THEN
      v_new_streak := v_current_streak + 1;  -- continuité
    ELSE
      v_new_streak := 1;                     -- rupture ou tout premier check-in
    END IF;

    -- Points : +5 (check-in) + +2 (streak maintenu)
    v_new_points := v_total_points + 7;

    -- Mettre à jour le profil
    UPDATE profiles
    SET
      current_streak = v_new_streak,
      longest_streak = GREATEST(v_longest_streak, v_new_streak),
      total_points   = v_new_points,
      level = CASE
        WHEN v_new_points >= 1001 THEN 5
        WHEN v_new_points >= 601  THEN 4
        WHEN v_new_points >= 301  THEN 3
        WHEN v_new_points >= 101  THEN 2
        ELSE 1
      END,
      updated_at = NOW()
    WHERE id = NEW.user_id;

  ELSE
    -- ── Deuxième check-in du jour (matin puis soir) ──────────
    -- Streak déjà comptabilisé : juste +5 pts
    v_new_points := v_total_points + 5;

    UPDATE profiles
    SET
      total_points = v_new_points,
      level = CASE
        WHEN v_new_points >= 1001 THEN 5
        WHEN v_new_points >= 601  THEN 4
        WHEN v_new_points >= 301  THEN 3
        WHEN v_new_points >= 101  THEN 2
        ELSE 1
      END,
      updated_at = NOW()
    WHERE id = NEW.user_id;

  END IF;

  RETURN NEW;
END;
$$;

-- ── Trigger déclenché après chaque INSERT sur checkins ────────
DROP TRIGGER IF EXISTS on_checkin_insert ON checkins;

CREATE TRIGGER on_checkin_insert
  AFTER INSERT ON checkins
  FOR EACH ROW
  EXECUTE FUNCTION handle_checkin_streak();
