# Script de gestion Docker pour Projet de Reference
# Usage: .\docker-manage.ps1 [start|stop|restart|rebuild|logs|status|clean|health]

param(
    [Parameter(Position=0)]
    [ValidateSet("start", "stop", "restart", "rebuild", "logs", "status", "clean", "health", "")]
    [string]$Command = ""
)

# Couleurs pour l'affichage
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Error-Message {
    param([string]$Message)
    Write-Host "[ERREUR] $Message" -ForegroundColor Red
}

function Write-Warning-Message {
    param([string]$Message)
    Write-Host "[ATTENTION] $Message" -ForegroundColor Yellow
}

function Write-Header {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Magenta
    Write-Host "  Projet de Reference - Gestion Docker" -ForegroundColor Magenta
    Write-Host "================================================" -ForegroundColor Magenta
    Write-Host ""
}

# Vérifier si Docker est installé et en cours d'exécution
function Test-Docker {
    try {
        $null = docker --version
        $null = docker ps
        return $true
    }
    catch {
        Write-Error-Message "Docker n'est pas installe ou n'est pas en cours d'execution"
        Write-Info "Veuillez demarrer Docker Desktop et reessayer"
        return $false
    }
}

# Afficher l'aide
function Show-Help {
    Write-Header
    Write-Host "Usage: .\docker-manage.ps1 [commande]" -ForegroundColor White
    Write-Host ""
    Write-Host "Commandes disponibles:" -ForegroundColor Yellow
    Write-Host "  start    " -NoNewline -ForegroundColor Green
    Write-Host "- Demarrer tous les services"
    Write-Host "  stop     " -NoNewline -ForegroundColor Green
    Write-Host "- Arreter tous les services"
    Write-Host "  restart  " -NoNewline -ForegroundColor Green
    Write-Host "- Redemarrer tous les services"
    Write-Host "  rebuild  " -NoNewline -ForegroundColor Green
    Write-Host "- Reconstruire et redemarrer tous les services"
    Write-Host "  logs     " -NoNewline -ForegroundColor Green
    Write-Host "- Afficher les logs de tous les services"
    Write-Host "  status   " -NoNewline -ForegroundColor Green
    Write-Host "- Afficher le statut des services"
    Write-Host "  health   " -NoNewline -ForegroundColor Green
    Write-Host "- Verifier la sante de tous les services"
    Write-Host "  clean    " -NoNewline -ForegroundColor Green
    Write-Host "- Arreter et supprimer tous les conteneurs et volumes"
    Write-Host ""
    Write-Host "Exemples:" -ForegroundColor Yellow
    Write-Host "  .\docker-manage.ps1 start"
    Write-Host "  .\docker-manage.ps1 logs"
    Write-Host "  .\docker-manage.ps1 status"
    Write-Host ""
}

# Démarrer les services
function Start-Services {
    Write-Header
    Write-Info "Demarrage des services..."

    docker-compose up -d

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Services demarres avec succes"
        Write-Host ""
        Write-Host "Accedez a l'application:" -ForegroundColor Yellow
        Write-Host "  - API Gateway    : " -NoNewline
        Write-Host "http://localhost:3000" -ForegroundColor Cyan
        Write-Host "  - User Service   : " -NoNewline
        Write-Host "http://localhost:8080" -ForegroundColor Cyan
        Write-Host "  - PostgreSQL     : " -NoNewline
        Write-Host "localhost:5432" -ForegroundColor Cyan
        Write-Host ""
        Write-Info "Conseil: Utilisez '.\docker-manage.ps1 health' pour verifier la sante des services"
    }
    else {
        Write-Error-Message "Echec du demarrage des services"
        exit 1
    }
}

# Arrêter les services
function Stop-Services {
    Write-Header
    Write-Info "Arret des services..."

    docker-compose stop

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Services arretes avec succes"
    }
    else {
        Write-Error-Message "Echec de l'arret des services"
        exit 1
    }
}

