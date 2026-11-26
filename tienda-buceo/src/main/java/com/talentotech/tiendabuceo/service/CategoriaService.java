package com.talentotech.tiendabuceo.service;

import com.talentotech.tiendabuceo.exception.CategoriaNoEncontradoException;
import com.talentotech.tiendabuceo.model.Categoria;
import com.talentotech.tiendabuceo.repository.CategoriaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CategoriaService {

    private final CategoriaRepository categoriaRepo;

    public List<Categoria> listarTodas() {
        return categoriaRepo.findAll();
    }

    public Categoria buscarPorId(Long id) {
        return categoriaRepo.findById(id)
                .orElseThrow(() -> new CategoriaNoEncontradoException("Categoría no encontrada con ID: " + id));
    }

    public Categoria crear(Categoria categoria) {
        if (categoriaRepo.existsByNombreIgnoreCase(categoria.getNombre())) {
            throw new IllegalArgumentException("Ya existe una categoría con el nombre: " + categoria.getNombre());
        }
        return categoriaRepo.save(categoria);
    }

    public void eliminar(Long id) {
        Categoria cat = buscarPorId(id);
        categoriaRepo.delete(cat);
    }
}
