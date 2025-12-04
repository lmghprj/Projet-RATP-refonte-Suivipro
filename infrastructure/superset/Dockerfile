FROM apache/superset:3.0.0

USER root

# Installer les drivers de base de données supplémentaires
RUN pip install psycopg2-binary

# Copier la configuration personnalisée
COPY superset_config.py /app/pythonpath/superset_config.py

# Créer les répertoires nécessaires
RUN mkdir -p /app/superset_cache && \
    chown -R superset:superset /app/superset_cache

USER superset

# Initialiser la base de données
# RUN superset db upgrade && \
#     superset fab create-admin \
#         --username admin \
#         --firstname Admin \
#         --lastname RATP \
#         --email admin@ratp.fr \
#         --password Admin@2024 && \
#     superset init

EXPOSE 8088

HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl --fail http://localhost:8088/health || exit 1
