const { User, DoctorApplication } = require('../../models');
const Doctor = require('../../models/doctor_model');
const Message = require('../../models/message_model');
const BASE_URL = process.env.BASE_URL || 'http://10.0.2.2:3000';

// GET /api/admin/medecins
const getAllMedecins = async (req, res) => {
  try {
    const demandes = await DoctorApplication.findAll({
      include: [
        {
          model: User,
          as: 'user',
          attributes: { exclude: ['password'] }
        }
      ],
      order: [['created_at', 'DESC']]
    });

    // On adapte les chemins des fichiers pour chaque demande
    const demandesWithUrls = demandes.map(demande => {
      const d = demande.toJSON();
      return {
        ...d,
        cni_front: d.cni_front ? `${BASE_URL}/uploads/doctor_application/${d.cni_front}` : null,
        cni_back: d.cni_back ? `${BASE_URL}/uploads/doctor_application/${d.cni_back}` : null,
        certification: d.certification ? `${BASE_URL}/uploads/doctor_application/${d.certification}` : null,
        cv_pdf: d.cv_pdf ? `${BASE_URL}/uploads/doctor_application/${d.cv_pdf}` : null,
        casier_judiciaire: d.casier_judiciaire ? `${BASE_URL}/uploads/doctor_application/${d.casier_judiciaire}` : null,
        user: d.user
          ? {
              ...d.user,
              profilePhoto: d.user.profilePhoto
                ? `${BASE_URL}/uploads/photo_profil/${d.user.profilePhoto}`
                : null
            }
          : null
      };
    });

    res.status(200).json(demandesWithUrls);
  } catch (error) {
    console.error('Erreur récupération demandes:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// PATCH /admin/medecins/:id/valider
const acceptDoctorApplication = async (req, res) => {
  try {
    const { id } = req.params;
    const application = await DoctorApplication.findByPk(id);
    if (!application || application.status !== 'pending') {
      return res.status(404).json({ message: 'Demande non trouvée ou déjà traitée' });
    }
    // Mettre à jour la demande
    application.status = 'accepted';
    await application.save();

    // Créer le médecin validé
    await Doctor.create({
      idUser: application.idUser,
      specialite: application.specialite,
      diplomes: application.diplomes,
      numero_inscription: application.numero_inscription,
      hopital: application.hopital,
      adresse_consultation: application.adresse_consultation
    });

    // Mettre à jour le rôle de l'utilisateur
    await User.update({ role: 'doctor' }, { where: { idUser: application.idUser } });

    // Envoyer un message automatique avec l'id de l'admin comme sender
    await Message.create({
      sender_id: req.user.idUser, // <-- ici on met l'admin qui valide
      receiver_id: application.idUser,
      application_id: application.id,
      subject: 'Validation de votre demande',
      content: 'Votre demande pour devenir médecin a été acceptée. Félicitations !',
      type: 'system',
      // is_read: false // <-- Ajout explicite
    });

    res.json({ message: 'Demande validée et médecin créé' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// PATCH /admin/medecins/:id/refuser
const refuseDoctorApplication = async (req, res) => {
  try {
    const { id } = req.params;
    const { admin_message } = req.body;
    const application = await DoctorApplication.findByPk(id);
    if (!application || application.status !== 'pending') {
      return res.status(404).json({ message: 'Demande non trouvée ou déjà traitée' });
    }
    // Mettre à jour la demande
    application.status = 'refused';
    application.admin_message = admin_message;
    await application.save();

    // Envoyer un message à l'utilisateur
    await Message.create({
      sender_id: req.user.idUser,
      receiver_id: application.idUser,
      application_id: application.id,
      subject: 'Refus de votre demande',
      content: admin_message,
      type: 'admin_reply',
      // is_read: false // <-- Ajout explicite
    });

    res.json({ message: 'Demande refusée et message envoyé' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

module.exports = {
  getAllMedecins,
  acceptDoctorApplication,
  refuseDoctorApplication
};