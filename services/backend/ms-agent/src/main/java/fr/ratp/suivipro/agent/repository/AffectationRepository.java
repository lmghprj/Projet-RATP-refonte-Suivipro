package fr.ratp.suivipro.agent.repository;

import fr.ratp.suivipro.agent.model.Affectation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface AffectationRepository extends JpaRepository<Affectation, Long> {

    List<Affectation> findByAgentId(Long agentId);

    List<Affectation> findByUniteOrganisationnelle(String uniteOrganisationnelle);

    List<Affectation> findByStatut(String statut);

    @Query("SELECT a FROM Affectation a WHERE a.agent.id = :agentId AND a.statut = 'ACTIVE'")
    List<Affectation> findActiveAffectationsByAgent(@Param("agentId") Long agentId);

    @Query("SELECT a FROM Affectation a WHERE a.dateDebut <= :date AND (a.dateFin IS NULL OR a.dateFin >= :date)")
    List<Affectation> findAffectationsAtDate(@Param("date") LocalDate date);
}
