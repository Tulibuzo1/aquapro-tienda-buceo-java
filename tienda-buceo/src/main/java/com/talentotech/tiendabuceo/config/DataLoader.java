package com.talentotech.tiendabuceo.config;

import com.talentotech.tiendabuceo.model.*;
import com.talentotech.tiendabuceo.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class DataLoader implements CommandLineRunner {

    private final CategoriaRepository categoriaRepo;
    private final ProductoRepository productoRepo;
    private final ClienteRepository clienteRepo;

    @Override
    public void run(String... args) {
        if (categoriaRepo.count() == 0) {
            Categoria mascaras = categoriaRepo.save(Categoria.builder().nombre("Máscaras").descripcion("Visores y óptica subacuática").build());
            Categoria aletas = categoriaRepo.save(Categoria.builder().nombre("Aletas").descripcion("Propulsión y calzado de buceo").build());
            Categoria trajes = categoriaRepo.save(Categoria.builder().nombre("Trajes").descripcion("Protección térmica en neopreno").build());
            Categoria reguladores = categoriaRepo.save(Categoria.builder().nombre("Reguladores").descripcion("Sistemas de respiración de primera y segunda etapa").build());
            Categoria accesorios = categoriaRepo.save(Categoria.builder().nombre("Accesorios").descripcion("Computadoras de inmersión e instrumentos").build());

            productoRepo.saveAll(List.of(
                Producto.builder().nombre("Máscara Big Eyes Evolution").marca("Cressi").talle("Único").precio(85000.0).stock(12).categoria(mascaras).build(),
                Producto.builder().nombre("Aletas Avanti Quattro Plus").marca("Mares").talle("M/L").precio(195000.0).stock(6).categoria(aletas).build(),
                Producto.builder().nombre("Traje Neopreno 5mm Castoro").marca("Cressi").talle("L").precio(340000.0).stock(4).categoria(trajes).build(),
                Producto.builder().nombre("Regulador MK25 EVO / S600").marca("Scubapro").talle("DIN").precio(890000.0).stock(3).categoria(reguladores).build(),
                Producto.builder().nombre("Computadora de Buceo Puck Pro+").marca("Mares").talle("Único").precio(410000.0).stock(5).categoria(accesorios).build()
            ));
        }

        if (clienteRepo.count() == 0) {
            clienteRepo.saveAll(List.of(
                Cliente.builder().nombre("Martín Gómez").email("martin.buzo@email.com").nivelCertificacion("ADVANCED").build(),
                Cliente.builder().nombre("Lucía Fernández").email("lucia.mar@email.com").nivelCertificacion("OPEN_WATER").build()
            ));
        }
    }
}
