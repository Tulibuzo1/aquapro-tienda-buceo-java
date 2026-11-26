package com.talentotech.tiendabuceo.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data @Builder
public class PedidoResponse {
    private Long id;
    private LocalDateTime fecha;
    private String estado;
    private Double total;
    private String clienteNombre;
    private String clienteCertificacion;
    private List<LineaPedidoResponse> items;
}
