# Configuration de la Sécurité Kafka - SuiviPro 2

## Vue d'ensemble

Ce document décrit la configuration de sécurité recommandée pour le cluster Kafka de SuiviPro 2, incluant l'authentification, l'autorisation et le chiffrement.

## Architecture de Sécurité

### Niveaux de Sécurité

1. **Authentification** : SASL/SCRAM-SHA-512
2. **Autorisation** : ACLs Kafka
3. **Chiffrement** : SSL/TLS pour les communications
4. **Audit** : Logging des accès et actions

## Mise en Place de l'Authentification SASL/SCRAM

### 1. Configuration des Brokers

Modifier le `docker-compose.yml` pour activer SASL/SCRAM :

```yaml
kafka-broker-1:
  environment:
    # ... autres configurations ...

    # SASL/SCRAM Configuration
    KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: SASL_SSL:SASL_SSL,PLAINTEXT_HOST:PLAINTEXT
    KAFKA_ADVERTISED_LISTENERS: SASL_SSL://kafka-broker-1:9093,PLAINTEXT_HOST://localhost:19092
    KAFKA_SECURITY_INTER_BROKER_PROTOCOL: SASL_SSL
    KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL: SCRAM-SHA-512
    KAFKA_SASL_ENABLED_MECHANISMS: SCRAM-SHA-512

    # SSL Configuration
    KAFKA_SSL_KEYSTORE_FILENAME: kafka.keystore.jks
    KAFKA_SSL_KEYSTORE_CREDENTIALS: keystore_creds
    KAFKA_SSL_KEY_CREDENTIALS: key_creds
    KAFKA_SSL_TRUSTSTORE_FILENAME: kafka.truststore.jks
    KAFKA_SSL_TRUSTSTORE_CREDENTIALS: truststore_creds
    KAFKA_SSL_CLIENT_AUTH: required

    # ACL Configuration
    KAFKA_AUTHORIZER_CLASS_NAME: kafka.security.authorizer.AclAuthorizer
    KAFKA_SUPER_USERS: User:admin;User:kafka-connect
    KAFKA_ALLOW_EVERYONE_IF_NO_ACL_FOUND: 'false'

  volumes:
    - ./config/ssl:/etc/kafka/secrets
```

### 2. Création des Certificats SSL

```bash
#!/bin/bash

# Générer le keystore pour le broker
keytool -keystore kafka.keystore.jks -alias kafka-broker -validity 365 -genkey -keyalg RSA \
  -dname "CN=kafka-broker,OU=SuiviPro,O=RATP,L=Paris,ST=IDF,C=FR" \
  -storepass changeit -keypass changeit

# Générer le CA
openssl req -new -x509 -keyout ca-key -out ca-cert -days 365 \
  -subj "/CN=CA-SuiviPro/OU=Security/O=RATP/L=Paris/ST=IDF/C=FR" \
  -passout pass:changeit

# Importer le CA dans le truststore
keytool -keystore kafka.truststore.jks -alias CARoot -import -file ca-cert \
  -storepass changeit -noprompt

# Signer le certificat du broker
keytool -keystore kafka.keystore.jks -alias kafka-broker -certreq -file cert-file \
  -storepass changeit

openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file -out cert-signed \
  -days 365 -CAcreateserial -passin pass:changeit

# Importer les certificats dans le keystore
keytool -keystore kafka.keystore.jks -alias CARoot -import -file ca-cert \
  -storepass changeit -noprompt

keytool -keystore kafka.keystore.jks -alias kafka-broker -import -file cert-signed \
  -storepass changeit
```

### 3. Création des Utilisateurs SASL/SCRAM

```bash
# Se connecter au broker
docker exec -it kafka-broker-1 bash

# Créer l'utilisateur admin
kafka-configs --zookeeper zookeeper-1:2181 \
  --alter --add-config 'SCRAM-SHA-512=[password=admin-password]' \
  --entity-type users --entity-name admin

# Créer les utilisateurs pour les microservices
kafka-configs --zookeeper zookeeper-1:2181 \
  --alter --add-config 'SCRAM-SHA-512=[password=ms-agent-password]' \
  --entity-type users --entity-name ms-agent

kafka-configs --zookeeper zookeeper-1:2181 \
  --alter --add-config 'SCRAM-SHA-512=[password=ms-alerte-password]' \
  --entity-type users --entity-name ms-alerte

kafka-configs --zookeeper zookeeper-1:2181 \
  --alter --add-config 'SCRAM-SHA-512=[password=ms-habilitation-password]' \
  --entity-type users --entity-name ms-habilitation

kafka-configs --zookeeper zookeeper-1:2181 \
  --alter --add-config 'SCRAM-SHA-512=[password=ms-formation-password]' \
  --entity-type users --entity-name ms-formation

kafka-configs --zookeeper zookeeper-1:2181 \
  --alter --add-config 'SCRAM-SHA-512=[password=ms-securite-password]' \
  --entity-type users --entity-name ms-securite

kafka-configs --zookeeper zookeeper-1:2181 \
  --alter --add-config 'SCRAM-SHA-512=[password=ms-integration-password]' \
  --entity-type users --entity-name ms-integration

kafka-configs --zookeeper zookeeper-1:2181 \
  --alter --add-config 'SCRAM-SHA-512=[password=ms-notification-password]' \
  --entity-type users --entity-name ms-notification

kafka-configs --zookeeper zookeeper-1:2181 \
  --alter --add-config 'SCRAM-SHA-512=[password=ms-reporting-password]' \
  --entity-type users --entity-name ms-reporting

kafka-configs --zookeeper zookeeper-1:2181 \
  --alter --add-config 'SCRAM-SHA-512=[password=ms-audit-password]' \
  --entity-type users --entity-name ms-audit
```

