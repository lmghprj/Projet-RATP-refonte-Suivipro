const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');
const morgan = require('morgan');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

// Routes de santé
app.get('/health', (req, res) => {
  res.json({
    status: 'UP',
    service: 'API Gateway',
    timestamp: new Date().toISOString()
  });
});

// Proxy vers le service d'authentification (Node.js)
app.use('/api/auth', createProxyMiddleware({
  target: process.env.AUTH_SERVICE_URL || 'http://auth-service:3001',
  changeOrigin: true,
  pathRewrite: {
    '^/api/auth': '/api/auth'
  },
  onError: (err, req, res) => {
    console.error('Proxy error (auth):', err);
    res.status(502).json({
      error: 'Service d\'authentification temporairement indisponible',
      message: err.message
    });
  }
}));

// Proxy vers les routes d'administration (auth-service)
app.use('/api/admin', createProxyMiddleware({
  target: process.env.AUTH_SERVICE_URL || 'http://auth-service:3001',
  changeOrigin: true,
  pathRewrite: {
    '^/api/admin': '/api/admin'
  },
  onError: (err, req, res) => {
    console.error('Proxy error (admin):', err);
    res.status(502).json({
      error: 'Service d\'administration temporairement indisponible',
      message: err.message
    });
  }
}));

// Proxy vers les routes de gestion de mot de passe (auth-service)
app.use('/api/password', createProxyMiddleware({
  target: process.env.AUTH_SERVICE_URL || 'http://auth-service:3001',
  changeOrigin: true,
  pathRewrite: {
    '^/api/password': '/api/password'
  },
  onError: (err, req, res) => {
    console.error('Proxy error (password):', err);
    res.status(502).json({
      error: 'Service de gestion de mot de passe temporairement indisponible',
      message: err.message
    });
  }
}));

// Proxy vers le service utilisateur (Spring Boot)
app.use('/api/users', createProxyMiddleware({
  target: process.env.USER_SERVICE_URL || 'http://user-service:8080',
  changeOrigin: true,
  pathRewrite: {
    '^/api/users': '/api/users'
  },
  onError: (err, req, res) => {
    console.error('Proxy error (users):', err);
    res.status(502).json({
      error: 'Service utilisateur temporairement indisponible',
      message: err.message
    });
  }
}));

// Route par défaut
app.get('/', (req, res) => {
  res.json({
    message: 'Bienvenue sur l\'API Gateway',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      auth: '/api/auth',
      admin: '/api/admin',
      password: '/api/password',
      users: '/api/users'
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

// Démarrage du serveur
app.listen(PORT, () => {
  console.log(`🚀 API Gateway démarré sur le port ${PORT}`);
  console.log(`📍 URL: http://localhost:${PORT}`);
});
