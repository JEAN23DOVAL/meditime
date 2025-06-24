const { Op } = require('sequelize');
const Rdv = require('../../models/rdv_model');
const { notifyRdvStatus } = require('../../utils/rdvNotification');

async function expireOldRdvs(app) {
  const now = new Date();

  // RDV "upcoming" dont la date est passée
  const expiredRdvs = await Rdv.findAll({
    where: {
      status: 'upcoming',
      date: { [Op.lt]: now }
    }
  });

  for (const rdv of expiredRdvs) {
    let prevStatus = rdv.status;
    // Applique la logique métier de fin de RDV
    if (rdv.doctor_present === true && rdv.patient_present === true) {
      rdv.status = 'completed';
    } else if (rdv.doctor_present === true && rdv.patient_present !== true) {
      rdv.status = 'no_show';
    } else if (rdv.patient_present === true && rdv.doctor_present !== true) {
      rdv.status = 'doctor_no_show';
    }
    // (Si aucun n'a validé, expirePresenceRdv.js s'en charge)
    if (rdv.status !== prevStatus) {
      rdv.updated_at = new Date();
      await rdv.save();
      await notifyRdvStatus(app, rdv, prevStatus);
    }
  }

  // Passe les rdv pending à expired si la date est passée
  const pendingRdvs = await Rdv.findAll({
    where: {
      status: 'pending',
      date: { [Op.lt]: now }
    }
  });
  for (const rdv of pendingRdvs) {
    let prevStatus = rdv.status;
    rdv.status = 'expired';
    rdv.updated_at = new Date();
    await rdv.save();
    await notifyRdvStatus(app, rdv, prevStatus);
  }

  console.log(`[CRON] Mise à jour des rdv terminée à ${now.toISOString()}`);
}

module.exports = expireOldRdvs;