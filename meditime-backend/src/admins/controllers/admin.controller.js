const User = require('../../models/user_model');

const getSummaryStats = async (req, res) => {
  try {
    const patients = await User.count({ where: { role: 'patient' } });
    const doctors = await User.count({ where: { role: 'doctor' } });
    const admins = await User.count({ where: { role: 'admin' } });
    const totalUsers = patients + doctors + admins;

    return res.status(200).json({ patients, doctors, admins, totalUsers });
  } catch (error) {
    console.error('Erreur lors de la récupération des statistiques :', error);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

module.exports = { getSummaryStats };