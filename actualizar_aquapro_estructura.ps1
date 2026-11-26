$base = "tienda-buceo"
$java = "$base/src/main/java/com/talentotech/tiendabuceo"
$test = "$base/src/test/java/com/talentotech/tiendabuceo"
$res = "$base/src/main/resources"
$static = "$res/static"

Write-Host "Actualizando estructura de AquaPro..." -ForegroundColor Cyan

# Limpiar codigo Java anterior para evitar conflictos de clases
if (Test-Path "$java") { Remove-Item -Recurse -Force "$java" }

# Crear estructura de carpetas
$dirs = @(
    "$java/config",
    "$java/controller",
    "$java/dto",
    "$java/exception",
    "$java/model",
    "$java/repository",
    "$java/service",
    "$test",
    "$static"
)
foreach ($d in $dirs) { New-Item -ItemType Directory -Force -Path $d | Out-Null }

# 1. .gitignore
@'
target/
!.mvn/wrapper/maven-wrapper.jar
!**/src/main/**/target/
!**/src/test/**/target/

### IntelliJ IDEA ###
.idea/
*.iws
*.iml
*.ipr

### VS Code ###
.vscode/
.classpath
.project
.settings/
.factorypath

### Mac / Windows ###
.DS_Store
Thumbs.db
'@ | Set-Content -Encoding UTF8 "$base/.gitignore"

# 2. TiendaBuceoApplication.java
@'
package com.talentotech.tiendabuceo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class TiendaBuceoApplication {
    public static void main(String[] args) {
        SpringApplication.run(TiendaBuceoApplication.class, args);
    }
}
'@ | Set-Content -Encoding UTF8 "$java/TiendaBuceoApplication.java"

# 3. Test de contexto
@'
package com.talentotech.tiendabuceo;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class TiendaBuceoApplicationTests {
    @Test
    void contextLoads() {
    }
}
'@ | Set-Content -Encoding UTF8 "$test/TiendaBuceoApplicationTests.java"

# 4. Config: CorsConfig y DataLoader
@'
package com.talentotech.tiendabuceo.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CorsConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins("*")
                .allowedMethods("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS")
                .allowedHeaders("*");
    }
}
'@ | Set-Content -Encoding UTF8 "$java/config/CorsConfig.java"

@'
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
'@ | Set-Content -Encoding UTF8 "$java/config/DataLoader.java"

# 5. Models
@'
package com.talentotech.tiendabuceo.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Entity
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Categoria {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "El nombre de la categoría es obligatorio")
    @Column(unique = true)
    private String nombre;

    private String descripcion;
}
'@ | Set-Content -Encoding UTF8 "$java/model/Categoria.java"

@'
package com.talentotech.tiendabuceo.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;

@Entity
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Producto {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "El nombre es obligatorio")
    private String nombre;

    @NotBlank(message = "La marca es obligatoria")
    private String marca;

    private String talle;

    @NotNull(message = "El precio es obligatorio")
    @Positive(message = "El precio debe ser mayor a 0")
    private Double precio;

    @NotNull(message = "El stock es obligatorio")
    @Min(value = 0, message = "El stock no puede ser negativo")
    private Integer stock;

    @ManyToOne
    @JoinColumn(name = "categoria_id", nullable = false)
    private Categoria categoria;
}
'@ | Set-Content -Encoding UTF8 "$java/model/Producto.java"

@'
package com.talentotech.tiendabuceo.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;

@Entity
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Cliente {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "El nombre es obligatorio")
    private String nombre;

    @Email(message = "El formato de email no es válido")
    @NotBlank(message = "El email es obligatorio")
    @Column(unique = true)
    private String email;

    private String nivelCertificacion;
}
'@ | Set-Content -Encoding UTF8 "$java/model/Cliente.java"

