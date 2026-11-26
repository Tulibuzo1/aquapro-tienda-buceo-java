package com.talentotech.tiendabuceo.service;

import com.talentotech.tiendabuceo.dto.PedidoRequestDTO;
import com.talentotech.tiendabuceo.exception.RecursoNoEncontradoException;
import com.talentotech.tiendabuceo.model.*;
import com.talentotech.tiendabuceo.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TiendaService {

    private final ProductoRepository productoRepo;
    private final ClienteRepository clienteRepo;
    private final PedidoRepository pedidoRepo;

    // --- PRODUCTOS ---
    public List<Producto> listarProductos(String categoria) {
        if (categoria != null && !categoria.isBlank()) {
            return productoRepo.findByCategoriaIgnoreCase(categoria);
        }
        return productoRepo.findAll();
    }

    public Producto buscarProductoPorId(Long id) {
        return productoRepo.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Producto no encontrado con ID: " + id));
    }

    public Producto guardarProducto(Producto p) {
        return productoRepo.save(p);
    }

    public Producto actualizarProducto(Long id, Producto datos) {
        Producto p = buscarProductoPorId(id);
        p.setNombre(datos.getNombre());
        p.setMarca(datos.getMarca());
        p.setCategoria(datos.getCategoria());
        p.setTalle(datos.getTalle());
        p.setPrecio(datos.getPrecio());
        p.setStock(datos.getStock());
        return productoRepo.save(p);
    }

    public Producto actualizarStock(Long id, Integer nuevoStock) {
        if (nuevoStock == null || nuevoStock < 0) {
            throw new IllegalArgumentException("El stock no puede ser negativo");
        }
        Producto p = buscarProductoPorId(id);
        p.setStock(nuevoStock);
        return productoRepo.save(p);
    }

    public void eliminarProducto(Long id) {
        Producto p = buscarProductoPorId(id);
        productoRepo.delete(p);
    }

    // --- CLIENTES ---
    public List<Cliente> listarClientes() {
        return clienteRepo.findAll();
    }

    public Cliente guardarCliente(Cliente c) {
        return clienteRepo.save(c);
    }

    // --- PEDIDOS ---
    @Transactional
    public Pedido crearPedido(PedidoRequestDTO request) {
        if (request.getItems() == null || request.getItems().isEmpty()) {
            throw new IllegalArgumentException("El carrito está vacío");
        }

        Cliente cliente = clienteRepo.findById(request.getClienteId())
                .orElseThrow(() -> new RecursoNoEncontradoException("Cliente no encontrado con ID: " + request.getClienteId()));

        Pedido pedido = Pedido.builder()
                .cliente(cliente)
                .fecha(LocalDateTime.now())
                .estado("PAGADO")
                .total(0.0)
                .build();

        double totalAcumulado = 0.0;

        for (PedidoRequestDTO.ItemDTO item : request.getItems()) {
            Producto prod = buscarProductoPorId(item.getProductoId());

            if (item.getCantidad() == null || item.getCantidad() <= 0) {
                throw new IllegalArgumentException("La cantidad debe ser mayor a 0");
            }

            if (prod.getStock() < item.getCantidad()) {
                throw new IllegalArgumentException("Stock insuficiente para: " + prod.getNombre() + " (Disponible: " + prod.getStock() + ")");
            }

            prod.setStock(prod.getStock() - item.getCantidad());
            productoRepo.save(prod);

            DetallePedido detalle = DetallePedido.builder()
                    .pedido(pedido)
                    .producto(prod)
                    .cantidad(item.getCantidad())
                    .precioUnitario(prod.getPrecio())
                    .build();

            pedido.getDetalles().add(detalle);
            totalAcumulado += prod.getPrecio() * item.getCantidad();
        }

        pedido.setTotal(totalAcumulado);
        return pedidoRepo.save(pedido);
    }

    public List<Pedido> listarPedidos() {
        return pedidoRepo.findAll();
    }

    @Transactional
    public Pedido cancelarPedido(Long id) {
        Pedido pedido = pedidoRepo.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Pedido no encontrado con ID: " + id));

        if ("CANCELADO".equals(pedido.getEstado())) {
            throw new IllegalArgumentException("El pedido ya fue cancelado previamente");
        }

        for (DetallePedido det : pedido.getDetalles()) {
            Producto prod = det.getProducto();
            prod.setStock(prod.getStock() + det.getCantidad());
            productoRepo.save(prod);
        }

        pedido.setEstado("CANCELADO");
        return pedidoRepo.save(pedido);
    }
}
