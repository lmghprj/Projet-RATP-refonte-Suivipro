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
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/agents")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Agents", description = "API de gestion des dossiers agents")
public class AgentController {

    private final AgentService agentService;

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
}
