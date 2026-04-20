// Modèle utilisateur — correspond à la table `users` dans Supabase
// Utilisé pour la validation et la sérialisation des données

const userSchema = {
  id: 'uuid',           // géré par Supabase Auth
  email: 'string',
  full_name: 'string',
  avatar_url: 'string | null',
  activity_type: 'string',      // type d'activité freelance
  experience_years: 'number',
  goals: 'string[]',
  notification_time_morning: 'string',  // ex: "07:30"
  notification_time_evening: 'string',  // ex: "18:30"
  level: 'number',              // niveau gamification (1-5)
  total_points: 'number',
  current_streak: 'number',
  longest_streak: 'number',
  show_in_leaderboard: 'boolean',
  fcm_token: 'string | null',   // token Firebase pour les notifs push
  created_at: 'timestamp',
  updated_at: 'timestamp',
};

// Valeurs par défaut à la création
const defaultUser = {
  level: 1,
  total_points: 0,
  current_streak: 0,
  longest_streak: 0,
  show_in_leaderboard: false,
  notification_time_morning: '07:30',
  notification_time_evening: '18:30',
};

// Champs autorisés à la mise à jour par l'utilisateur
const updatableFields = [
  'full_name',
  'avatar_url',
  'activity_type',
  'experience_years',
  'goals',
  'notification_time_morning',
  'notification_time_evening',
  'show_in_leaderboard',
  'fcm_token',
];

module.exports = { userSchema, defaultUser, updatableFields };
