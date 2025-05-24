'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('doctor', {
      id: { type: Sequelize.INTEGER, autoIncrement: true, primaryKey: true },
      idUser: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'users', key: 'idUser' }
      },
      specialite: { type: Sequelize.STRING(100), allowNull: false },
      diplomes: { type: Sequelize.TEXT, allowNull: false },
      numero_inscription: { type: Sequelize.STRING(100), allowNull: false },
      hopital: { type: Sequelize.STRING(150), allowNull: false },
      adresse_consultation: { type: Sequelize.STRING(255), allowNull: false },
      created_at: { type: Sequelize.DATE, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('doctor');
  }
};