// Controller récompenses — badges, niveaux, classement
const { supabase } = require('../middleware/auth');
const { AppError } = require('../middleware/errorHandler');

// Définition des badges selon les streaks (cf. CLAUDE.md)
const STREAK_BADGES = [
  { id: 'streak_3',   label: '3 jours de suite',  emoji: '🔥',  threshold: 3   },
  { id: 'streak_7',   label: 'Une semaine !',      emoji: '🔥🔥', threshold: 7  },
  { id: 'streak_14',  label: '2 semaines',         emoji: '⭐',  threshold: 14  },
  { id: 'streak_30',  label: '1 mois',             emoji: '🏆',  threshold: 30  },
  { id: 'streak_100', label: '100 jours',          emoji: '💎',  threshold: 100 },
  { id: 'streak_365', label: '1 an',               emoji: '👑',  threshold: 365 },
];

// Niveaux de l'application (cf. CLAUDE.md)
const LEVELS = [
  { level: 1, label: 'Explorateur',  min: 0,    max: 100  },
  { level: 2, label: 'Indépendant',  min: 101,  max: 300  },
  { level: 3, label: 'Entrepreneur', min: 301,  max: 600  },
  { level: 4, label: 'Bâtisseur',    min: 601,  max: 1000 },
  { level: 5, label: 'Visionnaire',  min: 1001, max: null },
];

const getBadges = async (req, res, next) => {
  try {
    const { data: user, error } = await supabase
      .from('profiles')
      .select('current_streak, longest_streak')
      .eq('id', req.user.id)
      .single();

    if (error) throw new AppError('Impossible de récupérer les badges', 500);

    // Badges débloqués selon le longest streak
    const unlockedBadges = STREAK_BADGES.filter(
      (badge) => user.longest_streak >= badge.threshold
    );

    // Badge spécial "Relevé" si implémenté (optionnel ici)
    res.json({
      unlocked: unlockedBadges,
      current_streak: user.current_streak,
      longest_streak: user.longest_streak,
      next_badge: STREAK_BADGES.find((b) => b.threshold > user.longest_streak) || null,
    });
  } catch (err) {
    next(err);
  }
};

const getLevel = async (req, res, next) => {
  try {
    const { data: user, error } = await supabase
      .from('profiles')
      .select('total_points, level')
      .eq('id', req.user.id)
      .single();

    if (error) throw new AppError('Impossible de récupérer le niveau', 500);

    const currentLevel = LEVELS.find((l) => l.level === user.level) || LEVELS[0];
    const nextLevel = LEVELS.find((l) => l.level === user.level + 1) || null;

    res.json({
      level: user.level,
      label: currentLevel.label,
      total_points: user.total_points,
      points_to_next: nextLevel ? nextLevel.min - user.total_points : null,
      next_level_label: nextLevel?.label || null,
    });
  } catch (err) {
    next(err);
  }
};

const getLeaderboard = async (req, res, next) => {
  try {
    const { group_id } = req.query;

    // Vérifier que l'utilisateur a activé le classement
    const { data: me } = await supabase
      .from('profiles')
      .select('show_in_leaderboard')
      .eq('id', req.user.id)
      .single();

    if (!me.show_in_leaderboard) {
      return res.json({ message: 'Active le classement dans tes paramètres pour participer.', data: [] });
    }

    // Classement basé sur la régularité (current_streak), pas les points absolus
    let query = supabase
      .from('profiles')
      .select('id, full_name, avatar_url, level, current_streak')
      .eq('show_in_leaderboard', true)
      .order('current_streak', { ascending: false })
      .limit(50);

    const { data, error } = await query;
    if (error) throw new AppError('Impossible de récupérer le classement', 500);

    res.json(data);
  } catch (err) {
    next(err);
  }
};

module.exports = { getBadges, getLevel, getLeaderboard };
