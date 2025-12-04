# Changelog

Tous les changements notables de ce projet seront documentés dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [Unreleased]

### À venir
- Tests end-to-end complets
- Documentation API interactive (Swagger)
- Module de gestion des permissions avancées

## [1.0.0] - 2024-12-04

### Ajouté

#### Architecture
- Architecture microservices complète
- 5 microservices backend (Java Spring Boot 3.2.0)
- API Gateway avec Node.js/Express
- Frontend React 18 avec Vite

#### Backend Services
- **auth-service** : Authentification JWT, gestion des rôles et permissions
- **user-service** : CRUD utilisateurs, profils
- **notification-service** : Envoi d'emails, gestion des notifications
- **reporting-service** : Génération de rapports, export Excel
- **admin-service** : Administration système, audit logs

#### Infrastructure
- Base de données PostgreSQL 15 avec 5 bases séparées
- Base de données MySQL 8 pour Matomo
- Redis pour le cache distribué
- Nginx comme reverse proxy

#### Observabilité (ELK Stack)
- Elasticsearch 8.11.0 pour le stockage des logs
- Logstash pour la collecte et le traitement
- Kibana pour la visualisation des logs
- Logs centralisés de tous les services

#### Analytics et KPI
- Apache Superset 3.0 pour les dashboards KPI
- Matomo 5.0 on-premise pour l'analytics web
- Connexions préconfigurées aux bases de données

#### Monitoring
- Prometheus pour la collecte des métriques
- Grafana pour les dashboards de monitoring
- Métriques Spring Boot Actuator
- Health checks sur tous les services

#### CI/CD
- GitHub Actions workflows
- Tests automatisés (backend et frontend)
- Scan de sécurité avec Trivy
- Analyse de code avec CodeQL
- Build et push d'images Docker
- Déploiement automatisé

#### Sécurité
- Authentification JWT
- Hashage bcrypt des mots de passe
- CORS configuré
- Rate limiting sur l'API Gateway
- Headers de sécurité (Helmet.js)
- Conteneurs non-root
- Scan de vulnérabilités automatique

#### Documentation
- README complet
- Guide de contribution
- Documentation d'architecture
- Exemples d'utilisation API
- Configuration des environnements

#### Configuration
- Variables d'environnement
- Configuration par service
- Docker Compose orchestration
- Scripts de déploiement

### Sécurité
- Tous les services exposent des endpoints de health check
- Authentification requise pour les endpoints sensibles
- Validation des données d'entrée
- Protection contre les injections SQL
- Protection XSS

[Unreleased]: https://github.com/lmghprj/Projet-RATP-refonte-Suivipro/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/lmghprj/Projet-RATP-refonte-Suivipro/releases/tag/v1.0.0
