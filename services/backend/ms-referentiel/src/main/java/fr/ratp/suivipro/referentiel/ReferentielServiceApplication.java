package fr.ratp.suivipro.referentiel;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.kafka.annotation.EnableKafka;

@SpringBootApplication
@EnableKafka
public class ReferentielServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(ReferentielServiceApplication.class, args);
    }
}
