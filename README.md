# Projet de Référence - Architecture Microservices

Projet de référence démontrant une architecture microservices avec Node.js, Java Spring Boot, et PostgreSQL, orchestrée avec Docker.

## Architecture

Le projet est composé de cinq services principaux :

- **Frontend** (React/Vite) - Port 3002
  - Interface utilisateur moderne et réactive
  - Authentification avec JWT
  - Gestion des rôles et permissions
  - Dashboard administrateur

- **API Gateway** (Node.js/Express) - Port 3000
  - Point d'entrée unique pour toutes les requêtes
  - Routage vers les différents microservices
  - Gestion des CORS et logging

- **Auth Service** (Node.js/Express) - Port 3001
  - Service d'authentification et autorisation
  - Gestion des utilisateurs et rôles (admin, manager, user, guest)
  - JWT pour les tokens d'authentification
  - Hashage sécurisé des mots de passe (bcrypt)

- **User Service** (Java Spring Boot) - Port 8080
  - Service de gestion des utilisateurs
  - API REST complète (CRUD)
  - Connexion à PostgreSQL (userdb)

- **PostgreSQL** - Port 5432
  - Base de données relationnelle
  - Deux bases de données : `userdb` et `authdb`
  - Données persistantes via volumes Docker

## Prérequis

- [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)

### Extensions VS Code recommandées

Les extensions suivantes seront suggérées automatiquement à l'ouverture du projet :

- Docker
- Java Extension Pack
- Spring Boot Extension Pack
- Prettier - Code formatter
- ESLint
- PostgreSQL Client

## Installation et Démarrage

### 1. Cloner le projet

```bash
git clone <votre-repo-url>
cd Projet-de-reference
```

### 2. Démarrer l'ensemble des services avec Docker Compose

```bash
docker-compose up -d
```

Cette commande va :
- Construire les images Docker pour l'API Gateway et le User Service
- Télécharger l'image PostgreSQL
- Démarrer tous les services
- Créer les volumes pour la persistance des données

### 3. Vérifier que les services sont démarrés

```bash
docker-compose ps
```

Tous les services doivent avoir le status "Up".

### 4. Accéder à l'application

#### Interface Web (Frontend)

Ouvrez votre navigateur et accédez à : **http://localhost:3002**

**Connexion avec le compte administrateur :**
- Username : `admin`
- Password : `Azerty01*`

Une fois connecté, vous accéderez au dashboard qui affiche :
- Votre profil utilisateur avec vos rôles
- La liste des utilisateurs (pour les administrateurs)
- Les informations sur les différents rôles disponibles

### 5. Tester l'API

#### Authentification (via API Gateway)

```bash
# Connexion
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "Azerty01*"
  }'

# La réponse contient un token JWT :
# {
#   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
#   "user": { ... }
# }

# Utiliser le token pour les requêtes protégées
TOKEN="votre-token-jwt-ici"

# Récupérer le profil
curl http://localhost:3000/api/auth/profile \
  -H "Authorization: Bearer $TOKEN"

# Enregistrer un nouvel utilisateur
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "johndoe",
    "email": "john.doe@example.com",
    "password": "P@ssw0rd123!",
    "firstName": "John",
    "lastName": "Doe"
  }'
```

#### Gestion des utilisateurs (via API Gateway)

```bash
# Health check de l'API Gateway
curl http://localhost:3000/health

# Lister tous les utilisateurs (User Service)
curl http://localhost:3000/api/users

# Créer un utilisateur (User Service)
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Jane",
    "lastName": "Smith",
    "email": "jane.smith@example.com"
  }'
```

## Scripts de Gestion Windows

Pour faciliter la gestion de l'application sous Windows, deux scripts sont disponibles :

### Script Batch (docker-manage.bat)

Script simple pour les utilisateurs qui préfèrent l'invite de commande Windows.

```cmd
# Démarrer l'application
docker-manage.bat start

# Arrêter l'application
docker-manage.bat stop

# Redémarrer l'application
docker-manage.bat restart

# Reconstruire et redémarrer
docker-manage.bat rebuild

# Voir les logs
docker-manage.bat logs

# Voir le statut
docker-manage.bat status

# Nettoyer (supprimer conteneurs et volumes)
docker-manage.bat clean
```

### Script PowerShell (docker-manage.ps1)

Script avancé avec interface colorée et vérification de santé.

