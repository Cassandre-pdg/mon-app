// Middleware d'authentification — vérifie le JWT Supabase
// Tous les appels API doivent inclure le header : Authorization: Bearer <token>

const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY // clé service role (jamais exposée côté client)
);

const authMiddleware = async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token manquant ou invalide' });
  }

  const token = authHeader.split(' ')[1];

  const { data: { user }, error } = await supabase.auth.getUser(token);

  if (error || !user) {
    return res.status(401).json({ error: 'Non autorisé' });
  }

  // Injecte l'utilisateur dans la requête pour les controllers
  req.user = user;
  next();
};

module.exports = { authMiddleware, supabase };
