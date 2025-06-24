const DoctorReview = require('../models/doctor_review_model');
const Doctor = require('../models/doctor_model');
const User = require('../models/user_model'); // Ajoute ceci
const formatPhotoUrl = require('../utils/formatPhotoUrl');
const { emitToUser } = require('../utils/wsEmitter');

async function updateDoctorNote(doctor_id) {
  const reviews = await DoctorReview.findAll({ where: { doctor_id } });
  const avg = reviews.length
    ? reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length
    : 0;
  await Doctor.update({ note: avg }, { where: { id: doctor_id } });
}

exports.createReview = async (req, res) => {
  try {
    const { doctor_id, rating, comment } = req.body;
    const patient_id = req.user.idUser;

    // Vérifie que le patient n'a pas déjà laissé un avis
    const existing = await DoctorReview.findOne({ where: { doctor_id, patient_id } });
    if (existing) return res.status(400).json({ message: "Vous avez déjà laissé un avis." });

    const review = await DoctorReview.create({ doctor_id, patient_id, rating, comment });
    await updateDoctorNote(doctor_id);
    
    // Après création d'un avis
    emitToUser(req.app, doctor_id, 'review_update', { type: 'new', review });

    res.status(201).json(review);
  } catch (error) {
    res.status(500).json({ message: "Erreur serveur", error: error.message });
  }
};

exports.getReviewsByDoctor = async (req, res) => {
  try {
    const { doctor_id } = req.params;
    const reviews = await DoctorReview.findAll({
      where: { doctor_id },
      include: [
        {
          model: Doctor,
          as: 'doctor',
          attributes: ['id', 'idUser', 'specialite', 'hopital', 'note']
        },
        {
          model: User,
          as: 'patient',
          attributes: ['idUser', 'firstName', 'lastName', 'profilePhoto']
        }
      ],
      order: [['created_at', 'DESC']]
    });

    // Adapter la photo de profil du patient
    const reviewsWithPhoto = reviews.map(r => {
      const obj = r.toJSON();
      if (obj.patient && obj.patient.profilePhoto) {
        obj.patient.profilePhoto = formatPhotoUrl(obj.patient.profilePhoto, req);
      }
      return obj;
    });

    res.json(reviewsWithPhoto);
  } catch (error) {
    res.status(500).json({ message: "Erreur serveur", error: error.message });
  }
};