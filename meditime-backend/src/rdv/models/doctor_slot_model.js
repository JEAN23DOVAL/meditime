const { DataTypes } = require('sequelize');
const { sequelize } = require('../../config/db');
const Doctor = require('../../models/doctor_model');

const DoctorSlot = sequelize.define('DoctorSlot', {
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  doctorId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: 'doctor', key: 'id' }
  },
  startDay: { type: DataTypes.STRING(20), allowNull: false },
  startHour: { type: DataTypes.INTEGER, allowNull: false },
  startMinute: { type: DataTypes.INTEGER, allowNull: false },
  endDay: { type: DataTypes.STRING(20), allowNull: false },
  endHour: { type: DataTypes.INTEGER, allowNull: false },
  endMinute: { type: DataTypes.INTEGER, allowNull: false },
  created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  status: { type: DataTypes.ENUM('active', 'expired'), allowNull: false, defaultValue: 'active' }
}, {
  tableName: 'doctor_slots',
  timestamps: false,
  indexes: [
    {
      unique: true,
      fields: ['doctorId', 'startDay', 'startHour', 'startMinute', 'endDay', 'endHour', 'endMinute']
    }
  ]
});

// Association
Doctor.hasMany(DoctorSlot, { foreignKey: 'doctorId', as: 'slots' });
DoctorSlot.belongsTo(Doctor, { foreignKey: 'doctorId', as: 'doctor' });

module.exports = DoctorSlot;