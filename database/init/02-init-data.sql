-- Script d'insertion de données de test pour SuiviPro RATP

\c userdb;

-- Insertion de profils utilisateurs de test
INSERT INTO user_profiles (user_id, matricule, department, position, phone, city, postal_code)
VALUES
    (1, 'MAT001', 'Direction Informatique', 'Administrateur Système', '01 23 45 67 89', 'Paris', '75001'),
    (2, 'MAT002', 'Service Commercial', 'Manager Commercial', '01 23 45 67 90', 'Paris', '75002'),
    (3, 'MAT003', 'Service Technique', 'Technicien', '01 23 45 67 91', 'Paris', '75003')
ON CONFLICT (matricule) DO NOTHING;

\c notificationdb;

-- Insertion de templates de notification
INSERT INTO notification_templates (name, subject, body, type)
VALUES
    ('welcome_email', 'Bienvenue sur SuiviPro RATP', 'Bonjour {firstName},\n\nBienvenue sur la plateforme SuiviPro RATP.', 'EMAIL'),
    ('password_reset', 'Réinitialisation de mot de passe', 'Bonjour,\n\nVous avez demandé une réinitialisation de mot de passe.', 'EMAIL'),
    ('account_locked', 'Compte verrouillé', 'Votre compte a été verrouillé pour des raisons de sécurité.', 'EMAIL')
ON CONFLICT (name) DO NOTHING;

\c reportingdb;

-- Insertion de métriques de test
INSERT INTO metrics (metric_name, metric_value, metric_date, category)
VALUES
    ('utilisateurs_actifs', 150, CURRENT_DATE, 'USERS'),
    ('connexions_jour', 45, CURRENT_DATE, 'ACTIVITY'),
    ('rapports_generes', 12, CURRENT_DATE, 'REPORTS'),
    ('temps_reponse_moyen', 245, CURRENT_DATE, 'PERFORMANCE')
ON CONFLICT DO NOTHING;

\c admindb;

-- Insertion de logs d'audit de test
INSERT INTO audit_logs (user_id, action, entity_type, entity_id, ip_address, user_agent)
VALUES
    (1, 'LOGIN', 'USER', 1, '192.168.1.100', 'Mozilla/5.0'),
    (1, 'CREATE', 'USER', 2, '192.168.1.100', 'Mozilla/5.0'),
    (1, 'UPDATE', 'SETTINGS', 1, '192.168.1.100', 'Mozilla/5.0');
