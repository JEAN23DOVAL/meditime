const { body, validationResult } = require('express-validator');

// 🧪 Middleware de validation pour l'inscription utilisateur
const validateRegister = [
  body('lastName').notEmpty().withMessage('Le nom est requis'),
  body('firstName').optional().isString().withMessage('Le prénom doit être une chaîne'),
  body('email')
    .isEmail().withMessage('Email invalide')
    .normalizeEmail(),
  body('password')
    .isLength({ min: 8 }).withMessage('Le mot de passe doit contenir au moins 8 caractères')
    .matches(/[A-Z]/).withMessage('Le mot de passe doit contenir au moins une majuscule')
    .matches(/[0-9]/).withMessage('Le mot de passe doit contenir au moins un chiffre')
    .matches(/[!@#$%^&*]/).withMessage('Le mot de passe doit contenir au moins un caractère spécial'),

  body('phone')
    .optional()
    .isMobilePhone('fr-FR').withMessage('Numéro de téléphone invalide'),

  body('birthDate')
    .optional()
    .isISO8601().toDate().withMessage('Format de date invalide'),

  // 🛑 Vérifie les erreurs
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({
        errors: errors.array().map(err => ({
          champ: err.param,
          message: err.msg
        }))
      });
    }
    next();
  }
];

// 🔐 Middleware de validation pour la connexion utilisateur
const validateLogin = [
  body('email')
    .isEmail().withMessage('Email invalide')
    .normalizeEmail(),
  body('password')
    .notEmpty().withMessage('Le mot de passe est requis'),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({
        errors: errors.array().map(err => ({ champ: err.param, message: err.msg }))
      });
    }
    next();
  }
];

module.exports = {
  validateRegister,
  validateLogin,
};