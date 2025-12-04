const { User, Role } = require('../models');
const { validationResult } = require('express-validator');
const { sendWelcomeEmail } = require('../services/emailService');
const crypto = require('crypto');
const { Op } = require('sequelize');

/**
 * Génère un mot de passe temporaire aléatoire sécurisé
 */
const generateTemporaryPassword = () => {
  // Génère un mot de passe de 12 caractères : lettres, chiffres et caractères spéciaux
  const length = 12;
  const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*';
  let password = '';

  const randomBytes = crypto.randomBytes(length);
  for (let i = 0; i < length; i++) {
    password += charset[randomBytes[i] % charset.length];
  }

  // S'assurer qu'il contient au moins 1 majuscule, 1 minuscule, 1 chiffre et 1 caractère spécial
  return password + 'Aa1!';
};

/**
 * Créer un utilisateur (admin uniquement)
 */
const createUser = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { username, email, firstName, lastName, roleNames } = req.body;

    // Vérifier si l'utilisateur existe déjà
    const existingUser = await User.findOne({
      where: { [Op.or]: [{ username }, { email }] }
    });

    if (existingUser) {
      return res.status(409).json({
        error: 'Utilisateur existant',
        message: 'Ce nom d\'utilisateur ou cet email est déjà utilisé'
      });
    }

    // Générer un mot de passe temporaire
    const temporaryPassword = generateTemporaryPassword();

    // Créer l'utilisateur avec mustChangePassword à true
    const user = await User.create({
      username,
      email,
      password: temporaryPassword,
      firstName,
      lastName,
      mustChangePassword: true,
      createdBy: req.user.id // ID de l'admin qui crée l'utilisateur
    });

    // Attribuer les rôles
    if (roleNames && roleNames.length > 0) {
      const roles = await Role.findAll({
        where: { name: roleNames }
      });
      await user.setRoles(roles);
    } else {
      // Par défaut, attribuer le rôle "user"
      const userRole = await Role.findOne({ where: { name: 'user' } });
      if (userRole) {
        await user.addRole(userRole);
      }
    }

    // Recharger l'utilisateur avec ses rôles
    await user.reload({
      include: [{
        model: Role,
        as: 'roles',
        attributes: ['id', 'name', 'description']
      }]
    });

    // Envoyer l'email de bienvenue avec les identifiants
    const emailResult = await sendWelcomeEmail(user, temporaryPassword);

    if (!emailResult.success) {
      console.warn('Email non envoyé:', emailResult.error);
    }

    // Préparer la réponse
    const response = {
      message: 'Utilisateur créé avec succès',
      user: user.toJSON(),
      emailSent: emailResult.success
    };

    // Si l'email n'a pas été envoyé, inclure les identifiants dans la réponse
    // pour que l'admin puisse les communiquer manuellement
    if (!emailResult.success) {
      response.temporaryCredentials = {
        username: user.username,
        password: temporaryPassword,
        warning: 'L\'email n\'a pas pu être envoyé. Veuillez communiquer ces identifiants manuellement à l\'utilisateur.'
      };
    }

    res.status(201).json(response);
  } catch (error) {
    console.error('Erreur lors de la création de l\'utilisateur:', error);
    res.status(500).json({
      error: 'Erreur serveur',
      message: 'Une erreur est survenue lors de la création de l\'utilisateur'
    });
  }
};

/**
 * Lister tous les utilisateurs (admin uniquement)
 */
const getAllUsers = async (req, res) => {
  try {
    const users = await User.findAll({
      include: [{
        model: Role,
        as: 'roles',
        attributes: ['id', 'name', 'description']
      }],
      order: [['createdAt', 'DESC']]
    });

    res.json({
      users: users.map(u => u.toJSON())
    });
  } catch (error) {
    console.error('Erreur lors de la récupération des utilisateurs:', error);
    res.status(500).json({
      error: 'Erreur serveur',
      message: 'Une erreur est survenue lors de la récupération des utilisateurs'
    });
  }
};

/**
 * Supprimer un utilisateur (admin uniquement)
 */
const deleteUser = async (req, res) => {
  try {
    const { id } = req.params;

    // Ne pas permettre de supprimer son propre compte
    if (id === req.user.id) {
      return res.status(403).json({
        error: 'Action interdite',
        message: 'Vous ne pouvez pas supprimer votre propre compte'
      });
    }

    const user = await User.findByPk(id);
    if (!user) {
      return res.status(404).json({
        error: 'Utilisateur non trouvé',
        message: 'L\'utilisateur demandé n\'existe pas'
      });
    }

    await user.destroy();

    res.json({
      message: 'Utilisateur supprimé avec succès'
    });
  } catch (error) {
    console.error('Erreur lors de la suppression de l\'utilisateur:', error);
    res.status(500).json({
      error: 'Erreur serveur',
      message: 'Une erreur est survenue lors de la suppression de l\'utilisateur'
    });
  }
};

/**
 * Mettre à jour les rôles d'un utilisateur (admin uniquement)
 */
const updateUserRoles = async (req, res) => {
  try {
    const { id } = req.params;
    const { roleNames } = req.body;

    const user = await User.findByPk(id);
    if (!user) {
      return res.status(404).json({
        error: 'Utilisateur non trouvé',
        message: 'L\'utilisateur demandé n\'existe pas'
      });
    }

    const roles = await Role.findAll({
      where: { name: roleNames }
    });

    await user.setRoles(roles);

    await user.reload({
      include: [{
        model: Role,
        as: 'roles',
        attributes: ['id', 'name', 'description']
      }]
    });

    res.json({
      message: 'Rôles mis à jour avec succès',
      user: user.toJSON()
    });
  } catch (error) {
    console.error('Erreur lors de la mise à jour des rôles:', error);
    res.status(500).json({
      error: 'Erreur serveur',
      message: 'Une erreur est survenue lors de la mise à jour des rôles'
    });
  }
};

/**
 * Récupérer tous les rôles disponibles (admin uniquement)
 */
const getAllRoles = async (req, res) => {
  try {
    const roles = await Role.findAll({
      attributes: ['id', 'name', 'description', 'permissions']
    });

    res.json({
      roles
    });
  } catch (error) {
    console.error('Erreur lors de la récupération des rôles:', error);
    res.status(500).json({
      error: 'Erreur serveur',
      message: 'Une erreur est survenue lors de la récupération des rôles'
    });
  }
};

/**
 * Mettre à jour les permissions d'un rôle (admin uniquement)
 */
const updateRolePermissions = async (req, res) => {
  try {
    const { id } = req.params;
    const { permissions } = req.body;

    const role = await Role.findByPk(id);
    if (!role) {
      return res.status(404).json({
        error: 'Rôle non trouvé',
        message: 'Le rôle demandé n\'existe pas'
      });
    }

    role.permissions = permissions;
    await role.save();

    res.json({
      message: 'Permissions mises à jour avec succès',
      role
    });
  } catch (error) {
    console.error('Erreur lors de la mise à jour des permissions:', error);
    res.status(500).json({
      error: 'Erreur serveur',
      message: 'Une erreur est survenue lors de la mise à jour des permissions'
    });
  }
};

module.exports = {
  createUser,
  getAllUsers,
  deleteUser,
  updateUserRoles,
  getAllRoles,
  updateRolePermissions
};
