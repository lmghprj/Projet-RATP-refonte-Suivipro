#!/bin/bash

# =============================================================================
# Script de vérification de santé du cluster Kafka SuiviPro 2
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
log_info "SuiviPro 2 Kafka Cluster Health Check"
log_info "==================================================================="

HEALTH_PASSED=0
HEALTH_FAILED=0

run_check() {
    local check_name=$1
    local check_command=$2

    echo -n "Checking $check_name... "

    if eval "$check_command" &> /dev/null; then
        echo -e "${GREEN}✓ PASS${NC}"
        HEALTH_PASSED=$((HEALTH_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        HEALTH_FAILED=$((HEALTH_FAILED + 1))
        return 1
    fi
}

log_info ""
log_info "ZooKeeper Health Checks"
log_info "-------------------------------------------------------------------"

run_check "ZooKeeper 1 connectivity" "docker exec zookeeper-1 bash -c 'echo ruok | nc localhost 2181 | grep imok'"
run_check "ZooKeeper 2 connectivity" "docker exec zookeeper-2 bash -c 'echo ruok | nc localhost 2181 | grep imok'"
run_check "ZooKeeper 3 connectivity" "docker exec zookeeper-3 bash -c 'echo ruok | nc localhost 2181 | grep imok'"

log_info ""
log_info "Kafka Broker Health Checks"
log_info "-------------------------------------------------------------------"

run_check "Kafka Broker 1 API" "docker exec kafka-broker-1 kafka-broker-api-versions --bootstrap-server localhost:9092"
run_check "Kafka Broker 2 API" "docker exec kafka-broker-2 kafka-broker-api-versions --bootstrap-server localhost:9092"
run_check "Kafka Broker 3 API" "docker exec kafka-broker-3 kafka-broker-api-versions --bootstrap-server localhost:9092"

log_info ""
log_info "Kafka Cluster Health Checks"
log_info "-------------------------------------------------------------------"

run_check "Cluster metadata" "docker exec kafka-broker-1 kafka-metadata --bootstrap-server kafka-broker-1:9092 --describe --replication"

# Vérifier le nombre de brokers
echo -n "Checking broker count... "
BROKER_COUNT=$(docker exec kafka-broker-1 kafka-broker-api-versions --bootstrap-server kafka-broker-1:9092 2>/dev/null | grep -c "id:" || echo "0")
if [ "$BROKER_COUNT" -eq 3 ]; then
    echo -e "${GREEN}✓ PASS${NC} (3 brokers found)"
    HEALTH_PASSED=$((HEALTH_PASSED + 1))
else
    echo -e "${RED}✗ FAIL${NC} (Expected 3 brokers, found $BROKER_COUNT)"
    HEALTH_FAILED=$((HEALTH_FAILED + 1))
fi

# Vérifier les partitions sous-répliquées
echo -n "Checking under-replicated partitions... "
UNDER_REPLICATED=$(docker exec kafka-broker-1 kafka-topics --bootstrap-server kafka-broker-1:9092 --describe 2>/dev/null | grep -c "UnderReplicated" || echo "0")
if [ "$UNDER_REPLICATED" -eq 0 ]; then
    echo -e "${GREEN}✓ PASS${NC} (No under-replicated partitions)"
    HEALTH_PASSED=$((HEALTH_PASSED + 1))
else
    echo -e "${YELLOW}⚠ WARNING${NC} ($UNDER_REPLICATED under-replicated partitions found)"
    HEALTH_FAILED=$((HEALTH_FAILED + 1))
fi

# Vérifier les partitions offline
echo -n "Checking offline partitions... "
OFFLINE_PARTITIONS=$(docker exec kafka-broker-1 kafka-topics --bootstrap-server kafka-broker-1:9092 --describe --unavailable-partitions 2>/dev/null | wc -l || echo "0")
if [ "$OFFLINE_PARTITIONS" -eq 0 ]; then
    echo -e "${GREEN}✓ PASS${NC} (No offline partitions)"
    HEALTH_PASSED=$((HEALTH_PASSED + 1))
else
    echo -e "${RED}✗ FAIL${NC} ($OFFLINE_PARTITIONS offline partitions found)"
    HEALTH_FAILED=$((HEALTH_FAILED + 1))
fi

log_info ""
log_info "Schema Registry Health Checks"
log_info "-------------------------------------------------------------------"

run_check "Schema Registry API" "curl -sf http://localhost:8081/subjects"

log_info ""
log_info "Kafka Connect Health Checks"
log_info "-------------------------------------------------------------------"

run_check "Kafka Connect API" "curl -sf http://localhost:8083/connectors"

log_info ""
log_info "Kafka UI Health Checks"
log_info "-------------------------------------------------------------------"

run_check "Kafka UI" "curl -sf http://localhost:8080/actuator/health"

log_info ""
log_info "Topic Checks"
log_info "-------------------------------------------------------------------"

# Vérifier le nombre de topics
echo -n "Checking SuiviPro topics count... "
TOPIC_COUNT=$(docker exec kafka-broker-1 kafka-topics --bootstrap-server kafka-broker-1:9092 --list 2>/dev/null | grep -c "^suivipro\." || echo "0")
if [ "$TOPIC_COUNT" -eq 30 ]; then
    echo -e "${GREEN}✓ PASS${NC} (30 topics found)"
    HEALTH_PASSED=$((HEALTH_PASSED + 1))
elif [ "$TOPIC_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠ WARNING${NC} (No topics found - run init-topics.sh)"
    HEALTH_FAILED=$((HEALTH_FAILED + 1))
else
    echo -e "${YELLOW}⚠ WARNING${NC} (Expected 30 topics, found $TOPIC_COUNT)"
    HEALTH_FAILED=$((HEALTH_FAILED + 1))
fi

log_info ""
log_info "==================================================================="
log_info "Health Check Summary"
log_info "==================================================================="

TOTAL_CHECKS=$((HEALTH_PASSED + HEALTH_FAILED))
SUCCESS_RATE=$((HEALTH_PASSED * 100 / TOTAL_CHECKS))

if [ $SUCCESS_RATE -eq 100 ]; then
    log_success "All health checks passed! ($HEALTH_PASSED/$TOTAL_CHECKS)"
    echo -e "${GREEN}Cluster Status: HEALTHY${NC}"
    exit 0
elif [ $SUCCESS_RATE -ge 80 ]; then
    log_warning "Most health checks passed ($HEALTH_PASSED/$TOTAL_CHECKS)"
    echo -e "${YELLOW}Cluster Status: DEGRADED${NC}"
    exit 1
else
    log_error "Many health checks failed ($HEALTH_FAILED/$TOTAL_CHECKS failed)"
    echo -e "${RED}Cluster Status: UNHEALTHY${NC}"
    exit 2
fi
