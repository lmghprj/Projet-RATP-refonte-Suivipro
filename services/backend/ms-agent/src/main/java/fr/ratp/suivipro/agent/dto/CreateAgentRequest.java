package fr.ratp.suivipro.agent.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateAgentRequest {
    @NotBlank(message = "Le matricule est obligatoire")
    private String matricule;

    @NotBlank(message = "Le nom est obligatoire")
    private String nom;

    @NotBlank(message = "Le prénom est obligatoire")
    private String prenom;

    @NotNull(message = "La date de naissance est obligatoire")
    private LocalDate dateNaissance;

    @Email(message = "Email invalide")
    private String email;

    private String telephone;
    private String adresse;

    @NotBlank(message = "Le statut est obligatoire")
    private String statut;

    @NotBlank(message = "Le grade est obligatoire")
    private String grade;

    @NotBlank(message = "La fonction est obligatoire")
    private String fonction;

    private LocalDate dateEntree;
    private String uniteOrganisationnelle;
    private String secteur;
    private String sexe;
    private String numeroSecu;
    private String situationFamiliale;
    private Integer nombreEnfants;
    private String commentaires;
    private String photoUrl;
}
