// server.js
const dotenv = require('dotenv');
const { connectDb } = require('./src/config/db');
// Important : importer les modèles avant l'app
require('./src/models/index');
const http = require('http');
const app = require('./src/app');
const server = http.createServer(app);
const { Server } = require('socket.io');
const io = new Server(server, { cors: { origin: '*' } });
const bcrypt = require('bcrypt');
const cron = require('node-cron');
const expireOldSlots = require('./src/rdv/cron/expireDoctorSlots');
const expirePresenceRdvs = require('./src/rdv/cron/expirePresenceRdv');
const expireOldRdvs = require('./src/rdv/cron/expireRdv');
const sendRdvReminders = require('./src/rdv/cron/rdvReminders');

dotenv.config();

// Rendre io accessible partout
app.set('io', io);

// (Optionnel) Authentification WebSocket
io.use((socket, next) => {
  const token = socket.handshake.auth?.token;
  if (!token) return next(new Error('No token'));
  try {
    const decoded = require('./src/utils/verifyToken')(token);
    socket.user = decoded;
    next();
  } catch (e) {
    next(new Error('Invalid token'));
  }
});

// Gestion des rooms
io.on('connection', (socket) => {
  if (socket.user?.idUser) socket.join(`user_${socket.user.idUser}`);
  if (socket.user?.role === 'admin') socket.join('admins');
  // Ajoute ici d'autres rooms si besoin (ex: par conversation)
  console.log(`User ${socket.user?.idUser} connecté via WebSocket`);
});

const startServer = async () => {
  try {
    await connectDb();
    console.log('✅ Connexion à la base de données réussie');

    // Lancer le cron toutes les 5 minutes
    cron.schedule('*/5 * * * *', async () => {
      await expireOldSlots();
      await expirePresenceRdvs(app); // Passe app pour notifyRdvStatus
      await expireOldRdvs(app);      // Passe app pour notifyRdvStatus
      await sendRdvReminders(); // <--- c'est bon ici
    });

    const PORT = process.env.PORT || 3000;
    server.listen(PORT, '0.0.0.0', () => {
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