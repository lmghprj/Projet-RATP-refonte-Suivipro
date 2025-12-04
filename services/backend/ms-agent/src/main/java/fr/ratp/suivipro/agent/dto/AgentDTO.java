package fr.ratp.suivipro.agent.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AgentDTO {
    private Long id;
    private String matricule;
    private String nom;
    private String prenom;
    private LocalDate dateNaissance;
    private String email;
    private String telephone;
    private String adresse;
    private String statut;
    private String grade;
    private String fonction;
    private LocalDate dateEntree;
    private LocalDate dateSortie;
    private String uniteOrganisationnelle;
    private String secteur;
    private String sexe;
    private String numeroSecu;
    private String situationFamiliale;
    private Integer nombreEnfants;
    private String commentaires;
    private String photoUrl;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
