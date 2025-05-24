const Message = require('../models/message_model');
const User = require('../models/user_model');

const getUserMessages = async (req, res) => {
  try {
    const userId = req.user.idUser;
    const messages = await Message.findAll({
      where: { receiver_id: userId },
      order: [['created_at', 'DESC']],
      include: [
        { model: User, as: 'sender', attributes: ['idUser', 'lastName', 'firstName', 'role', 'profilePhoto'] }
      ]
    });
    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Pour l’admin : tous les messages ou par utilisateur
const getAllMessages = async (req, res) => {
  try {
    const messages = await Message.findAll({
      order: [['created_at', 'DESC']],
      include: [
        { model: User, as: 'sender', attributes: ['idUser', 'lastName', 'firstName', 'role', 'profilePhoto'] },
        { model: User, as: 'receiver', attributes: ['idUser', 'lastName', 'firstName', 'role', 'profilePhoto'] }
      ]
    });
    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

const markAsRead = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.idUser;
    // On ne marque comme lu que si le message appartient à l'utilisateur connecté
    const message = await Message.findOne({ where: { id, receiver_id: userId } });
    if (!message) {
      return res.status(404).json({ message: "Message non trouvé" });
    }
    message.is_read = true;
    message.read_at = new Date();
    await message.save();
    res.json({ message: "Message marqué comme lu" });
  } catch (error) {
    res.status(500).json({ message: "Erreur serveur" });
  }
};

const sendMessage = async (req, res) => {
  try {
    const senderId = req.user.idUser;
    const { receiver_id, content, subject, type } = req.body;

    if (!receiver_id || !content) {
      return res.status(400).json({ message: "receiver_id et content sont requis" });
    }

    // Vérifier que le destinataire existe
    const receiver = await User.findByPk(receiver_id);
    if (!receiver) {
      return res.status(404).json({ message: "Destinataire introuvable" });
    }

    // Créer le message
    const message = await Message.create({
      sender_id: senderId,
      receiver_id,
      content,
      subject: subject || null,
      type: type || 'user_to_admin',
      is_read: false // <-- Ajout explicite
    });

    // Inclure les infos du sender et receiver dans la réponse
    const fullMessage = await Message.findByPk(message.id, {
      include: [
        { model: User, as: 'sender', attributes: ['idUser', 'lastName', 'firstName', 'role', 'profilePhoto'] },
        { model: User, as: 'receiver', attributes: ['idUser', 'lastName', 'firstName', 'role', 'profilePhoto'] }
      ]
    });

    res.status(201).json(fullMessage);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur lors de l'envoi du message" });
  }
};

module.exports = {
  getUserMessages,
  getAllMessages,
  markAsRead,
  sendMessage
};