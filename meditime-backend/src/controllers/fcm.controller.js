const User = require('../models/user_model');

exports.saveFcmToken = async (req, res) => {
  try {
    const userId = req.user.idUser;
    const { token } = req.body;
    if (!token) return res.status(400).json({ message: 'Token FCM manquant' });

    await User.update({ fcm_token: token }, { where: { idUser: userId } });
    res.json({ message: 'Token FCM enregistré' });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};