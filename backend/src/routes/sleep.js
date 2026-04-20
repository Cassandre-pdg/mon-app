const express = require('express');
const router = express.Router();
const sleepController = require('../controllers/sleep.controller');

// GET  /api/sleep              → historique sommeil (7 derniers jours par défaut)
// POST /api/sleep              → enregistrer une nuit
// PUT  /api/sleep/:id          → modifier un log sommeil
// DELETE /api/sleep/:id        → supprimer un log

router.get('/', sleepController.getSleepLogs);
router.post('/', sleepController.createSleepLog);
router.put('/:id', sleepController.updateSleepLog);
router.delete('/:id', sleepController.deleteSleepLog);

module.exports = router;
