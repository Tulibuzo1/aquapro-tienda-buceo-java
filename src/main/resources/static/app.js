const API = "/api";
let productosCache = [];
let carrito = [];
let categoriaActual = "";

const IMAGENES_CATEGORIA = {
    "Máscaras":     "https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=600&q=80",
    "Aletas":       "https://images.unsplash.com/photo-1582967788606-a171c1080cb0?auto=format&fit=crop&w=600&q=80",
    "Trajes":       "https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=600&q=80",
    "Reguladores":  "https://images.unsplash.com/photo-1682687220742-aba13b6e50ba?auto=format&fit=crop&w=600&q=80",
    "Accesorios":   "https://images.unsplash.com/photo-1551244072-5d12893278ab?auto=format&fit=crop&w=600&q=80"
};

document.addEventListener("DOMContentLoaded", () => {
    cargarProductos();
    cargarClientes();
    renderCarrito();
});

function escapeHtml(str) {
    return String(str ?? "").replace(/[&<>"']/g, c => ({
        '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
    })[c]);
}

function notificar(mensaje) {
    document.getElementById("toast-mensaje").textContent = mensaje;
    const toast = new bootstrap.Toast(document.getElementById("liveToast"), { delay: 3000 });
    toast.show();
}

function cambiarVista(vista) {
    ["catalogo", "pedidos", "admin"].forEach(v => {
        document.getElementById(`vista-${v}`).classList.toggle("d-none", v !== vista);
        const btn = document.getElementById(`nav-${v}`);
        const btnM = document.getElementById(`nav-${v}-m`);
        [btn, btnM].forEach(b => b && b.classList.toggle("active", v === vista));
    });
    document.getElementById("hero-banner").classList.toggle("d-none", vista !== "catalogo");
    if (vista === "pedidos") cargarPedidos();
}

async function cargarProductos() {
    const url = categoriaActual
        ? `${API}/productos?categoria=${encodeURIComponent(categoriaActual)}`
        : `${API}/productos`;
    const res = await fetch(url);
    productosCache = await res.json();
    filtrarLocalmente();
}

function seleccionarCategoria(cat, btn) {
    categoriaActual = cat;
    document.querySelectorAll(".filter-chip").forEach(c => c.classList.remove("active"));
    btn.classList.add("active");
    cargarProductos();
}

function filtrarLocalmente() {
    const texto = document.getElementById("buscador-productos").value.toLowerCase();
    const filtrados = productosCache.filter(p =>
        p.nombre.toLowerCase().includes(texto) ||
        p.marca.toLowerCase().includes(texto)
    );
    renderizarProductos(filtrados);
}

function renderizarProductos(lista) {
    const grid = document.getElementById("grid-productos");

    if (lista.length === 0) {
        grid.innerHTML = `
            <div class="col-12">
                <div class="empty-state">
                    <p>No encontramos equipos con ese criterio.</p>
                    <p class="small mb-0">Probá con otra búsqueda o quitá los filtros.</p>
                </div>
            </div>`;
        return;
    }

    grid.innerHTML = lista.map(p => {
        const imgUrl = IMAGENES_CATEGORIA[p.categoria] || IMAGENES_CATEGORIA["Accesorios"];
        const sinStock = p.stock === 0;
        return `
            <div class="col-sm-6 col-lg-4">
                <article class="product-card">
                    <div class="product-img-wrap">
                        <img src="${imgUrl}" alt="${escapeHtml(p.nombre)}" loading="lazy">
                    </div>
                    <div class="product-info">
                        <div class="product-eyebrow">${escapeHtml(p.marca)} · ${escapeHtml(p.categoria)}</div>
                        <h3 class="product-name">${escapeHtml(p.nombre)}</h3>
                        <div class="product-meta">
                            <span>Talle ${escapeHtml(p.talle)}</span>
                            <span class="${sinStock ? 'is-out' : 'is-in'}">
                                ${sinStock ? 'Agotado' : `${p.stock} en stock`}
                            </span>
                        </div>
                        <div class="product-footer">
                            <span class="product-price">$${p.precio.toLocaleString('es-AR')}</span>
                            <div class="product-actions">
                                <button class="btn-buy" ${sinStock ? 'disabled' : ''}
                                        data-action="add"
                                        data-id="${p.id}"
                                        data-nombre="${escapeHtml(p.nombre)}"
                                        data-precio="${p.precio}"
                                        data-stock="${p.stock}">
                                    Agregar
                                </button>
                                <button class="btn-delete" data-action="delete" data-id="${p.id}" title="Dar de baja">
                                    <i class="bi bi-x-lg"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </article>
            </div>`;
    }).join("");

    grid.querySelectorAll('[data-action="add"]').forEach(btn => {
        btn.addEventListener("click", () => {
            agregarCarrito(
                parseInt(btn.dataset.id),
                btn.dataset.nombre,
                parseFloat(btn.dataset.precio),
                parseInt(btn.dataset.stock)
            );
        });
    });
    grid.querySelectorAll('[data-action="delete"]').forEach(btn => {
        btn.addEventListener("click", () => eliminarProducto(parseInt(btn.dataset.id)));
    });
}

