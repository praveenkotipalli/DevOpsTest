package com.devops;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.ResponseEntity;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class SampleApplicationTests {

    @LocalServerPort
    private int port;

    private final TestRestTemplate restTemplate = new TestRestTemplate();

    @Test
    void contextLoads() {
        // Test that the application context loads successfully
    }

    @Test
    void homeEndpointReturnsCorrectMessage() {
        String url = "http://localhost:" + port + "/";
        ResponseEntity<String> response = restTemplate.getForEntity(url, String.class);
        
        assertEquals(200, response.getStatusCodeValue());
        assertTrue(response.getBody().contains("DevOps Pipeline is Running"));
    }

    @Test
    void healthEndpointReturnsHealthy() {
        String url = "http://localhost:" + port + "/health";
        ResponseEntity<String> response = restTemplate.getForEntity(url, String.class);
        
        assertEquals(200, response.getStatusCodeValue());
        assertTrue(response.getBody().contains("Healthy"));
    }

    @Test
    void performanceEndpointReturnsMetricsInfo() {
        String url = "http://localhost:" + port + "/performance";
        ResponseEntity<String> response = restTemplate.getForEntity(url, String.class);
        
        assertEquals(200, response.getStatusCodeValue());
        assertTrue(response.getBody().contains("Performance metrics"));
    }
}
