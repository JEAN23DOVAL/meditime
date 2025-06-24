const { Admin } = require('../../models');

module.exports = async (req, res, next) => {
  if (req.user?.role !== 'admin') return res.status(403).json({ message: 'Accès réservé aux admins' });
  const adminProfile = await Admin.findOne({ where: { userId: req.user.idUser } });
  if (!adminProfile || adminProfile.adminRole !== 'super_admin') {
    return res.status(403).json({ message: 'Accès réservé aux super admins' });
  }
  next();
};