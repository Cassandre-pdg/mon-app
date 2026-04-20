// Controller notifications — préférences + envoi FCM
const { supabase } = require('../middleware/auth');
const { AppError } = require('../middleware/errorHandler');
const admin = require('firebase-admin');

// Initialisation Firebase Admin — lazy (au premier appel, pas au démarrage)
const getFirebaseApp = () => {
  if (admin.apps.length) return admin.apps[0];

  const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT;
  if (!serviceAccount || serviceAccount.includes('project_id":"...')) {
    console.warn('[FCM] FIREBASE_SERVICE_ACCOUNT non configuré — notifications désactivées');
    return null;
  }

  return admin.initializeApp({
    credential: admin.credential.cert(JSON.parse(serviceAccount)),
  });
};

// 6 types de notifications V1 (cf. CLAUDE.md)
const NOTIFICATION_TYPES = [
  'morning_checkin',   // rappel check-in matin (7h30)
  'evening_checkin',   // rappel check-in soir (18h30)
  'planner_reminder',  // rappel tâches du jour
  'streak_alert',      // alerte streak en danger
  'community_activity',// activité dans les groupes suivis
  'weekly_summary',    // récap hebdomadaire
];

const getSettings = async (req, res, next) => {
  try {
    const { data, error } = await supabase
      .from('notification_settings')
      .select('*')
      .eq('user_id', req.user.id)
      .single();

    if (error) throw new AppError('Paramètres introuvables', 404);
    res.json(data);
  } catch (err) {
    next(err);
  }
};

const updateSettings = async (req, res, next) => {
  try {
    // Filtrer uniquement les types de notifs valides (opt-in explicite RGPD)
    const updates = {};
    NOTIFICATION_TYPES.forEach((type) => {
      if (req.body[type] !== undefined) updates[type] = Boolean(req.body[type]);
    });

    const { data, error } = await supabase
      .from('notification_settings')
      .upsert({ user_id: req.user.id, ...updates })
      .select()
      .single();

    if (error) throw new AppError('Mise à jour des paramètres échouée', 500);
    res.json(data);
  } catch (err) {
    next(err);
  }
};

// Envoi d'une notification FCM à un utilisateur
const sendPushNotification = async (fcmToken, title, body, data = {}) => {
  const app = getFirebaseApp();
  if (!app) return; // Firebase non configuré, on ignore silencieusement

  try {
    await admin.messaging(app).send({
      token: fcmToken,
      notification: { title, body },
      data,
      android: { priority: 'normal' },
      apns: { payload: { aps: { badge: 1 } } },
    });
  } catch (err) {
    console.error('[FCM] Erreur envoi notification:', err.message);
  }
};

// Route de test (dev uniquement)
const sendTestNotification = async (req, res, next) => {
  try {
    const { data: user } = await supabase
      .from('profiles')
      .select('fcm_token')
      .eq('id', req.user.id)
      .single();

    if (!user?.fcm_token) throw new AppError('Aucun token FCM enregistré', 400);

    await sendPushNotification(
      user.fcm_token,
      'Solo Pro 👋',
      'Test de notification — tout fonctionne !',
    );

    res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

module.exports = { getSettings, updateSettings, sendTestNotification, sendPushNotification };
