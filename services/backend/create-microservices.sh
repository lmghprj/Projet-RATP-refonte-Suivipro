#!/bin/bash

# Script pour créer la structure de base des microservices restants
# Basé sur le template de ms-agent

# Définition des microservices avec leurs ports et descriptions
declare -A SERVICES=(
    ["ms-habilitation"]="8082:suivipro_habilitation:Microservice de gestion des habilitations"
    ["ms-formation"]="8083:suivipro_formation:Microservice de gestion des formations et instructions"
    ["ms-securite"]="8084:suivipro_securite:Microservice de gestion de la sécurité et des écarts"
    ["ms-paisf"]="8085:suivipro_paisf:Microservice de gestion du PAISF"
    ["ms-alerte"]="8086:suivipro_alerte:Microservice de gestion des alertes"
    ["ms-objectif"]="8087:suivipro_objectif:Microservice de gestion des objectifs et indicateurs"
    ["ms-reporting"]="8088:suivipro_reporting:Microservice de reporting et BI"
    ["ms-organisation"]="8089:suivipro_organisation:Microservice de gestion de l'organisation"
    ["ms-iam"]="8090:suivipro_iam:Microservice de gestion IAM"
    ["ms-document"]="8091:suivipro_document:Microservice de gestion documentaire (GED)"
    ["ms-integration"]="8092:suivipro_integration:Microservice d'intégration SI"
    ["ms-notification"]="8093:suivipro_notification:Microservice de notifications"
    ["ms-audit"]="8094:suivipro_audit:Microservice d'audit et traçabilité"
    ["ms-referentiel"]="8095:suivipro_referentiel:Microservice de gestion des référentiels"
)

for SERVICE in "${!SERVICES[@]}"; do
    IFS=':' read -r PORT DB_NAME DESCRIPTION <<< "${SERVICES[$SERVICE]}"

    # Extraire le nom du package (ex: habilitation de ms-habilitation)
    PACKAGE_NAME=${SERVICE#ms-}
    CLASS_NAME="$(tr '[:lower:]' '[:upper:]' <<< ${PACKAGE_NAME:0:1})${PACKAGE_NAME:1}"

    echo "Creating $SERVICE..."

    # Créer pom.xml
    cat > "$SERVICE/pom.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
        <relativePath/>
    </parent>

    <groupId>fr.ratp.suivipro</groupId>
    <artifactId>$SERVICE</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <name>$SERVICE</name>
    <description>$DESCRIPTION - SuiviPro RATP</description>

    <properties>
        <java.version>17</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.kafka</groupId>
            <artifactId>spring-kafka</artifactId>
        </dependency>
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.springdoc</groupId>
            <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
            <version>2.2.0</version>
        </dependency>
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-registry-prometheus</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOF

    # Créer application.yml
    mkdir -p "$SERVICE/src/main/resources"
    cat > "$SERVICE/src/main/resources/application.yml" << EOF
spring:
  application:
    name: $SERVICE
  datasource:
    url: jdbc:postgresql://postgres:5432/$DB_NAME
    username: \${DB_USER:suivipro}
    password: \${DB_PASSWORD:suivipro123}
    driver-class-name: org.postgresql.Driver
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true
  kafka:
    bootstrap-servers: \${KAFKA_BOOTSTRAP_SERVERS:kafka:9092}
    consumer:
      group-id: ${SERVICE}-group
      auto-offset-reset: earliest
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.springframework.kafka.support.serializer.JsonDeserializer
      properties:
        spring.json.trusted.packages: '*'
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.springframework.kafka.support.serializer.JsonSerializer

server:
  port: $PORT

management:
  endpoints:
    web:
      exposure:
        include: health,info,prometheus,metrics
  metrics:
    export:
      prometheus:
        enabled: true

springdoc:
  api-docs:
    path: /api-docs
  swagger-ui:
    path: /swagger-ui.html
  info:
    title: ${CLASS_NAME^} Service API
    description: $DESCRIPTION
    version: 1.0.0

logging:
  level:
    fr.ratp.suivipro: INFO
EOF

    # Créer la classe principale
    mkdir -p "$SERVICE/src/main/java/fr/ratp/suivipro/$PACKAGE_NAME"
    cat > "$SERVICE/src/main/java/fr/ratp/suivipro/$PACKAGE_NAME/${CLASS_NAME}ServiceApplication.java" << EOF
package fr.ratp.suivipro.$PACKAGE_NAME;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.kafka.annotation.EnableKafka;

@SpringBootApplication
@EnableKafka
public class ${CLASS_NAME}ServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(${CLASS_NAME}ServiceApplication.class, args);
    }
}
EOF

    # Créer Dockerfile
    cat > "$SERVICE/Dockerfile" << EOF
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE $PORT
ENTRYPOINT ["java", "-jar", "app.jar"]
EOF

    # Créer .dockerignore
    cat > "$SERVICE/.dockerignore" << EOF
target/
.git/
.gitignore
*.md
.mvn/
mvnw
mvnw.cmd
EOF

    echo "$SERVICE created successfully"
done

echo "All microservices created!"
