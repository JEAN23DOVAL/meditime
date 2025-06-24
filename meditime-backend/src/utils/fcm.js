const admin = require('firebase-admin');
const User = require('../models/user_model');

// Initialise Firebase Admin si ce n'est pas déjà fait
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(require('../../serviceAccountKey.json')),
  });
}

exports.sendFcmToUser = async (userId, notification, data = {}) => {
  const user = await User.findByPk(userId);
  if (!user || !user.fcm_token) return;

  // Convertir toutes les valeurs de data en string
  const stringData = {};
  for (const key in data) {
    if (Object.prototype.hasOwnProperty.call(data, key)) {
      stringData[key] = String(data[key]);
    }
  }

  const message = {
    token: user.fcm_token,
    notification, // { title, body }
    data: stringData, // <-- toujours des strings
    android: { priority: 'high' },
    apns: { payload: { aps: { sound: 'default' } } }
  };

  try {
    await admin.messaging().send(message);
  } catch (err) {
    console.error('Erreur envoi FCM:', err);
  }
};