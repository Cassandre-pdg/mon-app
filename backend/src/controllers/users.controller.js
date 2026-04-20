// Controller utilisateurs — logique métier pour la gestion du profil
const { supabase } = require('../middleware/auth');
const { updatableFields, defaultUser } = require('../models/user.model');
const { AppError } = require('../middleware/errorHandler');

const getMe = async (req, res, next) => {
  try {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', req.user.id)
      .single();

    if (error) throw new AppError('Profil introuvable', 404);
    res.json(data);
  } catch (err) {
    next(err);
  }
};

const updateMe = async (req, res, next) => {
  try {
    // Filtrer uniquement les champs autorisés
    const updates = {};
    updatableFields.forEach((field) => {
      if (req.body[field] !== undefined) updates[field] = req.body[field];
    });

    if (Object.keys(updates).length === 0) {
      throw new AppError('Aucun champ valide à mettre à jour', 400);
    }

    updates.updated_at = new Date().toISOString();

    const { data, error } = await supabase
      .from('profiles')
      .update(updates)
      .eq('id', req.user.id)
      .select()
      .single();

    if (error) throw new AppError('Mise à jour échouée', 500);
    res.json(data);
  } catch (err) {
    next(err);
  }
};

const saveFcmToken = async (req, res, next) => {
  try {
    const { fcm_token } = req.body;
    if (!fcm_token) throw new AppError('Token FCM manquant', 400);

    const { error } = await supabase
      .from('profiles')
      .update({ fcm_token, updated_at: new Date().toISOString() })
      .eq('id', req.user.id);

    if (error) throw new AppError('Enregistrement token FCM échoué', 500);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

const deleteAccount = async (req, res, next) => {
  try {
    // Suppression RGPD : supprime toutes les données liées à l'utilisateur
    // Supabase cascade via les contraintes FK définies dans les migrations
    const { error: deleteError } = await supabase.auth.admin.deleteUser(req.user.id);
    if (deleteError) throw new AppError('Suppression du compte échouée', 500);

    res.json({ message: 'Ton compte sera supprimé définitivement dans 30 jours.' });
  } catch (err) {
    next(err);
  }
};

module.exports = { getMe, updateMe, saveFcmToken, deleteAccount };
