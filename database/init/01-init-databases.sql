-- Script d'initialisation des bases de données pour SuiviPro RATP
-- Architecture DDD (Domain-Driven Design)

-- Création des bases de données pour les 15 microservices
CREATE DATABASE IF NOT EXISTS suivipro_agent;
CREATE DATABASE IF NOT EXISTS suivipro_habilitation;
CREATE DATABASE IF NOT EXISTS suivipro_formation;
CREATE DATABASE IF NOT EXISTS suivipro_securite;
CREATE DATABASE IF NOT EXISTS suivipro_paisf;
CREATE DATABASE IF NOT EXISTS suivipro_alerte;
CREATE DATABASE IF NOT EXISTS suivipro_objectif;
CREATE DATABASE IF NOT EXISTS suivipro_reporting;
CREATE DATABASE IF NOT EXISTS suivipro_organisation;
CREATE DATABASE IF NOT EXISTS suivipro_iam;
CREATE DATABASE IF NOT EXISTS suivipro_document;
CREATE DATABASE IF NOT EXISTS suivipro_integration;
CREATE DATABASE IF NOT EXISTS suivipro_notification;
CREATE DATABASE IF NOT EXISTS suivipro_audit;
CREATE DATABASE IF NOT EXISTS suivipro_referentiel;

-- Bases de données pour l'infrastructure
CREATE DATABASE IF NOT EXISTS supersetdb;
CREATE DATABASE IF NOT EXISTS sonardb;

-- Créer l'utilisateur suivipro si nécessaire
-- Note: Les microservices utiliseront cet utilisateur pour se connecter
DO
$$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'suivipro') THEN
        CREATE USER suivipro WITH PASSWORD 'suivipro123';
    END IF;
END
$$;

-- Accorder les privilèges sur toutes les bases de données
GRANT ALL PRIVILEGES ON DATABASE suivipro_agent TO suivipro;
GRANT ALL PRIVILEGES ON DATABASE suivipro_habilitation TO suivipro;
GRANT ALL PRIVILEGES ON DATABASE suivipro_formation TO suivipro;
GRANT ALL PRIVILEGES ON DATABASE suivipro_securite TO suivipro;
GRANT ALL PRIVILEGES ON DATABASE suivipro_paisf TO suivipro;
GRANT ALL PRIVILEGES ON DATABASE suivipro_alerte TO suivipro;
GRANT ALL PRIVILEGES ON DATABASE suivipro_objectif TO suivipro;
GRANT ALL PRIVILEGES ON DATABASE suivipro_reporting TO suivipro;
GRANT ALL PRIVILEGES ON DATABASE suivipro_organisation TO suivipro;
GRANT ALL PRIVILEGES ON DATABASE suivipro_iam TO suivipro;
GRANT ALL PRIVILEGES ON DATABASE suivipro_document TO suivipro;
GRANT ALL PRIVILEGES ON DATABASE suivipro_integration TO suivipro;
GRANT ALL PRIVILEGES ON DATABASE suivipro_notification TO suivipro;
GRANT ALL PRIVILEGES ON DATABASE suivipro_audit TO suivipro;
GRANT ALL PRIVILEGES ON DATABASE suivipro_referentiel TO suivipro;
GRANT ALL PRIVILEGES ON DATABASE supersetdb TO suivipro;
GRANT ALL PRIVILEGES ON DATABASE sonardb TO suivipro;

-- ===== MS-IAM: Initialisation des données de base =====
\c suivipro_iam;

-- Table des utilisateurs (gérée par Spring Data JPA, mais on peut pré-créer un admin)
-- Note: La structure complète sera créée automatiquement par Hibernate

-- ===== MS-REFERENTIEL: Données de référence =====
\c suivipro_referentiel;

-- Les référentiels seront gérés via l'application
-- Exemples: Types de formations, catégories d'habilitations, types d'écarts, etc.

-- ===== MS-AUDIT: Configuration initiale =====
\c suivipro_audit;

-- La table d'audit sera créée automatiquement par Spring Data JPA

-- Afficher un message de confirmation
SELECT 'Bases de données initialisées avec succès pour SuiviPro RATP (Architecture DDD)' AS message;
