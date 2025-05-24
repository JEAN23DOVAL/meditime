const jwt = require('jsonwebtoken');
const Doctor = require('../models/doctor_model');

// On ne peut pas utiliser async dans un middleware JWT classique,
// donc on exporte une version asynchrone à utiliser dans les contrôleurs
const generateToken = async (user) => {
  let doctorId = null;
  if (user.role === 'doctor') {
    const doctor = await Doctor.findOne({ where: { idUser: user.idUser } });
    if (doctor) doctorId = doctor.id;
  }
  return jwt.sign(
    {
      idUser: user.idUser,
      doctorId, // id du docteur (null si pas médecin)
      lastName: user.lastName,
      firstName: user.firstName,
      email: user.email,
      profilePhoto: user.profilePhoto,
      birthDate:
        user.birthDate && !isNaN(new Date(user.birthDate).getTime())
          ? (typeof user.birthDate === 'string'
              ? user.birthDate
              : user.birthDate.toISOString().split('T')[0])
          : null,
      gender: user.gender,
      phone: user.phone,
      city: user.city,
      role: user.role,
      isVerified: user.isVerified === true || user.isVerified === 1
    },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );
};

module.exports = generateToken;