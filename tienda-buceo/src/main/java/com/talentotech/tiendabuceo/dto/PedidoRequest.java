package com.talentotech.tiendabuceo.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.util.List;

@Data
public class PedidoRequest {
    @NotNull(message = "El clienteId es obligatorio")
    private Long clienteId;

    @NotEmpty(message = "El pedido debe contener al menos un producto")
    @Valid
    private List<ItemPedidoRequest> items;
}
