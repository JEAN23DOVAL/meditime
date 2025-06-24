const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');
const User = require('./user_model');
const Doctor = require('./doctor_model');

const Rdv = sequelize.define('Rdv', {
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  patient_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: 'users', key: 'idUser' }
  },
  doctor_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: 'users', key: 'idUser' }
  },
  specialty: { type: DataTypes.STRING(100), allowNull: false },
  date: { type: DataTypes.DATE, allowNull: false },
  status: {
    type: DataTypes.ENUM(
      'pending',
      'upcoming',
      'completed',
      'cancelled',
      'no_show',
      'doctor_no_show',
      'both_no_show',
      'expired',
      'refused'
    ),
    allowNull: false,
    defaultValue: 'pending'
  },
  motif: { type: DataTypes.STRING(255), allowNull: true },
  duration_minutes: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 60 },
  created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  updated_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  doctor_present: { type: DataTypes.BOOLEAN, allowNull: true, defaultValue: null },
  doctor_presence_reason: { type: DataTypes.STRING(255), allowNull: true },
  patient_present: { type: DataTypes.BOOLEAN, allowNull: true, defaultValue: null },
  patient_presence_reason: { type: DataTypes.STRING(255), allowNull: true }
}, {
  tableName: 'rdv',
  timestamps: false
});

module.exports = Rdv;