const { verifyToken } = require('../utils/jwt');

/**
 * Middleware pour vérifier l'authentification via JWT
 */
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({
      error: 'Accès refusé',
      message: 'Aucun token fourni'
    });
  }

  try {
    const decoded = verifyToken(token);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(403).json({
      error: 'Token invalide',
      message: error.message
    });
  }
};

/**
 * Middleware pour vérifier les rôles requis
 * @param {Array} allowedRoles - Liste des rôles autorisés
 */
const requireRole = (allowedRoles) => {
  return (req, res, next) => {
    if (!req.user || !req.user.roles) {
      return res.status(403).json({
        error: 'Accès refusé',
        message: 'Utilisateur non authentifié'
      });
    }

    const hasRole = req.user.roles.some(role => allowedRoles.includes(role));

    if (!hasRole) {
      return res.status(403).json({
        error: 'Accès refusé',
        message: 'Permissions insuffisantes'
      });
    }

    next();
  };
};

module.exports = {
  authenticateToken,
  requireRole
};
