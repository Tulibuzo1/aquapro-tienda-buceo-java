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
