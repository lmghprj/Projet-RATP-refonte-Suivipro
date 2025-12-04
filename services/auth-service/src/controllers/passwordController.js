const { User } = require('../models');
const { validationResult } = require('express-validator');
const { sendPasswordChangedEmail } = require('../services/emailService');

/**
 * Changer le mot de passe (utilisateur connecté)
 */
const changePassword = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { currentPassword, newPassword } = req.body;

    const user = await User.findByPk(req.user.id);
    if (!user) {
      return res.status(404).json({
        error: 'Utilisateur non trouvé',
        message: 'L\'utilisateur demandé n\'existe pas'
      });
    }

    // Vérifier le mot de passe actuel
    const isValid = await user.comparePassword(currentPassword);
    if (!isValid) {
      return res.status(401).json({
        error: 'Mot de passe incorrect',
        message: 'Le mot de passe actuel est incorrect'
      });
    }

    // Mettre à jour le mot de passe
    user.password = newPassword;
    user.mustChangePassword = false; // Plus besoin de changer le mot de passe
    await user.save();

    // Envoyer un email de confirmation
    await sendPasswordChangedEmail(user);

    res.json({
      message: 'Mot de passe modifié avec succès'
    });
  } catch (error) {
    console.error('Erreur lors du changement de mot de passe:', error);
    res.status(500).json({
      error: 'Erreur serveur',
      message: 'Une erreur est survenue lors du changement de mot de passe'
    });
  }
};

module.exports = {
  changePassword
};
