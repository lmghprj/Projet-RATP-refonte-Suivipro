# Projet RATP - Refonte SuiviPro

Application de refonte du système SuiviPro pour la RATP, basée sur une **architecture microservices Domain-Driven Design (DDD)** moderne avec stack complète d'observabilité, analytics et qualité de code.

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

Le projet est structuré selon une **architecture microservices DDD (Domain-Driven Design)** avec **15 bounded contexts** représentant chacun un domaine métier distinct.

### Architecture DDD - Bounded Contexts

L'architecture suit les principes du Domain-Driven Design avec une séparation claire des contextes bornés :

```
┌─────────────────────────────────────────────────────────────────┐
│                         API Gateway (Node.js)                    │
│                              Port 3001                           │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                ┌───────────────┴───────────────┐
                │                               │
    ┌───────────▼──────────┐      ┌────────────▼──────────┐
    │  Core Business       │      │  Support & Transverse │
    │  Bounded Contexts    │      │  Bounded Contexts     │
    └──────────────────────┘      └───────────────────────┘
```

### Services Backend (Java Spring Boot 3.2.0) - Architecture DDD

#### Core Business Domain

1. **ms-agent** (Port 8081) - Contexte "Dossier Agent"
   - Gestion complète des dossiers agents
   - Affectations et historique
   - Visites médicales
   - Constats agents

2. **ms-habilitation** (Port 8082) - Contexte "Habilitations"
   - Gestion des habilitations et certifications
   - Validations et renouvellements
   - Historique des habilitations

3. **ms-formation** (Port 8083) - Contexte "Formation & Instruction"
   - Gestion des formations
   - Instructions de sécurité
   - Plans de formation
   - Évaluations

4. **ms-securite** (Port 8084) - Contexte "Sécurité & Écarts"
   - Gestion des écarts de sécurité
   - Incidents et accidents
   - Actions correctives
   - Analyses de risques

5. **ms-paisf** (Port 8085) - Contexte "PAISF"
   - Plan d'Action Individuel de Sécurité Ferroviaire
   - Suivi et évaluation PAISF
   - Objectifs individuels de sécurité

6. **ms-alerte** (Port 8086) - Contexte "Alertes"
   - Système d'alertes métier
   - Notifications de dépassement
   - Alertes de conformité
   - Escalades automatiques

7. **ms-objectif** (Port 8087) - Contexte "Objectifs & Indicateurs"
   - Définition des objectifs
   - Indicateurs de performance (KPI)
   - Tableaux de bord métier
   - Suivi de performance

8. **ms-reporting** (Port 8088) - Contexte "Reporting & BI"
   - Génération de rapports
   - Exports et consolidations
   - Analytics et statistiques
   - Connexion Superset

9. **ms-organisation** (Port 8089) - Contexte "Organisation"
   - Structure organisationnelle
   - Unités et départements
   - Hiérarchie et responsabilités
   - Secteurs et sites

#### Technical & Support Domain

10. **ms-iam** (Port 8090) - Contexte "Identity & Access Management"
    - Authentification (JWT)
    - Gestion des utilisateurs
    - Rôles et permissions
    - Single Sign-On

11. **ms-document** (Port 8091) - Contexte "Documents & GED"
    - Gestion Électronique de Documents
    - Stockage MinIO (S3-compatible)
    - Versioning et archivage
    - Métadonnées

12. **ms-integration** (Port 8092) - Contexte "Intégration SI"
    - Connecteurs vers SI externes
    - Synchronisation SerfRH
    - Intégration Nefertari, COMPETENCES, VISIR, OSIRIS
    - API de transformation de données

13. **ms-notification** (Port 8093) - Contexte "Notifications"
    - Notifications multi-canal (Email, SMS, Push)
    - Templates de messages
    - Historique des notifications
    - Préférences utilisateur

14. **ms-audit** (Port 8094) - Contexte "Audit & Traçabilité"
    - Logs d'audit
    - Traçabilité des actions
    - Conformité RGPD
    - Rapports d'audit

15. **ms-referentiel** (Port 8095) - Contexte "Référentiels"
    - Données de référence
    - Nomenclatures et catalogues
    - Paramètres métier
    - Configuration globale

### Services Frontend

- **frontend** (Port 3000) - Application React 18 avec Vite
- **api-gateway** (Port 3001) - Passerelle API Node.js/Express avec routage vers les 15 microservices

### Infrastructure

#### Bases de Données
- **PostgreSQL 15** (Port 5432) - Base de données relationnelle
  - Une base par microservice (Database per Service pattern)
  - `suivipro_agent`, `suivipro_habilitation`, `suivipro_formation`, etc.
  - `supersetdb`, `sonardb` pour l'infrastructure
