const { Op } = require('sequelize');
const Rdv = require('../../models/rdv_model');

async function expireOldRdvs() {
  const now = new Date();
  // Passe les rdv confirmés ou upcoming à completed si la date est passée
  await Rdv.update(
    { status: 'completed' },
    {
      where: {
        status: 'upcoming',
        date: { [Op.lt]: now }
      }
    }
  );
  // Passe les rdv pending à expired si la date est passée
  await Rdv.update(
    { status: 'expired' },
    {
      where: {
        status: 'pending',
        date: { [Op.lt]: now }
      }
    }
  );
  console.log(`[CRON] Mise à jour des rdv terminée à ${now.toISOString()}`);
}

module.exports = expireOldRdvs;