@'
package com.talentotech.tiendabuceo.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Pedido {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private LocalDateTime fecha;
    private String estado;
    private Double total;

    @ManyToOne
    @JoinColumn(name = "cliente_id")
    private Cliente cliente;

    @OneToMany(mappedBy = "pedido", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<LineaPedido> lineas = new ArrayList<>();
}
'@ | Set-Content -Encoding UTF8 "$java/model/Pedido.java"

@'
package com.talentotech.tiendabuceo.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class LineaPedido {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer cantidad;
    private Double precioUnitario;

    @ManyToOne
    @JoinColumn(name = "producto_id")
    private Producto producto;

    @ManyToOne
    @JoinColumn(name = "pedido_id")
    @JsonIgnore
    private Pedido pedido;
}
'@ | Set-Content -Encoding UTF8 "$java/model/LineaPedido.java"

# 6. DTOs
@'
package com.talentotech.tiendabuceo.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class ProductoRequest {
    @NotBlank(message = "El nombre es obligatorio")
    private String nombre;

    @NotBlank(message = "La marca es obligatoria")
    private String marca;

    private String talle;

    @NotNull(message = "El precio es obligatorio")
    @Positive(message = "El precio debe ser mayor a 0")
    private Double precio;

    @NotNull(message = "El stock es obligatorio")
    @Min(value = 0, message = "El stock no puede ser negativo")
    private Integer stock;

    @NotNull(message = "La categoría es obligatoria")
    private Long categoriaId;
}
'@ | Set-Content -Encoding UTF8 "$java/dto/ProductoRequest.java"

@'
package com.talentotech.tiendabuceo.dto;

import lombok.Builder;
import lombok.Data;

@Data @Builder
public class ProductoConCategoria {
    private Long id;
    private String nombre;
    private String marca;
    private String talle;
    private Double precio;
    private Integer stock;
    private Long categoriaId;
    private String categoriaNombre;
}
'@ | Set-Content -Encoding UTF8 "$java/dto/ProductoConCategoria.java"

@'
package com.talentotech.tiendabuceo.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ItemPedidoRequest {
    @NotNull(message = "El ID de producto es obligatorio")
    private Long productoId;

    @NotNull(message = "La cantidad es obligatoria")
    @Min(value = 1, message = "La cantidad mínima es 1")
    private Integer cantidad;
}
'@ | Set-Content -Encoding UTF8 "$java/dto/ItemPedidoRequest.java"

@'
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
'@ | Set-Content -Encoding UTF8 "$java/dto/PedidoRequest.java"

@'
package com.talentotech.tiendabuceo.dto;

import lombok.Builder;
import lombok.Data;

@Data @Builder
public class LineaPedidoResponse {
    private Long productoId;
    private String productoNombre;
    private Integer cantidad;
    private Double precioUnitario;
    private Double subtotal;
}
'@ | Set-Content -Encoding UTF8 "$java/dto/LineaPedidoResponse.java"

@'
package com.talentotech.tiendabuceo.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data @Builder
public class PedidoResponse {
    private Long id;
    private LocalDateTime fecha;
    private String estado;
    private Double total;
    private String clienteNombre;
    private String clienteCertificacion;
    private List<LineaPedidoResponse> items;
}
'@ | Set-Content -Encoding UTF8 "$java/dto/PedidoResponse.java"

# 7. Exceptions
@'
package com.talentotech.tiendabuceo.exception;

public class ProductoNoEncontradoException extends RuntimeException {
    public ProductoNoEncontradoException(String msg) { super(msg); }
}
'@ | Set-Content -Encoding UTF8 "$java/exception/ProductoNoEncontradoException.java"

@'
package com.talentotech.tiendabuceo.exception;

public class PedidoNoEncontradoException extends RuntimeException {
    public PedidoNoEncontradoException(String msg) { super(msg); }
}
'@ | Set-Content -Encoding UTF8 "$java/exception/PedidoNoEncontradoException.java"

@'
package com.talentotech.tiendabuceo.exception;

public class CategoriaNoEncontradoException extends RuntimeException {
    public CategoriaNoEncontradoException(String msg) { super(msg); }
}
'@ | Set-Content -Encoding UTF8 "$java/exception/CategoriaNoEncontradoException.java"

@'
package com.talentotech.tiendabuceo.exception;

public class StockInsuficienteException extends RuntimeException {
    public StockInsuficienteException(String msg) { super(msg); }
}
'@ | Set-Content -Encoding UTF8 "$java/exception/StockInsuficienteException.java"

@'
package com.talentotech.tiendabuceo.exception;

public class ProductoDuplicadoException extends RuntimeException {
    public ProductoDuplicadoException(String msg) { super(msg); }
}
'@ | Set-Content -Encoding UTF8 "$java/exception/ProductoDuplicadoException.java"

@'
package com.talentotech.tiendabuceo.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler({
        ProductoNoEncontradoException.class,
        PedidoNoEncontradoException.class,
        CategoriaNoEncontradoException.class
    })
    public ResponseEntity<Map<String, Object>> handleNotFound(RuntimeException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
            "timestamp", LocalDateTime.now().toString(),
            "status", 404,
            "error", ex.getMessage()
        ));
    }

    @ExceptionHandler({
        StockInsuficienteException.class,
        ProductoDuplicadoException.class,
        IllegalArgumentException.class
    })
    public ResponseEntity<Map<String, Object>> handleBadRequest(RuntimeException ex) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
            "timestamp", LocalDateTime.now().toString(),
            "status", 400,
            "error", ex.getMessage()
        ));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidation(MethodArgumentNotValidException ex) {
        String mensaje = ex.getBindingResult().getFieldErrors().isEmpty()
                ? "Datos de entrada inválidos"
                : ex.getBindingResult().getFieldErrors().get(0).getDefaultMessage();
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
            "timestamp", LocalDateTime.now().toString(),
            "status", 400,
            "error", mensaje
        ));
    }
}
'@ | Set-Content -Encoding UTF8 "$java/exception/GlobalExceptionHandler.java"

# 8. Repositories
@'
package com.talentotech.tiendabuceo.repository;

