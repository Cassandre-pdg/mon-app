// Modèle check-in — correspond à la table `checkins` dans Supabase
// Données sensibles : chiffrées côté client avant stockage (RGPD)

const checkinSchema = {
  id: 'uuid',
  user_id: 'uuid',          // clé étrangère → users.id
  type: 'morning | evening',
  mood_score: 'number',     // 1-5 : niveau d'énergie / humeur
  energy_score: 'number',   // 1-5
  focus_score: 'number',    // 1-5 (matin) / satisfaction_score (soir)
  notes: 'string | null',   // note libre, chiffrée
  created_at: 'timestamp',
};

// Questions du check-in matin
const morningQuestions = [
  { key: 'mood_score',    label: 'Comment tu te sens ce matin ?',        type: 'scale' },
  { key: 'energy_score',  label: 'Quel est ton niveau d\'énergie ?',     type: 'scale' },
  { key: 'focus_score',   label: 'Sur quoi tu vas te concentrer aujourd\'hui ?', type: 'scale' },
];

// Questions du check-in soir
const eveningQuestions = [
  { key: 'mood_score',        label: 'Comment s\'est passée ta journée ?',  type: 'scale' },
  { key: 'energy_score',      label: 'Quel est ton niveau d\'énergie ce soir ?', type: 'scale' },
  { key: 'focus_score',       label: 'Tu es satisfait(e) de ta journée ?',  type: 'scale' },
];

module.exports = { checkinSchema, morningQuestions, eveningQuestions };
