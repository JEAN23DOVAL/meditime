'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('doctor_reviews', {
      id: { type: Sequelize.INTEGER, autoIncrement: true, primaryKey: true },
      doctor_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'doctor', key: 'id' },
        onDelete: 'CASCADE'
      },
      patient_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'users', key: 'idUser' },
        onDelete: 'CASCADE'
      },
      rating: { type: Sequelize.INTEGER, allowNull: false },
      comment: { type: Sequelize.TEXT, allowNull: true },
      created_at: { type: Sequelize.DATE, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') },
      updated_at: { type: Sequelize.DATE, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') }
    });
    // Ajout colonne note si besoin
    await queryInterface.addColumn('doctor', 'note', {
      type: Sequelize.FLOAT,
      allowNull: false,
      defaultValue: 0
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('doctor_reviews');
    await queryInterface.removeColumn('doctor', 'note');
  }
};