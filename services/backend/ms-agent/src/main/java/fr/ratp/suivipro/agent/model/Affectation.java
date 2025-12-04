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
@Table(name = "affectations", indexes = {
    @Index(name = "idx_affectation_agent", columnList = "agent_id"),
    @Index(name = "idx_affectation_dates", columnList = "date_debut, date_fin")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Affectation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id", nullable = false)
    @NotNull
    private Agent agent;

    @NotBlank
    @Column(name = "unite_organisationnelle", nullable = false, length = 100)
    private String uniteOrganisationnelle;

    @NotBlank
    @Column(nullable = false, length = 100)
    private String poste;

    @Column(length = 100)
    private String secteur;

    @Column(length = 100)
    private String site;

    @NotNull
    @Column(name = "date_debut", nullable = false)
    private LocalDate dateDebut;

    @Column(name = "date_fin")
    private LocalDate dateFin;

    @Column(length = 50)
    private String typeAffectation; // PERMANENTE, TEMPORAIRE, DETACHEMENT

    @Column(length = 50)
    private String statut; // ACTIVE, TERMINEE, SUSPENDUE

    @Column(columnDefinition = "TEXT")
    private String motif;

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
