'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('consultations', {
      id: {
        type: Sequelize.INTEGER,
        autoIncrement: true,
        primaryKey: true
      },
      patient_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'users', key: 'idUser' }
      },
      doctor_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'doctor', key: 'id' } // <-- correction ici
      },
      rdv_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'rdv', key: 'id' }
      },
      diagnostic: {
        type: Sequelize.TEXT,
        allowNull: false
      },
      prescription: {
        type: Sequelize.TEXT,
        allowNull: false
      },
      doctor_notes: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      prescription_pdf_url: {
        type: Sequelize.STRING(255),
        allowNull: true
      },
      created_at: {
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      updated_at: {
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      }
    });

    // Index pour optimiser les recherches
    await queryInterface.addIndex('consultations', ['patient_id']);
    await queryInterface.addIndex('consultations', ['doctor_id']);
    await queryInterface.addIndex('consultations', ['rdv_id']);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('consultations');
  }
};