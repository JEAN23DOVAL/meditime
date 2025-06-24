const express = require('express');
const router = express.Router();
const { getSummaryStats } = require('../controllers/admin.controller');
const authMiddleware = require('../../middlewares/authMiddleware');
const adminMiddleware = require('../middleware/admin.middleware');
const medecinController = require('../controllers/medecin.controller');
const statsController = require('../controllers/stats.controller');
const patientController = require('../controllers/patient.controller');
const adminManagement = require('../controllers/adminManagement.controller');
const superAdminMiddleware = require('../middleware/superAdmin.middleware');
const rdvController = require('../../controllers/rdv.controller');

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
router.get('/stats', authMiddleware, adminMiddleware, statsController.getStats);

// --- AJOUT : EXPORT CSV/PDF ---
router.get('/stats/export-csv', authMiddleware, adminMiddleware, statsController.exportStatsCsv);
router.get('/stats/export-pdf', authMiddleware, adminMiddleware, statsController.exportStatsPdf);

router.get('/patients', authMiddleware, adminMiddleware, patientController.getAllPatients);
router.get('/patients/stats', authMiddleware, adminMiddleware, patientController.getPatientStats);
router.get('/patients/:id', authMiddleware, adminMiddleware, patientController.getPatientDetails);
router.patch('/patients/:id/toggle-status', authMiddleware, adminMiddleware, patientController.togglePatientStatus);
router.post('/patients/:id/reset-password', authMiddleware, adminMiddleware, patientController.resetPatientPassword);
router.post('/patients/:id/message', authMiddleware, adminMiddleware, patientController.sendMessageToPatient);
router.get('/patients/export', authMiddleware, adminMiddleware, patientController.exportPatients);
router.post('/patients/bulk-action', authMiddleware, adminMiddleware, patientController.bulkActionPatients);

// Gestion des médecins validés (Doctor)
router.get('/doctors', authMiddleware, adminMiddleware, medecinController.getAllDoctors);
router.get('/doctors/:id', authMiddleware, adminMiddleware, medecinController.getDoctorDetails);
router.patch('/doctors/:id', authMiddleware, adminMiddleware, medecinController.updateDoctorInfo);
router.patch('/doctors/:id/toggle-status', authMiddleware, adminMiddleware, medecinController.toggleDoctorStatus);
router.delete('/doctors/:id', authMiddleware, adminMiddleware, medecinController.deleteDoctor);
router.post('/doctors/:idUser/reset-password', authMiddleware, adminMiddleware, medecinController.resetDoctorPassword);
router.get('/doctors/:idUser/stats', authMiddleware, adminMiddleware, medecinController.getDoctorStats);
// Liste des rdv d’un médecin (admin)
router.get('/doctors/:idUser/rdvs', medecinController.getDoctorRdvs);

// Admin Management Routes

// Recherche et tri insensible à la casse sur les admins (super admin ou admin)
router.get(
  '/admins/search',
  authMiddleware,
  adminManagement.searchAdmins
);

// Lister tous les admins/modérateurs
router.get('/admins', authMiddleware, adminManagement.getAllAdmins);

// Voir le détail d’un admin
router.get('/admins/:id', authMiddleware, adminManagement.getAdminById);

// Créer un admin/modérateur (super admin uniquement)
router.post('/admins', authMiddleware, superAdminMiddleware, adminManagement.createAdmin);

// Modifier le rôle d’un admin (super admin uniquement)
router.patch('/admins/:id/role', authMiddleware, superAdminMiddleware, adminManagement.updateAdminRole);

// Désactiver un admin (super admin uniquement)
router.patch('/admins/:id/disable', authMiddleware, superAdminMiddleware, adminManagement.disableAdmin);

// Lister tous les RDV (admin)
router.get(
  '/rdvs',
  authMiddleware,
  adminMiddleware,
  (req, res, next) => {
    // On retire les consultations du résultat
    req.excludeConsultation = true;
    next();
  },
  async (req, res) => {
    // Appelle getAllRdvs mais filtre la consultation dans le résultat
    const { getAllRdvs } = require('../../controllers/rdv.controller');
    // Monkey patch pour retirer la consultation
    const originalJson = res.json.bind(res);
    res.json = (data) => {
      if (Array.isArray(data)) {
        data.forEach(rdv => delete rdv.consultation);
      } else if (data && typeof data === 'object') {
        delete data.consultation;
      }
      originalJson(data);
    };
    return getAllRdvs(req, res);
  }
);

// Détail d’un RDV (admin)
router.get(
  '/rdvs/:id',
  authMiddleware,
  adminMiddleware,
  async (req, res) => {
    const { getRdvById } = require('../../controllers/rdv.controller');
    // Monkey patch pour retirer la consultation
    const originalJson = res.json.bind(res);
    res.json = (data) => {
      if (data && typeof data === 'object') {
        delete data.consultation;
      }
      originalJson(data);
    };
    return getRdvById(req, res);
  }
);

// Modifier un RDV (admin)
router.put(
  '/rdvs/:id',
  authMiddleware,
  adminMiddleware,
  (req, res) => require('../../controllers/rdv.controller').updateRdv(req, res)
);

// Supprimer un RDV (admin)
router.delete(
  '/rdvs/:id',
  authMiddleware,
  adminMiddleware,
  (req, res) => require('../../controllers/rdv.controller').deleteRdv(req, res)
);

// Annuler un RDV (admin)
router.patch(
  '/rdvs/:id/cancel',
  authMiddleware,
  adminMiddleware,
  async (req, res) => {
    // On force l’annulation comme si c’était l’admin
    const { id } = req.params;
    const { Rdv } = require('../../models');
    const rdv = await Rdv.findByPk(id);
    if (!rdv) return res.status(404).json({ message: 'Rendez-vous non trouvé' });
    rdv.status = 'cancelled';
    rdv.updated_at = new Date();
    await rdv.save();
    // Notifie patient et médecin
    const { notifyRdvStatus } = require('../../utils/rdvNotification');
    notifyRdvStatus(req.app, rdv, 'pending', req.user.idUser).catch(console.error);
    res.json({ message: 'Rendez-vous annulé par l’admin', rdv });
  }
);

module.exports = router;