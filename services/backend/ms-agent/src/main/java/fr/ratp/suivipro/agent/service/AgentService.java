package fr.ratp.suivipro.agent.service;

import fr.ratp.suivipro.agent.dto.AgentDTO;
import fr.ratp.suivipro.agent.dto.CreateAgentRequest;
import fr.ratp.suivipro.agent.event.AgentEventPublisher;
import fr.ratp.suivipro.agent.model.Agent;
import fr.ratp.suivipro.agent.repository.AgentRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AgentService {

    private final AgentRepository agentRepository;
    private final AgentEventPublisher eventPublisher;

    public AgentDTO createAgent(CreateAgentRequest request) {
        log.info("Creating agent with matricule: {}", request.getMatricule());

        if (agentRepository.existsByMatricule(request.getMatricule())) {
            throw new IllegalArgumentException("Agent avec matricule " + request.getMatricule() + " existe déjà");
        }

        Agent agent = Agent.builder()
                .matricule(request.getMatricule())
                .nom(request.getNom())
                .prenom(request.getPrenom())
                .dateNaissance(request.getDateNaissance())
                .email(request.getEmail())
                .telephone(request.getTelephone())
                .adresse(request.getAdresse())
                .statut(request.getStatut())
                .grade(request.getGrade())
                .fonction(request.getFonction())
                .dateEntree(request.getDateEntree())
                .uniteOrganisationnelle(request.getUniteOrganisationnelle())
                .secteur(request.getSecteur())
                .sexe(request.getSexe())
                .numeroSecu(request.getNumeroSecu())
                .situationFamiliale(request.getSituationFamiliale())
                .nombreEnfants(request.getNombreEnfants())
                .commentaires(request.getCommentaires())
                .photoUrl(request.getPhotoUrl())
                .build();

        agent = agentRepository.save(agent);
        eventPublisher.publishAgentCreated(agent);

        log.info("Agent created successfully with id: {}", agent.getId());
        return toDTO(agent);
    }

    @Transactional(readOnly = true)
    public AgentDTO getAgentById(Long id) {
        log.info("Fetching agent with id: {}", id);
        Agent agent = agentRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Agent non trouvé avec l'id: " + id));
        return toDTO(agent);
    }

    @Transactional(readOnly = true)
    public AgentDTO getAgentByMatricule(String matricule) {
        log.info("Fetching agent with matricule: {}", matricule);
        Agent agent = agentRepository.findByMatricule(matricule)
                .orElseThrow(() -> new IllegalArgumentException("Agent non trouvé avec le matricule: " + matricule));
        return toDTO(agent);
    }

    @Transactional(readOnly = true)
    public List<AgentDTO> getAllAgents() {
        log.info("Fetching all agents");
        return agentRepository.findAll().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Page<AgentDTO> getAgentsByStatut(String statut, Pageable pageable) {
        log.info("Fetching agents with statut: {}", statut);
        return agentRepository.findByStatut(statut, pageable)
                .map(this::toDTO);
    }

    @Transactional(readOnly = true)
    public Page<AgentDTO> searchAgents(String search, Pageable pageable) {
        log.info("Searching agents with term: {}", search);
        return agentRepository.searchAgents(search, pageable)
                .map(this::toDTO);
    }

    public AgentDTO updateAgent(Long id, CreateAgentRequest request) {
        log.info("Updating agent with id: {}", id);
        Agent agent = agentRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Agent non trouvé avec l'id: " + id));

        agent.setNom(request.getNom());
        agent.setPrenom(request.getPrenom());
        agent.setDateNaissance(request.getDateNaissance());
        agent.setEmail(request.getEmail());
        agent.setTelephone(request.getTelephone());
        agent.setAdresse(request.getAdresse());
        agent.setStatut(request.getStatut());
        agent.setGrade(request.getGrade());
        agent.setFonction(request.getFonction());
        agent.setDateEntree(request.getDateEntree());
        agent.setUniteOrganisationnelle(request.getUniteOrganisationnelle());
        agent.setSecteur(request.getSecteur());
        agent.setSexe(request.getSexe());
        agent.setNumeroSecu(request.getNumeroSecu());
        agent.setSituationFamiliale(request.getSituationFamiliale());
        agent.setNombreEnfants(request.getNombreEnfants());
        agent.setCommentaires(request.getCommentaires());
        agent.setPhotoUrl(request.getPhotoUrl());

        agent = agentRepository.save(agent);
        eventPublisher.publishAgentUpdated(agent);

        log.info("Agent updated successfully with id: {}", agent.getId());
        return toDTO(agent);
    }

    public void deleteAgent(Long id) {
        log.info("Deleting agent with id: {}", id);
        Agent agent = agentRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Agent non trouvé avec l'id: " + id));

        agentRepository.delete(agent);
        eventPublisher.publishAgentDeleted(agent);

        log.info("Agent deleted successfully with id: {}", id);
    }

    private AgentDTO toDTO(Agent agent) {
        return AgentDTO.builder()
                .id(agent.getId())
                .matricule(agent.getMatricule())
                .nom(agent.getNom())
                .prenom(agent.getPrenom())
                .dateNaissance(agent.getDateNaissance())
                .email(agent.getEmail())
                .telephone(agent.getTelephone())
                .adresse(agent.getAdresse())
                .statut(agent.getStatut())
                .grade(agent.getGrade())
                .fonction(agent.getFonction())
                .dateEntree(agent.getDateEntree())
                .dateSortie(agent.getDateSortie())
                .uniteOrganisationnelle(agent.getUniteOrganisationnelle())
                .secteur(agent.getSecteur())
                .sexe(agent.getSexe())
                .numeroSecu(agent.getNumeroSecu())
                .situationFamiliale(agent.getSituationFamiliale())
                .nombreEnfants(agent.getNombreEnfants())
                .commentaires(agent.getCommentaires())
                .photoUrl(agent.getPhotoUrl())
                .createdAt(agent.getCreatedAt())
                .updatedAt(agent.getUpdatedAt())
                .build();
    }
}
