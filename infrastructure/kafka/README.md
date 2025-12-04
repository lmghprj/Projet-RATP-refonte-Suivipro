# Déploiement Kafka pour SuiviPro 2

Documentation complète du déploiement de l'infrastructure Kafka pour le système SuiviPro 2 de la RATP.

## Table des Matières

- [Vue d'ensemble](#vue-densemble)
- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Installation Rapide](#installation-rapide)
- [Configuration Détaillée](#configuration-détaillée)
- [Topics Kafka](#topics-kafka)
- [Scripts de Gestion](#scripts-de-gestion)
- [Monitoring](#monitoring)
- [Sécurité](#sécurité)
- [Performance Tuning](#performance-tuning)
- [Troubleshooting](#troubleshooting)
- [Maintenance](#maintenance)

---

## Vue d'ensemble

Cette infrastructure Kafka est conçue pour gérer les événements et la communication asynchrone entre les microservices de SuiviPro 2, le système de suivi professionnel des agents RER de la RATP.

### Caractéristiques Principales

- **Haute disponibilité** : Cluster de 3 brokers Kafka avec réplication
- **Durabilité** : Facteur de réplication 3, min.insync.replicas=2
- **Performance** : Optimisé pour ~500K événements/jour
- **Monitoring** : Kafka UI, JMX metrics, healthchecks
- **Scalabilité** : 30 topics avec 252 partitions totales

### Volumes de Données Estimés

- **3 000 agents** RER lignes A et B
- **~500K événements/jour** :
  - 500K logs audit
  - 100K événements applicatifs
  - 5K métriques monitoring
- **Rétention** : 7 à 365 jours selon le type d'événement
- **Stockage** : ~81 GB avec réplication (recommandé : 500 GB/broker)

---

## Architecture

### Composants Déployés

Le cluster Kafka comprend **10 conteneurs Docker** :

#### ZooKeeper Ensemble (3 nœuds)
- **zookeeper-1** : 172.25.0.11:2181
- **zookeeper-2** : 172.25.0.12:2182
- **zookeeper-3** : 172.25.0.13:2183

**Spécifications par nœud** :
- CPU : 2 vCPU
- RAM : 4 GB (2 GB heap JVM)
- Disque : 50 GB SSD

#### Kafka Brokers (3 nœuds)
- **kafka-broker-1** : 172.25.0.21:9092 (externe: 19092)
- **kafka-broker-2** : 172.25.0.22:9093 (externe: 19093)
- **kafka-broker-3** : 172.25.0.23:9094 (externe: 19094)

**Spécifications par broker** :
- CPU : 4-8 vCPU
- RAM : 16 GB (8 GB heap + 8 GB page cache)
- Disque : 500 GB SSD (RAID 10 recommandé)
- Réseau : 1-10 Gbps

#### Services Auxiliaires

- **Schema Registry** (172.25.0.31:8081) : Gestion des schémas Avro/JSON
- **Kafka Connect** (172.25.0.32:8083) : Connecteurs CDC et intégrations
- **Kafka UI** (172.25.0.40:8080) : Interface de management web
- **kafka-init** : Conteneur d'initialisation des topics

### Diagramme d'Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        SuiviPro 2 - Kafka Cluster              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐     │
│  │  ZooKeeper 1  │  │  ZooKeeper 2  │  │  ZooKeeper 3  │     │
│  │   :2181       │  │   :2182       │  │   :2183       │     │
│  └───────┬───────┘  └───────┬───────┘  └───────┬───────┘     │
│          │                   │                   │              │
│          └───────────────────┼───────────────────┘              │
│                              │                                  │
│  ┌────────────────────────┬──┴──┬────────────────────────┐    │
│  │                        │     │                        │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │    │
│  │  │  Broker 1   │  │  Broker 2   │  │  Broker 3   │  │    │
│  │  │   :9092     │  │   :9093     │  │   :9094     │  │    │
│  │  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  │    │
│  │         │                │                 │         │    │
│  │         └────────────────┼─────────────────┘         │    │
│  │                          │                           │    │
│  │  ┌───────────────────────┴──────────────────────┐   │    │
│  │  │           Topics (30 topics, 252 partitions) │   │    │
│  │  │  - suivipro.agent.events.*                   │   │    │
│  │  │  - suivipro.habilitation.events.*           │   │    │
│  │  │  - suivipro.formation.events.*              │   │    │
│  │  │  - suivipro.alerte.events.*                 │   │    │
│  │  │  - suivipro.audit.logs.*                    │   │    │
│  │  │  - ...                                       │   │    │
│  │  └──────────────────────────────────────────────┘   │    │
│  │                                                      │    │
│  └──────────────────────────────────────────────────────┘    │
│                                                                │
│  ┌─────────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │ Schema Registry │  │ Kafka Connect│  │  Kafka UI    │    │
│  │     :8081       │  │    :8083     │  │    :8080     │    │
│  └─────────────────┘  └──────────────┘  └──────────────┘    │
│                                                                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
            ┌─────────────────────────────────┐
            │   Microservices SuiviPro 2     │
            ├─────────────────────────────────┤
            │ • MS-Agent                      │
            │ • MS-Habilitation               │
            │ • MS-Formation                  │
            │ • MS-Alerte                     │
            │ • MS-Securite                   │
            │ • MS-Integration                │
            │ • MS-Notification               │
            │ • MS-Reporting                  │
            │ • MS-Audit                      │
            └─────────────────────────────────┘
```

---

## Prérequis

### Système d'Exploitation

- **Linux** : Ubuntu 20.04+, RHEL 8+, CentOS 8+
- **macOS** : 10.15+ (pour développement)
- **Windows** : WSL2 + Docker Desktop (pour développement)

### Logiciels Requis

- **Docker** : 20.10+
- **Docker Compose** : 2.0+ (ou docker-compose 1.29+)
- **Minimum 32 GB RAM** (recommandé : 64 GB)
- **Minimum 4 CPU cores** (recommandé : 8+)
- **Minimum 100 GB disque libre** (recommandé : 1.5 TB SSD)

### Vérification des Prérequis

```bash
# Vérifier Docker
docker --version
docker compose version

# Vérifier les ressources disponibles
free -h
df -h
lscpu
```

---

## Installation Rapide

### 1. Cloner le Repository

```bash
git clone <repository-url>
cd Projet-de-reference/infrastructure/kafka
```

### 2. Démarrer le Cluster

```bash
# Démarrer tous les services
./scripts/start.sh

# Le script va :
# - Démarrer ZooKeeper (3 nœuds)
# - Démarrer Kafka Brokers (3 nœuds)
# - Démarrer Schema Registry
# - Démarrer Kafka Connect (avec plugins)
# - Démarrer Kafka UI
# - Initialiser les topics
```

### 3. Vérifier le Statut

```bash
# Vérifier que tous les services sont en cours d'exécution
./scripts/status.sh

# Vérifier la santé du cluster
./scripts/health-check.sh
```

### 4. Accéder à Kafka UI

Ouvrir dans un navigateur : **http://localhost:8080**

### 5. Arrêter le Cluster

```bash
# Arrêter tous les services
./scripts/stop.sh

# Arrêter et supprimer les volumes (ATTENTION : perte de données)
./scripts/stop.sh --remove-volumes
```

---

## Configuration Détaillée

### Structure des Fichiers

```
infrastructure/kafka/
├── docker-compose.yml          # Configuration Docker Compose
├── README.md                   # Cette documentation
├── config/
│   ├── security-acls.md       # Documentation sécurité
│   └── connect-plugins/       # Plugins Kafka Connect personnalisés
├── scripts/
│   ├── start.sh               # Script de démarrage
│   ├── stop.sh                # Script d'arrêt
│   ├── status.sh              # Vérification du statut
│   ├── health-check.sh        # Vérification de santé
│   ├── init-topics.sh         # Initialisation des topics
│   └── system-tuning.sh       # Tuning système Linux
└── docs/
    └── (documentation additionnelle)
```

### Variables d'Environnement

Les principales variables d'environnement sont définies dans `docker-compose.yml` :

#### Kafka Brokers

```yaml
# Réplication
KAFKA_DEFAULT_REPLICATION_FACTOR: 3
KAFKA_MIN_INSYNC_REPLICAS: 2

# Partitions
KAFKA_NUM_PARTITIONS: 12
KAFKA_AUTO_CREATE_TOPICS_ENABLE: 'false'

# Rétention
KAFKA_LOG_RETENTION_HOURS: 720  # 30 jours
KAFKA_LOG_RETENTION_BYTES: -1   # illimité

# JVM
KAFKA_HEAP_OPTS: "-Xms8g -Xmx8g"
```

### Ports Exposés

| Service | Port Interne | Port Externe | Description |
|---------|--------------|--------------|-------------|
| ZooKeeper 1 | 2181 | 2181 | Client |
| ZooKeeper 2 | 2181 | 2182 | Client |
| ZooKeeper 3 | 2181 | 2183 | Client |
| Kafka Broker 1 | 9092 | 19092 | Kafka Protocol |
| Kafka Broker 2 | 9092 | 19093 | Kafka Protocol |
| Kafka Broker 3 | 9092 | 19094 | Kafka Protocol |
| Schema Registry | 8081 | 8081 | HTTP API |
| Kafka Connect | 8083 | 8083 | REST API |
| Kafka UI | 8080 | 8080 | Web Interface |
| JMX Broker 1 | 9101 | 9101 | JMX Metrics |
| JMX Broker 2 | 9101 | 9102 | JMX Metrics |
| JMX Broker 3 | 9101 | 9103 | JMX Metrics |

---

## Topics Kafka

### Nomenclature

**Pattern** : `suivipro.{domaine}.{type}.{action}`

**Exemples** :
- `suivipro.agent.events.created`
- `suivipro.habilitation.events.attributed`
- `suivipro.alerte.events.generated`

### Liste des Topics (30 topics)

#### Domaine Agent (3 topics)
| Topic | Partitions | Replication | Rétention | Volume/jour |
|-------|------------|-------------|-----------|-------------|
| `suivipro.agent.events.created` | 6 | 3 | 30j | 200 msg |
| `suivipro.agent.events.updated` | 6 | 3 | 30j | 500 msg |
| `suivipro.agent.events.archived` | 3 | 3 | 90j | 50 msg |

#### Domaine Habilitation (3 topics)
| Topic | Partitions | Replication | Rétention | Volume/jour |
|-------|------------|-------------|-----------|-------------|
| `suivipro.habilitation.events.attributed` | 12 | 3 | 90j | 300 msg |
| `suivipro.habilitation.events.suspended` | 6 | 3 | 90j | 80 msg |
| `suivipro.habilitation.events.renewed` | 6 | 3 | 90j | 150 msg |

#### Domaine Formation (2 topics)
| Topic | Partitions | Replication | Rétention | Volume/jour |
|-------|------------|-------------|-----------|-------------|
| `suivipro.formation.events.completed` | 12 | 3 | 90j | 200 msg |
| `suivipro.formation.events.session-created` | 6 | 3 | 30j | 100 msg |

#### Domaine Visite Médicale & Constat (3 topics)
| Topic | Partitions | Replication | Rétention | Volume/jour |
|-------|------------|-------------|-----------|-------------|
| `suivipro.visite-medicale.events.created` | 6 | 3 | 90j | 100 msg |
| `suivipro.constat.events.created` | 6 | 3 | 90j | 80 msg |
| `suivipro.constat.events.validated` | 6 | 3 | 90j | 60 msg |

#### Domaine Écart Conduite & Incident (3 topics)
| Topic | Partitions | Replication | Rétention | Volume/jour |
|-------|------------|-------------|-----------|-------------|
| `suivipro.ecart-conduite.events.detected` | 12 | 3 | 30j | 300 msg |
| `suivipro.incident.events.declared` | 12 | 3 | 365j | 40 msg |
| `suivipro.incident.events.analyzed` | 6 | 3 | 365j | 30 msg |

#### Domaine REX & Objectif (3 topics)
| Topic | Partitions | Replication | Rétention | Volume/jour |
|-------|------------|-------------|-----------|-------------|
| `suivipro.rex.events.published` | 6 | 3 | 90j | 20 msg |
| `suivipro.objectif.events.created` | 6 | 3 | 90j | 150 msg |
| `suivipro.objectif.events.evaluated` | 6 | 3 | 90j | 100 msg |

#### Domaine Alerte & Notification (3 topics)
| Topic | Partitions | Replication | Rétention | Volume/jour |
|-------|------------|-------------|-----------|-------------|
| `suivipro.alerte.events.created` | 12 | 3 | 30j | 400 msg |
| `suivipro.alerte.events.treated` | 6 | 3 | 30j | 350 msg |
| `suivipro.notification.events.sent` | 12 | 3 | 7j | 800 msg |

#### Domaine Integration (4 topics)
| Topic | Partitions | Replication | Rétention | Volume/jour |
|-------|------------|-------------|-----------|-------------|
| `suivipro.integration.events.serfrh-synced` | 3 | 3 | 30j | 30 msg/mois |
| `suivipro.integration.events.digiplan-synced` | 3 | 3 | 30j | 30 msg |
| `suivipro.integration.events.nefertari-synced` | 6 | 3 | 30j | 300 msg |
| `suivipro.integration.events.error` | 6 | 3 | 90j | Variable |

#### Domaine Document (1 topic)
| Topic | Partitions | Replication | Rétention | Volume/jour |
|-------|------------|-------------|-----------|-------------|
| `suivipro.document.events.generated` | 6 | 3 | 30j | 150 msg |

#### Domaine Audit (2 topics)
| Topic | Partitions | Replication | Rétention | Volume/jour |
|-------|------------|-------------|-----------|-------------|
| `suivipro.audit.logs.action` | 24 | 3 | 365j | 500K msg |
| `suivipro.audit.logs.access` | 12 | 3 | 90j | 100K msg |

#### Système (3 topics)
| Topic | Partitions | Replication | Rétention | Volume/jour |
|-------|------------|-------------|-----------|-------------|
| `suivipro.dlq.errors` | 12 | 3 | 90j | Variable |
| `suivipro.monitoring.metrics` | 12 | 3 | 7j | 1M msg |
| `suivipro.healthcheck.heartbeat` | 6 | 3 | 1j | 43K msg |

**Total** : 30 topics, 252 partitions

### Commandes Utiles pour les Topics

```bash
# Lister tous les topics
docker exec kafka-broker-1 kafka-topics \
  --bootstrap-server kafka-broker-1:9092 --list

# Décrire un topic
docker exec kafka-broker-1 kafka-topics \
  --bootstrap-server kafka-broker-1:9092 \
  --describe --topic suivipro.agent.events.created

# Voir les messages d'un topic (consumer console)
docker exec kafka-broker-1 kafka-console-consumer \
  --bootstrap-server kafka-broker-1:9092 \
  --topic suivipro.agent.events.created \
  --from-beginning

# Produire des messages de test
docker exec -it kafka-broker-1 kafka-console-producer \
  --bootstrap-server kafka-broker-1:9092 \
  --topic suivipro.agent.events.created
```

---

## Scripts de Gestion

### start.sh

Démarre le cluster Kafka complet.

```bash
./scripts/start.sh
```

**Fonctionnalités** :
- Démarre tous les services Docker
- Attend que les services soient healthy
- Affiche l'état du cluster
- Affiche les points d'accès

### stop.sh

Arrête le cluster Kafka.

```bash
# Arrêt simple
./scripts/stop.sh

# Arrêt avec suppression des volumes (DANGER)
./scripts/stop.sh --remove-volumes
```

### status.sh

Affiche le statut détaillé du cluster.

```bash
# Statut basique
./scripts/status.sh

# Statut avec liste des topics
./scripts/status.sh --verbose
```

**Informations affichées** :
- État des conteneurs
- Santé des services
- Nombre de topics
- Utilisation des ressources

### health-check.sh

Effectue des vérifications de santé approfondies.

```bash
./scripts/health-check.sh
```

**Vérifications effectuées** :
- Connectivité ZooKeeper (3 nœuds)
- API Kafka Brokers (3 nœuds)
- Métadonnées du cluster
- Nombre de brokers
- Partitions sous-répliquées
- Partitions offline
- Schema Registry API
- Kafka Connect API
- Kafka UI
- Nombre de topics

**Codes de sortie** :
- `0` : Tous les tests passés (HEALTHY)
- `1` : La plupart des tests passés (DEGRADED)
- `2` : Beaucoup de tests échoués (UNHEALTHY)

### init-topics.sh

Initialise tous les topics SuiviPro.

```bash
./scripts/init-topics.sh
```

Ce script est automatiquement exécuté au démarrage via le conteneur `kafka-init`.

### system-tuning.sh

Applique les optimisations système Linux pour Kafka.

```bash
# ATTENTION: Nécessite les privilèges root
sudo ./scripts/system-tuning.sh
```

**Optimisations appliquées** :
- File descriptors (100000)
- Buffers réseau (128 MB)
- Swappiness (1)
- Disk I/O scheduler
- Read-ahead (1024 KB)

---

## Monitoring

### Kafka UI

Interface web de monitoring et management : **http://localhost:8080**

**Fonctionnalités** :
- Vue d'ensemble du cluster
- Gestion des topics
- Visualisation des messages
- Consumer groups
- Brokers et partitions
- Schema Registry
- Kafka Connect

### JMX Metrics

Les brokers exposent des métriques JMX sur les ports 9101-9103.

**Métriques importantes** :

#### Broker Metrics

```bash
# Messages par seconde
kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec

# Débit entrant (bytes/sec)
kafka.server:type=BrokerTopicMetrics,name=BytesInPerSec

# Débit sortant (bytes/sec)
kafka.server:type=BrokerTopicMetrics,name=BytesOutPerSec

# Partitions sous-répliquées (CRITIQUE si >0)
kafka.server:type=ReplicaManager,name=UnderReplicatedPartitions

# Partitions offline (CRITIQUE si >0)
kafka.server:type=ReplicaManager,name=OfflinePartitionsCount
```

#### Consumer Lag

```bash
# Lag par partition (ALERTE si >10000)
kafka.consumer:type=consumer-fetch-manager-metrics,client-id={client},topic={topic},partition={partition},name=records-lag
```

### Integration avec Prometheus/Grafana

Pour intégrer avec Prometheus :

1. Installer JMX Exporter sur les brokers
2. Configurer Prometheus pour scraper les métriques
3. Importer des dashboards Grafana prédéfinis

Voir : [Kafka Monitoring with Prometheus](https://github.com/prometheus/jmx_exporter)

### Alertes Recommandées

| Niveau | Condition | Action |
|--------|-----------|--------|
| CRITICAL | Broker down >30s | Redémarrage immédiat |
| CRITICAL | Partitions offline >0 | Investigation urgente |
| HIGH | Partitions sous-répliquées >0 pendant >5min | Vérifier brokers |
| HIGH | Consumer lag >50000 | Scaler consumers |
| MEDIUM | Disque >80% | Augmenter capacité |
| MEDIUM | CPU >80% pendant >5min | Investiguer charge |
| LOW | Taux erreurs producteur >0.1% | Vérifier clients |

---

## Sécurité

### Configuration Actuelle (Développement)

Le cluster est actuellement configuré en mode **PLAINTEXT** (non sécurisé) pour faciliter le développement.

**Ports en clair** :
- Kafka : PLAINTEXT (9092)
- ZooKeeper : Non authentifié (2181)

### Configuration Production (Recommandé)

Pour la production, il est **OBLIGATOIRE** d'activer la sécurité.

Voir la documentation complète : [config/security-acls.md](config/security-acls.md)

**Éléments de sécurité à activer** :

1. **Authentification SASL/SCRAM-SHA-512**
2. **Chiffrement SSL/TLS**
3. **ACLs par microservice**
4. **Audit logging**

### Checklist Sécurité Production

- [ ] Changer tous les ports en SASL_SSL
- [ ] Générer et déployer les certificats SSL
- [ ] Créer les utilisateurs SASL/SCRAM
- [ ] Configurer les ACLs par microservice
- [ ] Activer l'audit logging
- [ ] Désactiver `KAFKA_ALLOW_EVERYONE_IF_NO_ACL_FOUND`
- [ ] Restreindre l'accès réseau (firewall)
- [ ] Mettre en place la rotation des credentials
- [ ] Configurer un vault pour les secrets

---

## Performance Tuning

### Tuning Système (Linux)

Exécuter le script de tuning :

```bash
sudo ./scripts/system-tuning.sh
```

### Tuning Kafka

#### Producer

```properties
# Durabilité maximale
acks=all
retries=3
max.in.flight.requests.per.connection=1

# Performance
batch.size=16384
linger.ms=10
compression.type=lz4
buffer.memory=33554432
```

#### Consumer

```properties
# Performance
fetch.min.bytes=1024
fetch.max.wait.ms=500
max.partition.fetch.bytes=1048576

# Contrôle
enable.auto.commit=false
auto.offset.reset=earliest
```

### Monitoring des Performances

```bash
# Test de throughput
docker exec kafka-broker-1 kafka-producer-perf-test \
  --topic test-perf \
  --num-records 1000000 \
  --record-size 1024 \
  --throughput -1 \
  --producer-props bootstrap.servers=kafka-broker-1:9092

# Test consumer
docker exec kafka-broker-1 kafka-consumer-perf-test \
  --topic test-perf \
  --messages 1000000 \
  --threads 1 \
  --bootstrap-server kafka-broker-1:9092
```

---

## Troubleshooting

### Problèmes Courants

#### 1. Les services ne démarrent pas

**Symptômes** : Conteneurs en état `starting` ou `unhealthy`

**Vérifications** :

```bash
# Vérifier les logs
docker-compose logs -f [service-name]

# Vérifier les ressources
docker stats

# Vérifier les volumes
docker volume ls
```

**Solutions** :
- Augmenter la mémoire allouée à Docker
- Vérifier les ports libres
- Supprimer les volumes corrompus : `docker-compose down -v`

#### 2. ZooKeeper ne forme pas de quorum

**Symptômes** : Brokers ne peuvent pas se connecter à ZooKeeper

**Vérifications** :

```bash
# Vérifier l'état ZooKeeper
docker exec zookeeper-1 bash -c 'echo stat | nc localhost 2181'
```

**Solutions** :
- Redémarrer les nœuds ZooKeeper un par un
- Vérifier la connectivité réseau entre les nœuds

#### 3. Partitions sous-répliquées

**Symptômes** : `UnderReplicatedPartitions` > 0

**Vérifications** :

```bash
# Identifier les partitions
docker exec kafka-broker-1 kafka-topics \
  --bootstrap-server kafka-broker-1:9092 \
  --describe --under-replicated-partitions
```

**Solutions** :
- Vérifier que tous les brokers sont en ligne
- Vérifier les ressources (CPU, RAM, disque, réseau)
- Augmenter `replica.lag.time.max.ms` si nécessaire

#### 4. Consumer lag élevé

**Symptômes** : Les consommateurs sont en retard sur les producteurs

**Vérifications** :

```bash
# Vérifier le lag
docker exec kafka-broker-1 kafka-consumer-groups \
  --bootstrap-server kafka-broker-1:9092 \
  --describe --group [group-id]
```

**Solutions** :
- Augmenter le nombre de consumers (parallélisation)
- Augmenter le nombre de partitions
- Optimiser le traitement des messages
- Vérifier les performances du consumer

#### 5. Erreurs "No space left on device"

**Symptômes** : Les brokers crash avec des erreurs d'espace disque

**Solutions** :
- Augmenter la capacité de stockage
- Réduire la rétention : `log.retention.hours`
- Activer la compaction pour certains topics
- Nettoyer manuellement : `kafka-log-dirs --bootstrap-server ...`

### Logs Utiles

```bash
# Tous les services
docker-compose logs -f

# Service spécifique
docker-compose logs -f kafka-broker-1

# Dernières 100 lignes
docker-compose logs --tail=100 kafka-broker-1

# Filtrer par niveau
docker-compose logs | grep ERROR
```

### Commandes de Diagnostic

```bash
# Vérifier les brokers
docker exec kafka-broker-1 kafka-broker-api-versions \
  --bootstrap-server kafka-broker-1:9092

# Vérifier les consumer groups
docker exec kafka-broker-1 kafka-consumer-groups \
  --bootstrap-server kafka-broker-1:9092 --list

# Vérifier les log directories
docker exec kafka-broker-1 kafka-log-dirs \
  --bootstrap-server kafka-broker-1:9092 --describe

# Vérifier les configs
docker exec kafka-broker-1 kafka-configs \
  --bootstrap-server kafka-broker-1:9092 \
  --entity-type brokers --entity-name 1 --describe
```

---

## Maintenance

### Sauvegarde

#### Sauvegarde des Métadonnées

```bash
# Exporter les topics
docker exec kafka-broker-1 kafka-topics \
  --bootstrap-server kafka-broker-1:9092 --list > topics-backup.txt

# Exporter les configurations
for topic in $(cat topics-backup.txt); do
  docker exec kafka-broker-1 kafka-configs \
    --bootstrap-server kafka-broker-1:9092 \
    --entity-type topics --entity-name $topic --describe \
    >> topics-config-backup.txt
done
```

#### Sauvegarde des Données

Les volumes Docker contiennent toutes les données :

```bash
# Lister les volumes
docker volume ls | grep kafka

# Sauvegarder un volume
docker run --rm -v kafka-broker-1-data:/data -v $(pwd):/backup \
  ubuntu tar czf /backup/kafka-broker-1-data.tar.gz /data
```

### Mise à Jour

#### Mise à jour des Images Docker

```bash
# Arrêter le cluster
./scripts/stop.sh

# Mettre à jour les images dans docker-compose.yml
# Exemple : confluentinc/cp-kafka:7.5.0 → 7.6.0

# Redémarrer
./scripts/start.sh
```

#### Rolling Restart

Pour minimiser l'interruption, redémarrer les brokers un par un :

```bash
# Broker 1
docker-compose restart kafka-broker-1
sleep 60

# Broker 2
docker-compose restart kafka-broker-2
sleep 60

# Broker 3
docker-compose restart kafka-broker-3
```

### Nettoyage

```bash
# Supprimer les logs anciens (si rétention désactivée)
docker exec kafka-broker-1 kafka-delete-records \
  --bootstrap-server kafka-broker-1:9092 \
  --offset-json-file offsets.json

# Nettoyer les volumes orphelins
docker volume prune

# Nettoyer les conteneurs arrêtés
docker container prune
```

---

## FAQ

### Puis-je utiliser ce cluster en production ?

Oui, mais vous devez **OBLIGATOIREMENT** :
- Activer la sécurité (SASL + SSL)
- Configurer les ACLs
- Mettre en place le monitoring avec alertes
- Appliquer le tuning système
- Configurer des backups réguliers

### Combien de ressources sont nécessaires ?

**Minimum** (développement) :
- 16 GB RAM
- 4 CPU cores
- 50 GB disque

**Recommandé** (production) :
- 64 GB RAM
- 16 CPU cores
- 1.5 TB SSD (RAID 10)
- 10 Gbps réseau

### Comment scaler le cluster ?

Pour ajouter des brokers :

1. Modifier `docker-compose.yml` pour ajouter `kafka-broker-4`
2. Redémarrer : `./scripts/start.sh`
3. Rééquilibrer les partitions : `kafka-reassign-partitions`

### Comment migrer vers un environnement cloud ?

Les options recommandées :

- **AWS** : Amazon MSK (Managed Kafka)
- **Azure** : Azure Event Hubs
- **GCP** : Confluent Cloud
- **On-premise** : Kubernetes + Strimzi operator

### Que faire en cas de crash complet ?

1. Sauvegarder les volumes Docker
2. Vérifier les logs : `docker-compose logs`
3. Essayer un redémarrage : `./scripts/stop.sh && ./scripts/start.sh`
4. Si nécessaire, restaurer depuis backup
5. Recréer les topics si perdus : `./scripts/init-topics.sh`

---

## Support et Contributions

### Obtenir de l'Aide

- **Documentation Kafka** : https://kafka.apache.org/documentation/
- **Confluent Documentation** : https://docs.confluent.io/
- **Issues GitHub** : (lien vers votre repo)

### Contribuer

Les contributions sont les bienvenues :

1. Fork le repository
2. Créer une branche : `git checkout -b feature/ma-feature`
3. Commiter : `git commit -am 'Ajout de ma feature'`
4. Pusher : `git push origin feature/ma-feature`
5. Créer une Pull Request

---

## License

(À définir selon votre organisation)

---

## Changelog

### Version 1.0.0 (2025-12-04)

- Déploiement initial du cluster Kafka
- 3 brokers Kafka + 3 ZooKeeper
- 30 topics SuiviPro prédéfinis
- Scripts de gestion complets
- Documentation complète
- Kafka UI, Schema Registry, Kafka Connect

---

## Auteurs

- Équipe Infrastructure SuiviPro 2 - RATP
- Date de création : Décembre 2025

---

## Ressources Additionnelles

- [Architecture Kafka](https://kafka.apache.org/intro)
- [Best Practices Kafka](https://kafka.apache.org/documentation/#design)
- [Kafka Security](https://kafka.apache.org/documentation/#security)
- [Kafka Performance Tuning](https://kafka.apache.org/documentation/#performance)
