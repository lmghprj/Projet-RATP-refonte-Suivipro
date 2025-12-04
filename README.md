# Projet RATP - Refonte SuiviPro

Application de refonte du système SuiviPro pour la RATP, basée sur une architecture microservices moderne avec stack complète d'observabilité et d'analytics.

## Table des Matières

- [Architecture](#architecture)
- [Technologies](#technologies)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
- [Utilisation](#utilisation)
- [Services](#services)
- [Monitoring et Observabilité](#monitoring-et-observabilité)
- [CI/CD](#cicd)
- [Sécurité](#sécurité)
- [Documentation API](#documentation-api)
- [Contribution](#contribution)

## Architecture

Le projet est structuré selon une architecture microservices avec les composants suivants :

### Services Backend (Java Spring Boot)

- **auth-service** (Port 8081) - Authentification et autorisation
- **user-service** (Port 8080) - Gestion des utilisateurs
- **notification-service** (Port 8082) - Gestion des notifications
- **reporting-service** (Port 8083) - Génération de rapports et statistiques
- **admin-service** (Port 8084) - Administration système

### Services Frontend

- **frontend** (Port 3000) - Application React avec Vite
- **api-gateway** (Port 3001) - Passerelle API Node.js/Express

### Bases de Données

- **PostgreSQL** (Port 5432) - Base de données principale
  - authdb - Base d'authentification
  - userdb - Base utilisateurs
  - notificationdb - Base notifications
  - reportingdb - Base reporting
  - admindb - Base administration
  - supersetdb - Base Apache Superset

- **MySQL** (Port 3306) - Base de données Matomo
- **Redis** (Port 6379) - Cache distribué

### Stack ELK (Observabilité)

- **Elasticsearch** (Port 9200) - Stockage et indexation des logs
- **Logstash** (Port 5000) - Collecte et traitement des logs
- **Kibana** (Port 5601) - Visualisation des logs

### Analytics et KPI

- **Apache Superset** (Port 8088) - Création de dashboards et KPI
- **Matomo** (Port 8080) - Analytics on-premise

### Monitoring

- **Prometheus** (Port 9090) - Collecte des métriques
- **Grafana** (Port 3003) - Visualisation des métriques

### Infrastructure

- **Nginx** (Port 80/443) - Reverse proxy et load balancer

## Technologies

### Backend

- Java 17
- Spring Boot 3.2.0
- Spring Data JPA
- Spring Security
- PostgreSQL 15
- Maven 3.9

### Frontend

- React 18
- Vite 5
- React Router 6
- Axios
- Zustand (state management)
- TanStack Query

### Infrastructure

- Docker & Docker Compose
- Nginx
- Redis

### Monitoring

- ELK Stack (Elasticsearch, Logstash, Kibana) 8.11.0
- Prometheus
- Grafana
- Apache Superset 3.0
- Matomo 5.0

### CI/CD

- GitHub Actions
- Trivy (security scanning)
- CodeQL (code analysis)

## Prérequis

- Docker Desktop 4.x ou supérieur
- Docker Compose 3.8 ou supérieur
- Git
- 16 GB RAM minimum recommandé
- 50 GB d'espace disque libre

## Installation

### 1. Cloner le repository

```bash
git clone https://github.com/lmghprj/Projet-RATP-refonte-Suivipro.git
cd Projet-RATP-refonte-Suivipro
```

### 2. Configuration de l'environnement

Copier le fichier `.env.example` vers `.env` et ajuster les valeurs :

```bash
cp .env.example .env
```

Variables importantes à configurer :

```env
# Sécurité
JWT_SECRET=votre-secret-jwt-securise
ELASTIC_PASSWORD=votre-mot-de-passe-elastic
SUPERSET_SECRET_KEY=votre-cle-superset

# Email (optionnel)
MAIL_HOST=smtp.gmail.com
MAIL_USERNAME=votre-email@gmail.com
MAIL_PASSWORD=votre-mot-de-passe-app
```

### 3. Démarrer l'application

```bash
# Démarrer tous les services
docker-compose up -d

# Vérifier le statut des services
docker-compose ps

# Suivre les logs
docker-compose logs -f
```

### 4. Initialiser les services

#### Superset

```bash
docker exec -it superset bash
superset db upgrade
superset fab create-admin \
  --username admin \
  --firstname Admin \
  --lastname RATP \
  --email admin@ratp.fr \
  --password Admin@2024
superset init
exit
```

#### Matomo

Accéder à http://localhost:8080 et suivre l'assistant d'installation.

## Configuration

### Variables d'environnement par service

Chaque service peut être configuré via des variables d'environnement. Consultez le fichier `.env.example` pour la liste complète.

### Ports utilisés

| Service | Port(s) | Description |
|---------|---------|-------------|
| Frontend | 3000 | Application React |
| API Gateway | 3001 | Passerelle API |
| User Service | 8080 | API utilisateurs |
| Auth Service | 8081 | API authentification |
| Notification Service | 8082 | API notifications |
| Reporting Service | 8083 | API reporting |
| Admin Service | 8084 | API administration |
| Superset | 8088 | Dashboards KPI |
| PostgreSQL | 5432 | Base de données |
| MySQL | 3306 | Base Matomo |
| Redis | 6379 | Cache |
| Elasticsearch | 9200, 9300 | Moteur de recherche |
| Logstash | 5000 | Collecteur de logs |
| Kibana | 5601 | Visualisation logs |
| Matomo | 8080 | Analytics |
| Prometheus | 9090 | Métriques |
| Grafana | 3003 | Dashboards monitoring |
| Nginx | 80, 443 | Reverse proxy |

## Utilisation

### Accès aux applications

- **Application principale** : http://localhost:3000
- **API Gateway** : http://localhost:3001
- **Kibana (Logs)** : http://localhost:5601
- **Grafana (Monitoring)** : http://localhost:3003
- **Superset (KPI)** : http://localhost:8088
- **Matomo (Analytics)** : http://localhost:8080
- **Prometheus** : http://localhost:9090

### Comptes par défaut

#### Application SuiviPro
- Username: `admin`
- Password: `Admin@2024`

#### Kibana/Elasticsearch
- Username: `elastic`
- Password: `changeme` (à modifier dans .env)

#### Grafana
- Username: `admin`
- Password: `admin` (à modifier dans .env)

#### Superset
- Username: `admin`
- Password: `Admin@2024`

⚠️ **IMPORTANT** : Changez tous les mots de passe par défaut en production !

## Services

### Backend Services

Tous les services backend exposent les endpoints suivants :

- `GET /actuator/health` - Health check
- `GET /actuator/info` - Informations sur le service
- `GET /actuator/metrics` - Métriques
- `GET /actuator/prometheus` - Métriques au format Prometheus

### API Gateway

Routes disponibles :

- `/api/auth/*` → Auth Service
- `/api/users/*` → User Service
- `/api/notifications/*` → Notification Service
- `/api/reports/*` → Reporting Service
- `/api/admin/*` → Admin Service

## Monitoring et Observabilité

### Logs (ELK Stack)

Les logs de tous les services sont centralisés dans Elasticsearch et visualisables via Kibana.

**Accès Kibana** : http://localhost:5601

Index patterns créés automatiquement :
- `suivipro-auth-service-*`
- `suivipro-user-service-*`
- `suivipro-notification-service-*`
- `suivipro-reporting-service-*`
- `suivipro-admin-service-*`
- `suivipro-api-gateway-*`

### Métriques (Prometheus + Grafana)

Les métriques de performance et santé sont collectées par Prometheus et visualisables dans Grafana.

**Accès Grafana** : http://localhost:3003

Métriques disponibles :
- CPU, mémoire, disque
- Requêtes HTTP (latence, débit, erreurs)
- Base de données (connexions, requêtes)
- JVM (heap, threads, GC)

### KPI et Reporting (Superset)

Apache Superset permet de créer des dashboards personnalisés connectés aux bases de données.

**Accès Superset** : http://localhost:8088

Connexions configurées :
- PostgreSQL (reportingdb) - Données métier
- PostgreSQL (userdb) - Données utilisateurs

### Analytics (Matomo)

Matomo collecte les données d'utilisation de l'application frontend.

**Accès Matomo** : http://localhost:8080

## CI/CD

Le projet utilise GitHub Actions pour l'intégration et le déploiement continus.

### Workflows disponibles

#### CI Backend (`ci-backend.yml`)
- Build et tests des services Java
- Scan de sécurité avec Trivy
- Génération de rapports de tests

#### CI Frontend (`ci-frontend.yml`)
- Build et lint du frontend React
- Scan de sécurité

#### CI API Gateway (`ci-api-gateway.yml`)
- Build et tests de l'API Gateway
- Scan de sécurité

#### CD Deploy (`cd-deploy.yml`)
- Build des images Docker
- Push vers GitHub Container Registry
- Déploiement automatique

#### Security Scan (`security-scan.yml`)
- Scan quotidien des dépendances
- Analyse CodeQL
- Détection de vulnérabilités

## Sécurité

### Bonnes pratiques implémentées

- JWT pour l'authentification
- Hashage des mots de passe (bcrypt)
- CORS configuré
- Rate limiting sur l'API Gateway
- Helmet.js pour les headers de sécurité
- Scan de sécurité automatique (Trivy, CodeQL)
- Conteneurs non-root
- Secrets séparés du code

### Recommandations pour la production

1. Changer tous les mots de passe par défaut
2. Utiliser HTTPS (certificats SSL)
3. Activer les firewalls
4. Configurer les backups automatiques
5. Mettre en place une rotation des secrets
6. Activer l'authentification 2FA
7. Monitorer les logs de sécurité

## Documentation API

La documentation complète de l'API est disponible dans le dossier `docs/api/`.

### Exemple d'utilisation

#### Authentification

```bash
# Login
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "Admin@2024"
  }'

# Réponse
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "admin",
    "email": "admin@ratp.fr"
  }
}
```

#### Récupération des utilisateurs

```bash
# Liste des utilisateurs
curl http://localhost:3001/api/users \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Commandes utiles

### Docker Compose

```bash
# Démarrer tous les services
docker-compose up -d

# Arrêter tous les services
docker-compose down

# Arrêter et supprimer les volumes
docker-compose down -v

# Voir les logs
docker-compose logs -f [service]

# Reconstruire un service
docker-compose build [service]

# Redémarrer un service
docker-compose restart [service]

# Voir le statut
docker-compose ps
```

### Logs

```bash
# Tous les logs
docker-compose logs -f

# Logs d'un service spécifique
docker-compose logs -f auth-service

# Dernières 100 lignes
docker-compose logs --tail=100 user-service
```

### Base de données

```bash
# Connexion à PostgreSQL
docker exec -it postgres-db psql -U postgres -d userdb

# Backup d'une base
docker exec postgres-db pg_dump -U postgres userdb > backup.sql

# Restore d'une base
docker exec -i postgres-db psql -U postgres userdb < backup.sql
```

## Structure du projet

```
Projet-RATP-refonte-Suivipro/
├── .github/
│   └── workflows/              # CI/CD GitHub Actions
├── config/                     # Configurations par environnement
├── database/
│   ├── init/                   # Scripts d'initialisation SQL
│   ├── migrations/             # Migrations de schéma
│   └── seeds/                  # Données de test
├── docs/
│   ├── api/                    # Documentation API
│   ├── architecture/           # Diagrammes d'architecture
│   └── guides/                 # Guides utilisateur
├── infrastructure/
│   ├── elk/                    # Configuration ELK
│   ├── superset/               # Configuration Superset
│   ├── matomo/                 # Configuration Matomo
│   ├── monitoring/             # Prometheus & Grafana
│   ├── nginx/                  # Configuration Nginx
│   └── redis/                  # Configuration Redis
├── scripts/
│   ├── deploy/                 # Scripts de déploiement
│   ├── backup/                 # Scripts de backup
│   └── migration/              # Scripts de migration
├── services/
│   ├── backend/
│   │   ├── auth-service/       # Service authentification
│   │   ├── user-service/       # Service utilisateurs
│   │   ├── notification-service/
│   │   ├── reporting-service/
│   │   └── admin-service/
│   ├── frontend/               # Application React
│   └── api-gateway/            # Passerelle API
├── tests/
│   ├── integration/            # Tests d'intégration
│   ├── e2e/                    # Tests end-to-end
│   └── performance/            # Tests de performance
├── .env.example                # Template variables d'environnement
├── .gitignore
├── docker-compose.yml          # Orchestration des services
└── README.md
```

## Contribution

### Workflow de contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

### Standards de code

- Java: Google Java Style Guide
- JavaScript/React: Airbnb JavaScript Style Guide
- Commits: Conventional Commits

## Support

Pour toute question ou problème :

- Ouvrir une issue sur GitHub
- Consulter la documentation dans `/docs`
- Contacter l'équipe technique RATP

## Licence

Propriété de la RATP - Tous droits réservés

## Auteurs

- Équipe Technique RATP
- Projet de refonte SuiviPro

---

**Version** : 1.0.0
**Dernière mise à jour** : 2024
