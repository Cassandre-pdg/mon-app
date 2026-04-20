// Point d'entrée du serveur Solo Pro
// Gère la logique serveur custom (notifications FCM, webhooks, traitements batch)
// Supabase gère Auth + BDD directement — ce serveur complète avec la logique métier

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const usersRouter = require('./src/routes/users');
const checkinsRouter = require('./src/routes/checkins');
const plannerRouter = require('./src/routes/planner');
const sleepRouter = require('./src/routes/sleep');
const communityRouter = require('./src/routes/community');
const notificationsRouter = require('./src/routes/notifications');
const rewardsRouter = require('./src/routes/rewards');

const { authMiddleware } = require('./src/middleware/auth');
const { errorHandler } = require('./src/middleware/errorHandler');
const { rateLimiter } = require('./src/middleware/rateLimiter');

const app = express();
const PORT = process.env.PORT || 3000;

// Sécurité de base
app.use(helmet());
app.use(cors({ origin: process.env.ALLOWED_ORIGINS?.split(',') || '*' }));
app.use(morgan('combined'));
app.use(express.json());
app.use(rateLimiter);

// Routes publiques
app.get('/health', (req, res) => res.json({ status: 'ok', app: 'Solo Pro API' }));

// Routes protégées (JWT Supabase requis)
app.use('/api/users', authMiddleware, usersRouter);
app.use('/api/checkins', authMiddleware, checkinsRouter);
app.use('/api/planner', authMiddleware, plannerRouter);
app.use('/api/sleep', authMiddleware, sleepRouter);
app.use('/api/community', authMiddleware, communityRouter);
app.use('/api/notifications', authMiddleware, notificationsRouter);
app.use('/api/rewards', authMiddleware, rewardsRouter);

// Gestion globale des erreurs
app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`Solo Pro API démarrée sur le port ${PORT}`);
});

module.exports = app;
