const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db'); // <-- Correction ici

const RdvReminderSent = sequelize.define('RdvReminderSent', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  rdv_id: { type: DataTypes.INTEGER, allowNull: false },
  reminder_label: { type: DataTypes.STRING, allowNull: false },
  sent_at: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW }
}, {
  tableName: 'rdv_reminder_sent',
  timestamps: false
});

module.exports = RdvReminderSent;