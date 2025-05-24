// server.js
const dotenv = require('dotenv');
const { connectDb } = require('./src/config/db');
const app = require('./src/app');
const bcrypt = require('bcrypt');
const cron = require('node-cron');
const expireOldSlots = require('./src/rdv/cron/expireDoctorSlots');

dotenv.config();

const startServer = async () => {
  try {
    await connectDb();
    console.log('✅ Connexion à la base de données réussie');

    // Lancer le cron toutes les 5 minutes
    cron.schedule('*/5 * * * *', async () => {
      await expireOldSlots();
    });

    const PORT = process.env.PORT || 3000;
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 Serveur démarré sur le port ${PORT}`);

      // Exemple de hash de mot de passe admin (exécuter une seule fois si besoin)
      // bcrypt.hash('MotDePasseAdmin1#', 10).then(hash => console.log(hash));
    });
  } catch (error) {
    console.error('❌ Erreur lors du démarrage du serveur :', error);
    process.exit(1);
  }
};

startServer();