import com.talentotech.tiendabuceo.model.Categoria;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CategoriaRepository extends JpaRepository<Categoria, Long> {
    boolean existsByNombreIgnoreCase(String nombre);
}
'@ | Set-Content -Encoding UTF8 "$java/repository/CategoriaRepository.java"

@'
package com.talentotech.tiendabuceo.repository;

import com.talentotech.tiendabuceo.model.Producto;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ProductoRepository extends JpaRepository<Producto, Long> {
    List<Producto> findByCategoriaId(Long categoriaId);
    boolean existsByNombreIgnoreCaseAndMarcaIgnoreCase(String nombre, String marca);
}
'@ | Set-Content -Encoding UTF8 "$java/repository/ProductoRepository.java"

@'
package com.talentotech.tiendabuceo.repository;

import com.talentotech.tiendabuceo.model.Cliente;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClienteRepository extends JpaRepository<Cliente, Long> {}
'@ | Set-Content -Encoding UTF8 "$java/repository/ClienteRepository.java"

@'
package com.talentotech.tiendabuceo.repository;

import com.talentotech.tiendabuceo.model.Pedido;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PedidoRepository extends JpaRepository<Pedido, Long> {}
'@ | Set-Content -Encoding UTF8 "$java/repository/PedidoRepository.java"

@'
package com.talentotech.tiendabuceo.repository;

import com.talentotech.tiendabuceo.model.LineaPedido;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LineaPedidoRepository extends JpaRepository<LineaPedido, Long> {}
'@ | Set-Content -Encoding UTF8 "$java/repository/LineaPedidoRepository.java"

# 9. Services
@'
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
'@ | Set-Content -Encoding UTF8 "$java/service/CategoriaService.java"

@'
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
'@ | Set-Content -Encoding UTF8 "$java/service/ProductoService.java"

@'
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
'@ | Set-Content -Encoding UTF8 "$java/service/PedidoService.java"

# 10. Controllers
@'
package com.talentotech.tiendabuceo.controller;

import com.talentotech.tiendabuceo.model.Categoria;
import com.talentotech.tiendabuceo.service.CategoriaService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categorias")
@RequiredArgsConstructor
public class CategoriaController {

    private final CategoriaService categoriaService;

