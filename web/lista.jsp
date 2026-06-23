<%-- 
    Document   : lista
    Created on : 4/04/2026, 11:26:57 p. m.
    Author     : annym
--%>
<%--
    Document : lista — Catalogo de Productos
    Modulo 3 : RF009/RF010 + boton agregar carrito CA024
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.Producto, model.Persona" %>
<%
    List<Producto> productos = (List<Producto>) request.getAttribute("productos");
    String msg   = request.getParameter("msg");
    String error = (String) request.getAttribute("error");
    String ctx   = request.getContextPath();

    Persona usuario = (Persona) session.getAttribute("usuario");
    String  rol     = usuario != null ? usuario.getTipo()   : "";
    String  nombre  = usuario != null ? usuario.getNombre() : "";

    if (error == null) error = request.getParameter("error");

    boolean hayFiltro    = Boolean.TRUE.equals(request.getAttribute("hayFiltro"));
    String  filtroBuscar = (String) request.getAttribute("buscar");
    String  filtroCat    = (String) request.getAttribute("categoria");
    String  filtroMin    = (String) request.getAttribute("min");
    String  filtroMax    = (String) request.getAttribute("max");
    String  filtroEstado = (String) request.getAttribute("estado");
    String  filtroOrden  = (String) request.getAttribute("orden");
    if (filtroBuscar == null) filtroBuscar = "";
    if (filtroCat    == null) filtroCat    = "";
    if (filtroMin    == null) filtroMin    = "";
    if (filtroMax    == null) filtroMax    = "";
    if (filtroEstado == null) filtroEstado = "";
    if (filtroOrden  == null) filtroOrden  = "";

    int totalProductos = (productos != null) ? productos.size() : 0;

    java.util.List<model.CarritoItem> carrito =
        (java.util.List<model.CarritoItem>) session.getAttribute("carrito");
    int carritoSize = (carrito != null) ? carrito.size() : 0;

    String[][] categorias = {
        {"Tecnologia"}, {"Ropa"}, {"Muebles"},
        {"Hogar"}, {"Deportes"}, {"Libros"}, {"Juguetes"}, {"Otro"}
    };
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MercadoRed — Catalogo</title>
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <style>
    /* ── BADGES ROL ── */
    .user-info { display:flex; align-items:center; gap:14px; font-size:.82rem; }
    .rol-badge  { padding:3px 10px; border-radius:20px; font-size:.68rem; font-weight:700;
                  letter-spacing:1px; text-transform:uppercase; }
    .rol-admin     { background:#2c2217; color:#f5f0e8; }
    .rol-vendedor  { background:#8b6247; color:#fff; }
    .rol-comprador { background:#c8a882; color:#2c2217; }
    .carrito-badge {
      background:var(--red); color:#fff; font-size:.6rem; font-weight:700;
      padding:1px 6px; border-radius:20px; margin-left:2px; vertical-align:middle;
    }
    .nav-active { color:var(--dark) !important; font-weight:600; }

    /* ── SUBHEADER DEL CATALOGO ── */
    .catalogo-subheader {
      background: var(--white);
      border-bottom: 1px solid var(--sand);
      padding: 20px 0;
    }
    .catalogo-subheader-inner {
      max-width: 1200px;
      margin: 0 auto;
      padding: 0 40px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
    }
    .catalogo-subheader h1 {
      font-family: var(--font-display);
      font-size: 1.6rem;
      font-weight: 400;
      color: var(--dark);
    }
    .catalogo-subheader .sub {
      font-size: .68rem;
      letter-spacing: 2px;
      text-transform: uppercase;
      color: var(--muted);
      margin-bottom: 4px;
    }
    .resultado-info { display: flex; align-items: center; gap: 12px; }
    .resultado-count { font-size: .82rem; color: var(--muted); }
    .resultado-count strong { color: var(--terra); font-weight: 600; }

    /* ── LAYOUT: 2 columnas independientes bajo el subheader ── */
    /*
     * FIX de scroll: el wrapper ocupa el espacio restante de la ventana
     * (100vh menos navbar 72px menos subheader ~85px).
     * Cada columna tiene su propio overflow-y:auto, por lo que
     * filtros y productos se desplazan de forma independiente.
     * El hero y el ticker viven en index.jsp (pagina Inicio),
     * no en esta vista de catalogo.
     */
    .catalogo-wrapper {
      display: grid;
      grid-template-columns: 268px 1fr;
      height: calc(100vh - 157px);   /* 72px navbar + 85px subheader */
      overflow: hidden;
    }

    /* Columna izquierda — filtros */
    .filtros-col {
      height: 100%;
      overflow-y: auto;
      background: var(--white);
      border-right: 1px solid var(--sand);
      scrollbar-width: thin;
      scrollbar-color: var(--sand) transparent;
    }
    .filtros-col::-webkit-scrollbar { width: 4px; }
    .filtros-col::-webkit-scrollbar-thumb { background: var(--sand); border-radius: 4px; }

    /* Columna derecha — productos */
    .productos-col {
      height: 100%;
      overflow-y: auto;
      background: var(--cream);
      scrollbar-width: thin;
      scrollbar-color: var(--sand) transparent;
    }
    .productos-col::-webkit-scrollbar { width: 4px; }
    .productos-col::-webkit-scrollbar-thumb { background: var(--sand); border-radius: 4px; }

    .productos-inner { padding: 32px 36px 80px; }

    /* ── PANEL FILTROS ── */
    .filtros-header {
      background: var(--dark);
      color: var(--cream);
      padding: 18px 22px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      position: sticky;
      top: 0;
      z-index: 5;
    }
    .filtros-header h3 {
      font-family: var(--font-body);
      font-size: .68rem;
      font-weight: 600;
      letter-spacing: 2.5px;
      text-transform: uppercase;
      margin: 0;
    }
    .filtros-count {
      background: var(--accent); color: var(--white);
      font-size: .62rem; font-weight: 700;
      padding: 2px 8px; border-radius: 20px; display: none;
    }
    .filtros-count.visible { display: inline-block; }

    .filtro-grupo { padding: 16px 20px; border-bottom: 1px solid var(--sand); }
    .filtro-grupo:last-child { border-bottom: none; }

    .filtro-label {
      font-size: .6rem; font-weight: 700; letter-spacing: 2px;
      text-transform: uppercase; color: var(--muted);
      margin-bottom: 11px; display: block;
    }

    .filtro-search-wrap { position: relative; }
    .filtro-search-wrap svg {
      position: absolute; left: 9px; top: 50%; transform: translateY(-50%);
      color: var(--warm); width: 13px; height: 13px; pointer-events: none;
    }
    .filtro-search-wrap input {
      width: 100%; padding: 8px 10px 8px 30px;
      border: 1.5px solid var(--sand); border-radius: var(--radius-sm);
      font-family: var(--font-body); font-size: .86rem; color: var(--dark);
      background: var(--cream); outline: none;
      transition: border-color .2s; box-sizing: border-box;
    }
    .filtro-search-wrap input:focus { border-color: var(--terra); background: var(--white); }
    .filtro-search-wrap input::placeholder { color: var(--warm); }

    .cat-chips { display: flex; flex-direction: column; gap: 2px; }
    .cat-chip {
      display: flex; align-items: center; gap: 8px;
      padding: 7px 9px; border-radius: var(--radius-sm);
      cursor: pointer; transition: background .15s;
      font-size: .82rem; color: var(--dark); user-select: none;
    }
    .cat-chip:hover { background: var(--cream); }
    .cat-chip.activo { background: var(--sand); color: var(--terra); font-weight: 600; }
    .cat-chip input[type="radio"] { display: none; }
    .cat-chip-dot {
      width: 6px; height: 6px; border-radius: 50%;
      background: var(--sand); border: 1.5px solid var(--warm); flex-shrink: 0;
    }
    .cat-chip.activo .cat-chip-dot { background: var(--terra); border-color: var(--terra); }

    .precio-inputs { display: grid; grid-template-columns: 1fr 1fr; gap: 7px; }
    .precio-field  { display: flex; flex-direction: column; gap: 4px; }
    .precio-field span {
      font-size: .58rem; letter-spacing: 1px; text-transform: uppercase;
      color: var(--muted); font-weight: 600;
    }
    .precio-field input {
      width: 100%; padding: 7px 9px;
      border: 1.5px solid var(--sand); border-radius: var(--radius-sm);
      font-family: var(--font-body); font-size: .82rem; color: var(--dark);
      background: var(--cream); outline: none; box-sizing: border-box;
      transition: border-color .2s;
    }
    .precio-field input:focus { border-color: var(--terra); }

    .filtro-select {
      width: 100%; padding: 8px 28px 8px 10px;
      border: 1.5px solid var(--sand); border-radius: var(--radius-sm);
      font-family: var(--font-body); font-size: .84rem; color: var(--dark);
      background: var(--cream); outline: none; cursor: pointer;
      appearance: none;
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'%3E%3Cpath d='M1 1l5 5 5-5' stroke='%238b6247' stroke-width='1.5' fill='none' stroke-linecap='round'/%3E%3C/svg%3E");
      background-repeat: no-repeat; background-position: right 10px center;
      transition: border-color .2s; box-sizing: border-box;
    }
    .filtro-select:focus { border-color: var(--terra); }

    .filtros-actions { padding: 14px 20px 22px; display: flex; flex-direction: column; gap: 7px; }
    .filtros-actions .btn { justify-content: center; width: 100%; font-size: .7rem; }

    /* ── CONTENIDO PRODUCTOS ── */
    .filtro-tags { display: flex; flex-wrap: wrap; gap: 7px; margin-bottom: 18px; }
    .filtro-tag {
      display: inline-flex; align-items: center; gap: 5px;
      background: var(--sand); color: var(--terra);
      border: 1.5px solid var(--warm);
      padding: 3px 11px; border-radius: 20px;
      font-size: .7rem; font-weight: 600;
    }
    .filtro-tag a { color: var(--muted); text-decoration: none; font-size: .82rem; transition: color .15s; }
    .filtro-tag a:hover { color: var(--red); }

    .catalogo-divider { height: 1px; background: var(--sand); margin-bottom: 24px; }

    /* Boton agregar al carrito */
    .btn-carrito {
      flex: 1; justify-content: center;
      background: var(--terra); color: var(--white);
      border: none; padding: 8px 12px;
      border-radius: var(--radius-sm);
      font-family: var(--font-body); font-size: .7rem;
      font-weight: 600; letter-spacing: .5px;
      cursor: pointer; transition: background .2s;
      text-decoration: none; display: inline-flex; align-items: center;
    }
    .btn-carrito:hover { background: var(--dark); }

    @media (max-width: 900px) {
      .catalogo-wrapper { grid-template-columns: 1fr; height: auto; overflow: visible; }
      .filtros-col, .productos-col { height: auto; overflow: visible; }
      .catalogo-subheader-inner { padding: 0 24px; }
    }
  </style>
</head>
<body>

<!-- NAVBAR -->
<header class="navbar">
  <div class="brand">Mercado<span>Red</span></div>
  <nav>
    <a href="<%= ctx %>/">Inicio</a>
    <a href="<%= ctx %>/producto?accion=listar" class="nav-active">Catalogo</a>

    <% if ("comprador".equals(rol)) { %>
      <a href="<%= ctx %>/carrito?accion=ver">
        Carrito<% if (carritoSize > 0) { %><span class="carrito-badge"><%= carritoSize %></span><% } %>
      </a>
      <a href="<%= ctx %>/orden?accion=listar">Mis Pedidos</a>
    <% } %>

    <% if ("vendedor".equals(rol) || "admin".equals(rol)) { %>
      <a href="<%= ctx %>/orden?accion=listar">Pedidos</a>
      <a href="<%= ctx %>/producto?accion=nuevo" class="btn btn-primary" style="padding:10px 20px;">+ Publicar</a>
    <% } %>

    <div class="user-info">
      <span class="rol-badge rol-<%= rol %>"><%= rol %></span>
      <span style="color:var(--muted);">Hola, <strong style="color:var(--dark);"><%= nombre %></strong></span>
      <a href="<%= ctx %>/logout" class="btn btn-secondary btn-sm">Salir</a>
    </div>
  </nav>
</header>

<!-- SUBHEADER DEL CATALOGO -->
<div class="catalogo-subheader">
  <div class="catalogo-subheader-inner">
    <div>
      <p class="sub"><% if ("comprador".equals(rol)) { %>Explora y compra<% } else { %>Gestion de inventario<% } %></p>
      <h1>Catalogo de Productos</h1>
    </div>
    <div class="resultado-info">
      <span class="resultado-count"><strong><%= totalProductos %></strong> <%= totalProductos == 1 ? "resultado" : "resultados" %></span>
      <% if ("admin".equals(rol) || "vendedor".equals(rol)) { %>
        <a href="<%= ctx %>/producto?accion=nuevo" class="btn btn-outline btn-sm">+ Nuevo</a>
      <% } else if ("comprador".equals(rol)) { %>
        <a href="<%= ctx %>/carrito?accion=ver" class="btn btn-outline btn-sm">
          Ver carrito<% if (carritoSize > 0) { %> (<%= carritoSize %>)<% } %>
        </a>
      <% } %>
    </div>
  </div>
</div>

<!-- LAYOUT DE DOS COLUMNAS CON SCROLL INDEPENDIENTE -->
<div class="catalogo-wrapper">

  <!-- FILTROS -->
  <aside class="filtros-col">
    <form method="get" action="<%= ctx %>/producto" id="filtrosForm">
      <input type="hidden" name="accion" value="listar">

      <div class="filtros-header">
        <h3>Filtros</h3>
        <%
          int nFiltros = 0;
          if (!filtroBuscar.isEmpty()) nFiltros++;
          if (!filtroCat.isEmpty())    nFiltros++;
          if (!filtroMin.isEmpty())    nFiltros++;
          if (!filtroMax.isEmpty())    nFiltros++;
          if (!filtroEstado.isEmpty()) nFiltros++;
        %>
        <span class="filtros-count <%= nFiltros > 0 ? "visible" : "" %>"><%= nFiltros %></span>
      </div>

      <div class="filtro-grupo">
        <span class="filtro-label">Buscar</span>
        <div class="filtro-search-wrap">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
          </svg>
          <input type="text" name="buscar" placeholder="Nombre o descripcion..."
                 value="<%= filtroBuscar %>" oninput="updateCount()">
        </div>
      </div>

      <div class="filtro-grupo">
        <span class="filtro-label">Categoria</span>
        <div class="cat-chips">
          <label class="cat-chip <%= filtroCat.isEmpty() ? "activo" : "" %>">
            <input type="radio" name="categoria" value=""
                   <%= filtroCat.isEmpty() ? "checked" : "" %> onchange="this.form.submit()">
            <span class="cat-chip-dot"></span><span>Todas</span>
          </label>
          <% for (String[] cat : categorias) { boolean sel = cat[0].equals(filtroCat); %>
          <label class="cat-chip <%= sel ? "activo" : "" %>">
            <input type="radio" name="categoria" value="<%= cat[0] %>"
                   <%= sel ? "checked" : "" %> onchange="this.form.submit()">
            <span class="cat-chip-dot"></span><span><%= cat[0] %></span>
          </label>
          <% } %>
        </div>
      </div>

      <div class="filtro-grupo">
        <span class="filtro-label">Precio (COP)</span>
        <div class="precio-inputs">
          <div class="precio-field">
            <span>Minimo</span>
            <input type="number" name="min" placeholder="0" value="<%= filtroMin %>" min="0" step="5000">
          </div>
          <div class="precio-field">
            <span>Maximo</span>
            <input type="number" name="max" placeholder="Sin limite" value="<%= filtroMax %>" min="0" step="5000">
          </div>
        </div>
      </div>

      <div class="filtro-grupo">
        <span class="filtro-label">Estado</span>
        <select name="estado" class="filtro-select" onchange="this.form.submit()">
          <option value="" <%= filtroEstado.isEmpty()        ? "selected" : "" %>>Todos</option>
          <option value="nuevo" <%= "nuevo".equals(filtroEstado) ? "selected" : "" %>>Nuevo</option>
          <option value="usado" <%= "usado".equals(filtroEstado) ? "selected" : "" %>>Usado</option>
        </select>
      </div>

      <div class="filtro-grupo">
        <span class="filtro-label">Ordenar por</span>
        <select name="orden" class="filtro-select" onchange="this.form.submit()">
          <option value=""            <%= filtroOrden.isEmpty()              ? "selected" : "" %>>Relevancia</option>
          <option value="precio_asc"  <%= "precio_asc" .equals(filtroOrden) ? "selected" : "" %>>Menor precio</option>
          <option value="precio_desc" <%= "precio_desc".equals(filtroOrden) ? "selected" : "" %>>Mayor precio</option>
          <option value="nombre_asc"  <%= "nombre_asc" .equals(filtroOrden) ? "selected" : "" %>>Nombre A-Z</option>
          <option value="nombre_desc" <%= "nombre_desc".equals(filtroOrden) ? "selected" : "" %>>Nombre Z-A</option>
          <option value="stock_desc"  <%= "stock_desc" .equals(filtroOrden) ? "selected" : "" %>>Mayor stock</option>
          <option value="reciente"    <%= "reciente"   .equals(filtroOrden) ? "selected" : "" %>>Mas recientes</option>
        </select>
      </div>

      <div class="filtros-actions">
        <button type="submit" class="btn btn-primary">Aplicar filtros</button>
        <% if (hayFiltro) { %>
          <a href="<%= ctx %>/producto?accion=listar" class="btn btn-secondary">Limpiar filtros</a>
        <% } %>
      </div>
    </form>
  </aside>

  <!-- PRODUCTOS -->
  <section class="productos-col">
    <div class="productos-inner">

      <!-- Alerts -->
      <% if ("creado".equals(msg)) { %>
        <div class="alert alert-success" style="margin-bottom:18px;">Producto publicado exitosamente.</div>
      <% } else if ("actualizado".equals(msg)) { %>
        <div class="alert alert-success" style="margin-bottom:18px;">Producto actualizado correctamente.</div>
      <% } else if ("eliminado".equals(msg)) { %>
        <div class="alert alert-warning" style="margin-bottom:18px;">Producto eliminado del catalogo.</div>
      <% } else if ("agregado".equals(msg)) { %>
        <div class="alert alert-success" style="margin-bottom:18px;">Producto agregado al carrito.</div>
      <% } %>
      <% if (error != null && !error.isEmpty()) { %>
        <div class="alert alert-error" style="margin-bottom:18px;">No tienes permiso para esa accion.</div>
      <% } %>

      <!-- Tags de filtros activos (CA023) -->
      <% if (hayFiltro) { %>
        <div class="filtro-tags">
          <% if (!filtroBuscar.isEmpty()) { %>
            <span class="filtro-tag">"<%= filtroBuscar %>"
              <a href="<%= ctx %>/producto?accion=listar&categoria=<%= filtroCat %>&min=<%= filtroMin %>&max=<%= filtroMax %>&estado=<%= filtroEstado %>&orden=<%= filtroOrden %>">x</a>
            </span>
          <% } %>
          <% if (!filtroCat.isEmpty()) { %>
            <span class="filtro-tag"><%= filtroCat %>
              <a href="<%= ctx %>/producto?accion=listar&buscar=<%= filtroBuscar %>&min=<%= filtroMin %>&max=<%= filtroMax %>&estado=<%= filtroEstado %>&orden=<%= filtroOrden %>">x</a>
            </span>
          <% } %>
          <% if (!filtroMin.isEmpty() || !filtroMax.isEmpty()) { %>
            <span class="filtro-tag">
              <% if (!filtroMin.isEmpty() && !filtroMax.isEmpty()) { %>$<%= filtroMin %> - $<%= filtroMax %>
              <% } else if (!filtroMin.isEmpty()) { %>Desde $<%= filtroMin %>
              <% } else { %>Hasta $<%= filtroMax %><% } %>
              <a href="<%= ctx %>/producto?accion=listar&buscar=<%= filtroBuscar %>&categoria=<%= filtroCat %>&estado=<%= filtroEstado %>&orden=<%= filtroOrden %>">x</a>
            </span>
          <% } %>
          <% if (!filtroEstado.isEmpty()) { %>
            <span class="filtro-tag"><%= filtroEstado %>
              <a href="<%= ctx %>/producto?accion=listar&buscar=<%= filtroBuscar %>&categoria=<%= filtroCat %>&min=<%= filtroMin %>&max=<%= filtroMax %>&orden=<%= filtroOrden %>">x</a>
            </span>
          <% } %>
        </div>
      <% } %>

      <div class="catalogo-divider"></div>

      <!-- Grid o estado vacio -->
      <% if (productos == null || productos.isEmpty()) { %>
        <% if (hayFiltro) { %>
          <div class="empty-state">
            <div class="icon">[ ]</div>
            <h3>Sin resultados</h3>
            <p>No encontramos productos con esos criterios. Intenta ajustar los filtros.</p>
            <a href="<%= ctx %>/producto?accion=listar" class="btn btn-primary">Ver todos los productos</a>
          </div>
        <% } else { %>
          <div class="empty-state">
            <div class="icon">[ ]</div>
            <h3>El catalogo esta vacio</h3>
            <p>Aun no hay productos publicados.</p>
            <% if ("admin".equals(rol) || "vendedor".equals(rol)) { %>
              <a href="<%= ctx %>/producto?accion=nuevo" class="btn btn-primary">Publicar producto</a>
            <% } %>
          </div>
        <% } %>
      <% } else { %>
        <div class="product-grid">
          <% for (Producto p : productos) { %>
          <div class="product-card">
            <div class="card-img">
  <% String imgUrl = p.getImagenUrl() != null && !p.getImagenUrl().isEmpty()
                     ? p.getImagenUrl() : ""; %>
  <% if (!imgUrl.isEmpty()) { %>
    <img class="card-img-real" src="<%= imgUrl %>" alt="<%= p.getTitulo() %>"
         onerror="this.style.display='none'; this.nextElementSibling.style.display='flex'"/>
    <div class="card-img-placeholder" style="display:none;">
      <%= p.getCategoria() != null && !p.getCategoria().isEmpty()
          ? p.getCategoria().substring(0,1) : "P" %>
    </div>
  <% } else { %>
    <div class="card-img-placeholder">
      <%= p.getCategoria() != null && !p.getCategoria().isEmpty()
          ? p.getCategoria().substring(0,1) : "P" %>
    </div>
  <% } %>
  <div class="card-badges">
    <span class="badge badge-<%= p.getEstadoProducto() %>"><%= p.getEstadoProducto() %></span>
  </div>
</div>
            <div class="card-body">
              <p class="card-cat"><%= p.getCategoria() %></p>
              <h3 class="card-title"><%= p.getTitulo() %></h3>
              <p class="card-price">$ <%= String.format("%,.0f", p.getPrecio()) %> COP</p>
              <p class="card-stock <%= p.getStock() == 0 ? "stock-cero" : "" %>">
                <%= p.getStock() == 0 ? "Sin stock" : p.getStock() + " disponibles" %>
              </p>
              <div class="card-actions">
                <% if ("comprador".equals(rol) && p.getStock() > 0) { %>
                  <form method="post" action="<%= ctx %>/carrito" style="flex:1;display:flex;">
                    <input type="hidden" name="accion"     value="agregar">
                    <input type="hidden" name="idProducto" value="<%= p.getIdProducto() %>">
                    <input type="hidden" name="cantidad"   value="1">
                    <button type="submit" class="btn-carrito">+ Agregar al carrito</button>
                  </form>
                <% } %>
                <% if ("admin".equals(rol) || "vendedor".equals(rol)) { %>
                  <a href="<%= ctx %>/producto?accion=editar&id=<%= p.getIdProducto() %>"
                     class="btn btn-sm btn-edit">Editar</a>
                  <a href="<%= ctx %>/producto?accion=eliminar&id=<%= p.getIdProducto() %>"
                     class="btn btn-sm btn-delete"
                     onclick="return confirm('Eliminar este producto?')">Eliminar</a>
                <% } %>
              </div>
            </div>
          </div>
          <% } %>
        </div>
      <% } %>
    </div>
  </section>

</div><!-- /catalogo-wrapper -->

<script>
function updateCount() {
  const buscar    = document.querySelector('[name="buscar"]').value.trim();
  const categoria = document.querySelector('[name="categoria"]:checked')?.value || '';
  const min       = document.querySelector('[name="min"]').value.trim();
  const max       = document.querySelector('[name="max"]').value.trim();
  const estado    = document.querySelector('[name="estado"]').value;
  const n = [buscar, categoria, min, max, estado].filter(v => v !== '').length;
  const badge = document.querySelector('.filtros-count');
  if (badge) { badge.textContent = n; badge.classList.toggle('visible', n > 0); }
}
</script>
</body>
</html>