**Note:** Si vous obtenez une erreur d'exécution de script PowerShell, exécutez d'abord :
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Utilisation :**

```powershell
# Afficher l'aide
.\docker-manage.ps1

# Démarrer l'application
.\docker-manage.ps1 start

# Arrêter l'application
.\docker-manage.ps1 stop

# Redémarrer l'application
.\docker-manage.ps1 restart

# Reconstruire et redémarrer
.\docker-manage.ps1 rebuild

# Voir les logs
.\docker-manage.ps1 logs

# Voir le statut
.\docker-manage.ps1 status

# Vérifier la santé des services (avec tests HTTP)
.\docker-manage.ps1 health

# Nettoyer (supprimer conteneurs et volumes)
.\docker-manage.ps1 clean
```

### Commandes Recommandées

**Démarrage rapide :**
```powershell
.\docker-manage.ps1 start
```

**Vérifier que tout fonctionne :**
```powershell
.\docker-manage.ps1 health
```

**Voir les logs en temps réel :**
```powershell
.\docker-manage.ps1 logs
```

**Nettoyer et repartir de zéro :**
```powershell
.\docker-manage.ps1 clean
.\docker-manage.ps1 start
```

## Structure du Projet

```
Projet-de-reference/
├── services/
│   ├── frontend/             # Interface utilisateur (React/Vite)
│   │   ├── src/
│   │   │   ├── components/   # Composants réutilisables
│   │   │   ├── contexts/     # Contextes React (AuthContext)
│   │   │   ├── pages/        # Pages (Login, Dashboard)
│   │   │   ├── services/     # Services API
│   │   │   ├── styles/       # Fichiers CSS
│   │   │   ├── App.jsx       # Composant principal
│   │   │   └── main.jsx      # Point d'entrée
│   │   ├── package.json
│   │   ├── vite.config.js
│   │   ├── Dockerfile
│   │   └── index.html
│   │
│   ├── api-gateway/          # Service API Gateway (Node.js)
│   │   ├── src/
│   │   │   └── index.js      # Point d'entrée
│   │   ├── package.json
│   │   ├── Dockerfile
│   │   └── .env
│   │
│   ├── auth-service/         # Service d'authentification (Node.js)
│   │   ├── src/
│   │   │   ├── config/       # Configuration (database)
│   │   │   ├── controllers/  # Contrôleurs (authController)
│   │   │   ├── middleware/   # Middleware (auth)
│   │   │   ├── models/       # Modèles Sequelize (User, Role)
│   │   │   ├── routes/       # Routes (authRoutes)
│   │   │   ├── utils/        # Utilitaires (JWT, initDatabase)
│   │   │   └── index.js      # Point d'entrée
│   │   ├── package.json
│   │   ├── Dockerfile
│   │   └── .env
│   │
│   └── user-service/         # Service utilisateur (Spring Boot)
│       ├── src/
│       │   └── main/
│       │       ├── java/
│       │       │   └── com/example/userservice/
│       │       │       ├── controller/
│       │       │       ├── model/
│       │       │       ├── repository/
│       │       │       ├── service/
│       │       │       └── UserServiceApplication.java
│       │       └── resources/
│       │           └── application.properties
│       ├── pom.xml
│       └── Dockerfile
│
├── database/
│   └── init/
│       ├── 01-init.sql       # Script d'initialisation userdb
│       └── 02-init-auth.sql  # Script d'initialisation authdb
│
├── .vscode/                  # Configuration VS Code
│   ├── settings.json
│   ├── extensions.json
│   ├── launch.json
│   └── tasks.json
│
├── docker-compose.yml        # Orchestration des services
├── docker-manage.bat         # Script de gestion Windows (Batch)
├── docker-manage.ps1         # Script de gestion Windows (PowerShell)
├── .gitignore
└── README.md
```

## Développement Local

### Développer l'API Gateway

```bash
cd services/api-gateway
npm install
npm run dev
```

### Développer le User Service

Ouvrir le projet dans VS Code et utiliser les fonctionnalités Spring Boot Dashboard ou lancer directement :

```bash
cd services/user-service
./mvnw spring-boot:run    # Linux/Mac
mvnw.cmd spring-boot:run  # Windows
```

### Accéder à la base de données PostgreSQL

Vous pouvez vous connecter à PostgreSQL avec les paramètres suivants :

