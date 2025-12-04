FROM docker.elastic.co/logstash/logstash:8.11.0

# Copier la configuration Logstash
COPY logstash.conf /usr/share/logstash/pipeline/logstash.conf

# Installer les plugins nécessaires (si besoin)
# RUN logstash-plugin install logstash-filter-json

USER logstash
