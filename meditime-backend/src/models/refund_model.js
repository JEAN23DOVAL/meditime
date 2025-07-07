const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const Refund = sequelize.define('Refund', {
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  payment_id: { type: DataTypes.INTEGER, allowNull: false },
  amount: { type: DataTypes.DECIMAL(12,2), allowNull: false },
  status: { type: DataTypes.ENUM('pending', 'success', 'failed'), allowNull: false, defaultValue: 'pending' },
  reason: { type: DataTypes.STRING(255) },
  created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
}, {
  tableName: 'refunds',
  timestamps: false
});

module.exports = Refund;
