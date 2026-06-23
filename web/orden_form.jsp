<%-- 
    Document   : OrdenForm
    Created on : 8/04/2026, 10:23:58 p. m.
    Author     : annym
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.Producto, model.Persona" %>
<%
    List<Producto> productos = (List<Producto>) request.getAttribute("productos");
    String error    = (String) request.getAttribute("error");
    String ctx      = request.getContextPath();
    Persona usuario = (Persona) session.getAttribute("usuario");
    String  nombre  = usuario != null ? usuario.getNombre() : "";
    String  rol     = usuario != null ? usuario.getTipo()   : "";

    // Si viene de "Comprar" en la lista, preseleccionar ese producto
    String preselId = request.getParameter("idProducto");
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>MercadoRed — Nueva Orden</title>
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <style>
    .user-info { display:flex; align-items:center; gap:16px; font-size:.82rem; }
    .rol-badge { padding:3px 10px; border-radius:20px; font-size:.68rem; font-weight:700; letter-spacing:1px; text-transform:uppercase; }
    .rol-comprador { background:#c8a882; color:#2c2217; }
    .prod-select { display:grid; grid-template-columns:repeat(auto-fill,minmax(220px,1fr)); gap:16px; margin:20px 0; }
    .prod-option { border:2px solid var(--sand); border-radius:10px; padding:16px; cursor:pointer; transition:all .2s; background:var(--white); }
    .prod-option:has(input:checked) { border-color:var(--terra); background:var(--cream); }
    .prod-option input[type=radio] { accent-color:var(--terra); margin-right:6px; }
    .prod-nombre { font-family:var(--font-display); font-size:1rem; margin:8px 0 4px; }
    .prod-precio { color:var(--terra); font-weight:700; }
    .prod-stock  { color:var(--muted); font-size:.78rem; }
    .resumen-box { background:var(--sand); border-radius:10px; padding:20px; margin:24px 0; }
    .resumen-box p { margin:6px 0; }
  </style>
  <script>
    function calcTotal() {
      var radios   = document.querySelectorAll('input[name="idProducto"]');
      var cantidad = parseInt(document.getElementById('cantidad').value) || 0;
      var precio = 0, nombre = '', maxStock = 1;
      radios.forEach(function(r) {
        if (r.checked) {
          precio   = parseFloat(r.dataset.precio);
          nombre   = r.dataset.nombre;
          maxStock = parseInt(r.dataset.stock);
        }
      });
      if (cantidad > maxStock) {
        document.getElementById('cantidad').value = maxStock;
        cantidad = maxStock;
      }
      var total = precio * cantidad;
      document.getElementById('res-nombre').textContent = nombre || '—';
      document.getElementById('res-precio').textContent = precio > 0 ? '$ ' + precio.toLocaleString('es-CO') + ' COP' : '—';
      document.getElementById('res-total').textContent  = total  > 0 ? '$ ' + total.toLocaleString('es-CO')  + ' COP' : '—';
      document.getElementById('res-cantidad').textContent = cantidad > 0 ? cantidad + ' unidad(es)' : '—';
    }
    window.onload = function() { calcTotal(); };
  </script>
</head>
<body>

<header class="navbar">
  <div class="brand">Mercado<span>Red</span></div>
  <nav>
    <a href="<%= ctx %>/producto?accion=listar">Catálogo</a>
    <a href="<%= ctx %>/orden?accion=listar">Mis Pedidos</a>
    <div class="user-info">
      <span class="rol-badge rol-<%= rol %>"><%= rol %></span>
      <span style="color:var(--muted);">Hola, <strong style="color:var(--dark);"><%= nombre %></strong></span>
      <a href="<%= ctx %>/logout" class="btn btn-secondary btn-sm">Salir</a>
    </div>
  </nav>
</header>

<div class="container">
  <div style="max-width:900px; padding:40px 0 80px;">

    <h1 class="form-title">🛒 Nueva Orden de Compra</h1>
    <p class="form-subtitle" style="margin-bottom:28px;">Selecciona un producto e indica la cantidad</p>

    <% if (error != null) { %>
      <div class="alert alert-error"><%= error %></div>
    <% } %>

    <% if (productos == null || productos.isEmpty()) { %>
      <div class="empty-state">
        <div class="icon">📦</div>
        <h3>Sin productos disponibles</h3>
        <p>No hay productos con stock en este momento.</p>
        <a href="<%= ctx %>/producto?accion=listar" class="btn btn-primary">Ver catálogo</a>
      </div>
    <% } else { %>

    <form action="<%= ctx %>/orden" method="post">

      <p style="font-size:.72rem;letter-spacing:1.5px;text-transform:uppercase;color:var(--muted);font-weight:600;margin-bottom:12px;">
        Elige el producto
      </p>

      <div class="prod-select">
        <% for (Producto p : productos) {
             boolean presel = String.valueOf(p.getIdProducto()).equals(preselId);
        %>
        <label class="prod-option">
          <input type="radio" name="idProducto"
                 value="<%= p.getIdProducto() %>"
                 data-precio="<%= p.getPrecio() %>"
                 data-nombre="<%= p.getTitulo() %>"
                 data-stock="<%= p.getStock() %>"
                 onchange="calcTotal()"
                 <%= presel ? "checked" : "" %>
                 required/>
          <div class="prod-nombre"><%= p.getTitulo() %></div>
          <div class="prod-precio">$ <%= String.format("%,.0f", p.getPrecio()) %> COP</div>
          <div class="prod-stock">📦 <%= p.getStock() %> disponibles · <%= p.getCategoria() %></div>
        </label>
        <% } %>
      </div>

      <div class="form-group" style="max-width:200px;">
        <label for="cantidad">Cantidad *</label>
        <input type="number" id="cantidad" name="cantidad"
               min="1" value="1" required
               oninput="calcTotal()" onchange="calcTotal()"/>
      </div>

      <div class="resumen-box">
        <p style="font-size:.72rem;letter-spacing:1.5px;text-transform:uppercase;color:var(--muted);font-weight:600;margin-bottom:12px;">
          Resumen de compra
        </p>
        <p>Producto: <strong id="res-nombre">—</strong></p>
        <p>Cantidad:  <strong id="res-cantidad">—</strong></p>
        <p>Precio unitario: <strong id="res-precio">—</strong></p>
        <p style="margin-top:10px; font-size:1.1rem;">
          Total a pagar: <strong id="res-total" style="color:var(--terra);">—</strong>
        </p>
      </div>

      <div style="display:flex; gap:12px;">
        <a href="<%= ctx %>/producto?accion=listar" class="btn btn-secondary">← Seguir viendo</a>
        <button type="submit" class="btn btn-primary"
                onclick="return confirm('¿Confirmar la compra?')">
          ✅ Confirmar compra
        </button>
      </div>

    </form>
    <% } %>
  </div>
</div>

<footer class="footer">
  <div class="footer-brand">MercadoRed</div>
  <p>© 2026 MercadoRed S.A.S. · Bogotá, Colombia</p>
</footer>
</body>
</html>
