const express = require('express');
const router = express.Router();
const { getUserMessages, getAllMessages, markAsRead, sendMessage } = require('../controllers/message.controller');
const authMiddleware = require('../middlewares/authMiddleware');
const adminMiddleware = require('../admins/middleware/admin.middleware');

// Pour un utilisateur connecté (patient/doctor)
router.get('/my', authMiddleware, getUserMessages);

// Pour l’admin : tous les messages
router.get('/all', authMiddleware, adminMiddleware, getAllMessages);

// Récupérer tous les échanges entre deux utilisateurs
router.get(
  '/conversation/:userId',
  authMiddleware,
  async (req, res) => {
    const myId = req.user.idUser;
    const otherId = parseInt(req.params.userId, 10);
    if (!otherId) return res.status(400).json({ message: 'userId manquant' });

    const { Message, User } = require('../models');
    try {
      const messages = await Message.findAll({
        where: {
          [require('sequelize').Op.or]: [
            { sender_id: myId, receiver_id: otherId },
            { sender_id: otherId, receiver_id: myId }
          ]
        },
        order: [['created_at', 'ASC']],
        include: [
          { model: User, as: 'sender', attributes: ['idUser', 'lastName', 'firstName', 'role', 'profilePhoto'] },
          { model: User, as: 'receiver', attributes: ['idUser', 'lastName', 'firstName', 'role', 'profilePhoto'] }
        ]
      });
      res.json(messages);
    } catch (error) {
      res.status(500).json({ message: 'Erreur serveur' });
    }
  }
);

router.patch('/:id/read', authMiddleware, markAsRead);
router.post('/send', authMiddleware, sendMessage);

module.exports = router;