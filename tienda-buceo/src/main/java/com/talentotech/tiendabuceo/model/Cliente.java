package com.talentotech.tiendabuceo.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;

@Entity
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Cliente {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "El nombre es obligatorio")
    private String nombre;

    @Email(message = "El formato de email no es válido")
    @NotBlank(message = "El email es obligatorio")
    @Column(unique = true)
    private String email;

    private String nivelCertificacion;
}
