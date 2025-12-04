package fr.ratp.suivipro.objectif;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.kafka.annotation.EnableKafka;

@SpringBootApplication
@EnableKafka
public class ObjectifServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(ObjectifServiceApplication.class, args);
    }
}
