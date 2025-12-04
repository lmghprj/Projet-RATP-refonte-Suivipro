const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
require('dotenv').config();

const { testConnection } = require('./config/database');
const authRoutes = require('./routes/authRoutes');
const adminRoutes = require('./routes/adminRoutes');
const passwordRoutes = require('./routes/passwordRoutes');
const initDatabase = require('./utils/initDatabase');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}));
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes de santé
app.get('/health', (req, res) => {
  res.json({
    status: 'UP',
    service: 'Authentication Service',
    timestamp: new Date().toISOString()
  });
});

// Routes d'authentification
app.use('/api/auth', authRoutes);

// Routes administration (admin uniquement)
app.use('/api/admin', adminRoutes);

// Routes de gestion du mot de passe
app.use('/api/password', passwordRoutes);

// Route par défaut
app.get('/', (req, res) => {
  res.json({
    message: 'Service d\'authentification',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      login: 'POST /api/auth/login',
      register: 'POST /api/auth/register',
      profile: 'GET /api/auth/profile (requires token)',
      verify: 'GET /api/auth/verify (requires token)'
    }
  });
});

// Gestion des erreurs 404
app.use((req, res) => {
  res.status(404).json({
    error: 'Route non trouvée',
    path: req.path
  });
});

// Gestion des erreurs globales
app.use((err, req, res, next) => {
  console.error('Erreur:', err);
  res.status(err.status || 500).json({
    error: 'Erreur serveur',
    message: err.message || 'Une erreur interne est survenue'
  });
});

// Initialisation et démarrage du serveur
const startServer = async () => {
  try {
    // Tester la connexion à la base de données
    await testConnection();

    // Initialiser la base de données (créer les tables, rôles et admin)
    await initDatabase();

    // Démarrer le serveur
    app.listen(PORT, () => {
      console.log('');
      console.log('================================================');
      console.log(`🚀 Authentication Service démarré`);
      console.log(`📍 URL: http://localhost:${PORT}`);
      console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
      console.log('================================================');
      console.log('');
    });
  } catch (error) {
    console.error('✗ Erreur lors du démarrage du serveur:', error);
    process.exit(1);
  }
};

startServer();
