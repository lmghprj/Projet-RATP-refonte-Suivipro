import os
from cachelib.file import FileSystemCache

# Configuration Superset pour SuiviPro RATP

# Secret key pour les sessions
SECRET_KEY = os.environ.get('SUPERSET_SECRET_KEY', 'changez-cette-cle-en-production-super-secrete')

# Configuration de la base de données
SQLALCHEMY_DATABASE_URI = os.environ.get('SUPERSET_DATABASE_URI',
    'postgresql://postgres:postgres@postgres:5432/supersetdb')

# Désactiver SQLAlchemy track modifications
SQLALCHEMY_TRACK_MODIFICATIONS = False

# Configuration du cache
CACHE_CONFIG = {
    'CACHE_TYPE': 'FileSystemCache',
    'CACHE_DEFAULT_TIMEOUT': 300,
    'CACHE_DIR': '/app/superset_cache',
    'CACHE_THRESHOLD': 500
}

# Configuration de la connexion à la base de données SuiviPro
DATABASES = {
    'reporting': {
        'type': 'postgresql',
        'host': 'postgres',
        'port': 5432,
        'database': 'reportingdb',
        'username': 'postgres',
        'password': 'postgres'
    }
}

# Configuration de sécurité
WTF_CSRF_ENABLED = True
WTF_CSRF_TIME_LIMIT = None

# Configuration du serveur web
SUPERSET_WEBSERVER_PORT = 8088
SUPERSET_WEBSERVER_TIMEOUT = 60

# Configuration de l'authentification
AUTH_TYPE = 1  # Database authentication
AUTH_USER_REGISTRATION = True
AUTH_USER_REGISTRATION_ROLE = "Public"

# Langue par défaut
BABEL_DEFAULT_LOCALE = 'fr'

# Configuration du logo
APP_NAME = "SuiviPro RATP - Analytics"
APP_ICON = "/static/assets/images/superset-logo.png"

# Feature flags
FEATURE_FLAGS = {
    "ENABLE_TEMPLATE_PROCESSING": True,
    "DASHBOARD_NATIVE_FILTERS": True,
    "DASHBOARD_CROSS_FILTERS": True,
    "DASHBOARD_NATIVE_FILTERS_SET": True,
}

# Configuration des logs
LOG_LEVEL = "INFO"
ENABLE_PROXY_FIX = True

# Configuration des emails (si nécessaire)
SMTP_HOST = os.environ.get('SMTP_HOST', 'localhost')
SMTP_PORT = int(os.environ.get('SMTP_PORT', 25))
SMTP_MAIL_FROM = os.environ.get('SMTP_MAIL_FROM', 'superset@ratp.fr')

# Limite de résultats
ROW_LIMIT = 50000
SAMPLES_ROW_LIMIT = 1000

# Configuration des visualisations
VIZ_ROW_LIMIT = 10000
