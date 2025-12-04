#!/bin/bash

# =============================================================================
# Script de démarrage du cluster Kafka SuiviPro 2
# =============================================================================

set -e

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_info "==================================================================="
log_info "Starting SuiviPro 2 Kafka Cluster"
log_info "==================================================================="

# Vérifier si Docker est installé
if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Vérifier si Docker Compose est installé
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    log_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Déterminer la commande docker-compose
if docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

log_info "Using Docker Compose command: $DOCKER_COMPOSE"

# Créer les dossiers de configuration s'ils n'existent pas
log_info "Creating configuration directories..."
mkdir -p config/connect-plugins

log_info ""
log_info "Starting Kafka cluster components..."
log_info "This may take several minutes on first run..."
log_info ""

# Démarrer les services
$DOCKER_COMPOSE up -d

log_info ""
log_info "Waiting for services to be healthy..."
log_info "This may take 2-3 minutes..."
sleep 10

# Attendre que les services soient en bonne santé
MAX_WAIT=180
ELAPSED=0
ALL_HEALTHY=false

while [ $ELAPSED -lt $MAX_WAIT ]; do
    UNHEALTHY=$($DOCKER_COMPOSE ps | grep -E "starting|unhealthy" || true)

    if [ -z "$UNHEALTHY" ]; then
        ALL_HEALTHY=true
        break
    fi

    echo -n "."
    sleep 5
    ELAPSED=$((ELAPSED + 5))
done

echo ""

if [ "$ALL_HEALTHY" = true ]; then
    log_success "All services are healthy!"
else
    log_warning "Some services may still be starting. Run './scripts/status.sh' to check."
fi

log_info ""
log_info "==================================================================="
log_info "Kafka Cluster Status"
log_info "==================================================================="

$DOCKER_COMPOSE ps

log_info ""
log_info "==================================================================="
log_info "Access Points"
log_info "==================================================================="
log_info "Kafka Brokers (external):"
log_info "  - Broker 1: localhost:19092"
log_info "  - Broker 2: localhost:19093"
log_info "  - Broker 3: localhost:19094"
log_info ""
log_info "Kafka Brokers (internal): kafka-broker-1:9092,kafka-broker-2:9092,kafka-broker-3:9092"
log_info ""
log_info "ZooKeeper:"
log_info "  - Node 1: localhost:2181"
log_info "  - Node 2: localhost:2182"
log_info "  - Node 3: localhost:2183"
log_info ""
log_info "Schema Registry: http://localhost:8081"
log_info "Kafka Connect: http://localhost:8083"
log_info "Kafka UI: http://localhost:8080"
log_info ""
log_info "==================================================================="
log_info "Next Steps"
log_info "==================================================================="
log_info "1. Check cluster status: ./scripts/status.sh"
log_info "2. Check health: ./scripts/health-check.sh"
log_info "3. View logs: $DOCKER_COMPOSE logs -f [service-name]"
log_info "4. Open Kafka UI: http://localhost:8080"
log_info ""
log_success "Kafka cluster started successfully!"
log_info "==================================================================="
