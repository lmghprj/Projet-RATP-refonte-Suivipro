package fr.ratp.suivipro.securite;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.kafka.annotation.EnableKafka;

@SpringBootApplication
@EnableKafka
public class SecuriteServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(SecuriteServiceApplication.class, args);
    }
}