    @GetMapping
    public ResponseEntity<List<Categoria>> listar() {
        return ResponseEntity.ok(categoriaService.listarTodas());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Categoria> obtenerPorId(@PathVariable Long id) {
        return ResponseEntity.ok(categoriaService.buscarPorId(id));
    }

    @PostMapping
    public ResponseEntity<Categoria> crear(@Valid @RequestBody Categoria categoria) {
        return ResponseEntity.status(HttpStatus.CREATED).body(categoriaService.crear(categoria));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        categoriaService.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
'@ | Set-Content -Encoding UTF8 "$java/controller/CategoriaController.java"

@'
package com.talentotech.tiendabuceo.controller;

import com.talentotech.tiendabuceo.dto.ProductoConCategoria;
import com.talentotech.tiendabuceo.dto.ProductoRequest;
import com.talentotech.tiendabuceo.service.ProductoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/productos")
@RequiredArgsConstructor
public class ProductoController {

    private final ProductoService productoService;

    @GetMapping
    public ResponseEntity<List<ProductoConCategoria>> listar(@RequestParam(required = false) Long categoriaId) {
        return ResponseEntity.ok(productoService.listar(categoriaId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductoConCategoria> obtenerPorId(@PathVariable Long id) {
        return ResponseEntity.ok(productoService.buscarPorId(id));
    }

    @PostMapping
    public ResponseEntity<ProductoConCategoria> crear(@Valid @RequestBody ProductoRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(productoService.crear(request));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ProductoConCategoria> actualizar(@PathVariable Long id, @Valid @RequestBody ProductoRequest request) {
        return ResponseEntity.ok(productoService.actualizar(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        productoService.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
'@ | Set-Content -Encoding UTF8 "$java/controller/ProductoController.java"

@'
package com.talentotech.tiendabuceo.controller;

import com.talentotech.tiendabuceo.dto.PedidoRequest;
import com.talentotech.tiendabuceo.dto.PedidoResponse;
import com.talentotech.tiendabuceo.service.PedidoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/pedidos")
@RequiredArgsConstructor
public class PedidoController {

    private final PedidoService pedidoService;

    @GetMapping
    public ResponseEntity<List<PedidoResponse>> listar() {
        return ResponseEntity.ok(pedidoService.listarTodos());
    }

    @GetMapping("/{id}")
    public ResponseEntity<PedidoResponse> obtenerPorId(@PathVariable Long id) {
        return ResponseEntity.ok(pedidoService.buscarPorId(id));
    }

    @PostMapping
    public ResponseEntity<PedidoResponse> crear(@Valid @RequestBody PedidoRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(pedidoService.crearPedido(request));
    }

    @PatchMapping("/{id}/cancelar")
    public ResponseEntity<PedidoResponse> cancelar(@PathVariable Long id) {
        return ResponseEntity.ok(pedidoService.cancelarPedido(id));
    }
}
'@ | Set-Content -Encoding UTF8 "$java/controller/PedidoController.java"

@'
package com.talentotech.tiendabuceo.controller;

import com.talentotech.tiendabuceo.model.Cliente;
import com.talentotech.tiendabuceo.repository.ClienteRepository;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/clientes")
@RequiredArgsConstructor
public class ClienteController {

    private final ClienteRepository clienteRepo;

    @GetMapping
    public ResponseEntity<List<Cliente>> listar() {
        return ResponseEntity.ok(clienteRepo.findAll());
    }

    @PostMapping
    public ResponseEntity<Cliente> crear(@Valid @RequestBody Cliente cliente) {
        return ResponseEntity.status(HttpStatus.CREATED).body(clienteRepo.save(cliente));
    }
}
'@ | Set-Content -Encoding UTF8 "$java/controller/ClienteController.java"

# 11. Front-End AquaPro (index.html y app.js)
@'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AquaPro | Equipamiento Técnico de Buceo</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Plus+Jakarta+Sans:wght@600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --ap-navy: #0B192C;
            --ap-deep: #132A46;
            --ap-cyan: #0096C7;
            --ap-bg: #F8FAFC;
            --ap-border: #E2E8F0;
            --ap-text: #1E293B;
            --ap-muted: #64748B;
        }
        body { font-family: 'Inter', sans-serif; background-color: var(--ap-bg); color: var(--ap-text); }
        h1, h2, h3, h4, h5, h6 { font-family: 'Plus Jakarta Sans', sans-serif; }
        .navbar-aquapro { background-color: #FFFFFF; border-bottom: 1px solid var(--ap-border); padding: 0.85rem 0; }
        .brand-logo { font-weight: 800; font-size: 1.35rem; letter-spacing: -0.03em; color: var(--ap-navy); text-decoration: none; display: flex; align-items: center; gap: 0.5rem; }
        .brand-dot { width: 10px; height: 10px; background-color: var(--ap-cyan); border-radius: 2px; display: inline-block; }
        .nav-link-custom { color: var(--ap-muted); font-weight: 500; font-size: 0.92rem; padding: 0.5rem 0.9rem; border-radius: 6px; border: none; background: transparent; transition: all 0.15s ease; }
        .nav-link-custom:hover, .nav-link-custom.active { color: var(--ap-navy); background-color: #F1F5F9; }
        .hero-strip { background: linear-gradient(135deg, var(--ap-navy) 0%, var(--ap-deep) 100%); color: #FFFFFF; padding: 2.5rem 0; border-bottom: 1px solid var(--ap-border); }
        .filter-chip { border: 1px solid var(--ap-border); background: #FFFFFF; color: var(--ap-text); font-size: 0.85rem; font-weight: 500; padding: 0.45rem 1rem; border-radius: 999px; transition: all 0.15s ease; }
        .filter-chip:hover { border-color: var(--ap-navy); }
        .filter-chip.active { background-color: var(--ap-navy); color: #FFFFFF; border-color: var(--ap-navy); }
        .product-card { background: #FFFFFF; border: 1px solid var(--ap-border); border-radius: 12px; overflow: hidden; transition: border-color 0.2s ease, transform 0.2s ease; height: 100%; display: flex; flex-direction: column; }
        .product-card:hover { border-color: #94A3B8; transform: translateY(-2px); }
        .product-img-wrap { position: relative; height: 195px; background-color: #F1F5F9; overflow: hidden; }
        .product-img-wrap img { width: 100%; height: 100%; object-fit: cover; }
        .badge-brand { position: absolute; top: 12px; left: 12px; background: rgba(255, 255, 255, 0.92); color: var(--ap-navy); font-size: 0.72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; padding: 0.25rem 0.6rem; border-radius: 4px; }
        .btn-ap-primary { background-color: var(--ap-navy); color: #FFFFFF; border: none; font-weight: 500; font-size: 0.88rem; padding: 0.55rem 1rem; border-radius: 8px; transition: background-color 0.15s ease; }
        .btn-ap-primary:hover:not(:disabled) { background-color: var(--ap-cyan); color: #FFFFFF; }
        .btn-ap-primary:disabled { background-color: #CBD5E1; color: #64748B; }
        .search-input { border: 1px solid var(--ap-border); border-radius: 8px; font-size: 0.9rem; padding: 0.45rem 0.9rem 0.45rem 2.2rem; background-color: #FFFFFF; }
        .panel-box { background: #FFFFFF; border: 1px solid var(--ap-border); border-radius: 12px; padding: 1.5rem; }
    </style>
</head>
<body>

<nav class="navbar navbar-aquapro sticky-top">
    <div class="container d-flex justify-content-between align-items-center">
        <div class="d-flex align-items-center gap-4">
            <a href="#" class="brand-logo" onclick="cambiarVista('catalogo')">
                <span class="brand-dot"></span> AquaPro
            </a>
            <div class="d-flex gap-1">
                <button class="nav-link-custom active" id="nav-catalogo" onclick="cambiarVista('catalogo')">Catálogo</button>
                <button class="nav-link-custom" id="nav-pedidos" onclick="cambiarVista('pedidos')">Pedidos</button>
                <button class="nav-link-custom" id="nav-admin" onclick="cambiarVista('admin')">Inventario</button>
            </div>
        </div>
        <div class="d-flex align-items-center gap-2">
            <a href="/swagger-ui/index.html" target="_blank" class="btn btn-sm btn-outline-secondary d-none d-sm-inline-flex align-items-center gap-1" style="border-radius: 8px;">
                <i class="bi bi-braces"></i> API Docs
            </a>
            <button class="btn btn-ap-primary d-flex align-items-center gap-2" data-bs-toggle="offcanvas" data-bs-target="#offcanvasCarrito">
                <i class="bi bi-bag"></i>
                <span>Bolsa</span>
                <span class="badge bg-info text-dark rounded-pill" id="contador-carrito">0</span>
            </button>
        </div>
    </div>
</nav>

<section class="hero-strip" id="hero-banner">
    <div class="container">
        <span class="text-uppercase fw-semibold" style="font-size: 0.75rem; letter-spacing: 0.1em; color: #38BDF8;">Temporada 2026 · Equipamiento Certificado</span>
        <h1 class="fw-bold mt-1 mb-2" style="font-size: 2rem; letter-spacing: -0.02em;">Precisión bajo la superficie.</h1>
        <p class="mb-0 text-white-50" style="font-size: 0.98rem; max-width: 540px;">
            Reguladores, computadoras de inmersión, trajes térmicos y óptica subacuática con stock real en tienda.
        </p>
    </div>
</section>

<main class="container my-4 pb-5">
    <section id="vista-catalogo">
        <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
            <div class="d-flex flex-wrap gap-2" id="filtros-categorias"></div>
            <div class="position-relative" style="min-width: 250px;">
                <i class="bi bi-search position-absolute text-muted" style="left: 12px; top: 50%; transform: translateY(-50%); font-size: 0.85rem;"></i>
                <input type="text" id="buscador-productos" class="form-control search-input" placeholder="Buscar equipo o marca..." oninput="filtrarLocalmente()">
            </div>
        </div>
        <div class="row g-4" id="grid-productos"></div>
    </section>

    <section id="vista-pedidos" class="d-none">
        <div class="mb-3">
            <h3 class="fw-bold mb-0">Registro de Operaciones</h3>
            <p class="text-muted small mb-0">Comprobantes emitidos y control de devoluciones de stock.</p>
        </div>
        <div class="panel-box table-responsive">
            <table class="table align-middle mb-0">
                <thead>
                    <tr class="text-muted small text-uppercase">
                        <th>Orden</th>
                        <th>Buzo</th>
                        <th>Equipamiento</th>
                        <th>Importe</th>
                        <th>Estado</th>
                        <th class="text-end">Gestión</th>
                    </tr>
                </thead>
                <tbody id="tabla-pedidos"></tbody>
            </table>
        </div>
    </section>

    <section id="vista-admin" class="d-none">
        <div class="row justify-content-center">
            <div class="col-lg-6">
                <div class="panel-box">
                    <h4 class="fw-bold mb-1">Alta de Equipamiento</h4>
                    <p class="text-muted small mb-4">Ingresá un nuevo artículo al catálogo de AquaPro.</p>
                    <form id="form-producto" onsubmit="crearProducto(event)">
                        <div class="mb-3">
                            <label class="form-label small fw-semibold">Modelo / Nombre técnico</label>
                            <input type="text" id="prod-nombre" class="form-control" required placeholder="Ej: Chaleco Hydros Pro">
                        </div>
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="form-label small fw-semibold">Fabricante</label>
                                <input type="text" id="prod-marca" class="form-control" required placeholder="Ej: Scubapro">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-semibold">Categoría</label>
                                <select id="prod-categoria" class="form-select" required></select>
                            </div>
                        </div>
                        <div class="row g-3 mb-4">
                            <div class="col-md-4">
                                <label class="form-label small fw-semibold">Talle / Conexión</label>
                                <input type="text" id="prod-talle" class="form-control" value="Único" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-semibold">Precio (ARS)</label>
                                <input type="number" id="prod-precio" class="form-control" required min="1">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-semibold">Unidades</label>
                                <input type="number" id="prod-stock" class="form-control" required min="0">
                            </div>
                        </div>
                        <button type="submit" class="btn btn-ap-primary w-100 py-2">Guardar en inventario</button>
                    </form>
                </div>
            </div>
        </div>
    </section>
</main>

<div class="offcanvas offcanvas-end" tabindex="-1" id="offcanvasCarrito" style="width: 400px;">
    <div class="offcanvas-header border-bottom">
        <h5 class="offcanvas-title fw-bold">Bolsa de Compra</h5>
        <button type="button" class="btn-close" data-bs-dismiss="offcanvas"></button>
    </div>
    <div class="offcanvas-body d-flex flex-column">
        <div class="mb-3">
            <label class="form-label small fw-semibold text-muted">Cliente / Certificación</label>
            <select id="select-cliente" class="form-select form-select-sm"></select>
        </div>
        <div id="lista-carrito" class="flex-grow-1 overflow-auto">
            <div class="text-center text-muted py-5 small">Tu bolsa está vacía.</div>
        </div>
        <div class="border-top pt-3 mt-3">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <span class="text-muted">Total a abonar</span>
                <span class="fs-4 fw-bold" style="color: var(--ap-navy);" id="total-carrito">$0</span>
            </div>
            <button class="btn btn-ap-primary w-100 py-2" onclick="confirmarPedido()">Finalizar orden</button>
        </div>
    </div>
</div>

<div class="toast-container position-fixed bottom-0 end-0 p-3">
    <div id="liveToast" class="toast align-items-center text-bg-dark border-0" role="alert">
        <div class="d-flex">
            <div class="toast-body" id="toast-mensaje">Operación realizada</div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="app.js"></script>
</body>
</html>
'@ | Set-Content -Encoding UTF8 "$static/index.html"

@'
const API = "/api";
let productosCache = [];
let carrito = [];
let categoriaIdActual = null;

const IMAGENES_CATEGORIA = {
    "Máscaras": "https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=600&q=80",
    "Aletas": "https://images.unsplash.com/photo-1582967788606-a171c1080cb0?auto=format&fit=crop&w=600&q=80",
    "Trajes": "https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=600&q=80",
    "Reguladores": "https://images.unsplash.com/photo-1682687220742-aba13b6e50ba?auto=format&fit=crop&w=600&q=80",
    "Accesorios": "https://images.unsplash.com/photo-1551244072-5d12893278ab?auto=format&fit=crop&w=600&q=80"
};

document.addEventListener("DOMContentLoaded", () => {
    cargarCategorias();
    cargarProductos();
    cargarClientes();
});

function notificar(mensaje) {
    document.getElementById("toast-mensaje").textContent = mensaje;
    new bootstrap.Toast(document.getElementById("liveToast"), { delay: 3000 }).show();
}

function cambiarVista(vista) {
    ["catalogo", "pedidos", "admin"].forEach(v => {
        document.getElementById(`vista-${v}`).classList.toggle("d-none", v !== vista);
        const navBtn = document.getElementById(`nav-${v}`);
        if (navBtn) navBtn.classList.toggle("active", v === vista);
    });
    document.getElementById("hero-banner").classList.toggle("d-none", vista !== "catalogo");
    if (vista === "pedidos") cargarPedidos();
}

async function cargarCategorias() {
    const res = await fetch(`${API}/categorias`);
    const categorias = await res.json();

    const filtrosEl = document.getElementById("filtros-categorias");
    filtrosEl.innerHTML = `<button class="filter-chip active" onclick="seleccionarCategoria(null, this)">Todos</button>` +
        categorias.map(c => `<button class="filter-chip" onclick="seleccionarCategoria(${c.id}, this)">${c.nombre}</button>`).join("");

    const selectAdmin = document.getElementById("prod-categoria");
    selectAdmin.innerHTML = categorias.map(c => `<option value="${c.id}">${c.nombre}</option>`).join("");
}

async function cargarProductos() {
    const url = categoriaIdActual ? `${API}/productos?categoriaId=${categoriaIdActual}` : `${API}/productos`;
    const res = await fetch(url);
    productosCache = await res.json();
    filtrarLocalmente();
}

function seleccionarCategoria(catId, btn) {
    categoriaIdActual = catId;
    document.querySelectorAll(".filter-chip").forEach(c => c.classList.remove("active"));
    btn.classList.add("active");
    cargarProductos();
}

function filtrarLocalmente() {
    const texto = document.getElementById("buscador-productos").value.toLowerCase();
    const filtrados = productosCache.filter(p =>
        p.nombre.toLowerCase().includes(texto) || p.marca.toLowerCase().includes(texto)
    );
    renderizarProductos(filtrados);
}

function renderizarProductos(lista) {
    const grid = document.getElementById("grid-productos");
    if (lista.length === 0) {
        grid.innerHTML = `<div class="col-12 text-center py-5 text-muted">No se encontraron equipos con ese criterio.</div>`;
        return;
    }

    grid.innerHTML = lista.map(p => {
        const imgUrl = IMAGENES_CATEGORIA[p.categoriaNombre] || IMAGENES_CATEGORIA["Accesorios"];
        const sinStock = p.stock === 0;
        return `
        <div class="col-sm-6 col-lg-4">
            <div class="product-card">
                <div class="product-img-wrap">
                    <span class="badge-brand">${p.marca}</span>
                    <img src="${imgUrl}" alt="${p.nombre}" loading="lazy">
                </div>
                <div class="p-3 d-flex flex-column flex-grow-1">
                    <div class="d-flex justify-content-between align-items-center mb-1">
                        <span class="text-muted small">${p.categoriaNombre} · Talle ${p.talle}</span>
                        <span class="small fw-medium ${sinStock ? 'text-danger' : 'text-success'}">
                            ${sinStock ? 'Agotado' : `${p.stock} disp.`}
                        </span>
                    </div>
                    <h6 class="fw-bold mb-3" style="font-size: 1rem;">${p.nombre}</h6>
                    <div class="mt-auto pt-2 border-top d-flex justify-content-between align-items-center">
                        <span class="fw-bold fs-5" style="color: var(--ap-navy);">$${p.precio.toLocaleString('es-AR')}</span>
                        <div class="d-flex gap-1">
                            <button class="btn btn-ap-primary btn-sm"
                                    onclick="agregarCarrito(${p.id}, '${p.nombre}', ${p.precio}, ${p.stock})"
                                    ${sinStock ? 'disabled' : ''}>
                                Agregar
                            </button>
                            <button class="btn btn-sm btn-outline-light text-muted border" onclick="eliminarProducto(${p.id})" title="Dar de baja">
                                <i class="bi bi-trash3"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `}).join("");
}

async function crearProducto(e) {
    e.preventDefault();
    const nuevo = {
        nombre: document.getElementById("prod-nombre").value,
        marca: document.getElementById("prod-marca").value,
        categoriaId: parseInt(document.getElementById("prod-categoria").value),
        talle: document.getElementById("prod-talle").value,
        precio: parseFloat(document.getElementById("prod-precio").value),
        stock: parseInt(document.getElementById("prod-stock").value)
    };

    const res = await fetch(`${API}/productos`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(nuevo)
    });

    if (res.ok) {
        notificar("Equipo incorporado al catálogo de AquaPro.");
        document.getElementById("form-producto").reset();
        cargarProductos();
        cambiarVista("catalogo");
    } else {
        const err = await res.json();
        notificar(err.error || "Error al guardar el producto.");
    }
}

async function eliminarProducto(id) {
    if (!confirm("¿Eliminar este artículo del inventario?")) return;
    await fetch(`${API}/productos/${id}`, { method: "DELETE" });
    notificar("Artículo eliminado.");
    cargarProductos();
}

async function cargarClientes() {
    const res = await fetch(`${API}/clientes`);
    const clientes = await res.json();
    document.getElementById("select-cliente").innerHTML = clientes.map(c =>
        `<option value="${c.id}">${c.nombre} — ${c.nivelCertificacion}</option>`
    ).join("");
}

function agregarCarrito(id, nombre, precio, stockMax) {
    const existente = carrito.find(item => item.id === id);
    if (existente) {
        if (existente.cantidad >= stockMax) {
            notificar("Alcanzaste el límite de stock disponible.");
            return;
        }
        existente.cantidad++;
    } else {
        carrito.push({ id, nombre, precio, cantidad: 1, stockMax });
    }
    renderCarrito();
    notificar(`"${nombre}" añadido a tu bolsa.`);
}

function cambiarCantidad(id, delta) {
    const item = carrito.find(i => i.id === id);
    if (!item) return;
    const nuevaCant = item.cantidad + delta;
    if (nuevaCant <= 0) {
        carrito = carrito.filter(i => i.id !== id);
    } else if (nuevaCant <= item.stockMax) {
        item.cantidad = nuevaCant;
    } else {
        notificar("No hay más unidades en stock.");
    }
    renderCarrito();
}

function renderCarrito() {
    const lista = document.getElementById("lista-carrito");
    let total = 0;
    let unidades = 0;

    if (carrito.length === 0) {
        lista.innerHTML = `<div class="text-center text-muted py-5 small">Tu bolsa está vacía.</div>`;
    } else {
        lista.innerHTML = carrito.map(item => {
            total += item.precio * item.cantidad;
            unidades += item.cantidad;
            return `
                <div class="d-flex justify-content-between align-items-center py-3 border-bottom">
                    <div style="max-width: 210px;">
                        <div class="fw-semibold small text-truncate">${item.nombre}</div>
                        <div class="text-muted small">$${item.precio.toLocaleString('es-AR')} c/u</div>
                    </div>
                    <div class="d-flex align-items-center gap-2">
                        <button class="btn btn-sm btn-light border px-2 py-0" onclick="cambiarCantidad(${item.id}, -1)">-</button>
                        <span class="small fw-semibold">${item.cantidad}</span>
                        <button class="btn btn-sm btn-light border px-2 py-0" onclick="cambiarCantidad(${item.id}, 1)">+</button>
                    </div>
                </div>
            `;
        }).join("");
    }

    document.getElementById("total-carrito").textContent = `$${total.toLocaleString('es-AR')}`;
    document.getElementById("contador-carrito").textContent = unidades;
}

async function confirmarPedido() {
    if (carrito.length === 0) {
        notificar("Agregá al menos un equipo antes de finalizar.");
        return;
    }

    const payload = {
        clienteId: parseInt(document.getElementById("select-cliente").value),
        items: carrito.map(i => ({ productoId: i.id, cantidad: i.cantidad }))
    };

    const res = await fetch(`${API}/pedidos`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload)
    });

    if (res.ok) {
        carrito = [];
        renderCarrito();
        cargarProductos();
        bootstrap.Offcanvas.getInstance(document.getElementById("offcanvasCarrito"))?.hide();
        notificar("Orden confirmada y stock actualizado.");
    } else {
        const err = await res.json();
        notificar(err.error || "Error al procesar la orden.");
    }
}

async function cargarPedidos() {
    const res = await fetch(`${API}/pedidos`);
    const pedidos = await res.json();
    const tbody = document.getElementById("tabla-pedidos");

    tbody.innerHTML = pedidos.map(p => `
        <tr>
            <td class="fw-semibold">#${String(p.id).padStart(4, '0')}</td>
            <td>
                <div class="fw-medium">${p.clienteNombre}</div>
                <div class="text-muted small">${p.clienteCertificacion}</div>
            </td>
            <td class="small">${p.items.map(d => `${d.cantidad}× ${d.productoNombre}`).join("<br>")}</td>
            <td class="fw-bold">$${p.total.toLocaleString('es-AR')}</td>
            <td>
                <span class="badge ${p.estado === 'PAGADO' ? 'bg-success-subtle text-success' : 'bg-secondary-subtle text-secondary'}">
                    ${p.estado}
                </span>
            </td>
            <td class="text-end">
                ${p.estado === 'PAGADO'
                    ? `<button class="btn btn-sm btn-outline-danger" onclick="cancelarPedido(${p.id})">Anular orden</button>`
                    : `<span class="text-muted small">—</span>`}
            </td>
        </tr>
    `).join("") || `<tr><td colspan="6" class="text-center text-muted py-4">Aún no hay órdenes registradas.</td></tr>`;
}

async function cancelarPedido(id) {
    const res = await fetch(`${API}/pedidos/${id}/cancelar`, { method: "PATCH" });
    if (res.ok) {
        notificar("Orden anulada. El stock regresó al inventario.");
        cargarPedidos();
        cargarProductos();
    }
}
'@ | Set-Content -Encoding UTF8 "$static/app.js"

# 12. README.md actualizado
@'
# AquaPro — API REST & E-Commerce de Equipamiento de Buceo

Proyecto integrador desarrollado para **Talento Tech (Back-End Java)**. Implementa una arquitectura en capas con Spring Boot 3, persistencia relacional en MySQL mediante Spring Data JPA, manejo centralizado de excepciones, validaciones de negocio e interfaz web integrada.

## Tecnologías
- **Java 17+** & **Spring Boot 3.3.5**
- **Spring Data JPA / Hibernate** + **MySQL**
- **Bean Validation (`jakarta.validation`)**
- **SpringDoc OpenAPI (Swagger UI)**
- **HTML5, Bootstrap 5, JavaScript (Fetch API)**

## Ejecución
1. Verificar que MySQL esté activo y configurar credenciales en `src/main/resources/application.properties`.
2. Ejecutar `TiendaBuceoApplication.java`.
3. Acceder a:
   - **Tienda Web AquaPro:** `http://localhost:8080`
   - **Documentación Swagger:** `http://localhost:8080/swagger-ui/index.html`

## Endpoints Principales

### Categorías (`/api/categorias`)
| Método | Endpoint | Descripción | Códigos HTTP |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/categorias` | Listar categorías | `200` |
| `GET` | `/api/categorias/{id}` | Obtener categoría por ID | `200`, `404` |
| `POST` | `/api/categorias` | Crear nueva categoría | `201`, `400` |
| `DELETE` | `/api/categorias/{id}` | Eliminar categoría | `204`, `404` |

### Productos (`/api/productos`)
| Método | Endpoint | Descripción | Códigos HTTP |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/productos` | Listar productos (filtro opcional `?categoriaId=`) | `200` |
| `GET` | `/api/productos/{id}` | Obtener producto por ID | `200`, `404` |
| `POST` | `/api/productos` | Crear nuevo equipo | `201`, `400`, `404` |
| `PUT` | `/api/productos/{id}` | Actualizar equipo existente | `200`, `400`, `404` |
| `DELETE` | `/api/productos/{id}` | Eliminar equipo | `204`, `404` |

### Pedidos (`/api/pedidos`)
| Método | Endpoint | Descripción | Códigos HTTP |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/pedidos` | Listar historial de órdenes | `200` |
| `GET` | `/api/pedidos/{id}` | Obtener detalle de orden | `200`, `404` |
| `POST` | `/api/pedidos` | Registrar compra y descontar stock | `201`, `400`, `404` |
| `PATCH` | `/api/pedidos/{id}/cancelar` | Anular orden y restaurar stock | `200`, `400`, `404` |

### Clientes (`/api/clientes`)
| Método | Endpoint | Descripción | Códigos HTTP |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/clientes` | Listar buzos registrados | `200` |
| `POST` | `/api/clientes` | Registrar nuevo cliente | `201`, `400` |
'@ | Set-Content -Encoding UTF8 "$base/README.md"

Write-Host "¡Estructura profesional de AquaPro generada con éxito!" -ForegroundColor Green
