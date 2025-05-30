const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db'); // <-- correction ici
const User = require('./user_model');
const Doctor = require('./doctor_model'); // Ajoute cette ligne

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
    type: DataTypes.ENUM('pending', 'upcoming', 'completed', 'cancelled', 'no_show', 'doctor_no_show', 'expired'),
    allowNull: false,
    defaultValue: 'pending'
  },
  motif: { type: DataTypes.STRING(255), allowNull: true },
  duration_minutes: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 60 },
  created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  updated_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
}, {
  tableName: 'rdv',
  timestamps: false
});

// Associations (optionnelles pour inclure infos patient/médecin)
Rdv.belongsTo(User, { foreignKey: 'patient_id', as: 'patient' });
Rdv.belongsTo(User, { foreignKey: 'doctor_id', as: 'doctor' });
Rdv.belongsTo(Doctor, { foreignKey: 'doctor_id', targetKey: 'idUser', as: 'doctorInfo' }); // Ajoute cette ligne

module.exports = Rdv;