# Projet RATP - Refonte SuiviPro

Application de refonte du système SuiviPro pour la RATP, basée sur une architecture microservices moderne avec stack complète d'observabilité, analytics et qualité de code.

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

### Services Backend (Java Spring Boot 3.2.0)

1. **auth-service** (Port 8081) - Authentification et autorisation JWT
2. **user-service** (Port 8080) - Gestion des utilisateurs et profils
3. **notification-service** (Port 8082) - Gestion des notifications et emails
4. **reporting-service** (Port 8083) - Génération de rapports et statistiques
5. **admin-service** (Port 8084) - Administration système et audit
6. **document-service** (Port 8085) - Gestion documentaire avec stockage objet
7. **planning-service** (Port 8086) - Gestion des plannings et horaires
8. **intervention-service** (Port 8087) - Suivi des interventions techniques
9. **asset-service** (Port 8088) - Gestion des équipements et matériels
10. **timekeeping-service** (Port 8089) - Gestion du temps de travail

### Services Frontend

- **frontend** (Port 3000) - Application React 18 avec Vite
- **api-gateway** (Port 3001) - Passerelle API Node.js/Express

### Infrastructure

#### Bases de Données
- **PostgreSQL 15** (Port 5432) - Base de données principale
  - authdb, userdb, notificationdb, reportingdb, admindb
  - documentdb, planningdb, interventiondb, assetdb, timekeepingdb
  - supersetdb, sonardb
- **MySQL 8** (Port 3306) - Base de données Matomo
- **Redis 7** (Port 6379) - Cache distribué

#### Messaging & Storage
- **RabbitMQ 3.12** (Ports 5672, 15672) - Message broker avec management UI
- **MinIO** (Ports 9000, 9001) - Stockage objet S3-compatible

#### Observabilité (ELK Stack)
- **Elasticsearch 8.11.0** (Ports 9200, 9300) - Stockage et indexation des logs
- **Logstash** (Port 5000) - Collecte et traitement des logs
- **Kibana** (Port 5601) - Visualisation des logs

#### Analytics & KPI
- **Apache Superset 3.0** (Port 8088) - Création de dashboards et KPI
- **Matomo 5.0** (Port 8080) - Analytics web on-premise

#### Monitoring
- **Prometheus** (Port 9091) - Collecte des métriques
- **Grafana** (Port 3003) - Visualisation des métriques

#### Qualité de Code
- **SonarQube 10 Community** (Port 9090) - Analyse de qualité de code

#### Infrastructure
- **Nginx** (Ports 80, 443) - Reverse proxy et load balancer

## Technologies

### Backend
- Java 17
- Spring Boot 3.2.0
- Spring Data JPA
- Spring Security
- Spring AMQP (RabbitMQ)
- PostgreSQL 15
- Maven 3.9
- JWT (jjwt 0.12.3)
- MinIO SDK
- Apache POI (exports Excel)

### Frontend
- React 18
- Vite 5
- React Router 6
- Axios
- Zustand (state management)
- TanStack Query (React Query)

### Infrastructure
- Docker & Docker Compose
- Nginx
- Redis
- RabbitMQ
- MinIO

### Monitoring & Observabilité
- ELK Stack (Elasticsearch, Logstash, Kibana) 8.11.0
- Prometheus
- Grafana
- Apache Superset 3.0
- Matomo 5.0

### Qualité de Code
- SonarQube 10 Community
- JaCoCo (couverture de code Java)
- ESLint (JavaScript/React)

### CI/CD
- GitHub Actions
- Trivy (security scanning)
- CodeQL (code analysis)
- SonarQube Scanner

## Prérequis

- Docker Desktop 4.x ou supérieur
- Docker Compose 3.8 ou supérieur
- Git
- 16 GB RAM minimum recommandé
- 100 GB d'espace disque libre (avec tous les services)

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
JWT_SECRET=votre-secret-jwt-securise-minimum-256-bits
ELASTIC_PASSWORD=votre-mot-de-passe-elastic
SUPERSET_SECRET_KEY=votre-cle-superset
SONAR_TOKEN=votre-token-sonarqube

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

#### SonarQube
Accéder à http://localhost:9090 (login: admin / password: admin)

## Configuration

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
| Document Service | 8085 | API documents |
| Planning Service | 8086 | API plannings |
| Intervention Service | 8087 | API interventions |
| Asset Service | 8088 | API équipements |
| Timekeeping Service | 8089 | API temps de travail |
| Superset | 8088 | Dashboards KPI |
| SonarQube | 9090 | Qualité de code |
| PostgreSQL | 5432 | Base de données |
| MySQL | 3306 | Base Matomo |
| Redis | 6379 | Cache |
| RabbitMQ | 5672, 15672 | Message broker |
| MinIO | 9000, 9001 | Stockage objet |
| Elasticsearch | 9200, 9300 | Moteur de recherche |
| Logstash | 5000 | Collecteur de logs |
| Kibana | 5601 | Visualisation logs |
| Matomo | 8080 | Analytics |
| Prometheus | 9091 | Métriques |
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
- **SonarQube (Qualité)** : http://localhost:9090
- **Prometheus** : http://localhost:9091
- **RabbitMQ Management** : http://localhost:15672
- **MinIO Console** : http://localhost:9001

### Comptes par défaut

