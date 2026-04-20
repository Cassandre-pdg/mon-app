const express = require('express');
const router = express.Router();
const checkinsController = require('../controllers/checkins.controller');

// POST /api/checkins           → créer un check-in (matin ou soir)
// GET  /api/checkins           → liste des check-ins (avec filtre date/type)
// GET  /api/checkins/today     → check-ins du jour
// GET  /api/checkins/streak    → infos sur le streak actuel

router.post('/', checkinsController.createCheckin);
router.get('/', checkinsController.getCheckins);
router.get('/today', checkinsController.getTodayCheckins);
router.get('/streak', checkinsController.getStreak);

module.exports = router;