## Configuration des ACLs

### ACLs par Microservice

#### MS-Agent (Producteur Agent Events)

```bash
# Write sur les topics agent
kafka-acls --bootstrap-server kafka-broker-1:9092 \
  --command-config /etc/kafka/admin.properties \
  --add --allow-principal User:ms-agent \
  --operation Write \
  --topic suivipro.agent.events.created

kafka-acls --bootstrap-server kafka-broker-1:9092 \
  --command-config /etc/kafka/admin.properties \
  --add --allow-principal User:ms-agent \
  --operation Write \
  --topic suivipro.agent.events.updated

kafka-acls --bootstrap-server kafka-broker-1:9092 \
  --command-config /etc/kafka/admin.properties \
  --add --allow-principal User:ms-agent \
  --operation Write \
  --topic suivipro.agent.events.archived

# Write sur visite médicale et constat
kafka-acls --bootstrap-server kafka-broker-1:9092 \
  --command-config /etc/kafka/admin.properties \
  --add --allow-principal User:ms-agent \
  --operation Write \
  --topic suivipro.visite-medicale.events.created

kafka-acls --bootstrap-server kafka-broker-1:9092 \
  --command-config /etc/kafka/admin.properties \
  --add --allow-principal User:ms-agent \
  --operation Write \
  --topic suivipro.constat.events.created

kafka-acls --bootstrap-server kafka-broker-1:9092 \
  --command-config /etc/kafka/admin.properties \
  --add --allow-principal User:ms-agent \
  --operation Write \
  --topic suivipro.constat.events.validated

# Write sur audit
kafka-acls --bootstrap-server kafka-broker-1:9092 \
  --command-config /etc/kafka/admin.properties \
  --add --allow-principal User:ms-agent \
  --operation Write \
  --topic suivipro.audit.logs.action

# Consumer group
kafka-acls --bootstrap-server kafka-broker-1:9092 \
  --command-config /etc/kafka/admin.properties \
  --add --allow-principal User:ms-agent \
  --operation Read --group ms-agent-group
```

#### MS-Alerte (Consommateur Multiple + Producteur)

```bash
# Read sur les topics d'événements
for topic in \
  suivipro.agent.events.created \
  suivipro.agent.events.updated \
  suivipro.habilitation.events.attributed \
  suivipro.habilitation.events.suspended \
  suivipro.formation.events.completed \
  suivipro.visite-medicale.events.created \
  suivipro.constat.events.created \
  suivipro.ecart-conduite.events.detected \
  suivipro.incident.events.declared
do
  kafka-acls --bootstrap-server kafka-broker-1:9092 \
    --command-config /etc/kafka/admin.properties \
    --add --allow-principal User:ms-alerte \
    --operation Read --topic $topic
done

# Write sur les topics alerte
kafka-acls --bootstrap-server kafka-broker-1:9092 \
  --command-config /etc/kafka/admin.properties \
  --add --allow-principal User:ms-alerte \
  --operation Write \
  --topic suivipro.alerte.events.created

kafka-acls --bootstrap-server kafka-broker-1:9092 \
  --command-config /etc/kafka/admin.properties \
  --add --allow-principal User:ms-alerte \
  --operation Write \
  --topic suivipro.alerte.events.treated

# Consumer group
kafka-acls --bootstrap-server kafka-broker-1:9092 \
  --command-config /etc/kafka/admin.properties \
  --add --allow-principal User:ms-alerte \
  --operation Read --group ms-alerte-group
```

#### MS-Habilitation

```bash
# Write sur habilitation topics
for topic in \
  suivipro.habilitation.events.attributed \
  suivipro.habilitation.events.suspended \
  suivipro.habilitation.events.renewed
do
  kafka-acls --bootstrap-server kafka-broker-1:9092 \
    --command-config /etc/kafka/admin.properties \
    --add --allow-principal User:ms-habilitation \
    --operation Write --topic $topic
done

# Read sur formation et constat
for topic in \
  suivipro.formation.events.completed \
  suivipro.constat.events.validated \
  suivipro.visite-medicale.events.created \
  suivipro.alerte.events.created
do
  kafka-acls --bootstrap-server kafka-broker-1:9092 \
    --command-config /etc/kafka/admin.properties \
    --add --allow-principal User:ms-habilitation \
    --operation Read --topic $topic
done

# Consumer group
kafka-acls --bootstrap-server kafka-broker-1:9092 \
  --command-config /etc/kafka/admin.properties \
  --add --allow-principal User:ms-habilitation \
  --operation Read --group ms-habilitation-group
```

