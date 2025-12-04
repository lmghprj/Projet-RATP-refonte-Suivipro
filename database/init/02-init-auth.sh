#!/bin/bash

# Script pour créer la base de données authdb

echo "Creating authdb database..."

# Se connecter à PostgreSQL et créer la base authdb
# L'erreur sera ignorée si la base existe déjà
psql -v ON_ERROR_STOP=0 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE authdb;
EOSQL

echo "Database setup completed!"
