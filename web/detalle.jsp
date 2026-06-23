<%-- 
    Document   : detalle
    Created on : 26/04/2026, 11:00:49 p. m.
    Author     : annym
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Producto, model.Persona" %>
<%
    Producto p   = (Producto) request.getAttribute("producto");
    String   ctx = request.getContextPath();
    Persona usuario = (Persona) session.getAttribute("usuario");
    String  rol     = usuario != null ? usuario.getTipo()   : "";
    String  nombre  = usuario != null ? usuario.getNombre() : "";

    if (p == null) {
        response.sendRedirect(ctx + "/producto?accion=listar");
        return;
    }

    // Declarar TODAS las variables al inicio — esto evita el error "cannot be resolved"
    String imagenUrl   = (p.getImagenUrl()           != null && !p.getImagenUrl().isEmpty())           ? p.getImagenUrl()           : "";
    String politicaDev = (p.getPoliticaDevolucion()  != null && !p.getPoliticaDevolucion().isEmpty())  ? p.getPoliticaDevolucion()  : "";
    String descripcion = (p.getDescripcion()          != null)                                          ? p.getDescripcion()         : "";
    String nombreVend  = (p.getNombreVendedor()       != null)                                          ? p.getNombreVendedor()      : "Vendedor";
    String tituloP     = (p.getTitulo()               != null)                                          ? p.getTitulo()              : "";

    java.util.Map<String,String> iconos = new java.util.HashMap<>();
    iconos.put("Tecnología","💻"); iconos.put("Ropa","👗"); iconos.put("Muebles","🛋️");
    iconos.put("Hogar","🏡"); iconos.put("Deportes","⚽"); iconos.put("Libros","📚");
    iconos.put("Juguetes","🧸"); iconos.put("Otro","📦");
    String icono = iconos.getOrDefault(p.getCategoria(), "📦");
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MercadoRed — <%= tituloP %></title>
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <style>
    .user-info { display:flex; align-items:center; gap:16px; font-size:.82rem; }
    .rol-badge { padding:3px 10px; border-radius:20px; font-size:.68rem; font-weight:700; letter-spacing:1px; text-transform:uppercase; }
    .rol-admin     { background:#2c2217; color:#f5f0e8; }
    .rol-vendedor  { background:#8b6247; color:#fff; }
    .rol-comprador { background:#c8a882; color:#2c2217; }

    .detalle-wrap { display:grid; grid-template-columns:1fr 1fr; gap:48px; padding:48px 0 80px; align-items:start; }
    @media(max-width:768px){ .detalle-wrap { grid-template-columns:1fr; gap:24px; } }

    .img-principal { width:100%; aspect-ratio:1; border-radius:16px; background:var(--sand); display:flex; align-items:center; justify-content:center; overflow:hidden; box-shadow:var(--shadow); }
    .img-principal img { width:100%; height:100%; object-fit:cover; border-radius:16px; }
    .img-placeholder { font-size:6rem; opacity:.5; }

    .info-panel { display:flex; flex-direction:column; gap:20px; }
    .cat-tag { display:inline-block; background:var(--sand); color:var(--terra); font-size:.72rem; font-weight:700; letter-spacing:1.5px; text-transform:uppercase; padding:4px 12px; border-radius:20px; }
    .producto-titulo { font-family:var(--font-display); font-size:2rem; font-weight:400; color:var(--dark); line-height:1.2; }
    .precio-grande { font-size:1.8rem; font-weight:900; color:var(--terra); }
    .precio-grande small { font-size:.85rem; font-weight:400; color:var(--muted); margin-left:4px; }
    .estado-row { display:flex; gap:10px; align-items:center; flex-wrap:wrap; }
    .divider { border:none; border-top:1px solid var(--sand); }
    .info-row { display:flex; justify-content:space-between; padding:10px 0; border-bottom:1px solid var(--sand); font-size:.9rem; }
    .info-row .lbl { color:var(--muted); font-weight:500; }
    .info-row .val { color:var(--dark); font-weight:600; }
    .seccion-titulo { font-family:var(--font-display); font-size:1rem; font-weight:400; color:var(--dark); margin-bottom:10px; }
    .descripcion-box { background:var(--cream); border-radius:10px; padding:16px; font-size:.9rem; line-height:1.7; color:#444; white-space:pre-line; }
    .politica-box { background:#fff8e1; border-left:4px solid var(--accent); border-radius:0 10px 10px 0; padding:14px 16px; font-size:.85rem; line-height:1.6; color:#8b6000; white-space:pre-line; }
    .vendedor-card { background:var(--white); border:1.5px solid var(--sand); border-radius:12px; padding:16px; display:flex; align-items:center; gap:14px; }
    .vendedor-avatar { width:44px; height:44px; background:var(--terra); border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:1.2rem; color:#fff; font-weight:700; flex-shrink:0; }
    .acciones-compra { display:flex; flex-direction:column; gap:10px; }
    .sin-stock { background:#fce4ec; border-radius:8px; padding:12px; text-align:center; font-size:.88rem; color:#880e4f; font-weight:600; }
  </style>
</head>
<body>

<header class="navbar">
  <div class="brand">Mercado<span>Red</span></div>
  <nav>
    <a href="<%= ctx %>/producto?accion=listar">← Catálogo</a>
    <% if ("comprador".equals(rol)) { %><a href="<%= ctx %>/orden?accion=listar">Mis Pedidos</a><% } %>
    <% if ("vendedor".equals(rol) || "admin".equals(rol)) { %><a href="<%= ctx %>/orden?accion=listar">Pedidos</a><% } %>
    <div class="user-info">
      <span class="rol-badge rol-<%= rol %>"><%= rol %></span>
      <span style="color:var(--muted);">Hola, <strong style="color:var(--dark);"><%= nombre %></strong></span>
      <a href="<%= ctx %>/logout" class="btn btn-secondary btn-sm">Salir</a>
    </div>
  </nav>
</header>

<div class="container">
  <div class="detalle-wrap">

  
    <div>
      <div class="img-principal">
        <% if (!imagenUrl.isEmpty()) { %>
          <img src="<%= imagenUrl %>" alt="<%= tituloP %>"
               onerror="this.style.display='none'; document.getElementById('ph').style.display='flex'"/>
          <div id="ph" class="img-placeholder" style="display:none;"><%= icono %></div>
        <% } else { %>
          <div class="img-placeholder"><%= icono %></div>
        <% } %>
      </div>
    </div>

 
    <div class="info-panel">

      <div><span class="cat-tag"><%= p.getCategoria() %></span></div>

      <h1 class="producto-titulo"><%= tituloP %></h1>

      <div class="precio-grande">$ <%= String.format("%,.0f", p.getPrecio()) %><small>COP</small></div>

      <div class="estado-row">
        <span class="badge badge-<%= p.getEstadoProducto() %>"><%= p.getEstadoProducto() %></span>
        <span class="badge badge-vis-<%= p.getVisibilidad() %>"><%= p.getVisibilidad() %></span>
        <% if (p.getStock() > 0) { %>
          <span style="font-size:.82rem;color:#3a6b3a;font-weight:600;">✅ <%= p.getStock() %> disponibles</span>
        <% } else { %>
          <span style="font-size:.82rem;color:#d93025;font-weight:600;">❌ Sin stock</span>
        <% } %>
      </div>

      <hr class="divider"/>

      <div>
        <div class="info-row"><span class="lbl">Categoría</span><span class="val"><%= p.getCategoria() %></span></div>
        <div class="info-row"><span class="lbl">Estado</span><span class="val"><%= p.getEstadoProducto() %></span></div>
        <div class="info-row"><span class="lbl">Stock</span><span class="val"><%= p.getStock() %> unidades</span></div>
        <div class="info-row"><span class="lbl">Publicado</span><span class="val" style="font-size:.82rem;"><%= p.getFechaCreacion() %></span></div>
      </div>

    
      <div>
        <p class="seccion-titulo">📝 Descripción</p>
        <div class="descripcion-box"><%= descripcion %></div>
      </div>

      
      <div>
        <p class="seccion-titulo">🔄 Política de devolución</p>
        <% if (!politicaDev.isEmpty()) { %>
          <div class="politica-box"><%= politicaDev %></div>
        <% } else { %>
          <div class="politica-box" style="color:#aaa;">Este vendedor no ha especificado una política de devolución.</div>
        <% } %>
      </div>

  
      <div class="vendedor-card">
        <div class="vendedor-avatar"><%= nombreVend.charAt(0) %></div>
        <div>
          <p style="font-weight:700;color:var(--dark);margin:0;"><%= nombreVend %></p>
          <p style="font-size:.78rem;color:var(--muted);margin:2px 0 0;">Vendedor en MercadoRed</p>
        </div>
      </div>

      
      <div class="acciones-compra">
        <% if ("comprador".equals(rol)) { %>
          <% if (p.getStock() > 0) { %>
            <a href="<%= ctx %>/orden?accion=nueva&idProducto=<%= p.getIdProducto() %>"
               class="btn btn-primary" style="justify-content:center;padding:16px;">🛒 Comprar ahora</a>
          <% } else { %>
            <div class="sin-stock">❌ Producto sin stock disponible</div>
          <% } %>
        <% } %>
        <% if ("admin".equals(rol) || "vendedor".equals(rol)) { %>
          <a href="<%= ctx %>/producto?accion=editar&id=<%= p.getIdProducto() %>"
             class="btn btn-edit" style="justify-content:center;">✏️ Editar publicación</a>
        <% } %>
        <a href="<%= ctx %>/producto?accion=listar"
           class="btn btn-secondary" style="justify-content:center;">← Volver al catálogo</a>
      </div>

    </div>
  </div>
</div>

<footer class="footer">
  <div class="footer-brand">MercadoRed</div>
  <p>© 2026 MercadoRed S.A.S. · Bogotá, Colombia</p>
</footer>
</body>
</html>
