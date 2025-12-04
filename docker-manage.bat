@echo off
REM Script de gestion Docker pour Projet de Reference
REM Usage: docker-manage.bat [start|stop|restart|rebuild|logs|status|clean]

setlocal

if "%1"=="" (
    echo Usage: docker-manage.bat [start^|stop^|restart^|rebuild^|logs^|status^|clean]
    echo.
    echo Commandes disponibles:
    echo   start    - Demarrer tous les services
    echo   stop     - Arreter tous les services
    echo   restart  - Redemarrer tous les services
    echo   rebuild  - Reconstruire et redemarrer tous les services
    echo   logs     - Afficher les logs de tous les services
    echo   status   - Afficher le statut des services
    echo   clean    - Arreter et supprimer tous les conteneurs et volumes
    exit /b 1
)

set COMMAND=%1

if "%COMMAND%"=="start" (
    echo [INFO] Demarrage des services...
    docker-compose up -d
    if errorlevel 1 (
        echo [ERREUR] Echec du demarrage des services
        exit /b 1
    )
    echo [OK] Services demarres avec succes
    echo.
    echo Accedez a l'application:
    echo   - API Gateway: http://localhost:3000
    echo   - User Service: http://localhost:8080
    echo   - PostgreSQL: localhost:5432
    goto end
)

if "%COMMAND%"=="stop" (
    echo [INFO] Arret des services...
    docker-compose stop
    if errorlevel 1 (
        echo [ERREUR] Echec de l'arret des services
        exit /b 1
    )
    echo [OK] Services arretes avec succes
    goto end
)

if "%COMMAND%"=="restart" (
    echo [INFO] Redemarrage des services...
    docker-compose restart
    if errorlevel 1 (
        echo [ERREUR] Echec du redemarrage des services
        exit /b 1
    )
    echo [OK] Services redemarres avec succes
    goto end
)

if "%COMMAND%"=="rebuild" (
    echo [INFO] Reconstruction et redemarrage des services...
    echo [INFO] Arret des services...
    docker-compose down
    echo [INFO] Reconstruction des images...
    docker-compose build --no-cache
    if errorlevel 1 (
        echo [ERREUR] Echec de la reconstruction
        exit /b 1
    )
    echo [INFO] Demarrage des services...
    docker-compose up -d
    if errorlevel 1 (
        echo [ERREUR] Echec du demarrage des services
        exit /b 1
    )
    echo [OK] Services reconstruits et demarres avec succes
    goto end
)

if "%COMMAND%"=="logs" (
    echo [INFO] Affichage des logs (Ctrl+C pour quitter)...
    docker-compose logs -f
    goto end
)

if "%COMMAND%"=="status" (
    echo [INFO] Statut des services:
    echo.
    docker-compose ps
    goto end
)

if "%COMMAND%"=="clean" (
    echo [AVERTISSEMENT] Cette operation va supprimer tous les conteneurs et volumes (perte de donnees^)
    set /p CONFIRM="Voulez-vous continuer? (oui/non): "
    if /i not "%CONFIRM%"=="oui" (
        echo [INFO] Operation annulee
        goto end
    )
    echo [INFO] Nettoyage en cours...
    docker-compose down -v
    if errorlevel 1 (
        echo [ERREUR] Echec du nettoyage
        exit /b 1
    )
    echo [OK] Nettoyage termine avec succes
    goto end
)

echo [ERREUR] Commande invalide: %COMMAND%
echo Usage: docker-manage.bat [start^|stop^|restart^|rebuild^|logs^|status^|clean]
exit /b 1

:end
endlocal
