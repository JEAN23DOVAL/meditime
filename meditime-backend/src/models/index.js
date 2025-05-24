const User = require('./user_model');
const DoctorApplication = require('./doctor_application_model');
const Message = require('./message_model');
const DoctorSlot = require('../rdv/models/doctor_slot_model');

User.hasMany(DoctorApplication, { foreignKey: 'idUser', as: 'applications' });
DoctorApplication.belongsTo(User, { foreignKey: 'idUser', as: 'user' });

Message.belongsTo(User, { foreignKey: 'sender_id', as: 'sender' });
Message.belongsTo(User, { foreignKey: 'receiver_id', as: 'receiver' });

module.exports = { User, DoctorApplication, Message, DoctorSlot };