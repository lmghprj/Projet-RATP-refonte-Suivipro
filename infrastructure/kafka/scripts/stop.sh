#!/bin/bash

# =============================================================================
# Script d'arrêt du cluster Kafka SuiviPro 2
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

# Déterminer la commande docker-compose
if docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

log_info "==================================================================="
log_info "Stopping SuiviPro 2 Kafka Cluster"
log_info "==================================================================="

# Option pour supprimer les volumes
REMOVE_VOLUMES=false
if [ "$1" == "--remove-volumes" ] || [ "$1" == "-v" ]; then
    log_warning "WARNING: This will remove all data volumes!"
    read -p "Are you sure? (yes/no): " confirm
    if [ "$confirm" == "yes" ]; then
        REMOVE_VOLUMES=true
    else
        log_info "Volume removal cancelled."
    fi
fi

log_info "Stopping all containers..."
$DOCKER_COMPOSE down

if [ "$REMOVE_VOLUMES" = true ]; then
    log_warning "Removing volumes..."
    $DOCKER_COMPOSE down -v
    log_success "Volumes removed successfully"
fi

log_success "Kafka cluster stopped successfully!"

log_info ""
log_info "==================================================================="
log_info "Next Steps"
log_info "==================================================================="
log_info "To start the cluster again: ./scripts/start.sh"
log_info "To remove volumes: ./scripts/stop.sh --remove-volumes"
log_info "==================================================================="
