package com.talentotech.tiendabuceo.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;

@Entity
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Producto {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "El nombre es obligatorio")
    private String nombre;

    @NotBlank(message = "La marca es obligatoria")
    private String marca;

    @NotBlank(message = "La categoría es obligatoria")
    private String categoria;

    private String talle;

    @Positive(message = "El precio debe ser mayor a 0")
    private Double precio;

    @Min(value = 0, message = "El stock no puede ser negativo")
    private Integer stock;
}
