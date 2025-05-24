'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('doctor_slots', {
      id: { type: Sequelize.INTEGER, autoIncrement: true, primaryKey: true },
      doctorId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'doctor', key: 'id' },
        onDelete: 'CASCADE'
      },
      day: { type: Sequelize.STRING(20), allowNull: false }, // ex: 'lundi'
      hour: { type: Sequelize.INTEGER, allowNull: false },   // 0-23
      minute: { type: Sequelize.INTEGER, allowNull: false }, // 0-59
      created_at: { type: Sequelize.DATE, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') }
    });
    await queryInterface.addConstraint('doctor_slots', {
      fields: ['doctorId', 'day', 'hour', 'minute'],
      type: 'unique',
      name: 'unique_doctor_slot'
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('doctor_slots');
  }
};