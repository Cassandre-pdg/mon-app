// Modèle planificateur — correspond à la table `planner_tasks` dans Supabase

const plannerTaskSchema = {
  id: 'uuid',
  user_id: 'uuid',
  title: 'string',
  priority: 1 | 2 | 3,         // 1 = priorité haute, 2 = moyenne, 3 = basse
  is_completed: 'boolean',
  completed_at: 'timestamp | null',
  planned_date: 'date',          // date cible (YYYY-MM-DD)
  pomodoro_count: 'number',      // nombre de pomodoros effectués sur cette tâche
  created_at: 'timestamp',
};

module.exports = { plannerTaskSchema };
