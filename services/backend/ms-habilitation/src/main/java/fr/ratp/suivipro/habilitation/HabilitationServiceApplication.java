package fr.ratp.suivipro.habilitation;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.kafka.annotation.EnableKafka;

@SpringBootApplication
@EnableKafka
public class HabilitationServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(HabilitationServiceApplication.class, args);
    }
}
