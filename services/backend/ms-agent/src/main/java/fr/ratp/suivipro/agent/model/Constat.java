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
@Table(name = "constats", indexes = {
    @Index(name = "idx_constat_agent", columnList = "agent_id"),
    @Index(name = "idx_constat_date", columnList = "date_constat"),
    @Index(name = "idx_constat_type", columnList = "type_constat")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Constat {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id", nullable = false)
    @NotNull
    private Agent agent;

    @NotNull
    @Column(name = "date_constat", nullable = false)
    private LocalDate dateConstat;

    @NotBlank
    @Column(name = "type_constat", nullable = false, length = 100)
    private String typeConstat; // SECURITE, COMPORTEMENT, PERFORMANCE, ADMINISTRATIF

    @NotBlank
    @Column(nullable = false, length = 50)
    private String severite; // FAIBLE, MOYENNE, ELEVEE, CRITIQUE

    @NotBlank
    @Column(nullable = false, length = 50)
    private String statut; // OUVERT, EN_COURS, RESOLU, CLOS

    @NotBlank
    @Column(columnDefinition = "TEXT", nullable = false)
    private String description;

    @Column(columnDefinition = "TEXT")
    private String actionCorrectrice;

    @Column(name = "date_resolution")
    private LocalDate dateResolution;

    @Column(name = "responsable_constat", length = 100)
    private String responsableConstat;

    @Column(name = "responsable_resolution", length = 100)
    private String responsableResolution;

    @Column(length = 100)
    private String lieu;

    @Column(name = "reference_externe", length = 100)
    private String referenceExterne;

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
