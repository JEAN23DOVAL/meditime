const express = require('express');
const router = express.Router();
const { getDoctorByIdUser, getDoctorById, getAllDoctorsSortedByNote, getDoctorsByProximity, updateDoctorExtraInfo } = require('../controllers/doctor.controller');
const authMiddleware = require('../middlewares/authMiddleware');

// D'abord les routes spécifiques
router.get('/proximity', authMiddleware, getDoctorsByProximity);
router.get('/best/all', getAllDoctorsSortedByNote);
router.get('/user/:idUser', getDoctorByIdUser);
// Puis la route paramétrée à la fin
router.get('/:id', authMiddleware, getDoctorById);
// Ajout de la route de mise à jour des infos complémentaires
router.patch('/:id/extra', authMiddleware, updateDoctorExtraInfo);

module.exports = router;