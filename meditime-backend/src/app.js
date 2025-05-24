const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
const bodyParser = require('body-parser');

const app = express();

// 🔒 Middleware de sécurité
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// 📂 Fichiers statiques (upload d'images, PDF…)
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// 📦 Routes API
const authRoutes = require('./routes/auth.routes');
app.use('/api/auth', authRoutes);
const doctorApplicationRoutes = require('./routes/doctorApplication.routes');
app.use('/api/doctor-application', doctorApplicationRoutes);
const adminRoutes = require('./admins/routes/admin.routes');
app.use('/api/admin', adminRoutes);
const messageRoutes = require('./routes/message.routes');
app.use('/api/messages', messageRoutes);
const doctorSlotRoutes = require('./rdv/routes/doctorSlot.routes');
app.use('/api/rdv/slots', doctorSlotRoutes);
const doctorRoutes = require('./routes/doctor.routes');
app.use('/api/doctor', doctorRoutes);

// 🧱 Middleware global de gestion d'erreurs
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Erreur interne du serveur' });
});

module.exports = app;