# Redémarrer les services
function Restart-Services {
    Write-Header
    Write-Info "Redemarrage des services..."

    docker-compose restart

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Services redemarres avec succes"
    }
    else {
        Write-Error-Message "Echec du redemarrage des services"
        exit 1
    }
}

# Reconstruire et redémarrer
function Rebuild-Services {
    Write-Header
    Write-Warning-Message "Cette operation va reconstruire toutes les images Docker"
    Write-Host ""

    Write-Info "Arret des services..."
    docker-compose down

    Write-Info "Reconstruction des images (cela peut prendre quelques minutes)..."
    docker-compose build --no-cache

    if ($LASTEXITCODE -ne 0) {
        Write-Error-Message "Echec de la reconstruction"
        exit 1
    }

    Write-Info "Demarrage des services..."
    docker-compose up -d

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Services reconstruits et demarres avec succes"
    }
    else {
        Write-Error-Message "Echec du demarrage des services"
        exit 1
    }
}

# Afficher les logs
function Show-Logs {
    Write-Header
    Write-Info "Affichage des logs (Ctrl+C pour quitter)..."
    Write-Host ""

    docker-compose logs -f
}

# Afficher le statut
function Show-Status {
    Write-Header
    Write-Info "Statut des services:"
    Write-Host ""

    docker-compose ps
}

# Vérifier la santé des services
function Test-Health {
    Write-Header
    Write-Info "Verification de la sante des services..."
    Write-Host ""

    $allHealthy = $true

    # Test API Gateway
    Write-Host "API Gateway (port 3000)... " -NoNewline
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -TimeoutSec 5 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "OK" -ForegroundColor Green
        }
        else {
            Write-Host "ERREUR" -ForegroundColor Red
            $allHealthy = $false
        }
    }
    catch {
        Write-Host "INACCESSIBLE" -ForegroundColor Red
        $allHealthy = $false
    }

    # Test User Service
    Write-Host "User Service (port 8080)... " -NoNewline
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/api/users/health" -TimeoutSec 5 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "OK" -ForegroundColor Green
        }
        else {
            Write-Host "ERREUR" -ForegroundColor Red
            $allHealthy = $false
        }
    }
    catch {
        Write-Host "INACCESSIBLE" -ForegroundColor Red
        $allHealthy = $false
    }

    # Test PostgreSQL
    Write-Host "PostgreSQL (port 5432)... " -NoNewline
    $postgresCheck = docker-compose exec -T postgres pg_isready -U postgres 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK" -ForegroundColor Green
    }
    else {
        Write-Host "ERREUR" -ForegroundColor Red
        $allHealthy = $false
    }

    Write-Host ""
    if ($allHealthy) {
        Write-Success "Tous les services sont operationnels"
    }
    else {
        Write-Warning-Message "Certains services ne repondent pas"
        Write-Info "Verifiez les logs avec: .\docker-manage.ps1 logs"
    }
}

# Nettoyer
function Clean-All {
    Write-Header
    Write-Warning-Message "Cette operation va supprimer tous les conteneurs et volumes"
    Write-Warning-Message "TOUTES LES DONNEES SERONT PERDUES"
    Write-Host ""

    $confirmation = Read-Host "Voulez-vous continuer? (oui/non)"

    if ($confirmation -ne "oui") {
        Write-Info "Operation annulee"
        return
    }

    Write-Info "Nettoyage en cours..."
    docker-compose down -v

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Nettoyage termine avec succes"
    }
    else {
        Write-Error-Message "Echec du nettoyage"
        exit 1
    }
}

# Programme principal
if (-not (Test-Docker)) {
    exit 1
}

switch ($Command) {
    "start" { Start-Services }
    "stop" { Stop-Services }
    "restart" { Restart-Services }
    "rebuild" { Rebuild-Services }
    "logs" { Show-Logs }
    "status" { Show-Status }
    "health" { Test-Health }
    "clean" { Clean-All }
    default { Show-Help }
}