### Script d'Application des ACLs

Créer un script `apply-acls.sh` :

```bash
#!/bin/bash

# Script d'application des ACLs pour SuiviPro 2

BOOTSTRAP_SERVERS="kafka-broker-1:9092"
ADMIN_CONFIG="/etc/kafka/admin.properties"

# Fonction pour appliquer une ACL
apply_acl() {
    local principal=$1
    local operation=$2
    local resource_type=$3
    local resource_name=$4

    kafka-acls --bootstrap-server $BOOTSTRAP_SERVERS \
      --command-config $ADMIN_CONFIG \
      --add --allow-principal "User:$principal" \
      --operation $operation \
      --$resource_type $resource_name
}

# Appliquer toutes les ACLs
# ... (voir exemples ci-dessus)
```

## Configuration Client

### Configuration Producer

```properties
# producer.properties
bootstrap.servers=kafka-broker-1:9093,kafka-broker-2:9093,kafka-broker-3:9093
security.protocol=SASL_SSL
sasl.mechanism=SCRAM-SHA-512
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
  username="ms-agent" \
  password="ms-agent-password";

# SSL settings
ssl.truststore.location=/path/to/kafka.truststore.jks
ssl.truststore.password=changeit

# Producer settings
acks=all
retries=3
max.in.flight.requests.per.connection=1
compression.type=lz4
```

### Configuration Consumer

```properties
# consumer.properties
bootstrap.servers=kafka-broker-1:9093,kafka-broker-2:9093,kafka-broker-3:9093
security.protocol=SASL_SSL
sasl.mechanism=SCRAM-SHA-512
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
  username="ms-alerte" \
  password="ms-alerte-password";

# SSL settings
ssl.truststore.location=/path/to/kafka.truststore.jks
ssl.truststore.password=changeit

# Consumer settings
group.id=ms-alerte-group
auto.offset.reset=earliest
enable.auto.commit=false
```

## Audit et Monitoring

### Activation du Logging d'Audit

```properties
# server.properties
authorizer.logger.name=kafka.authorizer.logger
log4j.logger.kafka.authorizer.logger=INFO, authorizerAppender
log4j.appender.authorizerAppender=org.apache.log4j.DailyRollingFileAppender
log4j.appender.authorizerAppender.DatePattern='.'yyyy-MM-dd-HH
log4j.appender.authorizerAppender.File=/var/log/kafka/kafka-authorizer.log
```

### Métriques de Sécurité à Surveiller

1. **Tentatives d'authentification échouées**
2. **Violations d'ACL**
3. **Connexions SSL/TLS échouées**
4. **Changements de configuration de sécurité**

## Rotation des Credentials

### Processus de Rotation

1. **Créer nouveaux credentials**
2. **Mettre à jour les clients progressivement**
3. **Vérifier que tous les clients utilisent les nouveaux credentials**
4. **Supprimer les anciens credentials**

```bash
# Ajouter un nouveau mot de passe (permet double authentification temporaire)
kafka-configs --zookeeper zookeeper-1:2181 \
  --alter --add-config 'SCRAM-SHA-512=[password=new-password]' \
  --entity-type users --entity-name ms-agent

# Après migration des clients, supprimer l'ancien
kafka-configs --zookeeper zookeeper-1:2181 \
  --alter --delete-config 'SCRAM-SHA-512' \
  --entity-type users --entity-name ms-agent
```

## Bonnes Pratiques

1. **Principe du moindre privilège** : Donner uniquement les permissions nécessaires
2. **Rotation régulière** : Changer les credentials tous les 90 jours
3. **Audit continu** : Surveiller les logs d'autorisation
4. **Chiffrement obligatoire** : Toutes les communications doivent être chiffrées en production
5. **Séparation des environnements** : Credentials différents par environnement
6. **Gestion centralisée** : Utiliser un vault (HashiCorp Vault, AWS Secrets Manager) pour les secrets

## Checklist de Mise en Production

- [ ] Certificats SSL générés et déployés
- [ ] Utilisateurs SASL/SCRAM créés pour tous les microservices
- [ ] ACLs configurées et testées
- [ ] Audit logging activé
- [ ] Monitoring de sécurité en place
- [ ] Procédure de rotation documentée
- [ ] Plan de réponse aux incidents de sécurité
- [ ] Tests de pénétration effectués
- [ ] Revue de sécurité par l'équipe InfoSec
