package fr.ratp.suivipro.agent.controller;

import fr.ratp.suivipro.agent.dto.AgentDTO;
import fr.ratp.suivipro.agent.dto.CreateAgentRequest;
import fr.ratp.suivipro.agent.service.AgentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.sql.DataSource;
import java.sql.Connection;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/agents")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Agents", description = "API de gestion des dossiers agents")
public class AgentController {

    private final AgentService agentService;

    @Autowired
    private DataSource dataSource;

    @PostMapping
    @Operation(summary = "Créer un nouvel agent")
    public ResponseEntity<AgentDTO> createAgent(@Valid @RequestBody CreateAgentRequest request) {
        log.info("POST /api/agents - Creating agent");
        AgentDTO agent = agentService.createAgent(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(agent);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Récupérer un agent par ID")
    public ResponseEntity<AgentDTO> getAgentById(
            @Parameter(description = "ID de l'agent") @PathVariable Long id) {
        log.info("GET /api/agents/{} - Fetching agent", id);
        AgentDTO agent = agentService.getAgentById(id);
        return ResponseEntity.ok(agent);
    }

    @GetMapping("/matricule/{matricule}")
    @Operation(summary = "Récupérer un agent par matricule")
    public ResponseEntity<AgentDTO> getAgentByMatricule(
            @Parameter(description = "Matricule de l'agent") @PathVariable String matricule) {
        log.info("GET /api/agents/matricule/{} - Fetching agent", matricule);
        AgentDTO agent = agentService.getAgentByMatricule(matricule);
        return ResponseEntity.ok(agent);
    }

    @GetMapping
    @Operation(summary = "Récupérer tous les agents")
    public ResponseEntity<List<AgentDTO>> getAllAgents() {
        log.info("GET /api/agents - Fetching all agents");
        List<AgentDTO> agents = agentService.getAllAgents();
        return ResponseEntity.ok(agents);
    }

    @GetMapping("/statut/{statut}")
    @Operation(summary = "Récupérer les agents par statut")
    public ResponseEntity<Page<AgentDTO>> getAgentsByStatut(
            @Parameter(description = "Statut de l'agent") @PathVariable String statut,
            Pageable pageable) {
        log.info("GET /api/agents/statut/{} - Fetching agents", statut);
        Page<AgentDTO> agents = agentService.getAgentsByStatut(statut, pageable);
        return ResponseEntity.ok(agents);
    }

    @GetMapping("/search")
    @Operation(summary = "Rechercher des agents")
    public ResponseEntity<Page<AgentDTO>> searchAgents(
            @Parameter(description = "Terme de recherche") @RequestParam String search,
            Pageable pageable) {
        log.info("GET /api/agents/search?search={} - Searching agents", search);
        Page<AgentDTO> agents = agentService.searchAgents(search, pageable);
        return ResponseEntity.ok(agents);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Mettre à jour un agent")
    public ResponseEntity<AgentDTO> updateAgent(
            @Parameter(description = "ID de l'agent") @PathVariable Long id,
            @Valid @RequestBody CreateAgentRequest request) {
        log.info("PUT /api/agents/{} - Updating agent", id);
        AgentDTO agent = agentService.updateAgent(id, request);
        return ResponseEntity.ok(agent);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Supprimer un agent")
    public ResponseEntity<Void> deleteAgent(
            @Parameter(description = "ID de l'agent") @PathVariable Long id) {
        log.info("DELETE /api/agents/{} - Deleting agent", id);
        agentService.deleteAgent(id);
        return ResponseEntity.noContent().build();
    }

    // ===== ENDPOINTS DE DEMONSTRATION =====

    @GetMapping("/health")
    @Operation(summary = "Health check du microservice MS-Agent")
    public ResponseEntity<Map<String, Object>> healthCheck() {
        log.info("GET /api/agents/health - Health check");
        Map<String, Object> response = new HashMap<>();
        response.put("status", "healthy");
        response.put("service", "ms-agent");
        response.put("port", 8081);
        response.put("domain", "agent");
        response.put("timestamp", LocalDateTime.now().toString());
        response.put("description", "Microservice de gestion des dossiers agents");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/db-test")
    @Operation(summary = "Test de connexion à la base de données PostgreSQL")
    public ResponseEntity<Map<String, Object>> testDatabaseConnection() {
        log.info("GET /api/agents/db-test - Testing database connection");
        Map<String, Object> response = new HashMap<>();

        try (Connection connection = dataSource.getConnection()) {
            boolean isValid = connection.isValid(5);
            String databaseProductName = connection.getMetaData().getDatabaseProductName();
            String databaseProductVersion = connection.getMetaData().getDatabaseProductVersion();
            String url = connection.getMetaData().getURL();

            response.put("status", "success");
            response.put("connected", isValid);
            response.put("database", databaseProductName);
            response.put("version", databaseProductVersion);
            response.put("url", url);
            response.put("timestamp", LocalDateTime.now().toString());
            response.put("message", "Connexion à la base de données réussie");

            log.info("Database connection test successful: {} {}", databaseProductName, databaseProductVersion);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Database connection test failed", e);
            response.put("status", "error");
            response.put("connected", false);
            response.put("error", e.getMessage());
            response.put("timestamp", LocalDateTime.now().toString());
            response.put("message", "Échec de la connexion à la base de données");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}
