require('dotenv').config();

let transporter = null;
let emailEnabled = false;

// Initialisation du transporteur email (optionnel)
try {
  const nodemailer = require('nodemailer');

  // Vérifier si nodemailer est correctement importé
  if (nodemailer && typeof nodemailer.createTransport === 'function') {
    transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST || 'smtp.gmail.com',
      port: process.env.SMTP_PORT || 587,
      secure: false, // true pour 465, false pour les autres ports
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS
      }
    });
    emailEnabled = true;
    console.log('✓ Service email configuré');
  } else {
    console.warn('⚠️  Nodemailer disponible mais createTransport non trouvé');
  }
} catch (error) {
  console.warn('⚠️  Service email non disponible:', error.message);
  console.warn('   Les utilisateurs seront créés mais ne recevront pas d\'email');
}

/**
 * Envoie un email de bienvenue avec les identifiants
 * @param {Object} user - Objet utilisateur
 * @param {String} temporaryPassword - Mot de passe temporaire
 */
const sendWelcomeEmail = async (user, temporaryPassword) => {
  // Si le service email n'est pas disponible, retourner un avertissement
  if (!emailEnabled || !transporter) {
    console.warn(`⚠️  Email non envoyé à ${user.email} - Service email non disponible`);
    console.warn(`   Identifiants créés: ${user.username} / ${temporaryPassword}`);
    return {
      success: false,
      error: 'Service email non configuré',
      credentials: { username: user.username, password: temporaryPassword }
    };
  }

  try {
    const mailOptions = {
      from: process.env.SMTP_FROM || '"Application Admin" <noreply@example.com>',
      to: user.email,
      subject: 'Bienvenue - Vos identifiants de connexion',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #333;">Bienvenue ${user.firstName || 'Nouvel utilisateur'} !</h2>
          <p>Votre compte a été créé avec succès. Voici vos identifiants de connexion :</p>

          <div style="background-color: #f5f5f5; padding: 20px; border-radius: 5px; margin: 20px 0;">
            <p style="margin: 10px 0;">
              <strong>Nom d'utilisateur :</strong> ${user.username}
            </p>
            <p style="margin: 10px 0;">
              <strong>Mot de passe temporaire :</strong> ${temporaryPassword}
            </p>
          </div>

          <p style="color: #d9534f;">
            <strong>⚠️ Important :</strong> Pour des raisons de sécurité, vous devrez changer votre mot de passe lors de votre première connexion.
          </p>

          <p>
            <a href="${process.env.FRONTEND_URL || 'http://localhost:3002'}/login"
               style="display: inline-block; padding: 12px 24px; background-color: #667eea; color: white; text-decoration: none; border-radius: 5px; margin-top: 20px;">
              Se connecter
            </a>
          </p>

          <p style="color: #666; font-size: 14px; margin-top: 30px;">
            Si vous n'êtes pas à l'origine de cette demande, veuillez ignorer cet email.
          </p>
        </div>
      `
    };

    const info = await transporter.sendMail(mailOptions);
    console.log('✓ Email envoyé:', info.messageId);
    return { success: true, messageId: info.messageId };
  } catch (error) {
    console.error('✗ Erreur lors de l\'envoi de l\'email:', error);
    // Ne pas bloquer la création de l'utilisateur si l'email échoue
    return { success: false, error: error.message };
  }
};

/**
 * Envoie un email de notification de changement de mot de passe
 * @param {Object} user - Objet utilisateur
 */
const sendPasswordChangedEmail = async (user) => {
  // Si le service email n'est pas disponible, retourner un avertissement
  if (!emailEnabled || !transporter) {
    console.warn(`⚠️  Email de confirmation non envoyé à ${user.email} - Service email non disponible`);
    return { success: false, error: 'Service email non configuré' };
  }

  try {
    const mailOptions = {
      from: process.env.SMTP_FROM || '"Application Admin" <noreply@example.com>',
      to: user.email,
      subject: 'Confirmation de changement de mot de passe',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #333;">Mot de passe modifié</h2>
          <p>Bonjour ${user.firstName || user.username},</p>
          <p>Votre mot de passe a été modifié avec succès.</p>
          <p>Si vous n'êtes pas à l'origine de cette modification, veuillez contacter immédiatement un administrateur.</p>
          <p style="color: #666; font-size: 14px; margin-top: 30px;">
            Cordialement,<br/>
            L'équipe Administrative
          </p>
        </div>
      `
    };

    const info = await transporter.sendMail(mailOptions);
    console.log('✓ Email de confirmation envoyé:', info.messageId);
    return { success: true, messageId: info.messageId };
  } catch (error) {
    console.error('✗ Erreur lors de l\'envoi de l\'email de confirmation:', error);
    return { success: false, error: error.message };
  }
};

module.exports = {
  sendWelcomeEmail,
  sendPasswordChangedEmail
};
