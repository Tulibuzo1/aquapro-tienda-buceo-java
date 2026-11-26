package com.talentotech.tiendabuceo.dto;

import lombok.Data;
import java.util.List;

@Data
public class PedidoRequestDTO {
    private Long clienteId;
    private List<ItemDTO> items;

    @Data
    public static class ItemDTO {
        private Long productoId;
        private Integer cantidad;
    }
}
