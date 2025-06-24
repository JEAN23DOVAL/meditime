const { Op } = require('sequelize');
const sequelize = require('sequelize');
const DoctorSlot = require('../models/doctor_slot_model');
const Doctor = require('../../models/doctor_model');
const { emitToRoom, emitToUser } = require('../../utils/wsEmitter');

const createSlot = async (req, res) => {
  try {
    const { doctorId, startDay, startHour, startMinute, endDay, endHour, endMinute } = req.body;

    // Vérifier que le médecin existe
    const doctor = await Doctor.findByPk(doctorId);
    if (!doctor) return res.status(404).json({ message: 'Médecin introuvable' });

    // Calculer les dates/heures complètes pour la comparaison
    const start = new Date(`${startDay}T${String(startHour).padStart(2, '0')}:${String(startMinute).padStart(2, '0')}:00`);
    const end = new Date(`${endDay}T${String(endHour).padStart(2, '0')}:${String(endMinute).padStart(2, '0')}:00`);

    // Vérifier que la période ne chevauche aucun créneau existant
    const overlapping = await DoctorSlot.findOne({
      where: {
        doctorId,
        // Chevauchement: (start < existingEnd) && (end > existingStart)
        [Op.and]: [
          sequelize.literal(`STR_TO_DATE(CONCAT(startDay, ' ', LPAD(startHour,2,'0'), ':', LPAD(startMinute,2,'0')), '%Y-%m-%d %H:%i') < '${end.toISOString().slice(0, 19).replace('T', ' ')}'`),
          sequelize.literal(`STR_TO_DATE(CONCAT(endDay, ' ', LPAD(endHour,2,'0'), ':', LPAD(endMinute,2,'0')), '%Y-%m-%d %H:%i') > '${start.toISOString().slice(0, 19).replace('T', ' ')}'`)
        ]
      }
    });

    if (overlapping) {
      return res.status(409).json({ message: 'Ce créneau chevauche un créneau existant.' });
    }

    // Vérifier l'unicité stricte (même période exactement)
    const exists = await DoctorSlot.findOne({
      where: { doctorId, startDay, startHour, startMinute, endDay, endHour, endMinute }
    });
    if (exists) return res.status(409).json({ message: 'Ce créneau existe déjà' });

    const slot = await DoctorSlot.create({ doctorId, startDay, startHour, startMinute, endDay, endHour, endMinute });
    // Recharge le slot pour avoir tous les champs (dont status)
    const slotWithStatus = await DoctorSlot.findByPk(slot.id);
    res.status(201).json(slotWithStatus);

    // Après création/modification/suppression d'un slot
    emitToRoom(req.app, `doctor_slots_${doctorId}`, 'slot_update', { type: 'create', slot: slotWithStatus });
    // Pour chaque patient concerné (si tu veux notifier individuellement)
    emitToUser(req.app, patientId, 'slot_update', { type: 'update', slot });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};

// (Optionnel) Récupérer tous les créneaux d’un médecin
const getSlotsByDoctor = async (req, res) => {
  try {
    const { doctorId } = req.params;
    const slots = await DoctorSlot.findAll({ where: { doctorId } });
    res.json(slots);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

const getActiveSlotsByDoctor = async (req, res) => {
  try {
    const { doctorId } = req.params;
    // On ne récupère que les créneaux actifs
    const slots = await DoctorSlot.findAll({
      where: {
        doctorId,
        status: 'active'
      },
      order: [
        ['startDay', 'ASC'],
        ['startHour', 'ASC'],
        ['startMinute', 'ASC']
      ]
    });
    res.json(slots);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Modifier un créneau
const updateSlot = async (req, res) => {
  try {
    const { id } = req.params;
    const { startDay, startHour, startMinute, endDay, endHour, endMinute } = req.body;
    const slot = await DoctorSlot.findByPk(id);
    if (!slot) return res.status(404).json({ message: 'Créneau introuvable' });

    // Vérifier qu'il n'y a pas de chevauchement avec un autre créneau actif du même médecin
    const start = new Date(`${startDay}T${String(startHour).padStart(2, '0')}:${String(startMinute).padStart(2, '0')}:00`);
    const end = new Date(`${endDay}T${String(endHour).padStart(2, '0')}:${String(endMinute).padStart(2, '0')}:00`);
    const overlapping = await DoctorSlot.findOne({
      where: {
        doctorId: slot.doctorId,
        id: { [Op.ne]: id },
        [Op.and]: [
          sequelize.literal(`STR_TO_DATE(CONCAT(startDay, ' ', LPAD(startHour,2,'0'), ':', LPAD(startMinute,2,'0')), '%Y-%m-%d %H:%i') < '${end.toISOString().slice(0, 19).replace('T', ' ')}'`),
          sequelize.literal(`STR_TO_DATE(CONCAT(endDay, ' ', LPAD(endHour,2,'0'), ':', LPAD(endMinute,2,'0')), '%Y-%m-%d %H:%i') > '${start.toISOString().slice(0, 19).replace('T', ' ')}'`)
        ]
      }
    });
    if (overlapping) {
      return res.status(409).json({ message: 'Ce créneau chevauche un créneau existant.' });
    }

    slot.startDay = startDay;
    slot.startHour = startHour;
    slot.startMinute = startMinute;
    slot.endDay = endDay;
    slot.endHour = endHour;
    slot.endMinute = endMinute;
    await slot.save();
    res.json(slot);

    // Après création/modification/suppression d'un slot
    emitToRoom(req.app, `doctor_slots_${slot.doctorId}`, 'slot_update', { type: 'update', slot });
    // Pour chaque patient concerné
    emitToUser(req.app, patientId, 'slot_update', { type: 'update', slot });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};

// Supprimer un créneau
const deleteSlot = async (req, res) => {
  try {
    const { id } = req.params;
    const slot = await DoctorSlot.findByPk(id);
    if (!slot) return res.status(404).json({ message: 'Créneau introuvable' });
    await slot.destroy();
    res.json({ message: 'Créneau supprimé avec succès' });

    // Après création/modification/suppression d'un slot
    emitToRoom(req.app, `doctor_slots_${slot.doctorId}`, 'slot_update', { type: 'delete', slot });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};

module.exports = { createSlot, getSlotsByDoctor, getActiveSlotsByDoctor, updateSlot, deleteSlot };