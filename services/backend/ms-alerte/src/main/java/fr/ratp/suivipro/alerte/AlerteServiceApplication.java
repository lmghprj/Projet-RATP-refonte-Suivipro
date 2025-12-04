package fr.ratp.suivipro.alerte;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.kafka.annotation.EnableKafka;

@SpringBootApplication
@EnableKafka
public class AlerteServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(AlerteServiceApplication.class, args);
    }
}
