# 🚇 Page de Démonstration - SuiviPro RATP

## 📋 Objectif

Cette page de démonstration permet de tester rapidement le bon fonctionnement de l'infrastructure microservices SuiviPro RATP après déploiement.

## 🎯 Fonctionnalités testées

La page de démo teste :

1. ✅ **API Gateway** - Point d'entrée de l'API
2. ✅ **Microservices** - Connectivité aux microservices
3. ✅ **Base de données** - Connexion PostgreSQL
4. ✅ **Temps de réponse** - Performance des services

## 🚀 Accès à la page de démo

### URL locale

```
http://localhost:3000/demo
```

### URL Docker

```
http://localhost:8080/demo
```

## 🏗️ Architecture testée

```
Frontend ──▶ API Gateway (3001) ──▶ Microservices (8081-8095) ──▶ PostgreSQL
```

### Services testés

| Service | Port | Endpoint | Description |
|---------|------|----------|-------------|
| **API Gateway** | 3001 | `/api/health` | Health check de l'API Gateway |
| **MS-Agent** | 8081 | `/api/agents/health` | Health check MS-Agent |
| **MS-Agent DB** | 8081 | `/api/agents/db-test` | Test connexion PostgreSQL |
| **MS-Habilitation** | 8082 | `/api/habilitations/health` | Health check MS-Habilitation |
| **MS-Formation** | 8083 | `/api/formations/health` | Health check MS-Formation |
| **MS-IAM** | 8090 | `/api/iam/health` | Health check MS-IAM |

## 📦 Prérequis

### 1. Démarrer l'infrastructure

```bash
# Démarrer tous les services
docker-compose up -d

# Vérifier que tous les services sont démarrés
docker-compose ps
```

### 2. Vérifier les services

```bash
# API Gateway
curl http://localhost:3001/api/health

# MS-Agent
curl http://localhost:8081/actuator/health

# PostgreSQL (via ms-agent)
curl http://localhost:3001/api/agents/db-test
```

## 🖥️ Utilisation de la page de démo

### 1. Accéder à la page

Ouvrir votre navigateur et accéder à : http://localhost:3000/demo

### 2. Tester un service individuellement

- Cliquer sur le bouton **🔍 Tester** dans la carte d'un service
- Le résultat s'affiche en temps réel avec :
  - ✅ ou ❌ selon le succès/échec
  - Le code HTTP de retour
  - Le temps de réponse en millisecondes
  - Les données retournées par le service

### 3. Tester tous les services

- Cliquer sur le bouton **🔄 Tester tous les services**
- Tous les tests s'exécutent en parallèle
- Les résultats s'affichent au fur et à mesure

### 4. Interpréter les résultats

#### Résultat réussi (✅)
```json
{
  "status": "healthy",
  "service": "ms-agent",
  "port": 8081,
  "domain": "agent",
  "timestamp": "2024-12-04T22:35:00",
  "description": "Microservice de gestion des dossiers agents"
}
```

**Code HTTP** : 200
**Couleur** : Vert
**Signification** : Le service est opérationnel

#### Résultat échoué (❌)

```json
{
  "error": "connect ECONNREFUSED 127.0.0.1:8081"
}
```

**Code HTTP** : 0 ou 500
**Couleur** : Rouge
**Signification** : Le service n'est pas accessible

### 5. Test de la base de données

Le test de base de données vérifie :

- ✅ Connexion au serveur PostgreSQL
- ✅ Validation de la connexion
- ✅ Nom et version de la base
- ✅ URL de connexion

Exemple de résultat réussi :

```json
{
  "status": "success",
  "connected": true,
  "database": "PostgreSQL",
  "version": "15.3",
  "url": "jdbc:postgresql://postgres:5432/suivipro_agent",
  "timestamp": "2024-12-04T22:35:10",
  "message": "Connexion à la base de données réussie"
}
```

## 🔧 Dépannage

### Problème : API Gateway ne répond pas

**Symptôme** :
```
Error: connect ECONNREFUSED 127.0.0.1:3001
```

**Solutions** :

1. Vérifier que l'API Gateway est démarré :
   ```bash
   docker-compose ps api-gateway
   ```

2. Vérifier les logs :
   ```bash
   docker-compose logs api-gateway
   ```

3. Redémarrer l'API Gateway :
   ```bash
   docker-compose restart api-gateway
   ```

### Problème : Microservice ne répond pas

**Symptôme** :
```
HTTP 500 - Service temporairement indisponible
```

**Solutions** :

1. Vérifier que le microservice est démarré :
   ```bash
   docker-compose ps ms-agent
   ```

2. Vérifier les logs :
   ```bash
   docker-compose logs ms-agent
   ```

3. Attendre le démarrage complet (les microservices Spring Boot prennent 30-60 secondes) :
   ```bash
   docker-compose logs -f ms-agent
   # Attendre "Started AgentServiceApplication"
   ```

### Problème : Connexion base de données échoue

