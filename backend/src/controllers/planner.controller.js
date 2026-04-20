// Controller planificateur — gestion des 3 tâches prioritaires
const { supabase } = require('../middleware/auth');
const { AppError } = require('../middleware/errorHandler');

const MAX_TASKS_PER_DAY = 3; // Limite des tâches prioritaires
const POINTS_3_TASKS_DONE = 10;

const getTasks = async (req, res, next) => {
  try {
    const date = req.query.date || new Date().toISOString().split('T')[0];

    const { data, error } = await supabase
      .from('planner_tasks')
      .select('*')
      .eq('user_id', req.user.id)
      .eq('planned_date', date)
      .order('priority', { ascending: true });

    if (error) throw new AppError('Impossible de récupérer les tâches', 500);
    res.json(data);
  } catch (err) {
    next(err);
  }
};

const createTask = async (req, res, next) => {
  try {
    const { title, priority, planned_date } = req.body;
    const date = planned_date || new Date().toISOString().split('T')[0];

    if (!title) throw new AppError('Le titre de la tâche est obligatoire', 400);
    if (![1, 2, 3].includes(priority)) throw new AppError('La priorité doit être 1, 2 ou 3', 400);

    // Vérifier la limite de 3 tâches par jour
    const { count } = await supabase
      .from('planner_tasks')
      .select('id', { count: 'exact' })
      .eq('user_id', req.user.id)
      .eq('planned_date', date);

    if (count >= MAX_TASKS_PER_DAY) {
      throw new AppError(`Tu as déjà ${MAX_TASKS_PER_DAY} tâches pour aujourd'hui. Concentre-toi sur ce qui compte !`, 400);
    }

    const { data, error } = await supabase
      .from('planner_tasks')
      .insert({
        user_id: req.user.id,
        title,
        priority,
        planned_date: date,
        is_completed: false,
        pomodoro_count: 0,
      })
      .select()
      .single();

    if (error) throw new AppError('Création de la tâche échouée', 500);
    res.status(201).json(data);
  } catch (err) {
    next(err);
  }
};

const updateTask = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { title, priority } = req.body;

    const { data, error } = await supabase
      .from('planner_tasks')
      .update({ title, priority })
      .eq('id', id)
      .eq('user_id', req.user.id) // sécurité : l'utilisateur ne peut modifier que ses propres tâches
      .select()
      .single();

    if (error) throw new AppError('Mise à jour échouée', 500);
    res.json(data);
  } catch (err) {
    next(err);
  }
};

const completeTask = async (req, res, next) => {
  try {
    const { id } = req.params;
    const now = new Date().toISOString();

    const { data, error } = await supabase
      .from('planner_tasks')
      .update({ is_completed: true, completed_at: now })
      .eq('id', id)
      .eq('user_id', req.user.id)
      .select()
      .single();

    if (error) throw new AppError('Impossible de cocher la tâche', 500);

    // Vérifier si les 3 tâches du jour sont complétées → bonus points
    const date = data.planned_date;
    const { data: tasks } = await supabase
      .from('planner_tasks')
      .select('is_completed')
      .eq('user_id', req.user.id)
      .eq('planned_date', date);

    const allDone = tasks.length === MAX_TASKS_PER_DAY && tasks.every((t) => t.is_completed);

    if (allDone) {
      const { data: p } = await supabase.from('profiles').select('total_points').eq('id', req.user.id).single();
      await supabase
        .from('profiles')
        .update({ total_points: (p?.total_points || 0) + POINTS_3_TASKS_DONE, updated_at: now })
        .eq('id', req.user.id);
    }

    res.json({ task: data, allTasksDone: allDone, message: 'Belle avancée ! ✅' });
  } catch (err) {
    next(err);
  }
};

const deleteTask = async (req, res, next) => {
  try {
    const { id } = req.params;

    const { error } = await supabase
      .from('planner_tasks')
      .delete()
      .eq('id', id)
      .eq('user_id', req.user.id);

    if (error) throw new AppError('Suppression échouée', 500);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

module.exports = { getTasks, createTask, updateTask, completeTask, deleteTask };
