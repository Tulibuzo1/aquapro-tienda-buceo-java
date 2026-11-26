package com.talentotech.tiendabuceo.repository;
import com.talentotech.tiendabuceo.model.Producto;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ProductoRepository extends JpaRepository<Producto, Long> {
    List<Producto> findByCategoriaIgnoreCase(String categoria);
}
