const DoctorApplication = require('../models/doctor_application_model');

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
    res.json(lastApp);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

module.exports = { submitDoctorApplication, getLastApplication };