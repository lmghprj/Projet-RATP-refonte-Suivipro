const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const passwordController = require('../controllers/passwordController');
const { authenticateToken } = require('../middleware/auth');

// Validation pour le changement de mot de passe
const changePasswordValidation = [
  body('currentPassword')
    .notEmpty()
    .withMessage('Le mot de passe actuel est requis'),
  body('newPassword')
    .isLength({ min: 8 })
    .withMessage('Le nouveau mot de passe doit contenir au moins 8 caractères')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .withMessage('Le nouveau mot de passe doit contenir au moins une majuscule, une minuscule, un chiffre et un caractère spécial')
];

// Toutes les routes nécessitent une authentification
router.use(authenticateToken);

// Route de changement de mot de passe
router.post('/change-password', changePasswordValidation, passwordController.changePassword);

module.exports = router;
