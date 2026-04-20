// Limiteur de requêtes — protection contre les abus (RGPD + sécurité)

const rateLimit = require('express-rate-limit');

const rateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // fenêtre de 15 minutes
  max: 100,                  // 100 requêtes max par IP par fenêtre
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Trop de requêtes, réessaie dans quelques minutes.' },
});

module.exports = { rateLimiter };
