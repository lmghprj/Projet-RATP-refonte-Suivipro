; <?php exit; ?> DO NOT REMOVE THIS LINE
; Configuration Matomo pour SuiviPro RATP

[database]
host = "mysql"
username = "matomo"
password = "matomo"
dbname = "matomo"
tables_prefix = "matomo_"
port = 3306
adapter = "PDO\MYSQL"
type = "InnoDB"
schema = "Db"

[database_tests]
host = "mysql"
username = "matomo"
password = "matomo"
dbname = "matomo_tests"
tables_prefix = "matomo_"
port = 3306

[General]
salt = "changez_cette_valeur_salt_en_production_avec_valeur_securisee"
trusted_hosts[] = "matomo"
trusted_hosts[] = "localhost"
trusted_hosts[] = "suivipro-ratp.local"

force_ssl = 0
assume_secure_protocol = 0
enable_auto_update = 1
enable_update_communication = 1

[mail]
transport = "smtp"
host = ""
port = 25
username = ""
password = ""
encryption = ""

[log]
log_writers[] = "file"
log_level = "WARN"

[Tracker]
enable_fingerprinting_across_websites = 1
record_statistics = 1
trust_visitors_cookies = 1

[PluginsInstalled]
PluginsInstalled[] = "CorePluginsAdmin"
PluginsInstalled[] = "CoreAdminHome"
PluginsInstalled[] = "CoreHome"
PluginsInstalled[] = "Dashboard"
PluginsInstalled[] = "Goals"
PluginsInstalled[] = "Ecommerce"
