-- Script d'initialisation de la base de données

-- Création de la table users si elle n'existe pas
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Index sur l'email pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Données de test (optionnel)
INSERT INTO users (first_name, last_name, email) VALUES
    ('Jean', 'Dupont', 'jean.dupont@example.com'),
    ('Marie', 'Martin', 'marie.martin@example.com'),
    ('Pierre', 'Durand', 'pierre.durand@example.com')
ON CONFLICT (email) DO NOTHING;
