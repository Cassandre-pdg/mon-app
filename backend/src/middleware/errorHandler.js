// Gestionnaire d'erreurs global — renvoie toujours un format cohérent

const errorHandler = (err, req, res, next) => {
  console.error(`[Solo Pro Error] ${err.message}`, err.stack);

  const statusCode = err.statusCode || 500;
  const message = err.isOperational ? err.message : 'Une erreur interne est survenue';

  res.status(statusCode).json({
    error: message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
};

// Erreur métier personnalisée
class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
  }
}

module.exports = { errorHandler, AppError };
