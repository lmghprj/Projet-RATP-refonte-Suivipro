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
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "agents", indexes = {
    @Index(name = "idx_matricule", columnList = "matricule"),
    @Index(name = "idx_nom_prenom", columnList = "nom, prenom")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Agent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Column(unique = true, nullable = false, length = 20)
    private String matricule;

    @NotBlank
    @Column(nullable = false, length = 100)
    private String nom;

    @NotBlank
    @Column(nullable = false, length = 100)
    private String prenom;

    @NotNull
    @Column(name = "date_naissance", nullable = false)
    private LocalDate dateNaissance;

    @Column(length = 100)
    private String email;

    @Column(length = 20)
    private String telephone;

    @Column(length = 200)
    private String adresse;

    @NotBlank
    @Column(nullable = false, length = 50)
    private String statut; // ACTIF, INACTIF, SUSPENDU, DETACHE

    @NotBlank
    @Column(nullable = false, length = 50)
    private String grade;

    @NotBlank
    @Column(nullable = false, length = 50)
    private String fonction;

    @Column(name = "date_entree")
    private LocalDate dateEntree;

    @Column(name = "date_sortie")
    private LocalDate dateSortie;

    @Column(name = "unite_organisationnelle", length = 100)
    private String uniteOrganisationnelle;

    @Column(name = "secteur", length = 100)
    private String secteur;

    @Column(length = 20)
    private String sexe;

    @Column(name = "numero_secu", length = 20)
    private String numeroSecu;

    @Column(name = "situation_familiale", length = 50)
    private String situationFamiliale;

    @Column(name = "nombre_enfants")
    private Integer nombreEnfants;

    @Column(columnDefinition = "TEXT")
    private String commentaires;

    @Column(name = "photo_url", length = 500)
    private String photoUrl;

    @OneToMany(mappedBy = "agent", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @Builder.Default
    private List<Affectation> affectations = new ArrayList<>();

    @OneToMany(mappedBy = "agent", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @Builder.Default
    private List<VisiteMedicale> visitesMedicales = new ArrayList<>();

    @OneToMany(mappedBy = "agent", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @Builder.Default
    private List<Constat> constats = new ArrayList<>();

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

    @Version
    private Long version;
}
