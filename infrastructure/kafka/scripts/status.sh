#!/bin/bash

# =============================================================================
# Script de vérification du statut du cluster Kafka SuiviPro 2
# =============================================================================

set -e

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

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

# Vérifier que nous sommes dans le bon répertoire
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
KAFKA_DIR="$(dirname "$SCRIPT_DIR")"

cd "$KAFKA_DIR"

# Déterminer la commande docker-compose
if docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

log_info "==================================================================="
log_info "SuiviPro 2 Kafka Cluster Status"
log_info "==================================================================="

# Vérifier si les conteneurs sont en cours d'exécution
RUNNING_CONTAINERS=$($DOCKER_COMPOSE ps --services --filter "status=running" 2>/dev/null | wc -l)
TOTAL_CONTAINERS=$($DOCKER_COMPOSE ps --services 2>/dev/null | wc -l)

log_info "Running containers: $RUNNING_CONTAINERS / $TOTAL_CONTAINERS"
log_info ""

# Afficher le statut détaillé
$DOCKER_COMPOSE ps

log_info ""
log_info "==================================================================="
log_info "Service Health Status"
log_info "==================================================================="

check_service_health() {
    local service_name=$1
    local container_name=$2

    HEALTH=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null || echo "no-healthcheck")

    if [ "$HEALTH" == "healthy" ]; then
        echo -e "${GREEN}✓${NC} $service_name: ${GREEN}healthy${NC}"
    elif [ "$HEALTH" == "unhealthy" ]; then
        echo -e "${RED}✗${NC} $service_name: ${RED}unhealthy${NC}"
    elif [ "$HEALTH" == "starting" ]; then
        echo -e "${YELLOW}⟳${NC} $service_name: ${YELLOW}starting${NC}"
    elif [ "$HEALTH" == "no-healthcheck" ]; then
        STATUS=$(docker inspect --format='{{.State.Status}}' "$container_name" 2>/dev/null || echo "not-found")
        if [ "$STATUS" == "running" ]; then
            echo -e "${CYAN}○${NC} $service_name: ${CYAN}running (no healthcheck)${NC}"
        else
            echo -e "${RED}✗${NC} $service_name: ${RED}$STATUS${NC}"
        fi
    else
        echo -e "${RED}✗${NC} $service_name: ${RED}unknown${NC}"
    fi
}

check_service_health "ZooKeeper 1" "zookeeper-1"
check_service_health "ZooKeeper 2" "zookeeper-2"
check_service_health "ZooKeeper 3" "zookeeper-3"
log_info ""
check_service_health "Kafka Broker 1" "kafka-broker-1"
check_service_health "Kafka Broker 2" "kafka-broker-2"
check_service_health "Kafka Broker 3" "kafka-broker-3"
log_info ""
check_service_health "Schema Registry" "schema-registry"
check_service_health "Kafka Connect" "kafka-connect"
check_service_health "Kafka UI" "kafka-ui"

log_info ""
log_info "==================================================================="
log_info "Kafka Topics"
log_info "==================================================================="

# Vérifier si on peut accéder au cluster Kafka
if docker exec kafka-broker-1 kafka-topics --bootstrap-server kafka-broker-1:9092 --list &> /dev/null; then
    TOPIC_COUNT=$(docker exec kafka-broker-1 kafka-topics --bootstrap-server kafka-broker-1:9092 --list 2>/dev/null | grep -c "^suivipro\." || echo "0")
    log_info "Total SuiviPro topics: $TOPIC_COUNT"

    if [ "$1" == "--verbose" ] || [ "$1" == "-v" ]; then
        log_info ""
        log_info "Topic list:"
        docker exec kafka-broker-1 kafka-topics --bootstrap-server kafka-broker-1:9092 --list 2>/dev/null | grep "^suivipro\." | sort
    fi
else
    log_warning "Cannot connect to Kafka cluster to list topics"
fi

log_info ""
log_info "==================================================================="
log_info "Resource Usage"
log_info "==================================================================="

echo -e "${CYAN}Container${NC}                  ${CYAN}CPU %${NC}     ${CYAN}Memory${NC}"
echo "-------------------------------------------------------------------"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" | grep -E "zookeeper|kafka|schema|connect" || log_warning "Cannot retrieve stats"

log_info ""
log_info "==================================================================="
log_info "Useful Commands"
log_info "==================================================================="
log_info "View logs: $DOCKER_COMPOSE logs -f [service-name]"
log_info "Check health: ./scripts/health-check.sh"
log_info "List all topics: $DOCKER_COMPOSE exec kafka-broker-1 kafka-topics --bootstrap-server kafka-broker-1:9092 --list"
log_info "Describe topic: $DOCKER_COMPOSE exec kafka-broker-1 kafka-topics --bootstrap-server kafka-broker-1:9092 --describe --topic <topic-name>"
log_info "Open Kafka UI: http://localhost:8080"
log_info "==================================================================="
