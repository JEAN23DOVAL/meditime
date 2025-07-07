const User = require('./user_model');
const DoctorApplication = require('./doctor_application_model');
const Message = require('./message_model');
const DoctorSlot = require('../rdv/models/doctor_slot_model');
const Doctor = require('./doctor_model');
const Consultation = require('./consultation_model');
const ConsultationFile = require('./consultation_file_model'); // Ajoute cette ligne
const Rdv = require('./rdv_model');
const DoctorReview = require('./doctor_review_model'); // Ajoute cette ligne
const Admin = require('./admin_model');
const RdvReminderSent = require('./rdv_reminder_sent_model');
const Payment = require('./payment_model');
const Refund = require('./refund_model');
const Transaction = require('./transaction_model');
const Fee = require('./fee_model');

// User associations
User.hasMany(DoctorApplication, { foreignKey: 'idUser', as: 'applications' });
DoctorApplication.belongsTo(User, { foreignKey: 'idUser', as: 'user' }); // AJOUTE cette ligne
User.hasOne(Doctor, { foreignKey: 'idUser', as: 'DoctorProfile' });
User.hasMany(Message, { foreignKey: 'sender_id', as: 'sentMessages' });
User.hasMany(Message, { foreignKey: 'receiver_id', as: 'receivedMessages' });
User.belongsTo(User, { foreignKey: 'suspendedBy', as: 'suspendedByAdmin' }); // Association ajoutée
User.hasMany(Consultation, { foreignKey: 'patient_id', as: 'consultationsAsPatient' }); // AJOUT
User.hasMany(Consultation, { foreignKey: 'doctor_id', as: 'consultationsAsDoctor' }); // AJOUT
User.hasOne(Admin, { foreignKey: 'userId', as: 'adminProfile' });

// Doctor associations
Doctor.belongsTo(User, { foreignKey: 'idUser', as: 'user' });
Doctor.hasMany(DoctorSlot, { foreignKey: 'doctorId', as: 'slots' });

// DoctorSlot associations
DoctorSlot.belongsTo(Doctor, { foreignKey: 'doctorId', as: 'doctor' });

// Message associations
Message.belongsTo(User, { foreignKey: 'sender_id', as: 'sender' });
Message.belongsTo(User, { foreignKey: 'receiver_id', as: 'receiver' });

// Consultation associations
Consultation.belongsTo(User, { foreignKey: 'patient_id', as: 'consultationPatient' });
Consultation.belongsTo(User, { foreignKey: 'doctor_id', as: 'consultationDoctor' });
Consultation.belongsTo(Doctor, { foreignKey: 'doctor_id', targetKey: 'idUser', as: 'consultationDoctorProfile' });
Consultation.belongsTo(Rdv, { foreignKey: 'rdv_id', as: 'consultationRdv' }); // alias unique

// Consultation <-> ConsultationFile
Consultation.hasMany(ConsultationFile, {
  foreignKey: 'consultation_id',
  as: 'files'
});
ConsultationFile.belongsTo(Consultation, {
  foreignKey: 'consultation_id',
  as: 'consultation'
});

// Rdv associations
Rdv.belongsTo(User, { 
  foreignKey: 'patient_id', 
  as: 'rdvPatient',
  onDelete: 'CASCADE'
});

Rdv.belongsTo(User, { 
  foreignKey: 'doctor_id', 
  as: 'rdvDoctor',
  onDelete: 'CASCADE'
});

Rdv.belongsTo(Doctor, { 
  foreignKey: 'doctor_id', 
  targetKey: 'idUser', 
  as: 'rdvDoctorProfile',
  onDelete: 'CASCADE'
});

Rdv.hasOne(Consultation, { 
  foreignKey: 'rdv_id', 
  as: 'rdvConsultation',
  onDelete: 'CASCADE'
}); 

Rdv.hasMany(RdvReminderSent, { foreignKey: 'rdv_id', as: 'remindersSent' });
RdvReminderSent.belongsTo(Rdv, { foreignKey: 'rdv_id', as: 'rdv' });

// Paiement associations
Payment.belongsTo(Rdv, { foreignKey: 'rdv_id', as: 'rdv' });
Payment.belongsTo(User, { foreignKey: 'patient_id', as: 'paymentPatient' });
Payment.belongsTo(User, { foreignKey: 'doctor_id', as: 'paymentDoctor' });
Payment.hasMany(Refund, { foreignKey: 'payment_id', as: 'refunds' });
Payment.hasMany(Transaction, { foreignKey: 'payment_id', as: 'transactions' });
Payment.hasMany(Fee, { foreignKey: 'payment_id', as: 'fees' });

Refund.belongsTo(Payment, { foreignKey: 'payment_id', as: 'payment' });
Transaction.belongsTo(Payment, { foreignKey: 'payment_id', as: 'payment' });
Transaction.belongsTo(User, { foreignKey: 'doctor_id', as: 'doctor' });
Fee.belongsTo(Payment, { foreignKey: 'payment_id', as: 'payment' });

// User associations inverses
User.hasMany(Rdv, {
  foreignKey: 'patient_id',
  as: 'patientRdvs'
});

User.hasMany(Rdv, {
  foreignKey: 'doctor_id',
  as: 'doctorRdvs'
});

// Doctor associations inverses
Doctor.hasMany(Rdv, {
  foreignKey: 'doctor_id',
  sourceKey: 'idUser',
  as: 'doctorAppointments'
});

Admin.belongsTo(User, { foreignKey: 'userId', as: 'user' });

module.exports = {
  User,
  DoctorApplication,
  Message,
  DoctorSlot,
  Doctor,
  Consultation,
  ConsultationFile, // Ajoute ici aussi
  Rdv,
  DoctorReview,
  Admin,
  RdvReminderSent,
  Payment,
  Refund,
  Transaction,
  Fee,
};