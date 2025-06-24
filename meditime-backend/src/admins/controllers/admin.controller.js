const User = require('../../models/user_model');
const { emitToUser } = require('../../utils/wsEmitter');

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

const suspendUser = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await User.findByPk(id);
    if (!user) return res.status(404).json({ message: 'Utilisateur non trouvé' });

    user.status = 'suspended';
    await user.save();

    emitToUser(req.app, user.idUser, 'admin_action', { action: 'suspend', user });

    res.json({ message: 'Utilisateur suspendu', user });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};

const sendMessage = async (req, res) => {
  const { receiverId, senderId, content } = req.body;

  try {
    // Logic to save the message in the database would go here

    const message = { receiverId, senderId, content, timestamp: new Date() };

    // Emit the message to the receiver
    emitToUser(req.app, receiverId, 'new_message', message);

    // Optionally, emit an event to the sender to confirm the message was sent
    emitToUser(req.app, senderId, 'message_sent', message);

    return res.status(201).json({ message: 'Message sent', messageDetails: message });
  } catch (error) {
    console.error('Error sending message:', error);
    return res.status(500).json({ message: 'Error sending message' });
  }
};

module.exports = { getSummaryStats, suspendUser, sendMessage };