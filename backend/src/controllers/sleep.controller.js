// Controller sommeil — gestion des logs de sommeil
const { supabase } = require('../middleware/auth');
const { AppError } = require('../middleware/errorHandler');

const SLEEP_POINTS = 3;

const getSleepLogs = async (req, res, next) => {
  try {
    const days = Number(req.query.days) || 7;
    const from = new Date();
    from.setDate(from.getDate() - days);

    const { data, error } = await supabase
      .from('sleep_logs')
      .select('*')
      .eq('user_id', req.user.id)
      .gte('sleep_date', from.toISOString().split('T')[0])
      .order('sleep_date', { ascending: false });

    if (error) throw new AppError('Impossible de récupérer les logs sommeil', 500);
    res.json(data);
  } catch (err) {
    next(err);
  }
};

const createSleepLog = async (req, res, next) => {
  try {
    const { sleep_date, bedtime, wake_time, quality_score, notes, source = 'manual' } = req.body;

    if (!sleep_date || !bedtime || !wake_time) {
      throw new AppError('Date, heure de coucher et de réveil obligatoires', 400);
    }

    // Calcul automatique de la durée
    const duration_minutes = calculateDuration(bedtime, wake_time);

    const { data, error } = await supabase
      .from('sleep_logs')
      .insert({
        user_id: req.user.id,
        sleep_date,
        bedtime,
        wake_time,
        duration_minutes,
        quality_score: quality_score || null,
        notes: notes || null,
        source,
      })
      .select()
      .single();

    if (error) throw new AppError('Enregistrement du sommeil échoué', 500);

    // Bonus points — récupérer les points actuels puis incrémenter
    const { data: profile } = await supabase
      .from('profiles')
      .select('total_points')
      .eq('id', req.user.id)
      .single();

    await supabase
      .from('profiles')
      .update({ total_points: (profile?.total_points || 0) + SLEEP_POINTS })
      .eq('id', req.user.id);

    res.status(201).json(data);
  } catch (err) {
    next(err);
  }
};

const updateSleepLog = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { bedtime, wake_time, quality_score, notes } = req.body;

    const updates = {};
    if (bedtime) updates.bedtime = bedtime;
    if (wake_time) updates.wake_time = wake_time;
    if (quality_score !== undefined) updates.quality_score = quality_score;
    if (notes !== undefined) updates.notes = notes;

    if (updates.bedtime && updates.wake_time) {
      updates.duration_minutes = calculateDuration(updates.bedtime, updates.wake_time);
    }

    const { data, error } = await supabase
      .from('sleep_logs')
      .update(updates)
      .eq('id', id)
      .eq('user_id', req.user.id)
      .select()
      .single();

    if (error) throw new AppError('Mise à jour échouée', 500);
    res.json(data);
  } catch (err) {
    next(err);
  }
};

const deleteSleepLog = async (req, res, next) => {
  try {
    const { error } = await supabase
      .from('sleep_logs')
      .delete()
      .eq('id', req.params.id)
      .eq('user_id', req.user.id);

    if (error) throw new AppError('Suppression échouée', 500);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

// Calcule la durée de sommeil en minutes
const calculateDuration = (bedtime, wakeTime) => {
  const [bH, bM] = bedtime.split(':').map(Number);
  const [wH, wM] = wakeTime.split(':').map(Number);
  let bedMinutes = bH * 60 + bM;
  let wakeMinutes = wH * 60 + wM;
  if (wakeMinutes < bedMinutes) wakeMinutes += 24 * 60; // passage minuit
  return wakeMinutes - bedMinutes;
};

module.exports = { getSleepLogs, createSleepLog, updateSleepLog, deleteSleepLog };
