const DoctorApplication = require('../models/doctor_application_model');
const formatPhotoUrl = require('../utils/formatPhotoUrl');
const { emitToAdmins, emitToUser } = require('../utils/wsEmitter');

const submitDoctorApplication = async (req, res) => {
  try {
    const {
      idUser, specialite, diplomes, numeroInscription, hopital, adresseConsultation
    } = req.body;

    // Vérifier s'il y a déjà une demande en attente
    const lastApp = await DoctorApplication.findOne({
      where: { idUser, status: 'pending' }
    });
    if (lastApp) {
      return res.status(400).json({ message: 'Vous avez déjà une demande en attente.' });
    }

    // Récupérer les fichiers uploadés
    const files = req.files || {};
    const cniFront = files.cniFront?.[0]?.filename || null;
    const cniBack = files.cniBack?.[0]?.filename || null;
    const certification = files.certification?.[0]?.filename || null;
    const cvPdf = files.cvPdf?.[0]?.filename || null;
    const casierJudiciaire = files.casierJudiciaire?.[0]?.filename || null;

    const newApp = await DoctorApplication.create({
      idUser,
      specialite,
      diplomes,
      numero_inscription: numeroInscription,
      hopital,
      adresse_consultation: adresseConsultation,
      cni_front: cniFront,
      cni_back: cniBack,
      certification,
      cv_pdf: cvPdf,
      casier_judiciaire: casierJudiciaire,
      status: 'pending'
    });

    // Après soumission
    emitToAdmins(req.app, 'doctor_application_update', { type: 'new', application: newApp });

    res.status(201).json({ message: 'Demande envoyée avec succès', application: newApp });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

const getLastApplication = async (req, res) => {
  try {
    const { idUser } = req.params;
    const lastApp = await DoctorApplication.findOne({
      where: { idUser },
      order: [['created_at', 'DESC']]
    });
    if (lastApp) {
      const app = lastApp.toJSON();
      app.cni_front = app.cni_front ? formatPhotoUrl(app.cni_front, req, 'doctor_application') : null;
      app.cni_back = app.cni_back ? formatPhotoUrl(app.cni_back, req, 'doctor_application') : null;
      app.certification = app.certification ? formatPhotoUrl(app.certification, req, 'doctor_application') : null;
      app.cv_pdf = app.cv_pdf ? formatPhotoUrl(app.cv_pdf, req, 'doctor_application') : null;
      app.casier_judiciaire = app.casier_judiciaire ? formatPhotoUrl(app.casier_judiciaire, req, 'doctor_application') : null;
      res.json(app);
    } else {
      res.status(404).json({ message: 'Aucune demande trouvée.' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

module.exports = { submitDoctorApplication, getLastApplication };