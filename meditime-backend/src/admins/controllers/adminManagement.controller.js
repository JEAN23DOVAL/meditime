const { User, Admin } = require('../../models');
const { hashPassword } = require('../../utils/hashPassword');
const { Op, fn, col, where } = require('sequelize');

// Lister tous les admins/modérateurs
exports.getAllAdmins = async (req, res) => {
  const admins = await Admin.findAll({
    include: [{ model: User, as: 'user', attributes: { exclude: ['password'] } }]
  });
  res.json(admins);
};

// Voir le détail d’un admin
exports.getAdminById = async (req, res) => {
  const admin = await Admin.findByPk(req.params.id, {
    include: [{ model: User, as: 'user', attributes: { exclude: ['password'] } }]
  });
  if (!admin) return res.status(404).json({ message: 'Admin non trouvé' });
  res.json(admin);
};

// Créer un admin/modérateur
exports.createAdmin = async (req, res) => {
  const { lastName, firstName, email, password, adminRole } = req.body;
  if (!lastName || !email || !password) return res.status(400).json({ message: 'Champs obligatoires manquants' });

  // 1. Créer le user (role: admin)
  const hashedPassword = await hashPassword(password);
  const user = await User.create({
    lastName, firstName, email, password: hashedPassword, role: 'admin', status: 'active'
  });

  // 2. Créer le profil admin
  const admin = await Admin.create({
    userId: user.idUser,
    adminRole: adminRole || 'super_admin',
    createdBy: req.user.idUser
  });

  res.status(201).json({ message: 'Admin créé', admin });
};

// Modifier le rôle d’un admin
exports.updateAdminRole = async (req, res) => {
  const { adminRole } = req.body;
  const admin = await Admin.findByPk(req.params.id);
  if (!admin) return res.status(404).json({ message: 'Admin non trouvé' });
  if (adminRole) admin.adminRole = adminRole;
  await admin.save();
  res.json({ message: 'Rôle mis à jour', admin });
};

// Désactiver/supprimer un admin (soft delete)
exports.disableAdmin = async (req, res) => {
  const admin = await Admin.findByPk(req.params.id);
  if (!admin) return res.status(404).json({ message: 'Admin non trouvé' });
  const user = await User.findByPk(admin.userId);
  if (!user) return res.status(404).json({ message: 'Utilisateur non trouvé' });
  user.status = 'inactive';
  await user.save();
  res.json({ message: 'Admin désactivé', user });
};

// Recherche et tri insensible à la casse sur les admins
exports.searchAdmins = async (req, res) => {
  const { search = '', sortBy = 'createdAt', order = 'DESC', adminRole = 'all' } = req.query;

  // Prépare la clause de recherche (nom, prénom, email)
  const searchFilter = search
    ? {
        [Op.or]: [
          where(fn('LOWER', col('user.lastName')), Op.like, `%${search.toLowerCase()}%`),
          where(fn('LOWER', col('user.firstName')), Op.like, `%${search.toLowerCase()}%`),
          where(fn('LOWER', col('user.email')), Op.like, `%${search.toLowerCase()}%`)
        ]
      }
    : {};

  // Prépare la clause de tri
  let orderArr = [];
  if (['lastName', 'firstName', 'email'].includes(sortBy)) {
    orderArr = [[{ model: User, as: 'user' }, sortBy, order]];
  } else if (sortBy === 'adminRole') {
    orderArr = [['adminRole', order]];
  } else {
    orderArr = [[sortBy, order]];
  }

  // Prépare le filtre par rôle
  let whereAdmin = {};
  if (adminRole && adminRole !== 'all') {
    whereAdmin.adminRole = adminRole;
  }

  const admins = await Admin.findAll({
    where: whereAdmin,
    include: [
      {
        model: User,
        as: 'user',
        attributes: { exclude: ['password'] },
        where: searchFilter
      }
    ],
    order: orderArr
  });

  res.json(admins);
};