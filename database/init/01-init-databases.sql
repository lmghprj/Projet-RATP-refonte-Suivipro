-- Script d'initialisation des bases de données pour SuiviPro RATP

-- Création des bases de données
CREATE DATABASE IF NOT EXISTS authdb;
CREATE DATABASE IF NOT EXISTS userdb;
CREATE DATABASE IF NOT EXISTS notificationdb;
CREATE DATABASE IF NOT EXISTS reportingdb;
CREATE DATABASE IF NOT EXISTS admindb;
CREATE DATABASE IF NOT EXISTS documentdb;
CREATE DATABASE IF NOT EXISTS planningdb;
CREATE DATABASE IF NOT EXISTS interventiondb;
CREATE DATABASE IF NOT EXISTS assetdb;
CREATE DATABASE IF NOT EXISTS timekeepingdb;
CREATE DATABASE IF NOT EXISTS supersetdb;
CREATE DATABASE IF NOT EXISTS sonardb;

-- Se connecter à authdb
\c authdb;

-- Table des utilisateurs
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Table des rôles
CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table de liaison users-roles
CREATE TABLE IF NOT EXISTS user_roles (
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    role_id INTEGER REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id)
);

-- Table des tokens de rafraîchissement
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(500) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revoked BOOLEAN DEFAULT FALSE
);

-- Insertion des rôles par défaut
INSERT INTO roles (name, description) VALUES
    ('ADMIN', 'Administrateur système avec tous les droits'),
    ('MANAGER', 'Gestionnaire avec droits étendus'),
    ('USER', 'Utilisateur standard'),
    ('GUEST', 'Invité avec accès limité')
ON CONFLICT (name) DO NOTHING;

-- Création d'un utilisateur admin par défaut
-- Mot de passe: Admin@2024 (à changer en production)
INSERT INTO users (username, email, password_hash, first_name, last_name, is_active, is_verified)
VALUES (
    'admin',
    'admin@ratp.fr',
    '$2a$10$XQyHpHvqPSNLv7mHLhH8l.YPNh8Z8QwNQxZKjB7OqN8p6Nv7mHLhH',
    'Administrateur',
    'Système',
    TRUE,
    TRUE
)
ON CONFLICT (username) DO NOTHING;

-- Assigner le rôle admin
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM users u, roles r
WHERE u.username = 'admin' AND r.name = 'ADMIN'
ON CONFLICT DO NOTHING;

-- Se connecter à userdb
\c userdb;

-- Table des profils utilisateurs
CREATE TABLE IF NOT EXISTS user_profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL,
    matricule VARCHAR(20) UNIQUE,
    department VARCHAR(100),
    position VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    postal_code VARCHAR(10),
    photo_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_matricule ON user_profiles(matricule);

-- Se connecter à notificationdb
\c notificationdb;

-- Table des notifications
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'INFO',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP
);

-- Index
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);

-- Table des templates de notification
CREATE TABLE IF NOT EXISTS notification_templates (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    subject VARCHAR(200),
    body TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Se connecter à reportingdb
\c reportingdb;

-- Table des rapports
CREATE TABLE IF NOT EXISTS reports (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL,
    created_by INTEGER NOT NULL,
    file_path TEXT,
    status VARCHAR(50) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

-- Table des métriques
CREATE TABLE IF NOT EXISTS metrics (
    id SERIAL PRIMARY KEY,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(15,2) NOT NULL,
    metric_date DATE NOT NULL,
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index
CREATE INDEX IF NOT EXISTS idx_metrics_date ON metrics(metric_date DESC);
CREATE INDEX IF NOT EXISTS idx_metrics_name ON metrics(metric_name);

-- Se connecter à admindb
\c admindb;

-- Table des logs d'audit
CREATE TABLE IF NOT EXISTS audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id INTEGER,
    old_value JSONB,
    new_value JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des paramètres système
CREATE TABLE IF NOT EXISTS system_settings (
    id SERIAL PRIMARY KEY,
    key VARCHAR(100) UNIQUE NOT NULL,
    value TEXT,
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by INTEGER
);

-- Index
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at DESC);

-- Insertion des paramètres système par défaut
INSERT INTO system_settings (key, value, description) VALUES
    ('maintenance_mode', 'false', 'Mode maintenance actif ou non'),
    ('max_login_attempts', '5', 'Nombre maximum de tentatives de connexion'),
    ('session_timeout', '3600', 'Durée de session en secondes'),
    ('password_min_length', '8', 'Longueur minimale du mot de passe')
ON CONFLICT (key) DO NOTHING;
