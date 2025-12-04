const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const adminController = require('../controllers/adminController');
const { authenticateToken, requireRole } = require('../middleware/auth');

// Validation pour la création d'utilisateur
const createUserValidation = [
  body('username')
    .trim()
    .isLength({ min: 3, max: 50 })
    .withMessage('Le nom d\'utilisateur doit contenir entre 3 et 50 caractères')
    .matches(/^[a-zA-Z0-9_]+$/)
    .withMessage('Le nom d\'utilisateur ne peut contenir que des lettres, chiffres et underscores'),
  body('email')
    .trim()
    .isEmail()
    .withMessage('Email invalide')
    .normalizeEmail(),
  body('firstName')
    .optional()
    .trim()
    .isLength({ max: 100 })
    .withMessage('Le prénom ne doit pas dépasser 100 caractères'),
  body('lastName')
    .optional()
    .trim()
    .isLength({ max: 100 })
    .withMessage('Le nom ne doit pas dépasser 100 caractères'),
  body('roleNames')
    .optional()
    .isArray()
    .withMessage('Les rôles doivent être un tableau')
];

// Toutes les routes nécessitent une authentification et le rôle admin
router.use(authenticateToken);
router.use(requireRole(['admin']));

// Routes utilisateurs
router.post('/users', createUserValidation, adminController.createUser);
router.get('/users', adminController.getAllUsers);
router.delete('/users/:id', adminController.deleteUser);
router.put('/users/:id/roles', adminController.updateUserRoles);

// Routes rôles
router.get('/roles', adminController.getAllRoles);
router.put('/roles/:id/permissions', adminController.updateRolePermissions);

module.exports = router;
