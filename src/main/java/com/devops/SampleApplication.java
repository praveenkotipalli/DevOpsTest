package com.devops;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class SampleApplication {

    public static void main(String[] args) {
        SpringApplication.run(SampleApplication.class, args);
    }

    @GetMapping("/")
    public String home() {
        return "🚀 DevOps Pipeline is Running! Performance Testing Active!";
    }

    @GetMapping("/health")
    public String health() {
        return "✅ Application is Healthy!";
    }

    @GetMapping("/performance")
    public String performance() {
        return "📊 Performance metrics are being collected by Prometheus!";
    }
}
