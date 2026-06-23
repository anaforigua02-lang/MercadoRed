<%-- 
    Document   : carrito
    Created on : 27/04/2026, 1:39:15 p. m.
    Author     : annym
--%>

<%--  Modulo 4 - Paso 1: Carrito (RF011 / CA024-CA026) --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.CarritoItem, model.Persona" %>
<%
    List<CarritoItem> carrito = (List<CarritoItem>) session.getAttribute("carrito");
    if (carrito == null) carrito = new java.util.ArrayList<>();
    Persona usuario = (Persona) session.getAttribute("usuario");
    String  nombre  = usuario != null ? usuario.getNombre() : "";
    String  rol     = usuario != null ? usuario.getTipo()   : "";
    String  ctx     = request.getContextPath();
    String  msg     = request.getParameter("msg");
    String  err     = request.getParameter("error");

    double total = 0;
    for (CarritoItem i : carrito) total += i.getSubtotal();
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MercadoRed — Carrito</title>
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <style>
    .user-info { display:flex; align-items:center; gap:14px; font-size:.82rem; }
    .rol-badge  { padding:3px 10px; border-radius:20px; font-size:.68rem; font-weight:700; letter-spacing:1px; text-transform:uppercase; }
    .rol-comprador { background:#c8a882; color:#2c2217; }

    /* Wizard */
    .wizard { display:flex; align-items:center; margin:40px 0 48px; }
    .wizard-step { display:flex; align-items:center; gap:12px; flex:1; position:relative; }
    .wizard-step:not(:last-child)::after {
      content:''; position:absolute; left:52px; top:20px;
      width:calc(100% - 52px); height:2px; background:var(--sand); z-index:0;
    }
    .step-circle {
      width:40px; height:40px; border-radius:50%; display:flex; align-items:center;
      justify-content:center; font-weight:700; font-size:.85rem; flex-shrink:0;
      position:relative; z-index:1; border:2px solid var(--sand);
      background:var(--white); color:var(--muted); transition:all .3s;
    }
    .step-circle.activo { background:var(--dark); color:var(--cream); border-color:var(--dark); }
    .step-circle.listo  { background:var(--green); color:#fff; border-color:var(--green); }
    .step-info { display:flex; flex-direction:column; }
    .step-num  { font-size:.6rem; letter-spacing:2px; text-transform:uppercase; color:var(--muted); }
    .step-name { font-size:.84rem; font-weight:600; color:var(--dark); }
    .step-name.inactivo { color:var(--muted); font-weight:400; }

    /* Layout */
    .carrito-layout { display:grid; grid-template-columns:1fr 320px; gap:36px; align-items:start; padding-bottom:80px; }

    /* Tabla items */
    .carrito-card { background:var(--white); border-radius:var(--radius); box-shadow:var(--shadow-sm); overflow:hidden; }
    .carrito-head {
      background:var(--dark); color:var(--cream); padding:16px 24px;
      display:flex; align-items:center; justify-content:space-between;
    }
    .carrito-head h3 { font-family:var(--font-body); font-size:.7rem; font-weight:600; letter-spacing:2.5px; text-transform:uppercase; margin:0; }
    .carrito-head a  { font-size:.7rem; color:var(--warm); text-decoration:none; letter-spacing:1px; transition:color .2s; }
    .carrito-head a:hover { color:var(--cream); }

    .carrito-item {
      display:grid; grid-template-columns:48px 1fr auto auto;
      gap:16px; align-items:center; padding:18px 24px;
      border-bottom:1px solid var(--sand);
    }
    .carrito-item:last-child { border-bottom:none; }

    .item-inicial {
      width:40px; height:40px; border-radius:50%;
      background:var(--sand); color:var(--terra);
      display:flex; align-items:center; justify-content:center;
      font-family:var(--font-display); font-size:1.1rem; font-weight:600;
    }
    .item-cat   { font-size:.62rem; letter-spacing:1.5px; text-transform:uppercase; color:var(--accent); font-weight:600; margin-bottom:2px; }
    .item-name  { font-family:var(--font-display); font-size:.95rem; color:var(--dark); margin-bottom:2px; }
    .item-price { font-size:.8rem; color:var(--muted); }

    /* Control de cantidad */
    .qty-control { display:flex; align-items:center; border:1.5px solid var(--sand); border-radius:var(--radius-sm); overflow:hidden; }
    .qty-btn {
      width:30px; height:30px; background:var(--cream); border:none;
      cursor:pointer; font-size:1rem; color:var(--terra);
      display:flex; align-items:center; justify-content:center;
      transition:background .15s;
    }
    .qty-btn:hover { background:var(--sand); }
    .qty-input {
      width:40px; height:30px; text-align:center; border:none;
      font-family:var(--font-body); font-size:.88rem; font-weight:600;
      color:var(--dark); background:var(--white); outline:none;
    }

    .item-acciones { display:flex; flex-direction:column; align-items:flex-end; gap:8px; }
    .item-subtotal { font-weight:700; color:var(--terra); font-size:.95rem; }
    .item-del { color:var(--muted); text-decoration:none; font-size:.72rem; letter-spacing:.5px; transition:color .2s; }
    .item-del:hover { color:var(--red); }

    /* Resumen */
    .resumen-card { background:var(--white); border-radius:var(--radius); box-shadow:var(--shadow-sm); overflow:hidden; position:sticky; top:88px; }
    .resumen-head { background:var(--terra); color:var(--cream); padding:16px 22px; font-family:var(--font-body); font-size:.7rem; font-weight:600; letter-spacing:2.5px; text-transform:uppercase; }
    .resumen-body { padding:22px; }
    .resumen-row  { display:flex; justify-content:space-between; margin-bottom:10px; font-size:.86rem; color:var(--muted); }
    .resumen-row strong { color:var(--dark); }
    .resumen-div  { height:1px; background:var(--sand); margin:14px 0; }
    .resumen-total { display:flex; justify-content:space-between; align-items:baseline; }
    .resumen-total .lbl { font-size:.7rem; letter-spacing:1.5px; text-transform:uppercase; color:var(--muted); font-weight:600; }
    .resumen-total .amt { font-family:var(--font-display); font-size:1.5rem; color:var(--terra); font-weight:600; }
    .resumen-notas { font-size:.7rem; color:var(--muted); line-height:1.9; margin-top:16px; text-align:center; }
  </style>
</head>
<body>

<header class="navbar">
  <div class="brand">Mercado<span>Red</span></div>
  <nav>
    <a href="<%= ctx %>/">Inicio</a>
    <a href="<%= ctx %>/producto?accion=listar">Catalogo</a>
    <a href="<%= ctx %>/orden?accion=listar">Mis Pedidos</a>
    <div class="user-info">
      <span class="rol-badge rol-<%= rol %>"><%= rol %></span>
      <span style="color:var(--muted);">Hola, <strong style="color:var(--dark);"><%= nombre %></strong></span>
      <a href="<%= ctx %>/logout" class="btn btn-secondary btn-sm">Salir</a>
    </div>
  </nav>
</header>

<div class="container">

  <!-- Wizard de pasos -->
  <div class="wizard">
    <div class="wizard-step">
      <div class="step-circle activo">1</div>
      <div class="step-info"><span class="step-num">Paso 1</span><span class="step-name">Carrito</span></div>
    </div>
    <div class="wizard-step">
      <div class="step-circle">2</div>
      <div class="step-info"><span class="step-num">Paso 2</span><span class="step-name inactivo">Direccion</span></div>
    </div>
    <div class="wizard-step">
      <div class="step-circle">3</div>
      <div class="step-info"><span class="step-num">Paso 3</span><span class="step-name inactivo">Pago</span></div>
    </div>
  </div>

  <% if ("agregado".equals(msg)) { %>
    <div class="alert alert-success" style="margin-bottom:20px;">Producto agregado al carrito.</div>
  <% } %>
  <% if ("vacio".equals(err)) { %>
    <div class="alert alert-warning" style="margin-bottom:20px;">Tu carrito esta vacio. Agrega productos antes de continuar.</div>
  <% } %>

  <% if (carrito.isEmpty()) { %>
    <div class="empty-state">
      <div class="icon">[ ]</div>
      <h3>Tu carrito esta vacio</h3>
      <p>Explora el catalogo y agrega los productos que quieras comprar.</p>
      <a href="<%= ctx %>/producto?accion=listar" class="btn btn-primary">Ver catalogo</a>
    </div>
  <% } else { %>
  <div class="carrito-layout">

    <!-- Items del carrito (CA025) -->
    <div class="carrito-card">
      <div class="carrito-head">
        <h3>Carrito · <%= carrito.size() %> <%= carrito.size()==1?"producto":"productos" %></h3>
        <a href="<%= ctx %>/carrito?accion=vaciar"
           onclick="return confirm('Vaciar el carrito?')">Vaciar carrito</a>
      </div>

      <% for (CarritoItem item : carrito) { %>
      <div class="carrito-item">
        <div class="item-inicial">
          <%= item.getTitulo() != null && !item.getTitulo().isEmpty()
              ? String.valueOf(item.getTitulo().charAt(0)).toUpperCase() : "P" %>
        </div>
        <div>
          <p class="item-cat"><%= item.getCategoria() %></p>
          <p class="item-name"><%= item.getTitulo() %></p>
          <p class="item-price">$ <%= String.format("%,.0f", item.getPrecioUnitario()) %> COP / unidad &nbsp;·&nbsp; Stock: <%= item.getStockDisponible() %></p>
        </div>

        <!-- Cantidad con auto-submit -->
        <form method="post" action="<%= ctx %>/carrito" id="form-<%= item.getIdProducto() %>">
          <input type="hidden" name="accion"     value="actualizar">
          <input type="hidden" name="idProducto" value="<%= item.getIdProducto() %>">
          <div class="qty-control">
            <button type="button" class="qty-btn"
                    onclick="cambiarCant(<%= item.getIdProducto() %>, -1, <%= item.getStockDisponible() %>)">-</button>
            <input type="number" name="cantidad" class="qty-input"
                   id="qty-<%= item.getIdProducto() %>"
                   value="<%= item.getCantidad() %>"
                   min="1" max="<%= item.getStockDisponible() %>"
                   onchange="this.form.submit()">
            <button type="button" class="qty-btn"
                    onclick="cambiarCant(<%= item.getIdProducto() %>, +1, <%= item.getStockDisponible() %>)">+</button>
          </div>
        </form>

        <div class="item-acciones">
          <span class="item-subtotal">$ <%= String.format("%,.0f", item.getSubtotal()) %></span>
          <a href="<%= ctx %>/carrito?accion=eliminar&id=<%= item.getIdProducto() %>"
             class="item-del"
             onclick="return confirm('Quitar este producto del carrito?')">Quitar</a>
        </div>
      </div>
      <% } %>
    </div>

    <!-- Resumen lateral (CA026) -->
    <aside class="resumen-card">
      <div class="resumen-head">Resumen de compra</div>
      <div class="resumen-body">
        <% for (CarritoItem item : carrito) { %>
        <div class="resumen-row">
          <span><%= item.getTitulo() %> x<%= item.getCantidad() %></span>
          <strong>$ <%= String.format("%,.0f", item.getSubtotal()) %></strong>
        </div>
        <% } %>
        <div class="resumen-div"></div>
        <div class="resumen-total">
          <span class="lbl">Total</span>
          <span class="amt">$ <%= String.format("%,.0f", total) %></span>
        </div>
        <p style="font-size:.68rem;color:var(--muted);text-align:right;margin-top:4px;">COP · IVA incluido</p>

        <div style="margin-top:22px; display:flex; flex-direction:column; gap:9px;">
          <a href="<%= ctx %>/carrito?accion=checkout" class="btn btn-primary" style="justify-content:center;">
            Continuar — Direccion de envio
          </a>
          <a href="<%= ctx %>/producto?accion=listar" class="btn btn-secondary" style="justify-content:center;">
            Seguir comprando
          </a>
        </div>

        <div class="resumen-notas">
          Pago 100% seguro<br>
          Envio a todo Colombia<br>
          Fondos protegidos hasta recibir
        </div>
      </div>
    </aside>
  </div>
  <% } %>
</div>

<footer class="footer">
  <div class="footer-brand">MercadoRed</div>
  <p>© 2026 MercadoRed S.A.S. · Bogota, Colombia</p>
</footer>

<script>
function cambiarCant(id, delta, maxStock) {
  var input = document.getElementById('qty-' + id);
  var val = parseInt(input.value) + delta;
  if (val < 1)        val = 1;
  if (val > maxStock) val = maxStock;
  input.value = val;
  document.getElementById('form-' + id).submit();
}
</script>
</body>
</html>
