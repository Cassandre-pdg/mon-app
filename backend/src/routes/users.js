const express = require('express');
const router = express.Router();
const usersController = require('../controllers/users.controller');

// GET  /api/users/me          → profil de l'utilisateur connecté
// PUT  /api/users/me          → mise à jour du profil
// POST /api/users/me/fcm-token → enregistrement token FCM (notifications push)
// DELETE /api/users/me        → suppression du compte (RGPD)

router.get('/me', usersController.getMe);
router.put('/me', usersController.updateMe);
router.post('/me/fcm-token', usersController.saveFcmToken);
router.delete('/me', usersController.deleteAccount);

module.exports = router;