- **Host:** localhost
- **Port:** 5432
- **Database:** userdb
- **Username:** postgres
- **Password:** postgres

## Commandes Utiles

### Docker Compose

```bash
# Démarrer les services
docker-compose up -d

# Arrêter les services
docker-compose down

# Voir les logs
docker-compose logs -f

# Voir les logs d'un service spécifique
docker-compose logs -f api-gateway
docker-compose logs -f user-service

# Reconstruire les images
docker-compose build

# Reconstruire et redémarrer
docker-compose up -d --build

# Supprimer les volumes (attention : perte de données)
docker-compose down -v
```

### VS Code

Le projet inclut des tâches VS Code prédéfinies (Ctrl+Shift+P → "Tasks: Run Task") :

- `docker-compose-up` : Démarrer tous les services
- `docker-compose-down` : Arrêter tous les services
- `docker-compose-build` : Reconstruire les images
- `install-api-gateway-dependencies` : Installer les dépendances Node.js

## API Endpoints

### API Gateway

- `GET /` - Informations sur l'API
- `GET /health` - Health check

### Auth Service (via API Gateway)

**Routes publiques :**
- `POST /api/auth/login` - Connexion utilisateur
- `POST /api/auth/register` - Inscription nouvel utilisateur

**Routes protégées (nécessitent un token JWT) :**
- `GET /api/auth/profile` - Récupère le profil de l'utilisateur connecté
- `GET /api/auth/verify` - Vérifie la validité du token

### User Service (via API Gateway)

- `GET /api/users` - Liste tous les utilisateurs
- `GET /api/users/{id}` - Récupère un utilisateur par son ID
- `POST /api/users` - Crée un nouvel utilisateur
- `PUT /api/users/{id}` - Met à jour un utilisateur
- `DELETE /api/users/{id}` - Supprime un utilisateur
- `GET /api/users/health` - Health check du service

## Système d'Authentification

### Rôles Disponibles

Le système gère quatre types de rôles avec des permissions différentes :

1. **Admin** 🔴
   - Accès complet à toutes les fonctionnalités
   - Gestion des utilisateurs et des rôles
   - Permissions : `create`, `read`, `update`, `delete` sur toutes les ressources

2. **Manager** 🟠
   - Accès étendu avec droits de gestion
   - Création et modification des utilisateurs
   - Consultation des rapports
   - Permissions : `create`, `read`, `update` sur les utilisateurs

3. **User** 🟢
   - Accès standard aux fonctionnalités de base
   - Consultation et modification de son propre profil
   - Permissions : `read`, `update` sur son profil

4. **Guest** ⚪
   - Accès limité en lecture seule
   - Consultation de son propre profil
   - Permissions : `read` sur son profil

### Compte Administrateur par Défaut

Au premier démarrage, un compte administrateur est automatiquement créé :

- **Username :** `admin`
- **Password :** `Azerty01*`
- **Email :** admin@example.com
- **Rôle :** Admin

⚠️ **IMPORTANT :** Changez ce mot de passe en production !

### JWT (JSON Web Tokens)

L'authentification utilise des tokens JWT avec les caractéristiques suivantes :
- **Durée de validité :** 24 heures (configurable)
- **Algorithme :** HS256
- **Contenu du token :** ID utilisateur, username, email, rôles

### Sécurité

- Mots de passe hashés avec **bcrypt** (salt rounds: 10)
- Validation des mots de passe : minimum 8 caractères, 1 majuscule, 1 minuscule, 1 chiffre, 1 caractère spécial
- Protection CORS configurable
- Tokens automatiquement vérifiés sur les routes protégées

## Dépannage

### Les services ne démarrent pas

1. Vérifier que Docker Desktop est bien lancé
2. Vérifier qu'aucun autre service n'utilise les ports 3000, 3001, 3002, 8080 ou 5432
3. Consulter les logs : `docker-compose logs`
4. Pour un service spécifique : `docker-compose logs auth-service` ou `docker-compose logs frontend`

### Erreur de connexion à PostgreSQL

Attendre quelques secondes après le démarrage de Docker Compose. PostgreSQL peut prendre un peu de temps pour être complètement opérationnel.

### Reconstruire complètement le projet

```bash
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

## Contribution

Ce projet sert de référence pour une architecture microservices. N'hésitez pas à l'adapter à vos besoins spécifiques.

## Licence

MIT
