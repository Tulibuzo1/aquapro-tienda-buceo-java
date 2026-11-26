package com.talentotech.tiendabuceo.controller;

import com.talentotech.tiendabuceo.dto.PedidoRequestDTO;
import com.talentotech.tiendabuceo.model.*;
import com.talentotech.tiendabuceo.service.TiendaService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class TiendaController {

    private final TiendaService service;

    // --- PRODUCTOS (CRUD COMPLETO) ---
    @GetMapping("/productos")
    public ResponseEntity<List<Producto>> getProductos(@RequestParam(required = false) String categoria) {
        return ResponseEntity.ok(service.listarProductos(categoria));
    }

    @GetMapping("/productos/{id}")
    public ResponseEntity<Producto> getProductoPorId(@PathVariable Long id) {
        return ResponseEntity.ok(service.buscarProductoPorId(id));
    }

    @PostMapping("/productos")
    public ResponseEntity<Producto> crearProducto(@Valid @RequestBody Producto producto) {
        Producto creado = service.guardarProducto(producto);
        return ResponseEntity.status(HttpStatus.CREATED).body(creado);
    }

    @PutMapping("/productos/{id}")
    public ResponseEntity<Producto> actualizarProducto(@PathVariable Long id, @Valid @RequestBody Producto producto) {
        return ResponseEntity.ok(service.actualizarProducto(id, producto));
    }

    @PatchMapping("/productos/{id}/stock")
    public ResponseEntity<Producto> actualizarStock(@PathVariable Long id, @RequestParam Integer stock) {
        return ResponseEntity.ok(service.actualizarStock(id, stock));
    }

    @DeleteMapping("/productos/{id}")
    public ResponseEntity<Void> eliminarProducto(@PathVariable Long id) {
        service.eliminarProducto(id);
        return ResponseEntity.noContent().build();
    }

    // --- CLIENTES ---
    @GetMapping("/clientes")
    public ResponseEntity<List<Cliente>> getClientes() {
        return ResponseEntity.ok(service.listarClientes());
    }

    @PostMapping("/clientes")
    public ResponseEntity<Cliente> crearCliente(@Valid @RequestBody Cliente cliente) {
        Cliente creado = service.guardarCliente(cliente);
        return ResponseEntity.status(HttpStatus.CREATED).body(creado);
    }

    // --- PEDIDOS ---
    @GetMapping("/pedidos")
    public ResponseEntity<List<Pedido>> getPedidos() {
        return ResponseEntity.ok(service.listarPedidos());
    }

    @PostMapping("/pedidos")
    public ResponseEntity<Pedido> crearPedido(@RequestBody PedidoRequestDTO request) {
        Pedido creado = service.crearPedido(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(creado);
    }

    @PatchMapping("/pedidos/{id}/cancelar")
    public ResponseEntity<Pedido> cancelarPedido(@PathVariable Long id) {
        return ResponseEntity.ok(service.cancelarPedido(id));
    }
}
