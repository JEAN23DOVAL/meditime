const { sendFcmToUser } = require('./fcm');
const { emitToUser } = require('./wsEmitter');
const Rdv = require('../models/rdv_model');
const User = require('../models/user_model');
const Doctor = require('../models/doctor_model');

async function notifyRdvStatus(app, rdv, prevStatus, actionUserId = null) {
  // Récupère les infos patient et médecin (avec genre, prénom, nom)
  const patient = await User.findByPk(rdv.patient_id);
  const doctor = await User.findByPk(rdv.doctor_id);
  const doctorProfile = await Doctor.findOne({ where: { idUser: rdv.doctor_id } });

  // Utilitaires pour personnaliser selon le genre
  const getDoctorLabel = () => {
    if (!doctor) return 'le médecin';
    if (doctor.gender === 'female') return `la Dr ${doctor.lastName}`;
    return `le Dr ${doctor.lastName}`;
  };
  const getPatientLabel = () => {
    if (!patient) return 'le patient';
    if (patient.gender === 'female') return `Mme ${patient.lastName}`;
    return `M. ${patient.lastName}`;
  };

  // Date/heure du RDV
  const dateStr = new Date(rdv.date).toLocaleString('fr-FR', {
    hour: '2-digit', minute: '2-digit', day: '2-digit', month: '2-digit', year: 'numeric'
  });
  const specialite = doctorProfile?.specialite ? ` (${doctorProfile.specialite})` : '';

  // Messages personnalisés
  const messages = {
    pending: {
      doctor: {
        title: 'Nouveau RDV',
        body: `Vous avez une nouvelle demande de rendez-vous de ${patient?.firstName || 'un patient'} pour le ${dateStr}.`,
      }
    },
    upcoming: {
      patient: {
        title: 'RDV accepté',
        body: `Votre rendez-vous avec ${getDoctorLabel()}${specialite} a été accepté pour le ${dateStr}.`,
      }
    },
    refused: {
      patient: {
        title: 'RDV refusé',
        body: `Votre rendez-vous avec ${getDoctorLabel()} a été refusé.`,
      }
    },
    expired: {
      patient: {
        title: 'RDV expiré',
        body: `Votre demande de rendez-vous avec ${getDoctorLabel()} a expiré.`,
      },
      doctor: {
        title: 'RDV expiré',
        body: `Vous n'avez pas traité la demande de rendez-vous de ${getPatientLabel()} à temps.`,
      }
    },
    completed: {
      patient: {
        title: 'RDV terminé',
        body: `Votre rendez-vous avec ${getDoctorLabel()}${specialite} est terminé. Merci de votre présence.`,
      },
      doctor: {
        title: 'RDV terminé',
        body: `Votre rendez-vous avec ${getPatientLabel()} est terminé. Merci de votre présence.`,
      }
    },
    cancelled: {
      patient: {
        title: 'RDV annulé',
        body: `Votre rendez-vous avec ${getDoctorLabel()} a été annulé.`,
      },
      doctor: {
        title: 'RDV annulé',
        body: `${getPatientLabel()} a annulé le rendez-vous.`,
      }
    },
    no_show: {
      patient: {
        title: 'Présence à valider',
        body: `Le rendez-vous avec ${getDoctorLabel()} est terminé. Merci de valider votre présence.`,
      },
      doctor: {
        title: 'Patient absent',
        body: `Le patient ne s'est pas présenté au rendez-vous.`,
      }
    },
    doctor_no_show: {
      patient: {
        title: 'Médecin absent',
        body: `Le médecin ne s'est pas présenté à votre rendez-vous.`,
      },
      doctor: {
        title: 'Présence à valider',
        body: `Le rendez-vous avec ${getPatientLabel()} est terminé. Merci de valider votre présence.`,
      }
    },
    both_no_show: {
      patient: {
        title: 'Aucun présent au RDV',
        body: `Le rendez-vous avec ${getDoctorLabel()} est terminé. Merci de signaler votre présence.`,
      },
      doctor: {
        title: 'Aucun présent au RDV',
        body: `Le rendez-vous avec ${getPatientLabel()} est terminé. Merci de signaler votre présence.`,
      }
    }
  };

  // Envoi notifications et WebSocket selon le statut
  switch (rdv.status) {
    case 'pending':
      emitToUser(app, rdv.doctor_id, 'rdv_update', { type: rdv.status, rdv });
      sendFcmToUser(rdv.doctor_id, messages.pending.doctor, { type: 'rdv', rdvId: String(rdv.id), status: 'pending' }).catch(console.error);
      break;
    case 'upcoming':
      emitToUser(app, rdv.patient_id, 'rdv_update', { type: rdv.status, rdv });
      sendFcmToUser(rdv.patient_id, messages.upcoming.patient, { type: 'rdv', rdvId: String(rdv.id), status: 'upcoming' }).catch(console.error);
      break;
    case 'refused':
      emitToUser(app, rdv.patient_id, 'rdv_update', { type: rdv.status, rdv });
      sendFcmToUser(rdv.patient_id, messages.refused.patient, { type: 'rdv', rdvId: String(rdv.id), status: 'refused' }).catch(console.error);
      break;
    case 'expired':
      emitToUser(app, rdv.patient_id, 'rdv_update', { type: rdv.status, rdv });
      emitToUser(app, rdv.doctor_id, 'rdv_update', { type: rdv.status, rdv });
      sendFcmToUser(rdv.patient_id, messages.expired.patient, { type: 'rdv', rdvId: String(rdv.id), status: 'expired' }).catch(console.error);
      sendFcmToUser(rdv.doctor_id, messages.expired.doctor, { type: 'rdv', rdvId: String(rdv.id), status: 'expired' }).catch(console.error);
      break;
    case 'completed':
      emitToUser(app, rdv.patient_id, 'rdv_update', { type: rdv.status, rdv });
      emitToUser(app, rdv.doctor_id, 'rdv_update', { type: rdv.status, rdv });
      sendFcmToUser(rdv.patient_id, messages.completed.patient, { type: 'rdv', rdvId: String(rdv.id), status: 'completed' }).catch(console.error);
      sendFcmToUser(rdv.doctor_id, messages.completed.doctor, { type: 'rdv', rdvId: String(rdv.id), status: 'completed' }).catch(console.error);
      break;
    case 'cancelled':
      if (actionUserId === rdv.patient_id) {
        emitToUser(app, rdv.doctor_id, 'rdv_update', { type: rdv.status, rdv });
        sendFcmToUser(rdv.doctor_id, messages.cancelled.doctor, { type: 'rdv', rdvId: String(rdv.id), status: 'cancelled' }).catch(console.error);
      } else {
        emitToUser(app, rdv.patient_id, 'rdv_update', { type: rdv.status, rdv });
        sendFcmToUser(rdv.patient_id, messages.cancelled.patient, { type: 'rdv', rdvId: String(rdv.id), status: 'cancelled' }).catch(console.error);
      }
      break;
    case 'no_show':
      emitToUser(app, rdv.patient_id, 'rdv_update', { type: rdv.status, rdv });
      emitToUser(app, rdv.doctor_id, 'rdv_update', { type: rdv.status, rdv });
      sendFcmToUser(rdv.patient_id, messages.no_show.patient, { type: 'rdv', rdvId: String(rdv.id), status: 'no_show' }).catch(console.error);
      sendFcmToUser(rdv.doctor_id, messages.no_show.doctor, { type: 'rdv', rdvId: String(rdv.id), status: 'no_show' }).catch(console.error);
      break;
    case 'doctor_no_show':
      emitToUser(app, rdv.patient_id, 'rdv_update', { type: rdv.status, rdv });
      emitToUser(app, rdv.doctor_id, 'rdv_update', { type: rdv.status, rdv });
      sendFcmToUser(rdv.patient_id, messages.doctor_no_show.patient, { type: 'rdv', rdvId: String(rdv.id), status: 'doctor_no_show' }).catch(console.error);
      sendFcmToUser(rdv.doctor_id, messages.doctor_no_show.doctor, { type: 'rdv', rdvId: String(rdv.id), status: 'doctor_no_show' }).catch(console.error);
      break;
    case 'both_no_show':
      emitToUser(app, rdv.patient_id, 'rdv_update', { type: rdv.status, rdv });
      emitToUser(app, rdv.doctor_id, 'rdv_update', { type: rdv.status, rdv });
      sendFcmToUser(rdv.patient_id, messages.both_no_show.patient, { type: 'rdv', rdvId: String(rdv.id), status: 'both_no_show' }).catch(console.error);
      sendFcmToUser(rdv.doctor_id, messages.both_no_show.doctor, { type: 'rdv', rdvId: String(rdv.id), status: 'both_no_show' }).catch(console.error);
      break;
    default:
      break;
  }
}

module.exports = { notifyRdvStatus };