async function crearProducto(e) {
    e.preventDefault();
    const nuevo = {
        nombre: document.getElementById("prod-nombre").value,
        marca: document.getElementById("prod-marca").value,
        categoria: document.getElementById("prod-categoria").value,
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
        notificar("Producto agregado al catálogo.");
        document.getElementById("form-producto").reset();
        cargarProductos();
        cambiarVista("catalogo");
    }
}

async function eliminarProducto(id) {
    if (!confirm("¿Dar de baja este producto del inventario?")) return;
    await fetch(`${API}/productos/${id}`, { method: "DELETE" });
    notificar("Producto eliminado del inventario.");
    cargarProductos();
}

async function cargarClientes() {
    const res = await fetch(`${API}/clientes`);
    const clientes = await res.json();
    document.getElementById("select-cliente").innerHTML = clientes.map(c =>
        `<option value="${c.id}">${escapeHtml(c.nombre)} — ${escapeHtml(c.nivelCertificacion)}</option>`
    ).join("");
}

function agregarCarrito(id, nombre, precio, stockMax) {
    const existente = carrito.find(item => item.id === id);
    if (existente) {
        if (existente.cantidad >= stockMax) {
            notificar("No hay más unidades disponibles.");
            return;
        }
        existente.cantidad++;
    } else {
        carrito.push({ id, nombre, precio, cantidad: 1, stockMax });
    }
    renderCarrito();
    notificar(`"${nombre}" agregado a tu bolsa.`);
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
        notificar("No hay más unidades disponibles.");
    }
    renderCarrito();
}

function renderCarrito() {
    const lista = document.getElementById("lista-carrito");
    let total = 0;
    let unidades = 0;

    if (carrito.length === 0) {
        lista.innerHTML = `<div class="cart-empty">Tu bolsa está vacía.</div>`;
    } else {
        lista.innerHTML = carrito.map(item => {
            total += item.precio * item.cantidad;
            unidades += item.cantidad;
            return `
                <div class="cart-item">
                    <div class="flex-grow-1" style="min-width:0;">
                        <div class="cart-item-name text-truncate">${escapeHtml(item.nombre)}</div>
                        <div class="cart-item-price">$${item.precio.toLocaleString('es-AR')} c/u</div>
                    </div>
                    <div class="cart-qty">
                        <button onclick="cambiarCantidad(${item.id}, -1)">−</button>
                        <span>${item.cantidad}</span>
                        <button onclick="cambiarCantidad(${item.id}, 1)">+</button>
                    </div>
                </div>`;
        }).join("");
    }

    document.getElementById("total-carrito").textContent = `$${total.toLocaleString('es-AR')}`;
    document.getElementById("contador-carrito").textContent = unidades;
}

async function confirmarPedido() {
    if (carrito.length === 0) {
        notificar("Tu bolsa está vacía.");
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
        notificar("Pedido confirmado.");
    } else {
        const err = await res.json();
        notificar(err.error || "No se pudo procesar el pedido.");
    }
}

async function cargarPedidos() {
    const res = await fetch(`${API}/pedidos`);
    const pedidos = await res.json();
    const tbody = document.getElementById("tabla-pedidos");

    tbody.innerHTML = pedidos.map(p => `
        <tr>
            <td class="fw-semibold" style="font-family:'Fraunces',serif;">#${String(p.id).padStart(4, '0')}</td>
            <td>
                <div class="fw-medium">${escapeHtml(p.cliente.nombre)}</div>
                <div class="text-muted small">${escapeHtml(p.cliente.nivelCertificacion)}</div>
            </td>
            <td class="small">${p.detalles.map(d => `${d.cantidad}× ${escapeHtml(d.producto.nombre)}`).join("<br>")}</td>
            <td class="fw-semibold">$${p.total.toLocaleString('es-AR')}</td>
            <td>
                <span class="badge-estado ${p.estado === 'PAGADO' ? 'badge-pagado' : 'badge-anulado'}">
                    ${p.estado}
                </span>
            </td>
            <td class="text-end">
                ${p.estado === 'PAGADO'
                    ? `<button class="btn btn-sm btn-outline-danger" style="border-radius:4px;font-size:0.78rem;" onclick="cancelarPedido(${p.id})">Anular</button>`
                    : `<span class="text-muted small">—</span>`}
            </td>
        </tr>
    `).join("") || `<tr><td colspan="6" class="text-center text-muted py-4">Aún no hay pedidos registrados.</td></tr>`;
}

async function cancelarPedido(id) {
    const res = await fetch(`${API}/pedidos/${id}/cancelar`, { method: "PATCH" });
    if (res.ok) {
        notificar("Pedido anulado. El stock volvió al inventario.");
        cargarPedidos();
        cargarProductos();
    }
}