- **MySQL 8** (Port 3306) - Base de données Matomo
- **Redis 7** (Port 6379) - Cache distribué et sessions

#### Event Bus & Messaging
- **Apache Kafka 7.5.0** (Ports 9092, 9093) - Event bus pour architecture événementielle
- **Zookeeper 7.5.0** (Port 2181) - Coordination Kafka
- **MinIO** (Ports 9000, 9001) - Stockage objet S3-compatible

#### Observabilité (ELK Stack)
- **Elasticsearch 8.11.0** (Ports 9200, 9300) - Stockage et indexation des logs
- **Logstash** (Port 5000) - Collecte et traitement des logs
- **Kibana** (Port 5601) - Visualisation des logs

#### Analytics & KPI
- **Apache Superset 3.0** (Port 8088) - Création de dashboards et KPI
- **Matomo 5.0** (Port 8080) - Analytics web on-premise

#### Monitoring
- **Prometheus** (Port 9091) - Collecte des métriques des 15 microservices
- **Grafana** (Port 3003) - Visualisation des métriques et dashboards

#### Qualité de Code
- **SonarQube 10 Community** (Port 9090) - Analyse statique et qualité de code

#### Infrastructure
- **Nginx** (Ports 80, 443) - Reverse proxy et load balancer

## Technologies

### Backend (Microservices)
- **Java 17** - Version LTS
- **Spring Boot 3.2.0** - Framework microservices
- **Spring Data JPA** - Persistence
- **Spring Kafka** - Event-Driven Architecture
- **PostgreSQL 15** - Base de données relationnelle
- **Maven 3.9** - Build tool
- **JWT** - Authentification stateless
- **MinIO SDK** - Client S3-compatible
- **Lombok** - Réduction du boilerplate
- **SpringDoc OpenAPI** - Documentation API automatique

### Frontend
- **React 18** - UI Library
- **Vite 5** - Build tool et dev server
- **React Router 6** - Routing
- **Axios** - HTTP client
- **Zustand** - State management
- **TanStack Query** - Data fetching et cache

### Event-Driven Architecture
- **Apache Kafka** - Event streaming platform
- **Zookeeper** - Coordination de services
- **Spring Cloud Stream** - Abstraction messaging

### Infrastructure
- **Docker** & **Docker Compose** - Containerization
- **Nginx** - Reverse proxy
- **Redis** - Cache et sessions
- **MinIO** - Object storage

### Observability & Monitoring
- **ELK Stack** (Elasticsearch, Logstash, Kibana) - Logs
- **Prometheus** + **Grafana** - Métriques
- **Spring Boot Actuator** - Health checks et métriques
- **Micrometer** - Metrics facade

### Quality & CI/CD
- **SonarQube** - Analyse de code
- **GitHub Actions** - CI/CD pipelines
- **JUnit 5** - Tests unitaires
- **Testcontainers** - Tests d'intégration

## Prérequis

- **Docker** 24+ et **Docker Compose** 2.20+
- **Java 17** (pour développement local)
- **Maven 3.9** (pour développement local)
- **Node.js 20+** (pour développement frontend)
- **Git**
- **Minimum 16 GB RAM** recommandé pour faire tourner toute la stack
- **Minimum 50 GB d'espace disque**

## Installation

### 1. Cloner le repository

```bash
git clone https://github.com/lmghprj/Projet-RATP-refonte-Suivipro.git
cd Projet-RATP-refonte-Suivipro
```

### 2. Configuration des variables d'environnement

Créer un fichier `.env` à la racine :

```env
# Database
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
DB_USER=suivipro
DB_PASSWORD=suivipro123

# Security
JWT_SECRET=your-very-secure-secret-key-change-me-in-production
ELASTIC_PASSWORD=changeme
SUPERSET_SECRET_KEY=changez-cette-cle-en-production
SUPERSET_ADMIN_PASSWORD=Admin@2024
GRAFANA_PASSWORD=admin

# Email (optionnel)
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@domain.com
MAIL_PASSWORD=your-email-password

# Kafka
KAFKA_BOOTSTRAP_SERVERS=kafka:9092
```

### 3. Lancer l'application complète

```bash
# Lancer tous les services
docker-compose up -d

# Voir les logs
docker-compose logs -f

# Vérifier l'état des services
docker-compose ps
```

### 4. Lancer uniquement l'infrastructure

```bash
# Lancer uniquement les services d'infrastructure
docker-compose up -d postgres kafka zookeeper redis minio elasticsearch kibana prometheus grafana
```

