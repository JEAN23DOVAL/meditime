const express = require('express');
const router = express.Router();
const { getDoctorByUserId, getDoctorById, getAllDoctorsSortedByNote, getDoctorsByProximity } = require('../controllers/doctor.controller');
const authMiddleware = require('../middlewares/authMiddleware');

// D'abord les routes spécifiques
router.get('/proximity', authMiddleware, getDoctorsByProximity);
router.get('/best/all', getAllDoctorsSortedByNote);
router.get('/by-user/:idUser', authMiddleware, getDoctorByUserId);
// Puis la route paramétrée à la fin
router.get('/:id', authMiddleware, getDoctorById);

module.exports = router;