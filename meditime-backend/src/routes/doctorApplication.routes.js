const express = require('express');
const router = express.Router();
const upload = require('../middlewares/doctorApplicationUpload');
const validate = require('../middlewares/validateDoctorApplication');
const controller = require('../controllers/doctorApplication.controller');

// Soumission d'une demande
router.post('/submit', upload, validate, controller.submitDoctorApplication);

// Récupérer la dernière demande d’un utilisateur
router.get('/last/:idUser', controller.getLastApplication);

module.exports = router;