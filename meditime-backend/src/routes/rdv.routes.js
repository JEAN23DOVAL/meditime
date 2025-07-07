const express = require('express');
const router = express.Router();
const { createRdv, getAllRdvs, getRdvById, updateRdv, deleteRdv, getAvailableSlots, acceptRdv, refuseRdv, cancelRdv, hasRdvBetweenPatientAndDoctor, markPresence } = require('../controllers/rdv.controller');
const authMiddleware = require('../middlewares/authMiddleware');

// Créer un rendez-vous
// router.post('/', authMiddleware, createRdv);

// Récupérer tous les rendez-vous (optionnel : ?patient_id=...&doctor_id=...)
router.get('/', authMiddleware, getAllRdvs);

// Récupérer les créneaux disponibles (doit être AVANT /:id)
router.get('/available-slots', authMiddleware, getAvailableSlots);

// Vérifier s'il existe un rdv entre un patient et un médecin
router.get('/has-between', authMiddleware, hasRdvBetweenPatientAndDoctor);

// Récupérer un rendez-vous par id
router.get('/:id', authMiddleware, getRdvById);

// Modifier un rendez-vous
router.put('/:id', authMiddleware, updateRdv);

// Supprimer un rendez-vous
router.delete('/:id', authMiddleware, deleteRdv);

// Accepter un rendez-vous (médecin)
router.patch('/:id/accept', authMiddleware, acceptRdv);

// Refuser un rendez-vous (médecin)
router.patch('/:id/refuse', authMiddleware, refuseRdv);

// Annuler un rendez-vous (patient ou médecin)
router.patch('/:id/cancel', authMiddleware, cancelRdv);

// Marquer la présence à un rendez-vous (médecin ou patient)
router.patch('/:id/mark-presence', authMiddleware, markPresence);

module.exports = router;