// filepath: e:\PROGRAMMATION\MON PROJET DE STAGE\app mobile\meditime-backend\src\controllers\adminPatientController.js
const { Op } = require('sequelize');
const { User, Rdv, Consultation, Message } = require('../../models');
const messageController = require('../../controllers/message.controller');
const { Parser } = require('json2csv');
const PDFDocument = require('pdfkit');
const fs = require('fs');
const path = require('path');
const formatPhotoUrl = require('../../utils/formatPhotoUrl');
const { emitToUser } = require('../../utils/wsEmitter');

// Helper pour formater l'URL de la photo
function formatPhoto(photo, req) {
  return formatPhotoUrl(photo, req);
}

// Liste paginée, recherche, filtres avancés
const getAllPatients = async (req, res) => {
  try {
    const {
      search = '',
      status,
      city,
      gender,
      createdAtStart,
      createdAtEnd,
      limit = 20,
      offset = 0,
      sort = 'createdAt',
      order = 'DESC'
    } = req.query;

    const where = { role: 'patient' };
    if (search) {
      where[Op.or] = [
        { lastName: { [Op.like]: `%${search}%` } },
        { firstName: { [Op.like]: `%${search}%` } },
        { email: { [Op.like]: `%${search}%` } },
        { phone: { [Op.like]: `%${search}%` } },
        { city: { [Op.like]: `%${search}%` } }
      ];
    }
    if (status) where.status = status;
    if (city) where.city = city;
    if (gender) where.gender = gender;
    if (createdAtStart || createdAtEnd) {
      where.createdAt = {};
      if (createdAtStart) where.createdAt[Op.gte] = new Date(createdAtStart);
      if (createdAtEnd) where.createdAt[Op.lte] = new Date(createdAtEnd);
    }

    const { count, rows } = await User.findAndCountAll({
      where,
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [[sort, order]],
      attributes: { exclude: ['password'] }
    });

    // Format photo
    const patients = rows.map(u => ({
      ...u.toJSON(),
      profilePhoto: formatPhoto(u.profilePhoto, req)
    }));

    res.json({ count, patients });
  } catch (error) {
    console.error('Error fetching patients:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Fiche détaillée patient (infos, stats, historique RDV/consultations)
const getPatientDetails = async (req, res) => {
  try {
    const { id } = req.params;
    const patient = await User.findByPk(id, {
      attributes: { exclude: ['password'] },
      include: [
        {
          model: Rdv,
          as: 'patientRdvs',
          attributes: ['id', 'doctor_id', 'specialty', 'date', 'status', 'motif', 'created_at'],
          include: [
            {
              model: User,
              as: 'rdvDoctor',
              attributes: ['idUser', 'firstName', 'lastName', 'profilePhoto', 'email', 'phone']
            },
            {
              model: require('../../models/doctor_model'),
              as: 'rdvDoctorProfile',
              attributes: ['specialite']
            }
          ],
          order: [['date', 'DESC']]
        },
        {
          model: Consultation,
          as: 'consultationsAsPatient',
          attributes: ['id', 'doctor_id', 'diagnostic', 'prescription', 'created_at', 'updated_at']
        }
      ]
    });

    if (!patient) return res.status(404).json({ message: 'Patient non trouvé' });

    // Statistiques
    const totalRdvs = await Rdv.count({ where: { patient_id: id } });
    const noShowCount = await Rdv.count({ where: { patient_id: id, status: 'no_show' } });
    const lastLogin = patient.lastLoginAt;

    // Format profilePhoto du patient
    const patientObj = patient.toJSON();
    patientObj.profilePhoto = formatPhoto(patientObj.profilePhoto, req);

    // Format profilePhoto dans les RDV (médecin inclus)
    if (Array.isArray(patientObj.patientRdvs)) {
      patientObj.patientRdvs = patientObj.patientRdvs.map(rdv => {
        if (rdv.rdvDoctor && rdv.rdvDoctor.profilePhoto) {
          rdv.rdvDoctor.profilePhoto = formatPhoto(rdv.rdvDoctor.profilePhoto, req);
        }
        if (rdv.rdvDoctor && rdv.rdvDoctorProfile && rdv.rdvDoctorProfile.specialite) {
          rdv.rdvDoctor.specialite = rdv.rdvDoctorProfile.specialite;
        }
        delete rdv.rdvDoctorProfile;
        // On retourne toutes les colonnes de la table rdv
        return {
          id: rdv.id,
          patient_id: rdv.patient_id ?? patientObj.idUser,
          doctor_id: rdv.doctor_id,
          specialty: rdv.specialty,
          date: rdv.date,
          status: rdv.status,
          motif: rdv.motif,
          duration_minutes: rdv.duration_minutes ?? 60,
          created_at: rdv.created_at,
          updated_at: rdv.updated_at ?? rdv.created_at,
          // Ajoute l'objet médecin enrichi
          rdvDoctor: rdv.rdvDoctor ? { ...rdv.rdvDoctor } : null
        };
      });
    }

    // Format profilePhoto dans les consultations (si tu inclus le médecin)
    if (Array.isArray(patientObj.consultationsAsPatient)) {
      patientObj.consultationsAsPatient = patientObj.consultationsAsPatient.map(consult => {
        if (consult.consultationDoctor && consult.consultationDoctor.profilePhoto) {
          consult.consultationDoctor.profilePhoto = formatPhoto(consult.consultationDoctor.profilePhoto, req);
        }
        return consult;
      });
    }

    res.json({
      ...patientObj,
      stats: {
        totalRdvs,
        noShowCount,
        lastLogin
      }
    });
  } catch (error) {
    console.error('Error fetching patient details:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Suspendre/réactiver un compte patient
const togglePatientStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const adminId = req.user.idUser;
    const { reason } = req.body; // optionnel

    const patient = await User.findByPk(id);
    if (!patient) return res.status(404).json({ message: 'Patient non trouvé' });

    if (patient.status === 'suspended') {
      patient.status = 'active';
      patient.suspendedBy = null;
      patient.suspendedAt = null;
      patient.suspensionReason = null;
    } else {
      patient.status = 'suspended';
      patient.suspendedBy = adminId;
      patient.suspendedAt = new Date();
      patient.suspensionReason = reason || null;
    }
    await patient.save();

    emitToUser(req.app, patient.idUser, 'patient_update', { patient });

    res.json({ message: `Compte ${patient.status === 'active' ? 'réactivé' : 'suspendu'}` });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Réinitialiser le mot de passe (génère un mot de passe temporaire)
const resetPatientPassword = async (req, res) => {
  try {
    const { id } = req.params;
    const patient = await User.findByPk(id);
    if (!patient) return res.status(404).json({ message: 'Patient non trouvé' });

    const tempPassword = Math.random().toString(36).slice(-8) + '#';
    const bcrypt = require('bcrypt');
    patient.password = await bcrypt.hash(tempPassword, 10);
    await patient.save();

    // Ici tu peux envoyer le mot de passe temporaire par email ou SMS si besoin

    res.json({ message: 'Mot de passe réinitialisé', tempPassword });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Envoyer un message à un patient (utilise la logique centrale)
const sendMessageToPatient = (req, res) => {
  // On force le receiver_id à req.params.id pour éviter toute fraude côté front
  req.body.receiver_id = req.params.id;
  // On peut forcer le type si besoin : req.body.type = 'admin_reply';
  return messageController.sendMessage(req, res);
};

// Statistiques globales patients
const getPatientStats = async (req, res) => {
  try {
    const totalPatients = await User.count({ where: { role: 'patient' } });
    const newPatients = await User.count({
      where: {
        role: 'patient',
        createdAt: { [Op.gte]: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) }
      }
    });
    // Pour les graphiques d'évolution, le front peut demander par période
    res.json({ totalPatients, newPatients });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Supprimer un patient (soft delete)
const deletePatient = async (req, res) => {
  try {
    const { id } = req.params;
    const patient = await User.findByPk(id);
    if (!patient) return res.status(404).json({ message: 'Patient non trouvé' });

    // On peut garder une trace de la suppression (qui, quand) si besoin
    patient.deletedAt = new Date();
    patient.status = 'inactive';
    await patient.save();

    res.json({ message: 'Patient supprimé' });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Export patients (CSV ou PDF)
const exportPatients = async (req, res) => {
  try {
    const { format = 'csv' } = req.query;
    const patients = await User.findAll({
      where: { role: 'patient' },
      attributes: { exclude: ['password'] }
    });

    const data = patients.map(u => ({
      id: u.idUser,
      lastName: u.lastName,
      firstName: u.firstName,
      email: u.email,
      phone: u.phone,
      city: u.city,
      gender: u.gender,
      status: u.status,
      createdAt: u.createdAt,
      updatedAt: u.updatedAt
    }));

    if (format === 'csv') {
      const parser = new Parser();
      const csv = parser.parse(data);
      res.header('Content-Type', 'text/csv');
      res.attachment('patients.csv');
      return res.send(csv);
    } else if (format === 'pdf') {
      const doc = new PDFDocument();
      const filePath = path.join(__dirname, '../../../tmp/patients.pdf');
      doc.pipe(fs.createWriteStream(filePath));
      doc.fontSize(18).text('Liste des patients', { align: 'center' });
      doc.moveDown();
      data.forEach(p => {
        doc.fontSize(12).text(
          `${p.lastName} ${p.firstName} | ${p.email} | ${p.phone} | ${p.city} | ${p.gender} | ${p.status} | ${p.createdAt}`
        );
      });
      doc.end();
      doc.on('finish', () => {
        res.download(filePath, 'patients.pdf', () => {
          fs.unlinkSync(filePath);
        });
      });
    } else {
      res.status(400).json({ message: 'Format non supporté' });
    }
  } catch (error) {
    console.error('Error exporting patients:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Action groupée sur les patients
const bulkActionPatients = async (req, res) => {
  try {
    const { ids, action, reason } = req.body;
    if (!Array.isArray(ids) || !action) {
      return res.status(400).json({ message: 'Paramètres manquants' });
    }
    let update = {};
    if (action === 'suspend') {
      update = {
        status: 'suspended',
        suspendedAt: new Date(),
        suspensionReason: reason || null
      };
    } else if (action === 'activate') {
      update = {
        status: 'active',
        suspendedAt: null,
        suspensionReason: null
      };
    } else if (action === 'delete') {
      update = {
        status: 'inactive',
        deletedAt: new Date()
      };
    } else {
      return res.status(400).json({ message: 'Action non supportée' });
    }
    await User.update(update, { where: { idUser: ids } });
    res.json({ message: 'Action groupée effectuée' });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

module.exports = {
  getAllPatients,
  getPatientDetails,
  togglePatientStatus,
  resetPatientPassword,
  sendMessageToPatient,
  getPatientStats,
  deletePatient,
  exportPatients,
  bulkActionPatients
};