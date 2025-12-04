package fr.ratp.suivipro.paisf;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.kafka.annotation.EnableKafka;

@SpringBootApplication
@EnableKafka
public class PaisfServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(PaisfServiceApplication.class, args);
    }
}
