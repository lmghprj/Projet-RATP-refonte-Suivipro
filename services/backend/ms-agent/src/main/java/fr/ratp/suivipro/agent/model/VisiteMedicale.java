package fr.ratp.suivipro.agent.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "visites_medicales", indexes = {
    @Index(name = "idx_visite_agent", columnList = "agent_id"),
    @Index(name = "idx_visite_date", columnList = "date_visite")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VisiteMedicale {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id", nullable = false)
    @NotNull
    private Agent agent;

    @NotNull
    @Column(name = "date_visite", nullable = false)
    private LocalDate dateVisite;

    @NotBlank
    @Column(name = "type_visite", nullable = false, length = 100)
    private String typeVisite; // EMBAUCHE, PERIODIQUE, REPRISE, ADAPTATION_POSTE, etc.

    @NotBlank
    @Column(nullable = false, length = 50)
    private String statut; // PLANIFIEE, REALISEE, REPORTEE, ANNULEE

    @Column(length = 100)
    private String medecinExaminateur;

    @Column(columnDefinition = "TEXT")
    private String resultat;

    @Column(length = 50)
    private String aptitude; // APTE, INAPTE, APTE_AVEC_RESERVE

    @Column(columnDefinition = "TEXT")
    private String restrictions;

    @Column(columnDefinition = "TEXT")
    private String recommandations;

    @Column(name = "date_prochaine_visite")
    private LocalDate dateProchaineVisite;

    @Column(name = "document_url", length = 500)
    private String documentUrl;

    @Column(columnDefinition = "TEXT")
    private String commentaires;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "created_by", length = 100)
    private String createdBy;

    @Column(name = "updated_by", length = 100)
    private String updatedBy;
}
