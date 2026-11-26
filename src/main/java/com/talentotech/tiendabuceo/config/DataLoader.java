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

    private final ProductoRepository productoRepo;
    private final ClienteRepository clienteRepo;

    @Override
    public void run(String... args) {
        if (productoRepo.count() == 0) {
            productoRepo.saveAll(List.of(
                Producto.builder().nombre("Máscara Big Eyes Evolution").marca("Cressi").categoria("Máscaras").talle("Único").precio(85000.0).stock(12).build(),
                Producto.builder().nombre("Aletas Avanti Quattro Plus").marca("Mares").categoria("Aletas").talle("M/L").precio(195000.0).stock(6).build(),
                Producto.builder().nombre("Traje Neopreno 5mm Castoro").marca("Cressi").categoria("Trajes").talle("L").precio(340000.0).stock(4).build(),
                Producto.builder().nombre("Regulador MK25 EVO / S600").marca("Scubapro").categoria("Reguladores").talle("DIN").precio(890000.0).stock(3).build(),
                Producto.builder().nombre("Computadora de Buceo Puck Pro+").marca("Mares").categoria("Accesorios").talle("Único").precio(410000.0).stock(5).build()
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
