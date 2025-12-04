# Guide d'Intégration Kafka - Projet RATP SuiviPro

## Vue d'ensemble

Ce document explique comment intégrer l'infrastructure Kafka dans le projet RATP SuiviPro (architecture DDD avec 15 microservices).

## Scripts Kafka Disponibles

Les scripts Kafka complets ont été intégrés dans `infrastructure/kafka/` :

### Structure des fichiers

```
infrastructure/kafka/
├── README.md                      # Documentation complète (30+ pages)
├── docker-compose.yml             # Stack Kafka complète (10 conteneurs)
├── config/
│   └── security-acls.md          # Configuration sécurité et ACLs
└── scripts/
    ├── start.sh                  # Démarrage du cluster
    ├── stop.sh                   # Arrêt du cluster
    ├── status.sh                 # Statut des services
    ├── health-check.sh           # Vérification santé
    ├── init-topics.sh            # Création des 30 topics
    └── system-tuning.sh          # Optimisation système
```

## Architecture Kafka Déployée

### Composants (10 conteneurs)

1. **Zookeeper Ensemble** (3 nodes)
   - zookeeper-1, zookeeper-2, zookeeper-3
   - Ports: 2181, 2182, 2183

2. **Kafka Brokers** (3 nodes)
   - kafka-broker-1, kafka-broker-2, kafka-broker-3
   - Ports: 9092, 9093, 9094

3. **Kafka Connect**
   - Intégration avec systèmes externes (SerfRH, Nefertari, etc.)
   - Port: 8083

4. **Schema Registry**
   - Gestion des schémas Avro
   - Port: 8081

5. **Kafka REST Proxy**
   - API REST pour Kafka
   - Port: 8082

6. **Kafka UI** (Monitoring)
   - Interface web de monitoring
   - Port: 9000

## Topics Kafka pour les 15 Microservices DDD

### Topics créés automatiquement

```
## Core Business Domain
suivipro.agent.events              # ms-agent
suivipro.habilitation.events       # ms-habilitation
suivipro.formation.events          # ms-formation
suivipro.securite.events           # ms-securite
suivipro.paisf.events              # ms-paisf
suivipro.alerte.events             # ms-alerte
suivipro.objectif.events           # ms-objectif
suivipro.reporting.events          # ms-reporting
suivipro.organisation.events       # ms-organisation

## Technical & Support Domain
suivipro.iam.events                # ms-iam
suivipro.document.events           # ms-document
suivipro.integration.events        # ms-integration
suivipro.notification.events       # ms-notification
suivipro.audit.events              # ms-audit
suivipro.referentiel.events        # ms-referentiel
```

Total: 30 topics avec 252 partitions

## Intégration avec docker-compose Principal

### Option 1: Stack Kafka Séparée (Recommandé)

Démarrer Kafka séparément du reste de l'infrastructure :

```bash
# Terminal 1: Démarrer Kafka
cd infrastructure/kafka
./scripts/start.sh

# Terminal 2: Démarrer les microservices
cd ../..
docker-compose up -d
```

### Option 2: Intégration Complète

Fusionner le docker-compose.yml Kafka avec le docker-compose.yml principal en ajoutant l'external network:

```yaml
networks:
  suivipro-network:
    external: true  # Référencer le réseau Kafka existant
```

## Démarrage Rapide

### 1. Prérequis Système

```bash
# Linux: Ajuster les limites système
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w fs.file-max=2097152

# Rendre permanent
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
echo "fs.file-max=2097152" | sudo tee -a /etc/sysctl.conf
```

### 2. Démarrer l'infrastructure Kafka

```bash
cd infrastructure/kafka

# Donner les permissions d'exécution
chmod +x scripts/*.sh

# Démarrer le cluster (3 Zookeepers + 3 Brokers + monitoring)
./scripts/start.sh

# Vérifier le statut
./scripts/status.sh

# Créer les topics pour les 15 microservices
./scripts/init-topics.sh
```

### 3. Accéder aux interfaces

- **Kafka UI**: http://localhost:9000
- **Schema Registry**: http://localhost:8081
- **Kafka REST Proxy**: http://localhost:8082
- **Kafka Connect**: http://localhost:8083

## Configuration des Microservices

Les 15 microservices DDD sont déjà configurés pour utiliser Kafka.

### Configuration dans application.yml (exemple)

```yaml
spring:
  kafka:
    bootstrap-servers: ${KAFKA_BOOTSTRAP_SERVERS:kafka-broker-1:9092,kafka-broker-2:9093,kafka-broker-3:9094}
    consumer:
      group-id: ms-agent-group
      auto-offset-reset: earliest
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.springframework.kafka.support.serializer.JsonDeserializer
      properties:
        spring.json.trusted.packages: '*'
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.springframework.kafka.support.serializer.JsonSerializer
```

