const Doctor = require('../models/doctor_model');
const User = require('../models/user_model');
const sequelize = require('sequelize');

const BASE_URL = process.env.BASE_URL || 'http://10.0.2.2:3000';

// Helper pour générer le lien complet d'un fichier
function fileUrl(folder, filename) {
  return filename ? `${BASE_URL}/uploads/${folder}/${filename}` : null;
}

const getDoctorByUserId = async (req, res) => {
  try {
    const { idUser } = req.params;
    const doctor = await Doctor.findOne({ where: { idUser } });
    if (!doctor) return res.status(404).json({ message: 'Médecin non trouvé' });

    const doctorObj = doctor.toJSON();

    res.json(doctorObj);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

const getDoctorById = async (req, res) => {
  try {
    const { id } = req.params;
    const doctor = await Doctor.findByPk(id);
    if (!doctor) return res.status(404).json({ message: 'Médecin non trouvé' });

    const doctorObj = doctor.toJSON();
    res.json(doctorObj);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Récupérer tous les docteurs, triés par note (null en dernier), AVEC infos user associées
const getAllDoctorsSortedByNote = async (req, res) => {
  try {
    const doctors = await Doctor.findAll({
      include: [{
        model: User,
        as: 'user',
        attributes: ['idUser', 'firstName', 'lastName', 'profilePhoto']
      }],
      order: [
        [sequelize.literal('note IS NULL'), 'ASC'],
        ['note', 'DESC']
      ]
    });
    res.json(doctors);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Récupérer les médecins proches de l'utilisateur connecté (puis les autres)
const getDoctorsByProximity = async (req, res) => {
  try {
    // On récupère la ville de l'utilisateur connecté depuis le token (injecté par authMiddleware)
    const userCity = req.user.city;

    // 1. Médecins de la même ville
    const doctorsSameCity = await Doctor.findAll({
      include: [{
        model: User,
        as: 'user',
        attributes: ['idUser', 'firstName', 'lastName', 'profilePhoto', 'city'],
        where: { city: userCity }
      }],
      order: [
        [sequelize.literal('note IS NULL'), 'ASC'],
        ['note', 'DESC']
      ]
    });

    // 2. Médecins des autres villes
    const doctorsOtherCities = await Doctor.findAll({
      include: [{
        model: User,
        as: 'user',
        attributes: ['idUser', 'firstName', 'lastName', 'profilePhoto', 'city'],
        where: { city: { [sequelize.Op.ne]: userCity } }
      }],
      order: [
        [sequelize.literal('note IS NULL'), 'ASC'],
        ['note', 'DESC']
      ]
    });

    // On concatène les deux listes
    res.json([...doctorsSameCity, ...doctorsOtherCities]);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

module.exports = {
  getDoctorByUserId,
  getDoctorById,
  getAllDoctorsSortedByNote,
  getDoctorsByProximity
};