const Rdv = require('../models/rdv_model');
const User = require('../models/user_model');
const Doctor = require('../models/doctor_model'); // <-- Ajoute cette ligne
const DoctorSlot = require('../rdv/models/doctor_slot_model');
const Consultation = require('../models/consultation_model');
const { Op } = require('sequelize');
const formatPhotoUrl = require('../utils/formatPhotoUrl');
const { sendFcmToUser } = require('../utils/fcm');
const { notifyRdvStatus } = require('../utils/rdvNotification');
const { emitToUser } = require('../utils/wsEmitter'); 
const { calculatePaymentShares } = require('../utils/paymentCalculation');
const Payment = require('../models/payment_model');
const axios = require('axios');

// Créer un rendez-vous
const createRdv = async (req, res) => {
  try {
    const { patient_id, doctor_id, specialty, date, motif, duration_minutes } = req.body;
    if (!patient_id || !doctor_id || !specialty || !date) {
      return res.status(400).json({ message: 'Champs obligatoires manquants' });
    }
    const rdvDate = new Date(date);

    const blockingStatuses = ['pending', 'upcoming'];

    // Vérifie que le patient n'a pas déjà un rdv à cette heure
    const patientConflict = await Rdv.findOne({
      where: {
        patient_id,
        date: rdvDate,
        status: blockingStatuses
      }
    });
    if (patientConflict) {
      return res.status(409).json({ message: "Vous avez déjà un rendez-vous à cette heure." });
    }

    // Vérifie que le médecin n'a pas déjà un rdv à cette heure
    const doctorConflict = await Rdv.findOne({
      where: {
        doctor_id,
        date: rdvDate,
        status: blockingStatuses
      }
    });
    if (doctorConflict) {
      return res.status(409).json({ message: "Ce créneau est déjà réservé chez ce médecin." });
    }

    // Récupère le médecin et son tarif
    const doctor = await Doctor.findOne({ where: { idUser: doctor_id } });
    if (!doctor) return res.status(404).json({ message: 'Médecin introuvable' });
    const price = doctor.pricePerHour;

    // Calcule les parts
    const shares = calculatePaymentShares(price);

    // Crée le RDV en pending (sera confirmé après paiement)
    const rdv = await Rdv.create({
      patient_id,
      doctor_id,
      specialty,
      date,
      motif: motif || null,
      duration_minutes: duration_minutes || 60,
      status: 'pending'
    });

    // Prépare la transaction CinetPay
    const transactionId = `rdv_${rdv.id}_${Date.now()}`;
    const cinetpayPayload = {
      apikey: process.env.CINETPAY_API_KEY,
      site_id: process.env.CINETPAY_SITE_ID,
      transaction_id: transactionId,
      amount: shares.totalToPay,
      currency: 'XAF',
      description: `Paiement RDV Meditime #${rdv.id}`,
      return_url: process.env.CINETPAY_RETURN_URL,
      notify_url: process.env.CINETPAY_NOTIFY_URL,
      customer_name: req.user?.firstName || 'Patient',
      customer_surname: req.user?.lastName || '',
      customer_email: req.user?.email || '',
      customer_phone_number: req.user?.phone || '',
      channels: 'ALL',
    };

    // Appel API CinetPay
    const cinetpayRes = await axios.post('https://api-checkout.cinetpay.com/v2/payment', cinetpayPayload);
    const paymentUrl = cinetpayRes.data.data.payment_url;

    // Enregistre le paiement en BDD
    await Payment.create({
      rdv_id: rdv.id,
      patient_id,
      doctor_id,
      amount: shares.totalToPay,
      platform_fee: shares.platformFee,
      doctor_amount: shares.doctorAmount,
      status: 'pending',
      cinetpay_transaction_id: transactionId,
      payment_method: 'cinetpay'
    });

    // Retourne l'URL de paiement ET le RDV complet au front
    res.status(201).json({
      paymentUrl,
      rdv: rdvToJson(rdv, req)
    });

    // ⏳ Notification en arrière-plan, ne bloque pas la réponse
    notifyRdvStatus(req.app, rdv, null).catch(console.error);
  } catch (error) {
    console.error('Erreur CinetPay:', error.response?.data || error.message);
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};

// Récupérer tous les rendez-vous (optionnel : filtrer par patient ou médecin)
const getAllRdvs = async (req, res) => {
  try {
    const { doctor_id, patient_id, status, date, startDate, endDate, search, sortBy = 'date', order = 'DESC' } = req.query;

    let where = {};
    if (doctor_id) where.doctor_id = parseInt(doctor_id, 10);
    if (patient_id) where.patient_id = parseInt(patient_id, 10);

    // Correction ici : accepte plusieurs statuts séparés par virgule
    if (status) {
      if (status.includes(',')) {
        where.status = { [Op.in]: status.split(',') };
      } else {
        where.status = status;
      }
    }
    if (date) where.date = date;
    if (startDate && endDate) {
      where.date = { [Op.between]: [new Date(startDate), new Date(endDate)] };
    }

    // Inclure TOUS les patients et médecins (pas de where dans include)
    let include = [
      {
        model: User,
        as: 'rdvPatient',
        attributes: ['idUser', 'lastName', 'firstName', 'profilePhoto', 'email', 'city'],
      },
      {
        model: User,
        as: 'rdvDoctor',
        attributes: ['idUser', 'lastName', 'firstName', 'profilePhoto', 'email', 'city'],
      },
      {
        model: Doctor,
        as: 'rdvDoctorProfile',
        attributes: ['id', 'specialite']
      },
      {
        model: Consultation,
        as: 'rdvConsultation',
        required: false,
        attributes: [
          'id', 'rdv_id', 'patient_id', 'diagnostic', 'prescription', 'doctor_notes', 'created_at', 'updated_at'
        ]
      }
    ];

    let rdvs = await Rdv.findAll({
      where,
      include,
      order: [[sortBy, order]]
    });

    // Recherche insensible à la casse sur patient, médecin, spécialité
    if (search && search.trim() !== '') {
      const searchLower = search.toLowerCase();
      rdvs = rdvs.filter(rdv => {
        // Patient
        const patientMatch =
          rdv.rdvPatient &&
          (
            (rdv.rdvPatient.firstName && rdv.rdvPatient.firstName.toLowerCase().includes(searchLower)) ||
            (rdv.rdvPatient.lastName && rdv.rdvPatient.lastName.toLowerCase().includes(searchLower))
          );
        // Médecin
        const doctorMatch =
          rdv.rdvDoctor &&
          (
            (rdv.rdvDoctor.firstName && rdv.rdvDoctor.firstName.toLowerCase().includes(searchLower)) ||
            (rdv.rdvDoctor.lastName && rdv.rdvDoctor.lastName.toLowerCase().includes(searchLower))
          );
        // Spécialité
        const specialiteMatch =
          rdv.rdvDoctorProfile &&
          rdv.rdvDoctorProfile.specialite &&
          rdv.rdvDoctorProfile.specialite.toLowerCase().includes(searchLower);

        // OU logique
        return patientMatch || doctorMatch || specialiteMatch;
      });
    }

    let formatted = rdvs.map(rdv => rdvToJson(rdv, req));
    if (req.excludeConsultation) {
      formatted = formatted.map(rdv => {
        delete rdv.consultation;
        return rdv;
      });
    }
    return res.json(formatted);
  } catch (error) {
    console.error('Error in getAllRdvs:', error);
    return res.status(500).json({
      message: 'Erreur serveur',
      error: process.env.NODE_ENV === 'development' ? error.toString() : undefined
    });
  }
};

// Récupérer un rendez-vous par id
const getRdvById = async (req, res) => {
  try {
    const { id } = req.params;
    const rdv = await Rdv.findByPk(id, {
      include: [
        { 
          model: User, 
          as: 'rdvPatient', 
          attributes: ['idUser', 'lastName', 'firstName', 'profilePhoto', 'email', 'city'] // <-- ajoute ici
        },
        { 
          model: User, 
          as: 'rdvDoctor', 
          attributes: ['idUser', 'lastName', 'firstName', 'profilePhoto', 'email', 'city'] // <-- ajoute ici
        },
        { model: Doctor, as: 'rdvDoctorProfile', attributes: ['id', 'specialite'] },
        { 
          model: Consultation, 
          as: 'rdvConsultation', 
          required: false,
          attributes: [
            'id', 
            'rdv_id',
            'patient_id',
            'diagnostic',
            'prescription',
            'doctor_notes',
            'created_at',
            'updated_at'
          ]
        }
      ]
    });
    if (!rdv) return res.status(404).json({ message: 'Rendez-vous non trouvé' });
    res.json(rdvToJson(rdv, req));
  } catch (error) {
    console.error('Erreur dans getRdvById:', error);
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};

// Modifier un rendez-vous
const updateRdv = async (req, res) => {
  try {
    const { id } = req.params;
    const { specialty, date, motif, duration_minutes } = req.body;
    const rdv = await Rdv.findByPk(id);
    if (!rdv) return res.status(404).json({ message: 'Rendez-vous non trouvé' });

    // Si la date change, vérifier les conflits
    if (date && date !== rdv.date.toISOString()) {
      const rdvDate = new Date(date);
      const blockingStatuses = ['pending', 'upcoming'];

      // Conflit patient
      const patientConflict = await Rdv.findOne({
        where: {
          patient_id: rdv.patient_id,
          date: rdvDate,
          status: blockingStatuses,
          id: { [Op.ne]: rdv.id }
        }
      });
      if (patientConflict) {
        return res.status(409).json({ message: "Vous avez déjà un rendez-vous à cette heure." });
      }

      // Conflit médecin
      const doctorConflict = await Rdv.findOne({
        where: {
          doctor_id: rdv.doctor_id,
          date: rdvDate,
          status: blockingStatuses,
          id: { [Op.ne]: rdv.id }
        }
      });
      if (doctorConflict) {
        return res.status(409).json({ message: "Ce créneau est déjà réservé chez ce médecin." });
      }

      rdv.date = rdvDate;
    }

    if (specialty !== undefined) rdv.specialty = specialty;
    if (motif !== undefined) rdv.motif = motif;
    if (duration_minutes !== undefined) rdv.duration_minutes = duration_minutes;

    // Remettre le statut à pending
    rdv.status = 'pending';
    rdv.updated_at = new Date();
    await rdv.save();
    res.json(rdvToJson(rdv, req));
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

// Médecin accepte un RDV (statut: upcoming)
const acceptRdv = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.idUser;
    const userRole = req.user.role;
    const rdv = await Rdv.findByPk(id);
    if (!rdv) return res.status(404).json({ message: 'Rendez-vous non trouvé' });
    if (userRole !== 'doctor' || rdv.doctor_id !== userId) {
      return res.status(403).json({ message: 'Accès interdit' });
    }
    if (rdv.status !== 'pending') {
      return res.status(400).json({ message: 'Seuls les rendez-vous en attente peuvent être validés' });
    }
    rdv.status = 'upcoming';
    rdv.updated_at = new Date();
    await rdv.save();

    res.json({ message: 'Rendez-vous accepté', rdv: rdvToJson(rdv, req) });

    // Notification en arrière-plan, ne bloque pas la réponse
    notifyRdvStatus(req.app, rdv, 'pending').catch(console.error);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Médecin refuse un RDV (statut: refused)
const refuseRdv = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.idUser;
    const userRole = req.user.role;
    const rdv = await Rdv.findByPk(id);
    if (!rdv) return res.status(404).json({ message: 'Rendez-vous non trouvé' });
    if (userRole !== 'doctor' || rdv.doctor_id !== userId) {
      return res.status(403).json({ message: 'Accès interdit' });
    }
    if (rdv.status !== 'pending') {
      return res.status(400).json({ message: 'Seuls les rendez-vous en attente peuvent être refusés' });
    }
    rdv.status = 'refused';
    rdv.updated_at = new Date();
    await rdv.save();

    res.json({ message: 'Rendez-vous refusé', rdv: rdvToJson(rdv, req) });

    // Notification en arrière-plan, ne bloque pas la réponse
    notifyRdvStatus(req.app, rdv, 'pending').catch(console.error);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Annuler un rendez-vous (accessible au patient ou au médecin)
const cancelRdv = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.idUser;
    const rdv = await Rdv.findByPk(id);
    if (!rdv) return res.status(404).json({ message: 'Rendez-vous non trouvé' });

    // Autorise si l'utilisateur est le patient OU le médecin du RDV
    if (rdv.patient_id !== userId && rdv.doctor_id !== userId) {
      return res.status(403).json({ message: 'Accès interdit' });
    }

    rdv.status = 'cancelled';
    rdv.updated_at = new Date();
    await rdv.save();

    res.json({ message: 'Rendez-vous annulé', rdv: rdvToJson(rdv, req) });

    // Notification en arrière-plan, ne bloque pas la réponse
    notifyRdvStatus(req.app, rdv, rdv.status, req.user.idUser).catch(console.error);

    // Cherche le paiement lié
    const payment = await Payment.findOne({ where: { rdv_id: rdv.id, status: 'success' } });
    if (payment) {
      // Appelle l'API CinetPay pour rembourser (si tu veux automatiser)
      try {
        await axios.post('https://api-checkout.cinetpay.com/v2/refund', {
          apikey: process.env.CINETPAY_API_KEY,
          site_id: process.env.CINETPAY_SITE_ID,
          transaction_id: payment.cinetpay_transaction_id,
          amount: payment.amount,
          reason: 'RDV annulé ou refusé'
        });
        payment.status = 'refunded';
        payment.refunded_at = new Date();
        await payment.save();
      } catch (e) {
        // Log l'erreur mais ne bloque pas l'annulation/refus
        console.error('Erreur remboursement CinetPay:', e.message);
      }
    }
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Ajoute cette méthode dans ton controller
const hasRdvBetweenPatientAndDoctor = async (req, res) => {
  try {
    const { patient_id, doctor_id } = req.query;
    if (!patient_id || !doctor_id) {
      return res.status(400).json({ message: 'patient_id et doctor_id requis' });
    }
    const allowedStatuses = ['completed', 'upcoming', 'no_show', 'doctor_no_show', 'cancelled', 'both_no_show'];
    const rdv = await Rdv.findOne({
      where: {
        patient_id,
        doctor_id,
        status: { [Op.in]: allowedStatuses }
      }
    });
    res.json({ exists: !!rdv });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};

// Dans rdv.controller.js
function rdvToJson(rdv, req) {
  const obj = rdv.toJSON ? rdv.toJSON() : rdv;
  return {
    id: obj.id,
    patient_id: obj.patient_id,
    doctor_id: obj.doctor_id,
    doctor_table_id: obj.rdvDoctorProfile?.id || null,
    specialty: obj.specialty,
    date: obj.date,
    status: obj.status,
    motif: obj.motif || null,
    duration_minutes: obj.duration_minutes,
    created_at: obj.created_at,
    updated_at: obj.updated_at,
    doctor_present: obj.doctor_present, // <-- AJOUTE ICI
    doctor_presence_reason: obj.doctor_presence_reason, // <-- AJOUTE ICI
    patient_present: obj.patient_present, // <-- AJOUTE ICI
    patient_presence_reason: obj.patient_presence_reason, // <-- AJOUTE ICI
    patient: obj.rdvPatient ? {
      idUser: obj.rdvPatient.idUser,
      lastName: obj.rdvPatient.lastName,
      firstName: obj.rdvPatient.firstName,
      profilePhoto: formatPhotoUrl(obj.rdvPatient.profilePhoto, req),
      email: obj.rdvPatient.email,
      city: obj.rdvPatient.city
    } : null,
    doctor: obj.rdvDoctor ? {
      idUser: obj.rdvDoctor.idUser,
      lastName: obj.rdvDoctor.lastName,
      firstName: obj.rdvDoctor.firstName,
      profilePhoto: formatPhotoUrl(obj.rdvDoctor.profilePhoto, req),
      specialite: obj.rdvDoctorProfile?.specialite,
      email: obj.rdvDoctor.email,
      city: obj.rdvDoctor.city
    } : null,
  };
}

// PATCH /rdv/:id/mark-presence
const markPresence = async (req, res) => {
  try {
    const { id } = req.params;
    const { present, reason } = req.body;
    const userId = req.user.idUser;
    const userRole = req.user.role;
    const rdv = await Rdv.findByPk(id);
    if (!rdv) return res.status(404).json({ message: 'RDV non trouvé' });

    const now = new Date();
    const rdvStart = new Date(rdv.date);
    const rdvEnd = new Date(rdvStart.getTime() + rdv.duration_minutes * 60000);
    const limit = new Date(rdvEnd.getTime() + 24 * 60 * 60 * 1000);

    if (now > limit) {
      return res.status(403).json({ message: 'La période de validation de présence est expirée.' });
    }

    let prevStatus = rdv.status;

    // Marque la présence
    if (userRole === 'doctor' && rdv.doctor_id === userId) {
      rdv.doctor_present = present;
      rdv.doctor_presence_reason = reason;
    } else if (userRole === 'patient' && rdv.patient_id === userId) {
      rdv.patient_present = present;
      rdv.patient_presence_reason = reason;
    } else {
      return res.status(403).json({ message: 'Accès interdit' });
    }

    // Logique stricte de statut
    // 1. Pendant le RDV (avant rdvEnd) : statut reste "upcoming"
    // 2. À la fin du RDV (rdvEnd) ou après : statut évolue selon les présences
    if (now < rdvEnd) {
      // Ne change pas le statut, reste "upcoming"
    } else {
      // Après la fin du RDV, applique la logique métier
      if (rdv.doctor_present === true && rdv.patient_present === true) {
        rdv.status = 'completed';
      } else if (rdv.doctor_present === true && rdv.patient_present !== true) {
        rdv.status = 'no_show';
      } else if (rdv.patient_present === true && rdv.doctor_present !== true) {
        rdv.status = 'doctor_no_show';
      } else if (
        (rdv.doctor_present !== true && rdv.patient_present !== true)
      ) {
        rdv.status = 'both_no_show';
      }
    }

    rdv.updated_at = new Date();
    await rdv.save();

    notifyRdvStatus(req.app, rdv, prevStatus, userId).catch(console.error);

    res.json({ success: true, status: rdv.status });
  } catch (e) {
    res.status(500).json({ message: 'Erreur serveur', error: e.message });
  }
};

module.exports = {
  createRdv,
  getAllRdvs,
  getRdvById,
  updateRdv,
  deleteRdv,
  getAvailableSlots,
  acceptRdv,
  refuseRdv,
  cancelRdv,
  hasRdvBetweenPatientAndDoctor,
  markPresence,
  rdvToJson // <-- ajoute ceci
};