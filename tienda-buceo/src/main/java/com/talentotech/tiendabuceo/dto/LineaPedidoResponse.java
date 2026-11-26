package com.talentotech.tiendabuceo.dto;

import lombok.Builder;
import lombok.Data;

@Data @Builder
public class LineaPedidoResponse {
    private Long productoId;
    private String productoNombre;
    private Integer cantidad;
    private Double precioUnitario;
    private Double subtotal;
}
