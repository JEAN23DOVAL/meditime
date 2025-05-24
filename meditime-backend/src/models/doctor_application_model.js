const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const DoctorApplication = sequelize.define('DoctorApplication', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  idUser: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'idUser'
    }
  },
  specialite: {
    type: DataTypes.STRING(100),
    allowNull: false
  },
  diplomes: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  numero_inscription: {
    type: DataTypes.STRING(100),
    allowNull: false
  },
  hopital: {
    type: DataTypes.STRING(150),
    allowNull: false
  },
  adresse_consultation: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  cni_front: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  cni_back: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  certification: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  cv_pdf: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  casier_judiciaire: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  status: {
    type: DataTypes.ENUM('pending', 'accepted', 'refused'),
    allowNull: false,
    defaultValue: 'pending'
  },
  admin_message: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  },
  updated_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'doctor_applications',
  timestamps: false
});

module.exports = DoctorApplication;