#### Application SuiviPro
- Username: `admin`
- Password: `Admin@2024`

#### Kibana/Elasticsearch
- Username: `elastic`
- Password: `changeme` (configuré dans .env)

#### Grafana
- Username: `admin`
- Password: `admin`

#### Superset
- Username: `admin`
- Password: `Admin@2024`

#### SonarQube
- Username: `admin`
- Password: `admin`

#### RabbitMQ
- Username: `guest`
- Password: `guest`

#### MinIO
- Access Key: `minioadmin`
- Secret Key: `minioadmin`

⚠️ **IMPORTANT** : Changez tous les mots de passe par défaut en production !

## Services

### Microservices Backend

Tous les services backend exposent les endpoints suivants :

- `GET /actuator/health` - Health check
- `GET /actuator/info` - Informations sur le service
- `GET /actuator/metrics` - Métriques
- `GET /actuator/prometheus` - Métriques au format Prometheus

### API Gateway

Routes disponibles :

- `/api/auth/*` → Auth Service (8081)
- `/api/users/*` → User Service (8080)
- `/api/notifications/*` → Notification Service (8082)
- `/api/reports/*` → Reporting Service (8083)
- `/api/admin/*` → Admin Service (8084)
- `/api/documents/*` → Document Service (8085)
- `/api/plannings/*` → Planning Service (8086)
- `/api/interventions/*` → Intervention Service (8087)
- `/api/assets/*` → Asset Service (8088)
- `/api/timekeeping/*` → Timekeeping Service (8089)

### Documentation API (OpenAPI/Swagger)

Chaque service dispose de sa spécification OpenAPI 3.0 dans :
```
services/backend/{service-name}/src/main/resources/openapi.yaml
```

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
- `suivipro-document-service-*`
- `suivipro-planning-service-*`
- `suivipro-intervention-service-*`
- `suivipro-asset-service-*`
- `suivipro-timekeeping-service-*`
- `suivipro-api-gateway-*`

### Métriques (Prometheus + Grafana)

Les métriques de performance et santé sont collectées par Prometheus et visualisables dans Grafana.

**Accès Grafana** : http://localhost:3003

Métriques disponibles :
- CPU, mémoire, disque
- Requêtes HTTP (latence, débit, erreurs)
- Base de données (connexions, requêtes)
- JVM (heap, threads, GC)
- RabbitMQ (messages, queues)
- MinIO (storage, bandwidth)

### KPI et Reporting (Superset)

Apache Superset permet de créer des dashboards personnalisés connectés aux bases de données.

**Accès Superset** : http://localhost:8088

### Analytics (Matomo)

Matomo collecte les données d'utilisation de l'application frontend.

**Accès Matomo** : http://localhost:8080

### Qualité de Code (SonarQube)

SonarQube analyse la qualité du code et détecte les bugs, vulnérabilités et code smells.

**Accès SonarQube** : http://localhost:9090

Projets configurés :
- suivipro-auth-service
- suivipro-user-service
- suivipro-notification-service
- suivipro-reporting-service
- suivipro-admin-service
- suivipro-document-service
- suivipro-planning-service
- suivipro-intervention-service
- suivipro-asset-service
- suivipro-timekeeping-service
- suivipro-frontend
- suivipro-api-gateway

## CI/CD

Le projet utilise GitHub Actions pour l'intégration et le déploiement continus.

### Workflows disponibles

#### CI Backend with Quality Analysis (`ci-backend-quality.yml`)
- Build et tests des services Java
- Analyse SonarQube
- Scan de sécurité avec Trivy
- Génération de rapports de tests
- Quality Gate check

#### SonarQube Analysis (`sonarqube-analysis.yml`)
- Analyse complète de qualité de code
- Backend (tous les services Java)
- Frontend (React)
- API Gateway (Node.js)
- Analyse hebdomadaire programmée

### Configuration

Variables secrets nécessaires dans GitHub :
- `SONAR_TOKEN` - Token d'authentification SonarQube
- `SONAR_HOST_URL` - URL de l'instance SonarQube
- `GITHUB_TOKEN` - Token GitHub (automatique)

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
- Analyse de qualité et vulnérabilités (SonarQube)

### Recommandations pour la production

1. Changer tous les mots de passe par défaut
2. Utiliser HTTPS (certificats SSL)
3. Activer les firewalls
4. Configurer les backups automatiques
5. Mettre en place une rotation des secrets
6. Activer l'authentification 2FA
7. Monitorer les logs de sécurité
8. Maintenir les dépendances à jour
9. Configurer SonarQube Quality Gates
10. Activer les alertes Prometheus

## Documentation API

La documentation complète de l'API est disponible via les spécifications OpenAPI dans chaque service.

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

## Commandes utiles

### Docker Compose

```bash
# Démarrer tous les services
docker-compose up -d

# Démarrer seulement certains services
docker-compose up -d auth-service user-service api-gateway frontend

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
│   │   ├── admin-service/
│   │   ├── document-service/   # Service documents
│   │   ├── planning-service/   # Service plannings
│   │   ├── intervention-service/ # Service interventions
│   │   ├── asset-service/      # Service équipements
│   │   └── timekeeping-service/ # Service temps de travail
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
- Qualité: SonarQube Quality Gates

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

**Version** : 2.0.0
**Dernière mise à jour** : Décembre 2024
