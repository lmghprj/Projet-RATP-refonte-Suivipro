package fr.ratp.suivipro.agent.event;

import fr.ratp.suivipro.agent.model.Agent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

@Component
@RequiredArgsConstructor
@Slf4j
public class AgentEventPublisher {

    private final KafkaTemplate<String, Object> kafkaTemplate;
    private static final String TOPIC = "agent-events";

    public void publishAgentCreated(Agent agent) {
        Map<String, Object> event = createEventPayload("AGENT_CREATED", agent);
        kafkaTemplate.send(TOPIC, agent.getMatricule(), event);
        log.info("Published AGENT_CREATED event for agent: {}", agent.getMatricule());
    }

    public void publishAgentUpdated(Agent agent) {
        Map<String, Object> event = createEventPayload("AGENT_UPDATED", agent);
        kafkaTemplate.send(TOPIC, agent.getMatricule(), event);
        log.info("Published AGENT_UPDATED event for agent: {}", agent.getMatricule());
    }

    public void publishAgentDeleted(Agent agent) {
        Map<String, Object> event = createEventPayload("AGENT_DELETED", agent);
        kafkaTemplate.send(TOPIC, agent.getMatricule(), event);
        log.info("Published AGENT_DELETED event for agent: {}", agent.getMatricule());
    }

    private Map<String, Object> createEventPayload(String eventType, Agent agent) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("eventType", eventType);
        payload.put("timestamp", System.currentTimeMillis());
        payload.put("agentId", agent.getId());
        payload.put("matricule", agent.getMatricule());
        payload.put("nom", agent.getNom());
        payload.put("prenom", agent.getPrenom());
        payload.put("statut", agent.getStatut());
        payload.put("uniteOrganisationnelle", agent.getUniteOrganisationnelle());
        return payload;
    }
}
