#!/bin/bash

# Script d'initialisation de Superset

echo "Initialisation de la base de données Superset..."
superset db upgrade

echo "Création de l'utilisateur administrateur..."
superset fab create-admin \
    --username admin \
    --firstname Admin \
    --lastname RATP \
    --email admin@ratp.fr \
    --password "${SUPERSET_ADMIN_PASSWORD:-Admin@2024}"

echo "Initialisation de Superset..."
superset init

echo "Import des exemples (optionnel)..."
# superset load_examples

echo "Superset initialisé avec succès!"
