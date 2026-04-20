// Controller check-ins — logique matin/soir + gestion streaks
const { supabase } = require('../middleware/auth');
const { AppError } = require('../middleware/errorHandler');

// Points gagnés par action (gamification)
const POINTS = {
  morning_checkin: 5,
  evening_checkin: 5,
  streak_bonus: 2,
};

const createCheckin = async (req, res, next) => {
  try {
    const { type, mood_score, energy_score, focus_score, notes } = req.body;

    if (!['morning', 'evening'].includes(type)) {
      throw new AppError('Type de check-in invalide (morning ou evening)', 400);
    }
    if (!mood_score || !energy_score || !focus_score) {
      throw new AppError('Les 3 scores sont obligatoires', 400);
    }

    // Vérifier qu'un check-in du même type n'existe pas déjà aujourd'hui
    const today = new Date().toISOString().split('T')[0];
    const { data: existing } = await supabase
      .from('checkins')
      .select('id')
      .eq('user_id', req.user.id)
      .eq('type', type)
      .gte('created_at', `${today}T00:00:00`)
      .lte('created_at', `${today}T23:59:59`)
      .single();

    if (existing) throw new AppError('Tu as déjà fait ton check-in aujourd\'hui !', 409);

    const { data, error } = await supabase
      .from('checkins')
      .insert({
        user_id: req.user.id,
        type,
        mood_score,
        energy_score,
        focus_score,
        notes: notes || null,
      })
      .select()
      .single();

    if (error) throw new AppError('Erreur lors de la sauvegarde du check-in', 500);

    // Mise à jour des points et du streak
    await updatePointsAndStreak(req.user.id, type);

    res.status(201).json({ checkin: data, message: 'Belle avancée !' });
  } catch (err) {
    next(err);
  }
};

const getCheckins = async (req, res, next) => {
  try {
    const { type, from, to, limit = 30 } = req.query;

    let query = supabase
      .from('checkins')
      .select('*')
      .eq('user_id', req.user.id)
      .order('created_at', { ascending: false })
      .limit(Number(limit));

    if (type) query = query.eq('type', type);
    if (from) query = query.gte('created_at', from);
    if (to) query = query.lte('created_at', to);

    const { data, error } = await query;
    if (error) throw new AppError('Impossible de récupérer les check-ins', 500);

    res.json(data);
  } catch (err) {
    next(err);
  }
};

const getTodayCheckins = async (req, res, next) => {
  try {
    const today = new Date().toISOString().split('T')[0];

    const { data, error } = await supabase
      .from('checkins')
      .select('*')
      .eq('user_id', req.user.id)
      .gte('created_at', `${today}T00:00:00`)
      .lte('created_at', `${today}T23:59:59`);

    if (error) throw new AppError('Erreur lors de la récupération', 500);

    res.json({
      morning: data.find((c) => c.type === 'morning') || null,
      evening: data.find((c) => c.type === 'evening') || null,
    });
  } catch (err) {
    next(err);
  }
};

const getStreak = async (req, res, next) => {
  try {
    const { data, error } = await supabase
      .from('profiles')
      .select('current_streak, longest_streak, total_points, level')
      .eq('id', req.user.id)
      .single();

    if (error) throw new AppError('Impossible de récupérer le streak', 500);
    res.json(data);
  } catch (err) {
    next(err);
  }
};

// Mise à jour interne des points et du streak après un check-in
const updatePointsAndStreak = async (userId, checkinType) => {
  const points = checkinType === 'morning' ? POINTS.morning_checkin : POINTS.evening_checkin;

  const { data: user } = await supabase
    .from('profiles')
    .select('current_streak, longest_streak, total_points, level')
    .eq('id', userId)
    .single();

  const newPoints = (user.total_points || 0) + points + POINTS.streak_bonus;
  const newStreak = (user.current_streak || 0) + 1;
  const longestStreak = Math.max(newStreak, user.longest_streak || 0);
  const newLevel = calculateLevel(newPoints);

  await supabase
    .from('profiles')
    .update({
      total_points: newPoints,
      current_streak: newStreak,
      longest_streak: longestStreak,
      level: newLevel,
      updated_at: new Date().toISOString(),
    })
    .eq('id', userId);
};

// Calcul du niveau selon les points (cf. CLAUDE.md)
const calculateLevel = (points) => {
  if (points <= 100) return 1;
  if (points <= 300) return 2;
  if (points <= 600) return 3;
  if (points <= 1000) return 4;
  return 5;
};

module.exports = { createCheckin, getCheckins, getTodayCheckins, getStreak };
