package com.talentotech.tiendabuceo.dto;

import lombok.Builder;
import lombok.Data;

@Data @Builder
public class ProductoConCategoria {
    private Long id;
    private String nombre;
    private String marca;
    private String talle;
    private Double precio;
    private Integer stock;
    private Long categoriaId;
    private String categoriaNombre;
}
