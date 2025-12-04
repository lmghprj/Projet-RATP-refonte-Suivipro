#!/bin/bash

# =============================================================================
# Script d'initialisation des topics Kafka pour SuiviPro 2
# =============================================================================
# Ce script crée tous les topics nécessaires pour l'application SuiviPro 2
# avec leurs configurations spécifiques (partitions, réplication, rétention)
# =============================================================================

set -e

BOOTSTRAP_SERVERS="kafka-broker-1:9092,kafka-broker-2:9092,kafka-broker-3:9092"

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Fonction pour créer un topic
create_topic() {
    local topic_name=$1
    local partitions=$2
    local replication=$3
    local retention_ms=$4
    local min_insync_replicas=${5:-2}

    log_info "Creating topic: $topic_name (partitions=$partitions, replication=$replication, retention=${retention_ms}ms)"

    if kafka-topics --bootstrap-server $BOOTSTRAP_SERVERS --list | grep -q "^${topic_name}$"; then
        log_warning "Topic $topic_name already exists, skipping..."
        return 0
    fi

    kafka-topics --bootstrap-server $BOOTSTRAP_SERVERS \
        --create \
        --topic $topic_name \
        --partitions $partitions \
        --replication-factor $replication \
        --config retention.ms=$retention_ms \
        --config min.insync.replicas=$min_insync_replicas \
        --config compression.type=lz4 \
        --config segment.ms=86400000

    if [ $? -eq 0 ]; then
        log_success "Topic $topic_name created successfully"
    else
        log_error "Failed to create topic $topic_name"
        return 1
    fi
}

log_info "==================================================================="
log_info "Starting Kafka topics initialization for SuiviPro 2"
log_info "Bootstrap servers: $BOOTSTRAP_SERVERS"
log_info "==================================================================="

# Wait for Kafka to be fully ready
log_info "Waiting for Kafka cluster to be ready..."
sleep 5

# Vérification de la connexion
log_info "Testing connection to Kafka cluster..."
kafka-broker-api-versions --bootstrap-server $BOOTSTRAP_SERVERS > /dev/null 2>&1
if [ $? -ne 0 ]; then
    log_error "Cannot connect to Kafka cluster. Exiting..."
    exit 1
fi
log_success "Successfully connected to Kafka cluster"

# =============================================================================
# AGENT TOPICS
# =============================================================================
log_info ""
log_info "Creating AGENT topics..."
log_info "-------------------------------------------------------------------"

# 30 jours = 2592000000 ms
create_topic "suivipro.agent.events.created" 6 3 2592000000
create_topic "suivipro.agent.events.updated" 6 3 2592000000
# 90 jours = 7776000000 ms
create_topic "suivipro.agent.events.archived" 3 3 7776000000

# =============================================================================
# HABILITATION TOPICS
# =============================================================================
log_info ""
log_info "Creating HABILITATION topics..."
log_info "-------------------------------------------------------------------"

create_topic "suivipro.habilitation.events.attributed" 12 3 7776000000
create_topic "suivipro.habilitation.events.suspended" 6 3 7776000000
create_topic "suivipro.habilitation.events.renewed" 6 3 7776000000

# =============================================================================
# FORMATION TOPICS
# =============================================================================
log_info ""
log_info "Creating FORMATION topics..."
log_info "-------------------------------------------------------------------"

create_topic "suivipro.formation.events.completed" 12 3 7776000000
create_topic "suivipro.formation.events.session-created" 6 3 2592000000

# =============================================================================
# VISITE MEDICALE & CONSTAT TOPICS
# =============================================================================
log_info ""
log_info "Creating VISITE MEDICALE & CONSTAT topics..."
log_info "-------------------------------------------------------------------"

create_topic "suivipro.visite-medicale.events.created" 6 3 7776000000
create_topic "suivipro.constat.events.created" 6 3 7776000000
create_topic "suivipro.constat.events.validated" 6 3 7776000000

# =============================================================================
# ECART CONDUITE & INCIDENT TOPICS
# =============================================================================
log_info ""
log_info "Creating ECART CONDUITE & INCIDENT topics..."
log_info "-------------------------------------------------------------------"

create_topic "suivipro.ecart-conduite.events.detected" 12 3 2592000000
# 365 jours = 31536000000 ms
create_topic "suivipro.incident.events.declared" 12 3 31536000000
create_topic "suivipro.incident.events.analyzed" 6 3 31536000000

# =============================================================================
# REX & OBJECTIF TOPICS
# =============================================================================
log_info ""
log_info "Creating REX & OBJECTIF topics..."
log_info "-------------------------------------------------------------------"

create_topic "suivipro.rex.events.published" 6 3 7776000000
create_topic "suivipro.objectif.events.created" 6 3 7776000000
create_topic "suivipro.objectif.events.evaluated" 6 3 7776000000

# =============================================================================
# ALERTE & NOTIFICATION TOPICS
# =============================================================================
log_info ""
log_info "Creating ALERTE & NOTIFICATION topics..."
log_info "-------------------------------------------------------------------"

create_topic "suivipro.alerte.events.created" 12 3 2592000000
create_topic "suivipro.alerte.events.treated" 6 3 2592000000
# 7 jours = 604800000 ms
create_topic "suivipro.notification.events.sent" 12 3 604800000

# =============================================================================
# INTEGRATION TOPICS
# =============================================================================
log_info ""
log_info "Creating INTEGRATION topics..."
log_info "-------------------------------------------------------------------"

create_topic "suivipro.integration.events.serfrh-synced" 3 3 2592000000
create_topic "suivipro.integration.events.digiplan-synced" 3 3 2592000000
create_topic "suivipro.integration.events.nefertari-synced" 6 3 2592000000
create_topic "suivipro.integration.events.error" 6 3 7776000000

# =============================================================================
# DOCUMENT TOPIC
# =============================================================================
log_info ""
log_info "Creating DOCUMENT topic..."
log_info "-------------------------------------------------------------------"

create_topic "suivipro.document.events.generated" 6 3 2592000000

# =============================================================================
# AUDIT TOPICS
# =============================================================================
log_info ""
log_info "Creating AUDIT topics..."
log_info "-------------------------------------------------------------------"

create_topic "suivipro.audit.logs.action" 24 3 31536000000
create_topic "suivipro.audit.logs.access" 12 3 7776000000

# =============================================================================
# SYSTEM TOPICS (DLQ, Monitoring, Healthcheck)
# =============================================================================
log_info ""
log_info "Creating SYSTEM topics..."
log_info "-------------------------------------------------------------------"

create_topic "suivipro.dlq.errors" 12 3 7776000000
create_topic "suivipro.monitoring.metrics" 12 3 604800000
# 1 jour = 86400000 ms
create_topic "suivipro.healthcheck.heartbeat" 6 3 86400000

# =============================================================================
# SUMMARY
# =============================================================================
log_info ""
log_info "==================================================================="
log_info "Topics initialization completed!"
log_info "==================================================================="

log_info ""
log_info "Listing all created topics:"
kafka-topics --bootstrap-server $BOOTSTRAP_SERVERS --list | grep "^suivipro\."

log_info ""
log_info "Total topics count:"
TOPIC_COUNT=$(kafka-topics --bootstrap-server $BOOTSTRAP_SERVERS --list | grep -c "^suivipro\.")
log_success "$TOPIC_COUNT topics created"

log_info ""
log_info "==================================================================="
log_info "Kafka topics initialization completed successfully!"
log_info "==================================================================="

exit 0