### 5. Build des microservices (développement local)

```bash
# Build tous les microservices
cd services/backend
for dir in ms-*/; do
  cd "$dir"
  mvn clean package -DskipTests
  cd ..
done
```

## Configuration

### Ports et URLs

#### Services Métier
- **API Gateway**: http://localhost:3001
- **Frontend**: http://localhost:3000
- **ms-agent**: http://localhost:8081
- **ms-habilitation**: http://localhost:8082
- **ms-formation**: http://localhost:8083
- **ms-securite**: http://localhost:8084
- **ms-paisf**: http://localhost:8085
- **ms-alerte**: http://localhost:8086
- **ms-objectif**: http://localhost:8087
- **ms-reporting**: http://localhost:8088
- **ms-organisation**: http://localhost:8089
- **ms-iam**: http://localhost:8090
- **ms-document**: http://localhost:8091
- **ms-integration**: http://localhost:8092
- **ms-notification**: http://localhost:8093
- **ms-audit**: http://localhost:8094
- **ms-referentiel**: http://localhost:8095

#### Infrastructure
- **PostgreSQL**: localhost:5432
- **Kafka**: localhost:9092, localhost:9093
- **Zookeeper**: localhost:2181
- **Redis**: localhost:6379
- **MinIO**: http://localhost:9000 (API), http://localhost:9001 (Console)

#### Observabilité & Analytics
- **Kibana**: http://localhost:5601
- **Grafana**: http://localhost:3003
- **Prometheus**: http://localhost:9091
- **Superset**: http://localhost:8088
- **Matomo**: http://localhost:8080
- **SonarQube**: http://localhost:9090

#### Reverse Proxy
- **Nginx**: http://localhost (80), https://localhost (443)

### Documentation API (Swagger/OpenAPI)

Chaque microservice expose sa documentation OpenAPI :

- **ms-agent**: http://localhost:8081/swagger-ui.html
- **ms-habilitation**: http://localhost:8082/swagger-ui.html
- **ms-formation**: http://localhost:8083/swagger-ui.html
- **ms-securite**: http://localhost:8084/swagger-ui.html
- ... (tous les autres microservices suivent le même pattern)

### Credentials par défaut

#### MinIO
- **Access Key**: minioadmin
- **Secret Key**: minioadmin

#### Superset
- **Username**: admin
- **Password**: Admin@2024 (ou valeur de SUPERSET_ADMIN_PASSWORD)

#### Grafana
- **Username**: admin
- **Password**: admin (ou valeur de GRAFANA_PASSWORD)

#### SonarQube
- **Username**: admin
- **Password**: admin (à changer à la première connexion)

#### Elasticsearch/Kibana
- **Username**: elastic
- **Password**: changeme (ou valeur de ELASTIC_PASSWORD)

## Utilisation

### Arrêter les services

```bash
# Arrêter tous les services
docker-compose down

# Arrêter et supprimer les volumes (⚠️ perte de données)
docker-compose down -v
```

### Redémarrer un service spécifique

```bash
docker-compose restart ms-agent
```

### Voir les logs d'un service

```bash
docker-compose logs -f ms-agent
```

### Accéder à un container

```bash
docker-compose exec ms-agent bash
```

## Services

### Accès aux différents services

#### Développement Frontend
```bash
cd services/frontend
npm install
npm run dev
```

#### Développement d'un microservice
```bash
cd services/backend/ms-agent
mvn spring-boot:run
```

#### Accès à PostgreSQL
```bash
docker-compose exec postgres psql -U postgres
\l  # Liste des bases de données
\c suivipro_agent  # Se connecter à la base ms-agent
\dt  # Liste des tables
```

#### Accès à Kafka
```bash
# Liste des topics
docker-compose exec kafka kafka-topics --list --bootstrap-server localhost:9092

# Créer un topic
docker-compose exec kafka kafka-topics --create --topic test-topic --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1

# Consommer un topic
docker-compose exec kafka kafka-console-consumer --topic agent-events --bootstrap-server localhost:9092 --from-beginning
```

## Monitoring et Observabilité

### Prometheus
- URL: http://localhost:9091
- Collecte automatique des métriques des 15 microservices via `/actuator/prometheus`
- Métriques JVM, HTTP, Kafka, base de données

### Grafana
- URL: http://localhost:3003
- Dashboards préconfigurés pour :
  - Vue d'ensemble des microservices
  - Performance des API
  - Métriques Kafka
  - État de santé des services

