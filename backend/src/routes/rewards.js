const express = require('express');
const router = express.Router();
const rewardsController = require('../controllers/rewards.controller');

// GET /api/rewards/badges     → badges de l'utilisateur
// GET /api/rewards/level      → niveau et points actuels
// GET /api/rewards/leaderboard → classement du groupe (opt-in uniquement)

router.get('/badges', rewardsController.getBadges);
router.get('/level', rewardsController.getLevel);
router.get('/leaderboard', rewardsController.getLeaderboard);

module.exports = router;
