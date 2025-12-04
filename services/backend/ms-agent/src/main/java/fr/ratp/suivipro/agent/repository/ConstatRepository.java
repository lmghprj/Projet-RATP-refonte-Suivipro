package fr.ratp.suivipro.agent.repository;

import fr.ratp.suivipro.agent.model.Constat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface ConstatRepository extends JpaRepository<Constat, Long> {

    List<Constat> findByAgentId(Long agentId);

    List<Constat> findByTypeConstat(String typeConstat);

    List<Constat> findBySeverite(String severite);

    List<Constat> findByStatut(String statut);

    @Query("SELECT c FROM Constat c WHERE c.agent.id = :agentId AND c.statut IN ('OUVERT', 'EN_COURS')")
    List<Constat> findOpenConstatsByAgent(@Param("agentId") Long agentId);

    @Query("SELECT c FROM Constat c WHERE c.dateConstat BETWEEN :startDate AND :endDate")
    List<Constat> findConstatsByDateRange(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);

    @Query("SELECT c FROM Constat c WHERE c.typeConstat = :type AND c.statut = :statut")
    List<Constat> findByTypeAndStatut(@Param("type") String typeConstat, @Param("statut") String statut);
}
