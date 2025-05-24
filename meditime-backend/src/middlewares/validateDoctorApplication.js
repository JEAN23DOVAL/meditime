const { body, validationResult } = require('express-validator');

const validateDoctorApplication = [
  body('idUser').isInt().withMessage('idUser requis'),
  body('specialite').notEmpty().withMessage('Spécialité requise'),
  body('diplomes').notEmpty().withMessage('Diplômes requis'),
  body('numeroInscription').notEmpty().withMessage('Numéro inscription requis'),
  body('hopital').notEmpty().withMessage('Hôpital requis'),
  body('adresseConsultation').notEmpty().withMessage('Adresse consultation requise'),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({ errors: errors.array() });
    }
    next();
  }
];

module.exports = validateDoctorApplication;