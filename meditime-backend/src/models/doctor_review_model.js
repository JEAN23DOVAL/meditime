const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const DoctorReview = sequelize.define('doctor_reviews', {
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  doctor_id: { type: DataTypes.INTEGER, allowNull: false },
  patient_id: { type: DataTypes.INTEGER, allowNull: false },
  rating: { type: DataTypes.INTEGER, allowNull: false },
  comment: { type: DataTypes.TEXT, allowNull: true },
  created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  updated_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
}, {
  tableName: 'doctor_reviews',
  timestamps: false
});

const Doctor = require('./doctor_model');
const User = require('./user_model');

DoctorReview.belongsTo(Doctor, { foreignKey: 'doctor_id', as: 'doctor' });
DoctorReview.belongsTo(User, { foreignKey: 'patient_id', as: 'patient' });

module.exports = DoctorReview;