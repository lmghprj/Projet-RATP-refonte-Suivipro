#!/bin/sh

# Remplacer les variables d'environnement dans les fichiers JS
find /usr/share/nginx/html -type f -name "*.js" -exec sed -i \
  "s|VITE_API_URL_PLACEHOLDER|${VITE_API_URL:-http://localhost:3001}|g" {} \;

# Démarrer nginx
exec "$@"
