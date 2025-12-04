package fr.ratp.suivipro.agent.repository;

import fr.ratp.suivipro.agent.model.Agent;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AgentRepository extends JpaRepository<Agent, Long> {

    Optional<Agent> findByMatricule(String matricule);

    List<Agent> findByStatut(String statut);

    List<Agent> findByUniteOrganisationnelle(String uniteOrganisationnelle);

    List<Agent> findByGrade(String grade);

    Page<Agent> findByStatut(String statut, Pageable pageable);

    @Query("SELECT a FROM Agent a WHERE " +
           "LOWER(a.nom) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(a.prenom) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(a.matricule) LIKE LOWER(CONCAT('%', :search, '%'))")
    Page<Agent> searchAgents(@Param("search") String search, Pageable pageable);

    @Query("SELECT a FROM Agent a WHERE a.uniteOrganisationnelle = :uo AND a.statut = :statut")
    List<Agent> findByUniteAndStatut(@Param("uo") String uniteOrganisationnelle, @Param("statut") String statut);

    boolean existsByMatricule(String matricule);
}
