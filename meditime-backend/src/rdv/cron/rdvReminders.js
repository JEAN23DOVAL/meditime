const { Op } = require('sequelize');
const { Rdv, User, Doctor, RdvReminderSent } = require('../../models');
const { sendFcmToUser } = require('../../utils/fcm');

const REMINDERS = [
  { label: '1d', ms: 24 * 60 * 60 * 1000, getTitle: (r) => 'Rendez-vous dans 1 jour' },
  { label: '1h', ms: 60 * 60 * 1000, getTitle: (r) => 'Rendez-vous dans 1 heure' },
  { label: '30m', ms: 30 * 60 * 1000, getTitle: (r) => 'Rendez-vous dans 30 minutes' },
  { label: '5m', ms: 5 * 60 * 1000, getTitle: (r) => 'Rendez-vous dans 5 minutes' },
  { label: 'start', ms: 0, getTitle: (r) => 'Votre rendez-vous commence' }
];

async function sendRdvReminders() {
  const now = new Date();
  const windowMs = 5 * 60 * 1000;
  const windowEnd = new Date(now.getTime() + windowMs);

  // On prend tous les RDV upcoming dans la fenêtre utile
  const in25h = new Date(now.getTime() + 25 * 60 * 60 * 1000);
  const rdvs = await Rdv.findAll({
    where: {
      status: 'upcoming',
      date: { [Op.between]: [now, in25h] }
    },
    include: [
      { model: User, as: 'rdvPatient', attributes: ['idUser', 'firstName', 'lastName', 'gender'] },
      { model: User, as: 'rdvDoctor', attributes: ['idUser', 'firstName', 'lastName', 'gender'] },
      { model: Doctor, as: 'rdvDoctorProfile', attributes: ['specialite'] }
    ]
  });

  for (const rdv of rdvs) {
    const rdvDate = new Date(rdv.date);
    for (const reminder of REMINDERS) {
      const target = new Date(rdvDate.getTime() - reminder.ms);
      if (target >= now && target < windowEnd) {
        // Vérifie si déjà envoyé
        const alreadySent = await RdvReminderSent.findOne({
          where: { rdv_id: rdv.id, reminder_label: reminder.label }
        });
        if (alreadySent) continue;

        // Personnalisation
        const patientName = `${rdv.rdvPatient?.firstName || ''} ${rdv.rdvPatient?.lastName || ''}`.trim();
        const doctorName = `${rdv.rdvDoctor?.firstName || ''} ${rdv.rdvDoctor?.lastName || ''}`.trim();
        const dateStr = rdvDate.toLocaleString('fr-FR', { hour: '2-digit', minute: '2-digit', day: '2-digit', month: '2-digit', year: 'numeric' });
        const specialite = rdv.rdvDoctorProfile?.specialite || '';

        // Patient
        await sendFcmToUser(rdv.patient_id, {
          title: reminder.getTitle(rdv),
          body: `Vous avez rendez-vous avec Dr. ${doctorName} (${specialite}) le ${dateStr}.`
        }, {
          type: 'rdv_reminder',
          rdvId: String(rdv.id),
          when: reminder.label
        });

        // Médecin
        await sendFcmToUser(rdv.doctor_id, {
          title: reminder.getTitle(rdv),
          body: `Vous avez rendez-vous avec ${patientName} le ${dateStr}.`
        }, {
          type: 'rdv_reminder',
          rdvId: String(rdv.id),
          when: reminder.label
        });

        // Trace l'envoi
        await RdvReminderSent.create({ rdv_id: rdv.id, reminder_label: reminder.label, sent_at: new Date() });
      }
    }
  }
}

module.exports = sendRdvReminders;