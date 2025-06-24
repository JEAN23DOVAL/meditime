const { Op } = require('sequelize');
const Rdv = require('../../models/rdv_model');
const { notifyRdvStatus } = require('../../utils/rdvNotification');

async function expirePresenceRdvs(app) {
  const now = new Date();

  // RDV terminés, statut upcoming, aucune présence validée
  const justEnded = await Rdv.findAll({
    where: {
      status: 'upcoming',
      doctor_present: null,
      patient_present: null,
      date: { [Op.lt]: now }
    }
  });

  for (const rdv of justEnded) {
    // Respecte la logique métier : statut both_no_show si aucun n'a validé
    rdv.status = 'both_no_show';
    rdv.updated_at = new Date();
    await rdv.save();
    await notifyRdvStatus(app, rdv, 'upcoming');
  }
}

module.exports = expirePresenceRdvs;