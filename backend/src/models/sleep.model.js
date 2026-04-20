// Modèle sommeil — correspond à la table `sleep_logs` dans Supabase
// Données sensibles : chiffrées côté client avant stockage (RGPD)

const sleepLogSchema = {
  id: 'uuid',
  user_id: 'uuid',
  sleep_date: 'date',            // date de la nuit (YYYY-MM-DD)
  bedtime: 'time',               // heure de coucher (HH:MM)
  wake_time: 'time',             // heure de réveil (HH:MM)
  duration_minutes: 'number',    // calculé automatiquement
  quality_score: 'number',       // 1-5 : qualité subjective
  notes: 'string | null',        // note libre, chiffrée
  source: 'manual | apple_health', // source des données
  created_at: 'timestamp',
};

module.exports = { sleepLogSchema };
