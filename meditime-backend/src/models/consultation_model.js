const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const Consultation = sequelize.define('Consultation', {
  id: { 
    type: DataTypes.INTEGER, 
    autoIncrement: true, 
    primaryKey: true 
  },
  rdv_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: 'rdv', key: 'id' }
  },
  patient_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: 'users', key: 'idUser' }
  },
  doctor_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: 'doctor', key: 'id' }
  },
  diagnostic: { 
    type: DataTypes.TEXT, 
    allowNull: false 
  },
  prescription: { 
    type: DataTypes.TEXT, 
    allowNull: false 
  },
  doctor_notes: { 
    type: DataTypes.TEXT, 
    allowNull: true 
  }
}, {
  tableName: 'consultations',
  timestamps: true,
  underscored: true
});

module.exports = Consultation;