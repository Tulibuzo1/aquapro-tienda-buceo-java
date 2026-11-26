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
