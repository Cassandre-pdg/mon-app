const express = require('express');
const router = express.Router();
const plannerController = require('../controllers/planner.controller');

// GET  /api/planner            → tâches du jour
// POST /api/planner            → créer une tâche
// PUT  /api/planner/:id        → mettre à jour une tâche
// PATCH /api/planner/:id/complete → cocher une tâche
// DELETE /api/planner/:id      → supprimer une tâche

router.get('/', plannerController.getTasks);
router.post('/', plannerController.createTask);
router.put('/:id', plannerController.updateTask);
router.patch('/:id/complete', plannerController.completeTask);
router.delete('/:id', plannerController.deleteTask);

module.exports = router;
