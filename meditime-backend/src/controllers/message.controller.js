const Message = require('../models/message_model');
const User = require('../models/user_model');
const formatPhotoUrl = require('../utils/formatPhotoUrl');
const { emitToUser } = require('../utils/wsEmitter');
const { sendFcmToUser } = require('../utils/fcm'); // Ajoute cet import

// Fonction utilitaire pour formater l'URL de la photo de profil
function formatPhoto(photo, req) {
  return formatPhotoUrl(photo, req);
}

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
    // Adapter la photo de profil du sender
    const messagesWithPhoto = messages.map(msg => {
      const m = msg.toJSON();
      if (m.sender) {
        m.sender.profilePhoto = formatPhoto(m.sender.profilePhoto, req);
      }
      return m;
    });
    res.json(messagesWithPhoto);
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
    // Adapter la photo de profil du sender et receiver
    const messagesWithPhoto = messages.map(msg => {
      const m = msg.toJSON();
      if (m.sender) m.sender.profilePhoto = formatPhoto(m.sender.profilePhoto, req);
      if (m.receiver) m.receiver.profilePhoto = formatPhoto(m.receiver.profilePhoto, req);
      return m;
    });
    res.json(messagesWithPhoto);
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
      is_read: false
    });

    // Inclure les infos du sender et receiver dans la réponse
    const fullMessage = await Message.findByPk(message.id, {
      include: [
        { model: User, as: 'sender', attributes: ['idUser', 'lastName', 'firstName', 'role', 'profilePhoto'] },
        { model: User, as: 'receiver', attributes: ['idUser', 'lastName', 'firstName', 'role', 'profilePhoto'] }
      ]
    });

    // Adapter la photo de profil du sender et receiver
    const m = fullMessage.toJSON();
    if (m.sender) m.sender.profilePhoto = formatPhoto(m.sender.profilePhoto, req);
    if (m.receiver) m.receiver.profilePhoto = formatPhoto(m.receiver.profilePhoto, req);

    res.status(201).json(m);

    // Temps réel : notifier le destinataire et l'expéditeur (après la réponse HTTP)
    emitToUser(req.app, receiver_id, 'new_message', m);
    emitToUser(req.app, senderId, 'message_sent', m);

    // 🔔 Envoi notification FCM au destinataire
    const notifTitle = m.sender?.role === 'admin'
      ? 'Message de l\'administrateur'
      : `Nouveau message de ${m.sender?.firstName || ''} ${m.sender?.lastName || ''}`;
    const notifBody = m.content.length > 60 ? m.content.substring(0, 60) + '...' : m.content;
    sendFcmToUser(receiver_id, {
      title: notifTitle,
      body: notifBody
    }, {
      type: 'message',
      messageId: String(m.id),
      senderId: String(m.sender?.idUser),
      receiverId: String(m.receiver?.idUser),
      senderName: `${m.sender?.firstName || ''} ${m.sender?.lastName || ''}`,
      conversationId: String(m.sender?.idUser === receiver_id ? m.receiver?.idUser : m.sender?.idUser)
    }).catch(console.error);

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