const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const Fee = sequelize.define('Fee', {
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  payment_id: { type: DataTypes.INTEGER, allowNull: false },
  amount: { type: DataTypes.DECIMAL(12,2), allowNull: false },
  type: { type: DataTypes.ENUM('cinetpay', 'platform'), allowNull: false },
  created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
}, {
  tableName: 'fees',
  timestamps: false
});

module.exports = Fee;
