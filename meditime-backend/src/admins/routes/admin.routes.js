const express = require('express');
const router = express.Router();
const { getSummaryStats } = require('../controllers/admin.controller');
const authMiddleware = require('../../middlewares/authMiddleware');
const adminMiddleware = require('../middleware/admin.middleware');
const medecinController = require('../controllers/medecin.controller');

router.get('/summary-stats', authMiddleware, adminMiddleware, getSummaryStats);
router.get('/medecins', authMiddleware, adminMiddleware, medecinController.getAllMedecins);
router.patch(
  '/medecins/:id/valider',
  authMiddleware,
  adminMiddleware,
  medecinController.acceptDoctorApplication
);

router.patch(
  '/medecins/:id/refuser',
  authMiddleware,
  adminMiddleware,
  medecinController.refuseDoctorApplication
);

module.exports = router;