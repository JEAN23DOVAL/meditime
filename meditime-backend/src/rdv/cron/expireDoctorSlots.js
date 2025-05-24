const { Op } = require('sequelize');
const DoctorSlot = require('../models/doctor_slot_model');
const { sequelize } = require('../../config/db'); // Utilise l'instance sequelize de la connexion

async function expireOldSlots() {
  const now = new Date();
  const nowStr = now.toISOString().slice(0, 16).replace('T', ' ');

  await DoctorSlot.update(
    { status: 'expired' },
    {
      where: {
        status: 'active',
        [Op.and]: [
          sequelize.literal(
            `STR_TO_DATE(CONCAT(endDay, ' ', LPAD(endHour,2,'0'), ':', LPAD(endMinute,2,'0')), '%Y-%m-%d %H:%i') < '${nowStr}'`
          )
        ]
      }
    }
  );
  console.log(`[CRON] Mise à jour des créneaux expirés terminée à ${nowStr}`);
}

module.exports = expireOldSlots;