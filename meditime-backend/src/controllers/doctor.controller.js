const Doctor = require('../models/doctor_model');
const User = require('../models/user_model');
const sequelize = require('sequelize');
const { searchDoctors } = require('./search.controller');
const formatPhotoUrl = require('../utils/formatPhotoUrl');

// const BASE_URL = process.env.BASE_URL || 'http://10.0.2.2:3000';
const BASE_URL = process.env.BASE_URL || 'http://192.168.128.24:3000';

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
    if (doctorObj.user) {
      doctorObj.user.profilePhoto = formatPhotoUrl(doctorObj.user.profilePhoto, req);
    }
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
    const doctorsWithPhoto = doctors.map(doc => {
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
    res.json(doctorsWithPhoto);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Récupérer les médecins proches de l'utilisateur connecté (puis les autres)
const getDoctorsByProximity = async (req, res) => {
  try {
    // On récupère la ville de l'utilisateur connecté depuis le token (injecté par authMiddleware)
    const userCity = req.user.city;

    // 1. Médecins de la même ville (insensible à la casse)
    const doctorsSameCity = await Doctor.findAll({
      include: [{
        model: User,
        as: 'user',
        attributes: ['idUser', 'firstName', 'lastName', 'profilePhoto', 'city'],
        where: sequelize.where(
          sequelize.fn('LOWER', sequelize.col('user.city')),
          sequelize.fn('LOWER', userCity || '')
        )
      }],
      order: [
        [sequelize.literal('note IS NULL'), 'ASC'],
        ['note', 'DESC']
      ]
    });

    // 2. Médecins des autres villes (insensible à la casse)
    const doctorsOtherCities = await Doctor.findAll({
      include: [{
        model: User,
        as: 'user',
        attributes: ['idUser', 'firstName', 'lastName', 'profilePhoto', 'city'],
        where: {
          [sequelize.Op.and]: [
            sequelize.where(
              sequelize.fn('LOWER', sequelize.col('user.city')),
              { [sequelize.Op.ne]: sequelize.fn('LOWER', userCity || '') }
            )
          ]
        }
      }],
      order: [
        [sequelize.literal('note IS NULL'), 'ASC'],
        ['note', 'DESC']
      ]
    });

    // On concatène les deux listes
    const allDoctors = [...doctorsSameCity, ...doctorsOtherCities];

    // Adapter la photo de profil en URL
    const doctorsWithPhoto = allDoctors.map(doc => {
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

    res.json(doctorsWithPhoto);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

const getDoctorByIdUser = async (req, res) => {
  try {
    const { idUser } = req.params;
    const doctor = await Doctor.findOne({
      where: { idUser },
      include: [{
        model: User,
        as: 'user',
        attributes: ['idUser', 'firstName', 'lastName', 'profilePhoto', 'city']
      }]
    });
    if (!doctor) return res.status(404).json({ message: 'Médecin non trouvé' });
    const d = doctor.toJSON();
    d.user = d.user
      ? {
          ...d.user,
          profilePhoto: formatPhotoUrl(d.user.profilePhoto, req)
        }
      : null;
    res.json(d);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

const updateDoctorExtraInfo = async (req, res) => {
  try {
    const { id } = req.params; // id du doctor
    const { experienceYears, pricePerHour, description } = req.body;

    const doctor = await Doctor.findByPk(id);
    if (!doctor) return res.status(404).json({ message: 'Médecin non trouvé' });

    // Validation simple côté back
    if (
      experienceYears !== undefined && (isNaN(experienceYears) || experienceYears < 0) ||
      pricePerHour !== undefined && (isNaN(pricePerHour) || pricePerHour < 0)
    ) {
      return res.status(400).json({ message: 'Valeurs numériques invalides (>= 0 requis)' });
    }

    if (experienceYears !== undefined) doctor.experienceYears = experienceYears;
    if (pricePerHour !== undefined) doctor.pricePerHour = pricePerHour;
    if (description !== undefined) doctor.description = description;

    await doctor.save();

    res.json({ message: 'Informations du médecin mises à jour', doctor });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Recherche avancée de médecins (GET /api/doctor)
const searchDoctorsController = async (req, res) => {
  try {
    const {
      search,
      available,
      minPrice,
      maxPrice,
      gender,
      sortBy,
      order
    } = req.query;

    const doctors = await searchDoctors({
      search,
      available,
      minPrice,
      maxPrice,
      gender,
      sortBy,
      order
    });

    // Adapter la photo de profil en URL
    const BASE_URL = process.env.BASE_URL || 'http://10.0.2.2:3000';
    const doctorsWithPhoto = doctors.map(doc => {
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

    res.json(doctorsWithPhoto);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

module.exports = {
  getDoctorByUserId,
  getDoctorById,
  getAllDoctorsSortedByNote,
  getDoctorsByProximity,
  getDoctorByIdUser,
  updateDoctorExtraInfo,
  searchDoctorsController
};