### ELK Stack (Logs)
- **Kibana**: http://localhost:5601
- Centralisation des logs de tous les microservices
- Patterns de log structurés (JSON)
- Dashboards de monitoring des erreurs

### Apache Superset (KPI)
- URL: http://localhost:8088
- Connexion aux bases de données PostgreSQL
- Création de dashboards métier
- Rapports et analyses

## CI/CD

### GitHub Actions

Workflows disponibles :
- **ci-backend-quality.yml** - Build et tests des microservices + SonarQube
- **ci-frontend.yml** - Build et tests frontend
- **docker-build.yml** - Build des images Docker

### SonarQube

Analyse de code automatique :
- Coverage des tests
- Code smells
- Bugs et vulnérabilités
- Duplications
- Complexité cyclomatique

```bash
# Analyser un microservice
cd services/backend/ms-agent
mvn clean verify sonar:sonar \
  -Dsonar.host.url=http://localhost:9090 \
  -Dsonar.login=your-sonar-token
```

## Sécurité

### Authentification
- **JWT** (JSON Web Tokens) géré par **ms-iam**
- Tokens avec expiration configurable
- Refresh tokens pour sessions longues

### Autorisation
- **RBAC** (Role-Based Access Control)
- Permissions granulaires par bounded context
- Spring Security sur tous les microservices

### Communication inter-services
- Réseau Docker privé (suivipro-network)
- TLS/SSL via Nginx reverse proxy
- Validation des tokens JWT entre services

### Données sensibles
- Variables d'environnement pour les secrets
- Pas de credentials en dur dans le code
- Support pour HashiCorp Vault (à configurer)

## Documentation API

Chaque microservice expose :
- **OpenAPI 3.0** spec à `/api-docs`
- **Swagger UI** à `/swagger-ui.html`
- **Spring Boot Actuator** à `/actuator`

### API Gateway
L'API Gateway route les requêtes vers les microservices :
- `/api/agents` → ms-agent
- `/api/habilitations` → ms-habilitation
- `/api/formations` → ms-formation
- `/api/securite` → ms-securite
- `/api/paisf` → ms-paisf
- `/api/alertes` → ms-alerte
- `/api/objectifs` → ms-objectif
- `/api/reports` → ms-reporting
- `/api/organisation` → ms-organisation
- `/api/auth` → ms-iam
- `/api/documents` → ms-document
- `/api/integration` → ms-integration
- `/api/notifications` → ms-notification
- `/api/audit` → ms-audit
- `/api/referentiels` → ms-referentiel

## Contribution

### Workflow de développement

1. Créer une branche feature
```bash
git checkout -b feature/nom-de-la-feature
```

2. Développer et tester localement
```bash
# Tests unitaires
mvn test

# Tests d'intégration
mvn verify
```

3. Commit avec messages conventionnels
```bash
git commit -m "feat(ms-agent): ajout endpoint recherche agents"
git commit -m "fix(ms-iam): correction validation JWT"
```

4. Push et créer une Pull Request
```bash
git push origin feature/nom-de-la-feature
```

### Standards de code

- **Java**: Google Java Style Guide
- **JavaScript**: ESLint + Prettier
- **Commits**: Conventional Commits
- **Tests**: Minimum 80% de coverage

## Architecture Détaillée

### Patterns Utilisés

1. **Domain-Driven Design (DDD)**
   - Bounded Contexts clairement définis
   - Ubiquitous Language
   - Aggregates et Entities
   - Value Objects

2. **Event-Driven Architecture**
   - Event Sourcing partiel
   - CQRS (Command Query Responsibility Segregation)
   - Saga pattern pour transactions distribuées

3. **Microservices Patterns**
   - Database per Service
   - API Gateway
   - Service Discovery
   - Circuit Breaker
   - Health Check API

4. **Data Patterns**
   - Repository pattern
   - DTO (Data Transfer Objects)
   - Mapper pattern

### Intégrations Externes

Le microservice **ms-integration** gère les connexions avec :
- **SerfRH** - Système RH
- **Nefertari** - Gestion documentaire
- **COMPETENCES** - Référentiel des compétences
- **VISIR** - Système de gestion
- **OSIRIS** - Base de données opérationnelle
- **Digiplan** - Planning
- **FOSTER** - Formation

## License

Propriété de la RATP - Tous droits réservés

## Contact

Pour toute question ou support :
- **Email**: support-suivipro@ratp.fr
- **Repository**: https://github.com/lmghprj/Projet-RATP-refonte-Suivipro

---

**Version**: 2.0.0 (Architecture DDD)
**Dernière mise à jour**: Décembre 2024
