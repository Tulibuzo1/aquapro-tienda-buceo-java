package com.talentotech.tiendabuceo.service;

import com.talentotech.tiendabuceo.dto.*;
import com.talentotech.tiendabuceo.exception.PedidoNoEncontradoException;
import com.talentotech.tiendabuceo.exception.StockInsuficienteException;
import com.talentotech.tiendabuceo.model.*;
import com.talentotech.tiendabuceo.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PedidoService {

    private final PedidoRepository pedidoRepo;
    private final ClienteRepository clienteRepo;
    private final ProductoRepository productoRepo;
    private final ProductoService productoService;

    public List<PedidoResponse> listarTodos() {
        return pedidoRepo.findAll().stream().map(this::toResponse).toList();
    }

    public PedidoResponse buscarPorId(Long id) {
        Pedido p = pedidoRepo.findById(id)
                .orElseThrow(() -> new PedidoNoEncontradoException("Pedido no encontrado con ID: " + id));
        return toResponse(p);
    }

    @Transactional
    public PedidoResponse crearPedido(PedidoRequest req) {
        Cliente cliente = clienteRepo.findById(req.getClienteId())
                .orElseThrow(() -> new IllegalArgumentException("Cliente no encontrado con ID: " + req.getClienteId()));

        Pedido pedido = Pedido.builder()
                .cliente(cliente)
                .fecha(LocalDateTime.now())
                .estado("PAGADO")
                .total(0.0)
                .build();

        double total = 0.0;

        for (ItemPedidoRequest item : req.getItems()) {
            Producto prod = productoService.obtenerEntidad(item.getProductoId());

            if (prod.getStock() < item.getCantidad()) {
                throw new StockInsuficienteException("Stock insuficiente para '" + prod.getNombre() + "'. Disponible: " + prod.getStock());
            }

            prod.setStock(prod.getStock() - item.getCantidad());
            productoRepo.save(prod);

            LineaPedido linea = LineaPedido.builder()
                    .pedido(pedido)
                    .producto(prod)
                    .cantidad(item.getCantidad())
                    .precioUnitario(prod.getPrecio())
                    .build();

            pedido.getLineas().add(linea);
            total += prod.getPrecio() * item.getCantidad();
        }

        pedido.setTotal(total);
        return toResponse(pedidoRepo.save(pedido));
    }

    @Transactional
    public PedidoResponse cancelarPedido(Long id) {
        Pedido pedido = pedidoRepo.findById(id)
                .orElseThrow(() -> new PedidoNoEncontradoException("Pedido no encontrado con ID: " + id));

        if ("CANCELADO".equals(pedido.getEstado())) {
            throw new IllegalArgumentException("La orden ya se encuentra anulada.");
        }

        for (LineaPedido linea : pedido.getLineas()) {
            Producto prod = linea.getProducto();
            prod.setStock(prod.getStock() + linea.getCantidad());
            productoRepo.save(prod);
        }

        pedido.setEstado("CANCELADO");
        return toResponse(pedidoRepo.save(pedido));
    }

    private PedidoResponse toResponse(Pedido p) {
        List<LineaPedidoResponse> items = p.getLineas().stream().map(l ->
            LineaPedidoResponse.builder()
                .productoId(l.getProducto().getId())
                .productoNombre(l.getProducto().getNombre())
                .cantidad(l.getCantidad())
                .precioUnitario(l.getPrecioUnitario())
                .subtotal(l.getCantidad() * l.getPrecioUnitario())
                .build()
        ).toList();

        return PedidoResponse.builder()
                .id(p.getId())
                .fecha(p.getFecha())
                .estado(p.getEstado())
                .total(p.getTotal())
                .clienteNombre(p.getCliente().getNombre())
                .clienteCertificacion(p.getCliente().getNivelCertificacion())
                .items(items)
                .build();
    }
}
