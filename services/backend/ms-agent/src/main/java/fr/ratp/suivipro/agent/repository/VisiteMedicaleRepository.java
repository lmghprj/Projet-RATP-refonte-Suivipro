package fr.ratp.suivipro.agent.repository;

import fr.ratp.suivipro.agent.model.VisiteMedicale;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface VisiteMedicaleRepository extends JpaRepository<VisiteMedicale, Long> {

    List<VisiteMedicale> findByAgentId(Long agentId);

    List<VisiteMedicale> findByTypeVisite(String typeVisite);

    List<VisiteMedicale> findByStatut(String statut);

    @Query("SELECT v FROM VisiteMedicale v WHERE v.agent.id = :agentId ORDER BY v.dateVisite DESC")
    List<VisiteMedicale> findByAgentIdOrderByDateDesc(@Param("agentId") Long agentId);

    @Query("SELECT v FROM VisiteMedicale v WHERE v.dateProchaineVisite BETWEEN :startDate AND :endDate")
    List<VisiteMedicale> findUpcomingVisites(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);

    @Query("SELECT v FROM VisiteMedicale v WHERE v.statut = 'PLANIFIEE' AND v.dateVisite < :date")
    List<VisiteMedicale> findOverdueVisites(@Param("date") LocalDate date);
}
