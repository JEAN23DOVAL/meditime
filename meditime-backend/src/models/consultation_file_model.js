const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const ConsultationFile = sequelize.define('ConsultationFile', {
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  consultation_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: 'consultations', key: 'id' }
  },
  file_path: { type: DataTypes.STRING, allowNull: false }, // <-- corrige ici
  file_type: { type: DataTypes.STRING, allowNull: false }
}, {
  tableName: 'consultation_files',
  timestamps: true,
  underscored: true
});

module.exports = ConsultationFile;