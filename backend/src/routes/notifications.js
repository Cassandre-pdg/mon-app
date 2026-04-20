const express = require('express');
const router = express.Router();
const notificationsController = require('../controllers/notifications.controller');

// GET  /api/notifications/settings    → préférences de notifications
// PUT  /api/notifications/settings    → mettre à jour les préférences
// POST /api/notifications/test        → envoyer une notif de test (dev seulement)

router.get('/settings', notificationsController.getSettings);
router.put('/settings', notificationsController.updateSettings);

if (process.env.NODE_ENV === 'development') {
  router.post('/test', notificationsController.sendTestNotification);
}

module.exports = router;
