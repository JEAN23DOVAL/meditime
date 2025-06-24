const express = require('express');
const router = express.Router();
const consultationController = require('../controllers/consultation.controller');
const validateConsultation = require('../middlewares/validateConsultation');
const authMiddleware = require('../middlewares/authMiddleware');
const upload = require('../middlewares/consultationUpload');

// Création d'une consultation
router.post(
  '/',
  authMiddleware,
  upload, // Ajoute ce middleware AVANT validateConsultation
  validateConsultation,
  consultationController.createConsultation
);

// Récupération d'une consultation par l'ID du rendez-vous
router.get('/rdv/:rdv_id', authMiddleware, consultationController.getConsultationByRdvId);

module.exports = router;