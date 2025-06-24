const { body, validationResult } = require('express-validator');

const validateConsultation = [
  body('rdv_id')
    .toInt() // Ajoute ceci
    .isInt()
    .withMessage('ID de rendez-vous invalide'),
  
  body('patient_id')
    .toInt() // Ajoute ceci
    .isInt()
    .withMessage('ID du patient invalide'),
  
  body('diagnostic')
    .notEmpty()
    .withMessage('Diagnostic requis')
    .trim()
    .isLength({ min: 10 })
    .withMessage('Le diagnostic doit contenir au moins 10 caractères'),
  
  body('prescription')
    .notEmpty()
    .withMessage('Prescription requise')
    .trim()
    .isLength({ min: 5 })
    .withMessage('La prescription doit contenir au moins 5 caractères'),
  
  body('doctor_notes')
    .optional()
    .trim()
    .isLength({ min: 5 })
    .withMessage('Les notes doivent contenir au moins 5 caractères'),

  // Middleware de validation
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({ 
        message: 'Erreur de validation',
        errors: errors.array() 
      });
    }
    next();
  }
];

module.exports = validateConsultation;