**Symptôme** :
```json
{
  "status": "error",
  "connected": false,
  "error": "Connection refused"
}
```

**Solutions** :

1. Vérifier que PostgreSQL est démarré :
   ```bash
   docker-compose ps postgres
   ```

2. Vérifier les logs PostgreSQL :
   ```bash
   docker-compose logs postgres
   ```

3. Tester la connexion directement :
   ```bash
   docker-compose exec postgres psql -U postgres -c "SELECT version();"
   ```

### Problème : CORS Error

**Symptôme** :
```
Access to XMLHttpRequest has been blocked by CORS policy
```

**Solution** :

Vérifier que l'API Gateway autorise l'origine du frontend dans `services/api-gateway/src/index.js` :

```javascript
app.use(cors({
  origin: ['http://localhost:3000', 'http://localhost:8080'],
  credentials: true,
}));
```

## 📊 Résultats attendus

Après un déploiement réussi, tous les tests doivent être **verts (✅)** :

- ✅ API Gateway : 200 OK (~10-50ms)
- ✅ MS-Agent : 200 OK (~50-200ms)
- ✅ MS-Agent DB : 200 OK (~100-300ms)
- ✅ MS-Habilitation : 200 OK (~50-200ms)
- ✅ MS-Formation : 200 OK (~50-200ms)
- ✅ MS-IAM : 200 OK (~50-200ms)

**Total** : 6/6 réussis

## 🔄 Mise à jour de la page de démo

Pour ajouter un nouveau microservice à tester, éditer `/services/frontend/src/pages/DemoPage.jsx` :

```javascript
const tests = [
  // ... tests existants
  {
    name: 'ms-nouveau',
    endpoint: '/api/nouveau/health',
    description: 'MS-Nouveau Health Check'
  },
]
```

Et ajouter une nouvelle carte dans le JSX :

```jsx
<div className="test-card">
  <div className="card-header">
    <h3>MS-Nouveau</h3>
    <span className={`status-badge status-${getStatusColor(results['ms-nouveau'])}`}>
      {getStatusIcon(results['ms-nouveau'])}
    </span>
  </div>
  <p className="description">Description du nouveau service</p>
  <button
    className="btn btn-test"
    onClick={() => testEndpoint('ms-nouveau', '/api/nouveau/health', 'MS-Nouveau Health Check')}
    disabled={loading['ms-nouveau']}
  >
    {loading['ms-nouveau'] ? '⏳ Test en cours...' : '🔍 Tester'}
  </button>
  {/* ... affichage des résultats ... */}
</div>
```

## 📝 Notes techniques

### Technologies utilisées

- **Frontend** : React 18 + Vite
- **HTTP Client** : Axios
- **Styling** : CSS moderne avec animations
- **API Gateway** : Node.js + Express
- **Microservices** : Spring Boot 3.2 + Java 17
- **Base de données** : PostgreSQL 15

### Configuration

#### Frontend (.env)

```bash
VITE_API_GATEWAY_URL=http://localhost:3001
```

#### API Gateway

Port : 3001
CORS : Activé pour localhost:3000 et localhost:8080

#### Microservices

Ports : 8081-8095
Endpoints health : `/api/{service}/health`
Endpoints db-test : `/api/{service}/db-test`

## 🎨 Captures d'écran

### Vue d'ensemble

![Demo Page Overview](docs/images/demo-page.png)

### Test réussi

![Successful Test](docs/images/demo-success.png)

### Test échoué

![Failed Test](docs/images/demo-error.png)

## 📚 Ressources

- [Architecture DDD](README.md#architecture)
- [Docker Compose](docker-compose.yml)
- [API Gateway](services/api-gateway/README.md)
- [Documentation microservices](services/backend/README.md)

## ✅ Checklist de déploiement

Avant de déployer en production, vérifier que :

- [ ] Tous les services démarrent sans erreur
- [ ] Tous les tests de la page de démo sont verts
- [ ] Les temps de réponse sont acceptables (< 1 seconde)
- [ ] La base de données est accessible depuis tous les microservices
- [ ] Les logs sont correctement générés
- [ ] Le monitoring est en place (Prometheus, Grafana)
- [ ] Les sauvegardes sont configurées

## 🔐 Sécurité

⚠️ **Important** : Cette page de démo est conçue pour les environnements de développement et de test.

**En production** :

- Activer l'authentification pour accéder à la page
- Restreindre les CORS aux domaines autorisés
- Utiliser HTTPS
- Masquer les informations sensibles (URLs de base de données, versions, etc.)
- Désactiver les endpoints de test ou les protéger par authentification

## 📞 Support

Pour toute question ou problème :

1. Consulter la section [Dépannage](#dépannage)
2. Vérifier les logs : `docker-compose logs`
3. Contacter l'équipe DevOps RATP

---

**Version** : 1.0.0
**Date** : 2024-12-04
**Auteur** : Équipe DevOps SuiviPro RATP
