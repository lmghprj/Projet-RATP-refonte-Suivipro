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

// Routes proxy vers les microservices (Architecture DDD)
const proxyOptions = {
  changeOrigin: true,
  logLevel: 'debug',
  onError: (err, req, res) => {
    logger.error(`Proxy error: ${err.message}`);
    res.status(500).json({ error: 'Service temporairement indisponible' });
  },
};

// MS-Agent - Gestion des dossiers agents
app.use('/api/agents', createProxyMiddleware({
  target: process.env.MS_AGENT_URL || 'http://ms-agent:8081',
  pathRewrite: { '^/api/agents': '/api/agents' },
  ...proxyOptions,
}));

// MS-Habilitation - Gestion des habilitations
app.use('/api/habilitations', createProxyMiddleware({
  target: process.env.MS_HABILITATION_URL || 'http://ms-habilitation:8082',
  pathRewrite: { '^/api/habilitations': '/api/habilitations' },
  ...proxyOptions,
}));

// MS-Formation - Gestion des formations et instructions
app.use('/api/formations', createProxyMiddleware({
  target: process.env.MS_FORMATION_URL || 'http://ms-formation:8083',
  pathRewrite: { '^/api/formations': '/api/formations' },
  ...proxyOptions,
}));

// MS-Securite - Gestion de la sécurité et des écarts
app.use('/api/securite', createProxyMiddleware({
  target: process.env.MS_SECURITE_URL || 'http://ms-securite:8084',
  pathRewrite: { '^/api/securite': '/api/securite' },
  ...proxyOptions,
}));

// MS-PAISF - Gestion PAISF
app.use('/api/paisf', createProxyMiddleware({
  target: process.env.MS_PAISF_URL || 'http://ms-paisf:8085',
  pathRewrite: { '^/api/paisf': '/api/paisf' },
  ...proxyOptions,
}));

// MS-Alerte - Gestion des alertes
app.use('/api/alertes', createProxyMiddleware({
  target: process.env.MS_ALERTE_URL || 'http://ms-alerte:8086',
  pathRewrite: { '^/api/alertes': '/api/alertes' },
  ...proxyOptions,
}));

// MS-Objectif - Gestion des objectifs et indicateurs
app.use('/api/objectifs', createProxyMiddleware({
  target: process.env.MS_OBJECTIF_URL || 'http://ms-objectif:8087',
  pathRewrite: { '^/api/objectifs': '/api/objectifs' },
  ...proxyOptions,
}));

// MS-Reporting - Reporting et BI
app.use('/api/reports', createProxyMiddleware({
  target: process.env.MS_REPORTING_URL || 'http://ms-reporting:8088',
  pathRewrite: { '^/api/reports': '/api/reports' },
  ...proxyOptions,
}));

// MS-Organisation - Gestion de l'organisation
app.use('/api/organisation', createProxyMiddleware({
  target: process.env.MS_ORGANISATION_URL || 'http://ms-organisation:8089',
  pathRewrite: { '^/api/organisation': '/api/organisation' },
  ...proxyOptions,
}));

// MS-IAM - Identity & Access Management
app.use('/api/auth', createProxyMiddleware({
  target: process.env.MS_IAM_URL || 'http://ms-iam:8090',
  pathRewrite: { '^/api/auth': '/api/auth' },
  ...proxyOptions,
}));

// MS-Document - Gestion documentaire (GED)
app.use('/api/documents', createProxyMiddleware({
  target: process.env.MS_DOCUMENT_URL || 'http://ms-document:8091',
  pathRewrite: { '^/api/documents': '/api/documents' },
  ...proxyOptions,
}));

// MS-Integration - Intégration SI
app.use('/api/integration', createProxyMiddleware({
  target: process.env.MS_INTEGRATION_URL || 'http://ms-integration:8092',
  pathRewrite: { '^/api/integration': '/api/integration' },
  ...proxyOptions,
}));

// MS-Notification - Gestion des notifications
app.use('/api/notifications', createProxyMiddleware({
  target: process.env.MS_NOTIFICATION_URL || 'http://ms-notification:8093',
  pathRewrite: { '^/api/notifications': '/api/notifications' },
  ...proxyOptions,
}));

// MS-Audit - Audit et traçabilité
app.use('/api/audit', createProxyMiddleware({
  target: process.env.MS_AUDIT_URL || 'http://ms-audit:8094',
  pathRewrite: { '^/api/audit': '/api/audit' },
  ...proxyOptions,
}));

// MS-Referentiel - Gestion des référentiels
app.use('/api/referentiels', createProxyMiddleware({
  target: process.env.MS_REFERENTIEL_URL || 'http://ms-referentiel:8095',
  pathRewrite: { '^/api/referentiels': '/api/referentiels' },
  ...proxyOptions,
}));

// Route par défaut
app.get('/', (req, res) => {
  res.json({
    name: 'SuiviPro RATP - API Gateway',
    version: '2.0.0',
    architecture: 'DDD (Domain-Driven Design)',
    status: 'running',
    services: {
      'ms-agent': { url: 'http://ms-agent:8081', route: '/api/agents', description: 'Gestion des dossiers agents' },
      'ms-habilitation': { url: 'http://ms-habilitation:8082', route: '/api/habilitations', description: 'Gestion des habilitations' },
      'ms-formation': { url: 'http://ms-formation:8083', route: '/api/formations', description: 'Gestion des formations et instructions' },
      'ms-securite': { url: 'http://ms-securite:8084', route: '/api/securite', description: 'Gestion de la sécurité et des écarts' },
      'ms-paisf': { url: 'http://ms-paisf:8085', route: '/api/paisf', description: 'Gestion PAISF' },
      'ms-alerte': { url: 'http://ms-alerte:8086', route: '/api/alertes', description: 'Gestion des alertes' },
      'ms-objectif': { url: 'http://ms-objectif:8087', route: '/api/objectifs', description: 'Gestion des objectifs et indicateurs' },
      'ms-reporting': { url: 'http://ms-reporting:8088', route: '/api/reports', description: 'Reporting et BI' },
      'ms-organisation': { url: 'http://ms-organisation:8089', route: '/api/organisation', description: 'Gestion de l\'organisation' },
      'ms-iam': { url: 'http://ms-iam:8090', route: '/api/auth', description: 'Identity & Access Management' },
      'ms-document': { url: 'http://ms-document:8091', route: '/api/documents', description: 'Gestion documentaire (GED)' },
      'ms-integration': { url: 'http://ms-integration:8092', route: '/api/integration', description: 'Intégration SI' },
      'ms-notification': { url: 'http://ms-notification:8093', route: '/api/notifications', description: 'Gestion des notifications' },
      'ms-audit': { url: 'http://ms-audit:8094', route: '/api/audit', description: 'Audit et traçabilité' },
      'ms-referentiel': { url: 'http://ms-referentiel:8095', route: '/api/referentiels', description: 'Gestion des référentiels' },
    },
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
