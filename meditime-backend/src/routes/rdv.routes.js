const express = require('express');
const router = express.Router();
const { createRdv, getAllRdvs, getRdvById, updateRdv, deleteRdv, getAvailableSlots } = require('../controllers/rdv.controller');
const authMiddleware = require('../middlewares/authMiddleware');

// Créer un rendez-vous
router.post('/', authMiddleware, createRdv);

// Récupérer tous les rendez-vous (optionnel : ?patient_id=...&doctor_id=...)
router.get('/', authMiddleware, getAllRdvs);

// Récupérer les créneaux disponibles (doit être AVANT /:id)
router.get('/available-slots', authMiddleware, getAvailableSlots);

// Récupérer un rendez-vous par id
router.get('/:id', authMiddleware, getRdvById);

// Modifier un rendez-vous
router.put('/:id', authMiddleware, updateRdv);

// Supprimer un rendez-vous
router.delete('/:id', authMiddleware, deleteRdv);

module.exports = router;