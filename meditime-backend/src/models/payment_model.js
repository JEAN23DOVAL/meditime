const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const Payment = sequelize.define('Payment', {
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  rdv_id: { type: DataTypes.INTEGER, allowNull: true }, // <-- allowNull: true
  patient_id: { type: DataTypes.INTEGER, allowNull: false },
  doctor_id: { type: DataTypes.INTEGER, allowNull: false },
  amount: { type: DataTypes.DECIMAL(12,2), allowNull: false },
  platform_fee: { type: DataTypes.DECIMAL(12,2), allowNull: false },
  doctor_amount: { type: DataTypes.DECIMAL(12,2), allowNull: false },
  status: { type: DataTypes.ENUM('pending', 'success', 'failed', 'refunded', 'cancelled'), allowNull: false, defaultValue: 'pending' },
  cinetpay_transaction_id: { type: DataTypes.STRING(100) },
  payment_method: { type: DataTypes.STRING(50) },
  paid_at: { type: DataTypes.DATE },
  refunded_at: { type: DataTypes.DATE },
  created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  updated_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  specialty: { type: DataTypes.STRING(100), allowNull: true },
  date: { type: DataTypes.DATE, allowNull: true },
  motif: { type: DataTypes.STRING(255), allowNull: true },
  duration_minutes: { type: DataTypes.INTEGER, allowNull: true }
}, {
  tableName: 'payments',
  timestamps: false
});

module.exports = Payment;
