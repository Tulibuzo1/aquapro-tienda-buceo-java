package com.talentotech.tiendabuceo.service;

import com.talentotech.tiendabuceo.dto.ProductoConCategoria;
import com.talentotech.tiendabuceo.dto.ProductoRequest;
import com.talentotech.tiendabuceo.exception.ProductoDuplicadoException;
import com.talentotech.tiendabuceo.exception.ProductoNoEncontradoException;
import com.talentotech.tiendabuceo.model.Categoria;
import com.talentotech.tiendabuceo.model.Producto;
import com.talentotech.tiendabuceo.repository.ProductoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProductoService {

    private final ProductoRepository productoRepo;
    private final CategoriaService categoriaService;

    public List<ProductoConCategoria> listar(Long categoriaId) {
        List<Producto> lista = (categoriaId != null)
                ? productoRepo.findByCategoriaId(categoriaId)
                : productoRepo.findAll();
        return lista.stream().map(this::toDTO).toList();
    }

    public ProductoConCategoria buscarPorId(Long id) {
        return toDTO(obtenerEntidad(id));
    }

    public Producto obtenerEntidad(Long id) {
        return productoRepo.findById(id)
                .orElseThrow(() -> new ProductoNoEncontradoException("Producto no encontrado con ID: " + id));
    }

    public ProductoConCategoria crear(ProductoRequest req) {
        if (productoRepo.existsByNombreIgnoreCaseAndMarcaIgnoreCase(req.getNombre(), req.getMarca())) {
            throw new ProductoDuplicadoException("El equipo '" + req.getNombre() + "' de " + req.getMarca() + " ya existe.");
        }
        Categoria cat = categoriaService.buscarPorId(req.getCategoriaId());
        Producto p = Producto.builder()
                .nombre(req.getNombre())
                .marca(req.getMarca())
                .talle(req.getTalle())
                .precio(req.getPrecio())
                .stock(req.getStock())
                .categoria(cat)
                .build();
        return toDTO(productoRepo.save(p));
    }

    public ProductoConCategoria actualizar(Long id, ProductoRequest req) {
        Producto p = obtenerEntidad(id);
        Categoria cat = categoriaService.buscarPorId(req.getCategoriaId());
        p.setNombre(req.getNombre());
        p.setMarca(req.getMarca());
        p.setTalle(req.getTalle());
        p.setPrecio(req.getPrecio());
        p.setStock(req.getStock());
        p.setCategoria(cat);
        return toDTO(productoRepo.save(p));
    }

    public void eliminar(Long id) {
        Producto p = obtenerEntidad(id);
        productoRepo.delete(p);
    }

    private ProductoConCategoria toDTO(Producto p) {
        return ProductoConCategoria.builder()
                .id(p.getId())
                .nombre(p.getNombre())
                .marca(p.getMarca())
                .talle(p.getTalle())
                .precio(p.getPrecio())
                .stock(p.getStock())
                .categoriaId(p.getCategoria().getId())
                .categoriaNombre(p.getCategoria().getNombre())
                .build();
    }
}
