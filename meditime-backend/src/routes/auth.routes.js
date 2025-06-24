const express = require('express');
const router = express.Router();
const upload = require('../middlewares/uploadMiddleware');
const { validateRegister, validateLogin } = require('../middlewares/validateInput');
const { registerUser, loginUser } = require('../controllers/auth.controller');
const authMiddleware = require('../middlewares/authMiddleware');
const { saveFcmToken } = require('../controllers/fcm.controller');

// 📌 Inscription utilisateur (avec photo de profil en option)
router.post(
  '/register',
  upload.single('photo_profil'), // Middleware d'upload (champ = photo_profil)
  validateRegister,              // Middleware de validation des champs
  registerUser                   // Contrôleur
);

// 📌 Connexion utilisateur
router.post(
  '/login',
  validateLogin,  // Validation des champs d'entrée
  loginUser       // Contrôleur
);

// 📌 Mise à jour du profil utilisateur
router.post(
  '/update-profile',
  upload.single('profilePhoto'), // Champ attendu : profilePhoto
  async (req, res, next) => {
    // Auth middleware ici si besoin (ex: vérifier le token)
    next();
  },
  require('../controllers/auth.controller').updateProfile
);

// Enregistrer le token FCM (POST /api/auth/fcm-token)
router.post('/fcm-token', authMiddleware, saveFcmToken);

module.exports = router;