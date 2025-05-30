const Rdv = require('../models/rdv_model');
const User = require('../models/user_model');
const Doctor = require('../models/doctor_model'); // <-- Ajoute cette ligne
const DoctorSlot = require('../rdv/models/doctor_slot_model');
const { Op } = require('sequelize');

// Créer un rendez-vous
const createRdv = async (req, res) => {
  try {
    const { patient_id, doctor_id, specialty, date, motif, duration_minutes } = req.body;
    if (!patient_id || !doctor_id || !specialty || !date) {
      return res.status(400).json({ message: 'Champs obligatoires manquants' });
    }
    const rdvDate = new Date(date);

    // Vérifie que le patient n'a pas déjà un rdv à cette heure
    const patientConflict = await Rdv.findOne({
      where: {
        patient_id,
        date: rdvDate
      }
    });
    if (patientConflict) {
      return res.status(409).json({ message: "Vous avez déjà un rendez-vous à cette heure." });
    }

    // Vérifie que le médecin n'a pas déjà un rdv à cette heure
    const doctorConflict = await Rdv.findOne({
      where: {
        doctor_id,
        date: rdvDate
      }
    });
    if (doctorConflict) {
      return res.status(409).json({ message: "Ce créneau est déjà réservé chez ce médecin." });
    }

    const rdv = await Rdv.create({
      patient_id,
      doctor_id,
      specialty,
      date,
      motif: motif || null,
      duration_minutes: duration_minutes || 60,
      status: 'pending'
    });

    // Recharge le RDV avec les associations patient et doctor
    const rdvWithUsers = await Rdv.findByPk(rdv.id, {
      include: [
        { model: User, as: 'patient', attributes: ['idUser', 'lastName', 'firstName', 'profilePhoto'] },
        { model: User, as: 'doctor', attributes: ['idUser', 'lastName', 'firstName', 'profilePhoto'] },
        { model: Doctor, as: 'doctorInfo', attributes: ['id'] }
      ]
    });

    res.status(201).json(rdvToJson(rdvWithUsers));
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};

// Récupérer tous les rendez-vous (optionnel : filtrer par patient ou médecin)
const getAllRdvs = async (req, res) => {
  try {
    const userId = req.user.idUser;
    const userRole = req.user.role;
    const { doctor_id, patient_id } = req.query;
    let where = {};

    if (userRole === 'patient') {
      // Un patient ne voit que ses propres rdv
      where.patient_id = userId;
      if (doctor_id) where.doctor_id = doctor_id;
    } else if (userRole === 'doctor') {
      // Si on demande explicitement patient_id = userId, alors il veut voir ses RDV en tant que patient
      if (patient_id && parseInt(patient_id) === userId) {
        where.patient_id = userId;
        if (doctor_id) where.doctor_id = doctor_id;
      } else {
        // Sinon, il veut voir ses RDV en tant que médecin
        where.doctor_id = userId;
        if (patient_id) where.patient_id = patient_id;
      }
    } else {
      // Pour un admin ou autre, tu peux adapter ici (ex: voir tous les rdv)
      return res.status(403).json({ message: "Accès non autorisé" });
    }

    const rdvs = await Rdv.findAll({
      where,
      include: [
        { model: User, as: 'patient', attributes: ['idUser', 'lastName', 'firstName', 'profilePhoto'] },
        { model: User, as: 'doctor', attributes: ['idUser', 'lastName', 'firstName', 'profilePhoto'] },
        { model: Doctor, as: 'doctorInfo', attributes: ['id'] }
      ],
      order: [['date', 'DESC']]
    });
    res.json(rdvs.map(rdvToJson));
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Récupérer un rendez-vous par id
const getRdvById = async (req, res) => {
  try {
    const { id } = req.params;
    const rdv = await Rdv.findByPk(id, {
      include: [
        { model: User, as: 'patient', attributes: ['idUser', 'lastName', 'firstName', 'profilePhoto'] },
        { model: User, as: 'doctor', attributes: ['idUser', 'lastName', 'firstName', 'profilePhoto'] },
        { model: Doctor, as: 'doctorInfo', attributes: ['id'] } // <-- Ajoute cette ligne
      ]
    });
    if (!rdv) return res.status(404).json({ message: 'Rendez-vous non trouvé' });
    res.json(rdvToJson(rdv));
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Modifier un rendez-vous
const updateRdv = async (req, res) => {
  try {
    const { id } = req.params;
    const { specialty, date, status, motif, duration_minutes } = req.body;
    const rdv = await Rdv.findByPk(id);
    if (!rdv) return res.status(404).json({ message: 'Rendez-vous non trouvé' });

    if (specialty !== undefined) rdv.specialty = specialty;
    if (date !== undefined) rdv.date = date;
    if (status !== undefined) rdv.status = status;
    if (motif !== undefined) rdv.motif = motif;
    if (duration_minutes !== undefined) rdv.duration_minutes = duration_minutes;

    rdv.updated_at = new Date();
    await rdv.save();
    res.json(rdvToJson(rdv));
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Supprimer un rendez-vous
const deleteRdv = async (req, res) => {
  try {
    const { id } = req.params;
    const rdv = await Rdv.findByPk(id);
    if (!rdv) return res.status(404).json({ message: 'Rendez-vous non trouvé' });
    await rdv.destroy();
    res.json({ message: 'Rendez-vous supprimé' });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/rdv/available-slots?doctor_id=...&date=YYYY-MM-DD
const getAvailableSlots = async (req, res) => {
  try {
    const doctor_id = parseInt(req.query.doctor_id, 10);
    const patient_id = req.user.idUser;

    if (!doctor_id) {
      return res.status(400).json({ message: 'doctor_id requis' });
    }

    // 1. Récupérer tous les slots actifs du médecin
    const slots = await DoctorSlot.findAll({
      where: {
        doctorId: doctor_id,
        status: 'active'
      }
    });

    if (slots.length === 0) {
      return res.json({ available: [], message: "Aucun créneau disponible pour ce médecin." });
    }

    // 2. Générer tous les créneaux d’1h pour chaque slot (sur plusieurs jours)
    let allHours = [];
    for (const slot of slots) {
      let start = new Date(`${slot.startDay}T${String(slot.startHour).padStart(2, '0')}:${String(slot.startMinute).padStart(2, '0')}:00`);
      let end = new Date(`${slot.endDay}T${String(slot.endHour).padStart(2, '0')}:${String(slot.endMinute).padStart(2, '0')}:00`);
      while (start < end) {
        const nextHour = new Date(start.getTime() + 60 * 60 * 1000);
        if (nextHour > end) break;
        allHours.push({
          start: new Date(start),
          end: new Date(nextHour)
        });
        start = nextHour;
      }
    }

    // 3. Récupérer tous les rdv du médecin ET du patient sur toutes ces périodes (statuts bloquants)
    const minDate = allHours.length > 0 ? allHours[0].start : null;
    const maxDate = allHours.length > 0 ? allHours[allHours.length - 1].end : null;
    const blockingStatuses = ['pending', 'upcoming'];
    const rdvs = await Rdv.findAll({
      where: {
        [Op.or]: [
          { doctor_id },
          { patient_id }
        ],
        status: blockingStatuses,
        date: {
          [Op.between]: [minDate, maxDate]
        }
      }
    });

    // 4. Exclure les créneaux où il y a déjà un rdv pour le médecin ou le patient à cette heure
    const takenTimes = rdvs.map(rdv => rdv.date.getTime());
    const available = allHours.map(slot => ({
      start: slot.start,
      end: slot.end,
      isTaken: takenTimes.includes(slot.start.getTime())
    }));

    res.json({ available, message: null });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};

function rdvToJson(rdv) {
  const obj = rdv.toJSON ? rdv.toJSON() : rdv;
  return {
    id: obj.id,
    patient_id: obj.patient_id,
    doctor_id: obj.doctor_id,
    doctor_table_id: obj.doctorInfo?.id ?? null, // <-- Ajoute ce champ
    specialty: obj.specialty,
    date: obj.date,
    status: obj.status,
    motif: obj.motif ?? null,
    duration_minutes: obj.duration_minutes,
    created_at: obj.created_at,
    updated_at: obj.updated_at,
    patient: obj.patient ?? null,
    doctor: obj.doctor ?? null
  };
}

module.exports = { createRdv, getAllRdvs, getRdvById, updateRdv, deleteRdv, getAvailableSlots };