// Controller communauté — feed, groupes, relations
const { supabase } = require('../middleware/auth');
const { AppError } = require('../middleware/errorHandler');
const { FREE_WEEKLY_POST_LIMIT } = require('../models/community.model');

const POST_POINTS = 2;
const RELATION_POINTS = 5;

// --- Groupes ---

const getGroups = async (req, res, next) => {
  try {
    const { data, error } = await supabase
      .from('community_groups')
      .select('*')
      .eq('is_public', true)
      .order('member_count', { ascending: false });

    if (error) throw new AppError('Impossible de récupérer les groupes', 500);
    res.json(data);
  } catch (err) {
    next(err);
  }
};

const getGroupById = async (req, res, next) => {
  try {
    const { data, error } = await supabase
      .from('community_groups')
      .select('*')
      .eq('id', req.params.id)
      .single();

    if (error) throw new AppError('Groupe introuvable', 404);
    res.json(data);
  } catch (err) {
    next(err);
  }
};

const joinGroup = async (req, res, next) => {
  try {
    // Incrémente le compteur de membres (géré via trigger Supabase en production)
    const { data: group } = await supabase
      .from('community_groups')
      .select('member_count')
      .eq('id', req.params.id)
      .single();

    const { error } = await supabase
      .from('community_groups')
      .update({ member_count: (group?.member_count || 0) + 1 })
      .eq('id', req.params.id);

    if (error) throw new AppError('Impossible de rejoindre le groupe', 500);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

// --- Posts ---

const getPosts = async (req, res, next) => {
  try {
    const { group_id, limit = 20, offset = 0 } = req.query;

    let query = supabase
      .from('posts')
      .select('*, users(full_name, avatar_url, level)')
      .order('created_at', { ascending: false })
      .range(Number(offset), Number(offset) + Number(limit) - 1);

    if (group_id) query = query.eq('group_id', group_id);

    const { data, error } = await query;
    if (error) throw new AppError('Impossible de récupérer le feed', 500);
    res.json(data);
  } catch (err) {
    next(err);
  }
};

const createPost = async (req, res, next) => {
  try {
    const { content, group_id } = req.body;
    if (!content) throw new AppError('Le contenu du post est obligatoire', 400);

    // Vérification limite hebdomadaire gratuite (3 posts/semaine)
    const weekStart = getWeekStart();
    const { count } = await supabase
      .from('posts')
      .select('id', { count: 'exact' })
      .eq('user_id', req.user.id)
      .gte('created_at', weekStart);

    if (count >= FREE_WEEKLY_POST_LIMIT) {
      throw new AppError(
        `Tu as posté ${FREE_WEEKLY_POST_LIMIT} fois cette semaine — avec Pro, c'est illimité 🚀`,
        403
      );
    }

    const { data, error } = await supabase
      .from('posts')
      .insert({
        user_id: req.user.id,
        content,
        group_id: group_id || null,
        likes_count: 0,
        comments_count: 0,
      })
      .select()
      .single();

    if (error) throw new AppError('Publication du post échouée', 500);

    // Bonus points
    const { data: poster } = await supabase.from('profiles').select('total_points').eq('id', req.user.id).single();
    await supabase.from('profiles').update({ total_points: (poster?.total_points || 0) + POST_POINTS }).eq('id', req.user.id);

    res.status(201).json(data);
  } catch (err) {
    next(err);
  }
};

const likePost = async (req, res, next) => {
  try {
    const { data: post } = await supabase.from('posts').select('likes_count').eq('id', req.params.id).single();
    const { error } = await supabase
      .from('posts')
      .update({ likes_count: (post?.likes_count || 0) + 1 })
      .eq('id', req.params.id);

    if (error) throw new AppError('Impossible de liker ce post', 500);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

const deletePost = async (req, res, next) => {
  try {
    const { error } = await supabase
      .from('posts')
      .delete()
      .eq('id', req.params.id)
      .eq('user_id', req.user.id);

    if (error) throw new AppError('Suppression échouée', 500);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

// --- Relations ---

const followUser = async (req, res, next) => {
  try {
    const { following_id, type = 'friend' } = req.body;
    if (!following_id) throw new AppError('Utilisateur cible manquant', 400);
    if (following_id === req.user.id) throw new AppError('Tu ne peux pas te suivre toi-même', 400);

    const { data, error } = await supabase
      .from('user_relations')
      .insert({
        follower_id: req.user.id,
        following_id,
        type,
        status: 'pending',
      })
      .select()
      .single();

    if (error) throw new AppError('Impossible d\'envoyer la demande', 500);

    // Bonus points
    const { data: follower } = await supabase.from('profiles').select('total_points').eq('id', req.user.id).single();
    await supabase.from('profiles').update({ total_points: (follower?.total_points || 0) + RELATION_POINTS }).eq('id', req.user.id);

    res.status(201).json(data);
  } catch (err) {
    next(err);
  }
};

const unfollowUser = async (req, res, next) => {
  try {
    const { error } = await supabase
      .from('user_relations')
      .delete()
      .eq('id', req.params.id)
      .eq('follower_id', req.user.id);

    if (error) throw new AppError('Impossible de ne plus suivre cet utilisateur', 500);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

// Retourne le lundi de la semaine courante (format ISO)
const getWeekStart = () => {
  const now = new Date();
  const day = now.getDay();
  const diff = now.getDate() - day + (day === 0 ? -6 : 1);
  const monday = new Date(now.setDate(diff));
  return monday.toISOString().split('T')[0] + 'T00:00:00';
};

module.exports = {
  getGroups, getGroupById, joinGroup,
  getPosts, createPost, likePost, deletePost,
  followUser, unfollowUser,
};
