const { User, DoctorApplication, Rdv, DoctorSlot } = require('../../models');
const Doctor = require('../../models/doctor_model');
const Message = require('../../models/message_model');
const bcrypt = require('bcrypt');
const { emitToUser } = require('../../utils/wsEmitter');
const formatPhotoUrl = require('../../utils/formatPhotoUrl');

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
        cni_front: d.cni_front ? formatPhotoUrl(d.cni_front, req, 'doctor_application') : null,
        cni_back: d.cni_back ? formatPhotoUrl(d.cni_back, req, 'doctor_application') : null,
        certification: d.certification ? formatPhotoUrl(d.certification, req, 'doctor_application') : null,
        cv_pdf: d.cv_pdf ? formatPhotoUrl(d.cv_pdf, req, 'doctor_application') : null,
        casier_judiciaire: d.casier_judiciaire ? formatPhotoUrl(d.casier_judiciaire, req, 'doctor_application') : null,
        user: d.user
          ? {
              ...d.user,
              profilePhoto: formatPhotoUrl(d.user.profilePhoto, req)
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

    // Émettre un événement WebSocket pour informer l'utilisateur
    emitToUser(req.app, application.idUser, 'doctor_validation', { status: 'accepted' });

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

    // Émettre un événement WebSocket pour informer l'utilisateur
    emitToUser(req.app, application.idUser, 'doctor_validation', { status: 'refused' });

    res.json({ message: 'Demande refusée et message envoyé' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Liste tous les médecins validés (avec infos user)
const getAllDoctors = async (req, res) => {
  try {
    const doctors = await Doctor.findAll({
      include: [{
        model: User,
        as: 'user',
        attributes: { exclude: ['password'] }
      }],
      order: [['created_at', 'DESC']]
    });

    // Adapter la photo de profil en URL
    const doctorsWithPhotoUrl = doctors.map(doc => {
      const d = doc.toJSON();
      return {
        ...d,
        user: d.user
          ? {
              ...d.user,
              profilePhoto: formatPhotoUrl(d.user.profilePhoto, req)
            }
          : null
      };
    });

    res.status(200).json(doctorsWithPhotoUrl);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Détail d’un médecin validé
const getDoctorDetails = async (req, res) => {
  try {
    const { id } = req.params; // id = Doctor.id
    const doctor = await Doctor.findByPk(id, {
      include: [{
        model: User,
        as: 'user',
        attributes: { exclude: ['password'] }
      }]
    });
    if (!doctor) return res.status(404).json({ message: 'Médecin non trouvé' });

    // Adapter la photo de profil en URL
    const d = doctor.toJSON();
    d.user = d.user
      ? {
          ...d.user,
          profilePhoto: d.user.profilePhoto
            ? `${BASE_URL}/uploads/photo_profil/${d.user.profilePhoto}`
            : null
        }
      : null;

    res.json(d);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Modifier infos complémentaires d’un médecin (expérience, prix, description)
const updateDoctorInfo = async (req, res) => {
  try {
    const { id } = req.params; // id = Doctor.id
    const { experienceYears, pricePerHour, description } = req.body;
    const doctor = await Doctor.findByPk(id);
    if (!doctor) return res.status(404).json({ message: 'Médecin non trouvé' });

    if (experienceYears !== undefined) doctor.experienceYears = experienceYears;
    if (pricePerHour !== undefined) doctor.pricePerHour = pricePerHour;
    if (description !== undefined) doctor.description = description;
    await doctor.save();

    res.json({ message: 'Infos médecin mises à jour', doctor });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Suspendre/réactiver un médecin (change le statut User)
const toggleDoctorStatus = async (req, res) => {
  try {
    const { id } = req.params; // id = User.idUser
    const user = await User.findByPk(id);
    if (!user || user.role !== 'doctor') return res.status(404).json({ message: 'Médecin non trouvé' });

    user.status = user.status === 'active' ? 'suspended' : 'active';
    await user.save();
    res.json({ message: `Statut médecin changé en ${user.status}` });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Supprimer un médecin (soft delete User et Doctor)
const deleteDoctor = async (req, res) => {
  try {
    const { id } = req.params; // id = Doctor.id
    const doctor = await Doctor.findByPk(id);
    if (!doctor) return res.status(404).json({ message: 'Médecin non trouvé' });

    // Soft delete côté User
    await User.update({ status: 'deleted' }, { where: { idUser: doctor.idUser } });
    // Soft delete côté Doctor
    await doctor.destroy();

    res.json({ message: 'Médecin supprimé (soft delete)' });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Réinitialiser le mot de passe d'un médecin (admin)
const resetDoctorPassword = async (req, res) => {
  try {
    const { idUser } = req.params;
    const user = await User.findByPk(idUser);
    if (!user || user.role !== 'doctor') return res.status(404).json({ message: 'Médecin non trouvé' });

    // Génère un mot de passe temporaire sécurisé
    const tempPassword = Math.random().toString(36).slice(-8) + 'A1!';
    const hash = await bcrypt.hash(tempPassword, 10);

    user.password = hash;
    await user.save();

    res.json({ message: 'Mot de passe réinitialisé', tempPassword });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Statistiques sur les rendez-vous d'un médecin
const getDoctorStats = async (req, res) => {
  try {
    const { idUser } = req.params;

    // Total des rdv par statut
    const rdvStats = await Rdv.findAll({
      where: { doctor_id: idUser },
      attributes: [
        'status',
        [Doctor.sequelize.fn('COUNT', Doctor.sequelize.col('status')), 'count']
      ],
      group: ['status']
    });

    // Nombre total de rdv
    const totalRdvs = await Rdv.count({ where: { doctor_id: idUser } });

    // Nombre de patients différents
    const uniquePatients = await Rdv.count({
      where: { doctor_id: idUser },
      distinct: true,
      col: 'patient_id'
    });

    // Nombre de créneaux actifs
    const activeSlots = await DoctorSlot.count({
      where: { doctorId: Doctor.sequelize.col('Doctor.id'), status: 'active' }
    });

    res.json({
      totalRdvs,
      rdvStats,
      uniquePatients,
      activeSlots
    });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/admin/doctors/:idUser/rdvs
const getDoctorRdvs = async (req, res) => {
  try {
    const { idUser } = req.params;
    const { Rdv, User } = require('../../models');

    // On récupère tous les rdv du médecin, avec infos patient
    const rdvs = await Rdv.findAll({
      where: { doctor_id: idUser },
      include: [
        {
          model: User,
          as: 'rdvPatient',
          attributes: ['idUser', 'firstName', 'lastName', 'profilePhoto', 'email', 'phone']
        }
      ],
      order: [['date', 'DESC']]
    });

    // Adapter la photo de profil patient en URL
    const rdvsWithPatient = rdvs.map(rdv => {
      const r = rdv.toJSON();
      return {
        ...r,
        rdvPatient: r.rdvPatient
          ? {
              ...r.rdvPatient,
              profilePhoto: formatPhotoUrl(r.rdvPatient.profilePhoto, req)
            }
          : null
      };
    });

    res.status(200).json(rdvsWithPatient);
  } catch (error) {
    console.error('Erreur récupération rdvs médecin:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

module.exports = {
  getAllMedecins,
  acceptDoctorApplication,
  refuseDoctorApplication,
  getAllDoctors,
  getDoctorDetails,
  updateDoctorInfo,
  toggleDoctorStatus,
  deleteDoctor,
  resetDoctorPassword,
  getDoctorStats,
  getDoctorRdvs
};