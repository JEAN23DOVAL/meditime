const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');
const User = require('./user_model');

const Doctor = sequelize.define('Doctor', {
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  idUser: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: 'users', key: 'idUser' }
  },
  specialite: { type: DataTypes.STRING(100), allowNull: false },
  diplomes: { type: DataTypes.TEXT, allowNull: false },
  numero_inscription: { type: DataTypes.STRING(100), allowNull: false },
  hopital: { type: DataTypes.STRING(150), allowNull: false },
  adresse_consultation: { type: DataTypes.STRING(255), allowNull: false },
  note: { type: DataTypes.FLOAT, allowNull: false, defaultValue: 0 },
  created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  patientsExamined: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 0 },
  experienceYears: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 0 },
  pricePerHour: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 0 },
  description: { type: DataTypes.TEXT, allowNull: true }
}, {
  tableName: 'doctor',
  timestamps: false
});

Doctor.belongsTo(User, { foreignKey: 'idUser', as: 'user' });

module.exports = Doctor;