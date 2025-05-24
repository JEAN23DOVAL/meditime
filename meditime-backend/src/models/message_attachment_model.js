const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const MessageAttachment = sequelize.define('MessageAttachment', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  message_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'messages',
      key: 'id'
    }
  },
  file_url: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  file_type: {
    type: DataTypes.STRING(50),
    allowNull: true
  },
  uploaded_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'message_attachments',
  timestamps: false
});

module.exports = MessageAttachment;