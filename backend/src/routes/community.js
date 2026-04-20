const express = require('express');
const router = express.Router();
const communityController = require('../controllers/community.controller');

// --- Groupes ---
// GET  /api/community/groups           → liste des groupes
// GET  /api/community/groups/:id       → détail d'un groupe
// POST /api/community/groups/:id/join  → rejoindre un groupe

// --- Posts ---
// GET  /api/community/posts            → feed (avec filtre group_id optionnel)
// POST /api/community/posts            → créer un post (limite 3/semaine gratuit)
// POST /api/community/posts/:id/like   → liker un post
// DELETE /api/community/posts/:id      → supprimer son post

// --- Relations ---
// POST /api/community/relations        → suivre quelqu'un
// DELETE /api/community/relations/:id  → ne plus suivre

router.get('/groups', communityController.getGroups);
router.get('/groups/:id', communityController.getGroupById);
router.post('/groups/:id/join', communityController.joinGroup);

router.get('/posts', communityController.getPosts);
router.post('/posts', communityController.createPost);
router.post('/posts/:id/like', communityController.likePost);
router.delete('/posts/:id', communityController.deletePost);

router.post('/relations', communityController.followUser);
router.delete('/relations/:id', communityController.unfollowUser);

module.exports = router;
