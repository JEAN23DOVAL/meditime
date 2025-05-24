const { Sequelize } = require('sequelize');
const dotenv = require('dotenv');

dotenv.config();

// Initialisation de Sequelize avec les variables d'environnement
const sequelize = new Sequelize(
  process.env.DB_NAME,       // Nom de la base
  process.env.DB_USER,       // Utilisateur
  process.env.DB_PASSWORD,   // Mot de passe
  {
    host: process.env.DB_HOST,
    dialect: 'mysql',
    logging: false, // désactive les logs SQL
    define: {
      freezeTableName: true, // empêche Sequelize de mettre le nom des tables au pluriel
    },
  }
);

// Fonction asynchrone pour tester la connexion
const connectDb = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Connexion à la base de données réussie');
  } catch (error) {
    console.error('❌ Erreur lors de la connexion à la base de données :', error);
    process.exit(1); // Arrête l'application si la connexion échoue
  }
};

// Exportation pour l'utiliser ailleurs
module.exports = {
  sequelize,
  connectDb,
};