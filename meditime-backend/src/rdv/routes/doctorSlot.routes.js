const express = require('express');
const router = express.Router();
const { createSlot, getSlotsByDoctor, updateSlot, deleteSlot, getActiveSlotsByDoctor } = require('../controllers/doctorSlot.controller');
const authMiddleware = require('../../middlewares/authMiddleware');
const validateDoctorSlot = require('../middlewares/validateDoctorSlot');

// POST /api/rdv/slots
router.post('/', authMiddleware, validateDoctorSlot, createSlot);

// GET /api/rdv/slots/:doctorId
router.get('/:doctorId', authMiddleware, getSlotsByDoctor);

// GET /api/rdv/slots/active/:doctorId
router.get('/active/:doctorId', authMiddleware, getActiveSlotsByDoctor);

// PUT /api/rdv/slots/:id
router.put('/:id', authMiddleware, validateDoctorSlot, updateSlot); 

// DELETE /api/rdv/slots/:id
router.delete('/:id', authMiddleware, deleteSlot);

module.exports = router;