### Variables d'environnement docker-compose

```yaml
environment:
  KAFKA_BOOTSTRAP_SERVERS: kafka-broker-1:9092,kafka-broker-2:9093,kafka-broker-3:9094
```

## Scripts de Gestion Windows

Les scripts `docker-manage.bat` et `docker-manage.ps1` ont également été intégrés à la racine du projet pour faciliter la gestion sous Windows.

### Utilisation PowerShell

```powershell
# Démarrer tous les services (microservices + Kafka)
.\docker-manage.ps1 start

# Voir le statut
.\docker-manage.ps1 status

# Vérifier la santé
.\docker-manage.ps1 health

# Arrêter tous les services
.\docker-manage.ps1 stop
```

## Monitoring et Observabilité

### Kafka UI (Port 9000)

Interface web complète avec :
- Vue d'ensemble des brokers
- Liste des topics et partitions
- Consumer groups et lag
- Messages en temps réel
- Configuration des topics

### Métriques Prometheus

Kafka expose automatiquement des métriques JMX via Prometheus configuré dans:
```
infrastructure/monitoring/prometheus/prometheus.yml
```

Topics surveillés :
- Throughput (messages/sec)
- Latence (p95, p99)
- Consumer lag
- Taille des partitions

## Capacité et Performance

### Dimensionnement

Pour 3000 agents RATP :
- **500K événements/jour** répartis sur 15 microservices
- **Rétention** : 7-365 jours selon le topic
- **Stockage estimé** : 81 GB (avec réplication x3)
- **Recommandation** : 500 GB par broker minimum

### Topics avec rétention longue

```
suivipro.audit.logs          # 365 jours (conformité RGPD)
suivipro.agent.history       # 180 jours
suivipro.formation.records   # 180 jours
suivipro.habilitation.events # 180 jours
```

## Sécurité

### ACLs Kafka (voir config/security-acls.md)

```bash
# Créer un utilisateur service
kafka-acls --bootstrap-server localhost:9092 \
  --add --allow-principal User:ms-agent \
  --operation Read --operation Write \
  --topic suivipro.agent.events
```

### SSL/TLS

Configuration disponible dans `config/security-acls.md` pour:
- SSL inter-brokers
- SASL authentication
- ACLs par microservice

## Troubleshooting

### Problèmes courants

#### 1. Brokers ne démarrent pas

```bash
# Vérifier les logs
docker-compose -f infrastructure/kafka/docker-compose.yml logs kafka-broker-1

# Vérifier Zookeeper
docker-compose -f infrastructure/kafka/docker-compose.yml ps zookeeper-1
```

#### 2. Consumer lag élevé

```bash
# Vérifier le lag via Kafka UI
http://localhost:9000

# Ou via ligne de commande
./scripts/health-check.sh
```

#### 3. Erreurs de connexion

```bash
# Tester la connectivité
docker-compose exec kafka-broker-1 kafka-broker-api-versions \
  --bootstrap-server localhost:9092
```

### Commandes Utiles

```bash
# Lister les topics
docker-compose exec kafka-broker-1 kafka-topics --list \
  --bootstrap-server localhost:9092

# Consommer un topic
docker-compose exec kafka-broker-1 kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic suivipro.agent.events \
  --from-beginning

# Publier un message test
echo '{"eventType":"TEST","data":"test"}' | \
  docker-compose exec -T kafka-broker-1 kafka-console-producer \
  --bootstrap-server localhost:9092 \
  --topic suivipro.agent.events
```

## Maintenance

### Backup et Restore

```bash
# Backup des topics (voir scripts/)
./scripts/backup-topics.sh

# Restore
./scripts/restore-topics.sh
```

### Mise à jour

```bash
# Arrêter le cluster
./scripts/stop.sh

# Mettre à jour les images
docker-compose pull

# Redémarrer
./scripts/start.sh
```

## Documentation Complète

Pour plus de détails, consultez :
- `infrastructure/kafka/README.md` - Documentation complète (979 lignes)
- `infrastructure/kafka/config/security-acls.md` - Configuration sécurité

## Support

Pour toute question sur l'intégration Kafka :
- Consulter le README complet dans `infrastructure/kafka/`
- Vérifier les logs : `docker-compose logs -f`
- Interface monitoring : http://localhost:9000

---

**Version**: 2.0.0 (Architecture DDD + Kafka)
**Date**: Décembre 2024
**Projet**: RATP SuiviPro - Refonte avec 15 microservices DDD
