FROM matomo:5.0-fpm-alpine

# Copier la configuration personnalisée (sera créée lors de l'installation)
# COPY config.ini.php /var/www/html/config/config.ini.php

# Permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD php-fpm-healthcheck || exit 1
