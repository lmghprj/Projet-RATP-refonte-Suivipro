#!/bin/bash

# =============================================================================
# Script de tuning système pour Kafka (Linux)
# =============================================================================
# Ce script applique les optimisations système recommandées pour Kafka
#
# ATTENTION: Ce script nécessite les privilèges root
# Usage: sudo ./system-tuning.sh
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

# Vérifier les privilèges root
if [ "$EUID" -ne 0 ]; then
    log_error "This script must be run as root"
    log_info "Usage: sudo $0"
    exit 1
fi

log_info "==================================================================="
log_info "Kafka System Tuning for SuiviPro 2"
log_info "==================================================================="

log_warning "This script will modify system settings for optimal Kafka performance"
read -p "Continue? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    log_info "Tuning cancelled."
    exit 0
fi

# Créer une sauvegarde de sysctl.conf
BACKUP_FILE="/etc/sysctl.conf.backup-$(date +%Y%m%d-%H%M%S)"
log_info "Creating backup of /etc/sysctl.conf to $BACKUP_FILE"
cp /etc/sysctl.conf "$BACKUP_FILE"

log_info ""
log_info "Applying system tuning parameters..."
log_info "-------------------------------------------------------------------"

# =============================================================================
# FILE DESCRIPTORS
# =============================================================================
log_info "Increasing file descriptors limit..."

# Augmenter les limites pour l'utilisateur actuel
cat >> /etc/security/limits.conf <<EOF

# Kafka tuning - Added $(date +%Y-%m-%d)
*       soft    nofile  100000
*       hard    nofile  100000
*       soft    nproc   65536
*       hard    nproc   65536
EOF

# Pour la session actuelle
ulimit -n 100000 2>/dev/null || log_warning "Cannot set ulimit for current session"

log_success "File descriptors limit increased to 100000"

# =============================================================================
# NETWORK TUNING
# =============================================================================
log_info "Optimizing network settings..."

cat >> /etc/sysctl.conf <<EOF

# ============================================
# Kafka Network Tuning - Added $(date +%Y-%m-%d)
# ============================================

# Augmenter les buffers socket
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728

# Augmenter le nombre maximum de connexions
net.core.somaxconn = 1024
net.core.netdev_max_backlog = 5000

# Optimisations TCP
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_max_syn_backlog = 8096
net.ipv4.tcp_slow_start_after_idle = 0

# Réutilisation rapide des sockets TIME_WAIT
net.ipv4.tcp_tw_reuse = 1

EOF

log_success "Network settings optimized"

# =============================================================================
# MEMORY & SWAP
# =============================================================================
log_info "Optimizing memory settings..."

cat >> /etc/sysctl.conf <<EOF

# ============================================
# Kafka Memory Tuning
# ============================================

# Réduire swappiness (Kafka ne doit jamais swapper)
vm.swappiness = 1

# Augmenter dirty ratio pour meilleure performance I/O
vm.dirty_ratio = 80
vm.dirty_background_ratio = 5

# Augmenter la taille du cache pour les inodes et dentries
vm.vfs_cache_pressure = 50

EOF

log_success "Memory settings optimized"

# =============================================================================
# DISK I/O
# =============================================================================
log_info "Checking disk I/O scheduler..."

# Détecter les disques
DISKS=$(lsblk -d -o NAME,TYPE | grep disk | awk '{print $1}')

for DISK in $DISKS; do
    CURRENT_SCHEDULER=$(cat /sys/block/$DISK/queue/scheduler 2>/dev/null | grep -oP '\[\K[^\]]+' || echo "unknown")
    log_info "Current scheduler for $DISK: $CURRENT_SCHEDULER"

    # Vérifier si c'est un SSD
    ROTA=$(cat /sys/block/$DISK/queue/rotational 2>/dev/null || echo "1")

    if [ "$ROTA" -eq 0 ]; then
        # SSD: utiliser noop ou none
        if [ -f /sys/block/$DISK/queue/scheduler ]; then
            echo noop > /sys/block/$DISK/queue/scheduler 2>/dev/null || \
            echo none > /sys/block/$DISK/queue/scheduler 2>/dev/null || \
            log_warning "Could not set scheduler for $DISK"

            log_success "Set scheduler to 'noop' for SSD: $DISK"
        fi
    else
        # HDD: utiliser deadline
        if [ -f /sys/block/$DISK/queue/scheduler ]; then
            echo deadline > /sys/block/$DISK/queue/scheduler 2>/dev/null || \
            log_warning "Could not set scheduler for $DISK"

            log_success "Set scheduler to 'deadline' for HDD: $DISK"
        fi
    fi

    # Augmenter read-ahead
    if [ -f /sys/block/$DISK/queue/read_ahead_kb ]; then
        echo 1024 > /sys/block/$DISK/queue/read_ahead_kb 2>/dev/null
        log_success "Increased read-ahead for $DISK to 1024 KB"
    fi
done

# =============================================================================
# APPLIQUER LES CHANGEMENTS
# =============================================================================
log_info ""
log_info "Applying sysctl changes..."
sysctl -p

log_success "System tuning applied successfully!"

log_info ""
log_info "==================================================================="
log_info "Summary of Changes"
log_info "==================================================================="
log_info "File Descriptors:"
log_info "  - nofile: 100000"
log_info "  - nproc: 65536"
log_info ""
log_info "Network:"
log_info "  - Socket buffer max: 128 MB"
log_info "  - Max connections: 1024"
log_info ""
log_info "Memory:"
log_info "  - Swappiness: 1"
log_info "  - Dirty ratio: 80%"
log_info ""
log_info "Disk I/O:"
log_info "  - Scheduler optimized per disk type"
log_info "  - Read-ahead: 1024 KB"
log_info ""
log_info "==================================================================="
log_info "Next Steps"
log_info "==================================================================="
log_info "1. Reboot the system for all changes to take effect:"
log_info "   sudo reboot"
log_info ""
log_info "2. Or reload limits without reboot:"
log_info "   - Logout and login again"
log_info "   - Restart Docker: sudo systemctl restart docker"
log_info ""
log_info "3. Verify changes:"
log_info "   - File descriptors: ulimit -n"
log_info "   - Sysctl: sysctl -a | grep -E 'net.core|vm.swappiness'"
log_info ""
log_info "Backup saved to: $BACKUP_FILE"
log_info "==================================================================="
