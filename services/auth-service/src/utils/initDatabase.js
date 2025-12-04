const { sequelize } = require('../config/database');
const { User, Role } = require('../models');

/**
 * Initialise la base de données avec les rôles et l'utilisateur admin par défaut
 */
const initDatabase = async () => {
  try {
    console.log('🔄 Initialisation de la base de données...');

    // Synchroniser les modèles avec la base de données
    await sequelize.sync({ alter: true });
    console.log('✓ Modèles synchronisés avec la base de données');

    // Créer les rôles par défaut
    const roles = [
      {
        name: 'admin',
        description: 'Administrateur avec tous les droits',
        permissions: {
          users: ['create', 'read', 'update', 'delete'],
          roles: ['create', 'read', 'update', 'delete'],
          all: true
        }
      },
      {
        name: 'manager',
        description: 'Gestionnaire avec droits étendus',
        permissions: {
          users: ['create', 'read', 'update'],
          reports: ['read', 'create']
        }
      },
      {
        name: 'user',
        description: 'Utilisateur standard',
        permissions: {
          profile: ['read', 'update']
        }
      },
      {
        name: 'guest',
        description: 'Invité avec droits limités',
        permissions: {
          profile: ['read']
        }
      }
    ];

    for (const roleData of roles) {
      const [role, created] = await Role.findOrCreate({
        where: { name: roleData.name },
        defaults: roleData
      });

      if (created) {
        console.log(`✓ Rôle "${roleData.name}" créé`);
      }
    }

    // Créer l'utilisateur administrateur par défaut
    const adminUsername = 'admin';
    const adminEmail = 'admin@example.com';
    const adminPassword = 'Azerty01*';

    const [adminUser, created] = await User.findOrCreate({
      where: { username: adminUsername },
      defaults: {
        username: adminUsername,
        email: adminEmail,
        password: adminPassword,
        firstName: 'Administrateur',
        lastName: 'Système',
        isActive: true
      }
    });

    if (created) {
      // Attribuer le rôle admin
      const adminRole = await Role.findOne({ where: { name: 'admin' } });
      if (adminRole) {
        await adminUser.addRole(adminRole);
        console.log(`✓ Utilisateur administrateur créé`);
        console.log(`  Username: ${adminUsername}`);
        console.log(`  Password: ${adminPassword}`);
        console.log(`  ⚠️  IMPORTANT: Changez le mot de passe en production !`);
      }
    } else {
      console.log(`ℹ️  L'utilisateur administrateur existe déjà`);
    }

    console.log('✓ Initialisation de la base de données terminée');
  } catch (error) {
    console.error('✗ Erreur lors de l\'initialisation de la base de données:', error);
    throw error;
  }
};

module.exports = initDatabase;
