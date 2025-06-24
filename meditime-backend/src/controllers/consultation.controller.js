const Consultation = require('../models/consultation_model');
const Doctor = require('../models/doctor_model');
const ConsultationFile = require('../models/consultation_file_model'); // Crée ce modèle si besoin
const formatPhotoUrl = require('../utils/formatPhotoUrl');
const { emitToUser } = require('../utils/wsEmitter');
const { sendFcmToUser } = require('../utils/fcm'); // Ajoute cet import
const User = require('../models/user_model'); // Pour récupérer le nom du médecin

exports.createConsultation = async (req, res) => {
  try {
    let { rdv_id, patient_id, doctor_id, diagnostic, prescription, doctor_notes } = req.body;

    // 1. Vérifier si une consultation existe déjà pour ce rdv_id
    let consultation = await Consultation.findOne({ where: { rdv_id } });

    if (consultation) {
      // 2. Si oui, faire un update
      await consultation.update({
        patient_id,
        doctor_id,
        diagnostic,
        prescription,
        doctor_notes
      });

      // Optionnel : supprimer les anciens fichiers si tu veux les remplacer
      await ConsultationFile.destroy({ where: { consultation_id: consultation.id } });
    } else {
      // 3. Sinon, créer une nouvelle consultation
      consultation = await Consultation.create({
        rdv_id,
        patient_id,
        doctor_id,
        diagnostic,
        prescription,
        doctor_notes
      });
    }

    // Gestion des fichiers uploadés (toujours ajouter les nouveaux)
    if (req.files && req.files.length > 0) {
      const files = req.files.map(file => ({
        consultation_id: consultation.id,
        file_path: `/uploads/consultations/${consultation.patient_id}/${file.filename}`,
        file_type: file.mimetype
      }));
      await ConsultationFile.bulkCreate(files);
    }

    // Émettre l'événement aux utilisateurs concernés
    emitToUser(req.app, patient_id, 'consultation_update', { consultation });
    emitToUser(req.app, doctor_id, 'consultation_update', { consultation });

    // 🔔 Notification FCM au patient
    const doctorUser = await User.findByPk(doctor_id);
    const notifTitle = 'Compte-rendu de consultation disponible';
    const notifBody = `Votre consultation avec le Dr ${doctorUser?.lastName || ''} est terminée. Consultez le compte-rendu.`;
    sendFcmToUser(patient_id, {
      title: notifTitle,
      body: notifBody
    }, {
      type: 'consultation',
      consultationId: String(consultation.id),
      rdvId: String(consultation.rdv_id),
      doctorId: String(doctor_id)
    }).catch(console.error);

    res.status(201).json({
      message: consultation._options.isNewRecord === false
        ? 'Consultation mise à jour avec succès'
        : 'Consultation créée avec succès',
      consultation
    });
  } catch (error) {
    console.error('Erreur création consultation:', error);
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};

exports.getConsultationById = async (req, res) => {
  try {
    const { id } = req.params;
    const consultation = await Consultation.findByPk(id, {
      include: [
        {
          model: ConsultationFile,
          as: 'files',
          attributes: ['id', 'file_path', 'file_type']
        }
      ]
    });
    if (!consultation) {
      return res.status(404).json({ message: 'Consultation non trouvée' });
    }

    // Adapter les liens des fichiers
    const consultationObj = consultation.toJSON();
    consultationObj.files = consultationObj.files.map(file => ({
      id: file.id,
      file_url: formatPhotoUrl(file.file_path, req, `consultations/${consultationObj.patient_id}`),
      file_type: file.file_type
    }));

    res.json(consultationObj);
  } catch (error) {
    console.error('Erreur récupération consultation:', error);
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};

exports.getConsultationByRdvId = async (req, res) => {
  try {
    const { rdv_id } = req.params;
    const consultation = await Consultation.findOne({
      where: { rdv_id },
      include: [
        {
          model: ConsultationFile,
          as: 'files',
          attributes: ['id', 'file_path', 'file_type']
        }
      ]
    });
    if (!consultation) {
      return res.status(404).json({ message: 'Consultation non trouvée' });
    }

    // Adapter les liens des fichiers
    const consultationObj = consultation.toJSON();
    consultationObj.files = consultationObj.files.map(file => ({
      id: file.id,
      file_url: formatPhotoUrl(file.file_path, req, `consultations/${consultationObj.patient_id}`),
      file_type: file.file_type
    }));

    res.json(consultationObj);
  } catch (error) {
    console.error('Erreur récupération consultation par rdv_id:', error);
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};