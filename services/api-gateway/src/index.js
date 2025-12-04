import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import morgan from 'morgan';
import { createProxyMiddleware } from 'http-proxy-middleware';
import winston from 'winston';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// Logger Winston pour ELK
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  defaultMeta: { service: 'api-gateway' },
  transports: [
    new winston.transports.File({ filename: '/var/log/api-gateway/error.log', level: 'error' }),
    new winston.transports.File({ filename: '/var/log/api-gateway/combined.log' }),
    new winston.transports.Console({
      format: winston.format.simple(),
    }),
  ],
});

// Middleware de sécurité
app.use(helmet());

// CORS
app.use(cors({
  origin: process.env.CORS_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true,
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limite chaque IP à 100 requêtes par windowMs
  message: 'Trop de requêtes depuis cette IP, veuillez réessayer plus tard.',
});
app.use(limiter);

// Logging HTTP
app.use(morgan('combined', {
  stream: {
    write: (message) => logger.info(message.trim())
  }
}));

// Body parser
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

// Routes proxy vers les microservices
const proxyOptions = {
  changeOrigin: true,
  logLevel: 'debug',
  onError: (err, req, res) => {
    logger.error(`Proxy error: ${err.message}`);
    res.status(500).json({ error: 'Service temporairement indisponible' });
  },
};

// Auth Service
app.use('/api/auth', createProxyMiddleware({
  target: process.env.AUTH_SERVICE_URL || 'http://auth-service:8081',
  pathRewrite: { '^/api/auth': '/api/auth' },
  ...proxyOptions,
}));

// User Service
app.use('/api/users', createProxyMiddleware({
  target: process.env.USER_SERVICE_URL || 'http://user-service:8080',
  pathRewrite: { '^/api/users': '/api/users' },
  ...proxyOptions,
}));

// Notification Service
app.use('/api/notifications', createProxyMiddleware({
  target: process.env.NOTIFICATION_SERVICE_URL || 'http://notification-service:8082',
  pathRewrite: { '^/api/notifications': '/api/notifications' },
  ...proxyOptions,
}));

// Reporting Service
app.use('/api/reports', createProxyMiddleware({
  target: process.env.REPORTING_SERVICE_URL || 'http://reporting-service:8083',
  pathRewrite: { '^/api/reports': '/api/reports' },
  ...proxyOptions,
}));

// Admin Service
app.use('/api/admin', createProxyMiddleware({
  target: process.env.ADMIN_SERVICE_URL || 'http://admin-service:8084',
  pathRewrite: { '^/api/admin': '/api/admin' },
  ...proxyOptions,
}));

// Route par défaut
app.get('/', (req, res) => {
  res.json({
    name: 'SuiviPro RATP - API Gateway',
    version: '1.0.0',
    status: 'running',
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route non trouvée' });
});

// Error handler
app.use((err, req, res, next) => {
  logger.error(err.stack);
  res.status(500).json({ error: 'Erreur interne du serveur' });
});

// Démarrage du serveur
app.listen(PORT, '0.0.0.0', () => {
  logger.info(`API Gateway démarré sur le port ${PORT}`);
});
