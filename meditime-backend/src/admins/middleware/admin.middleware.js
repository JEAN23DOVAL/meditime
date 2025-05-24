module.exports = (req, res, next) => {
  // Supposons que req.user est injecté par un middleware d'auth JWT
  if (req.user && req.user.role === 'admin') {
    return next();
  }
  return res.status(403).json({ message: 'Accès réservé aux administrateurs' });
};