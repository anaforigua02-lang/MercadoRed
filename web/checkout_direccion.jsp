<%-- 
    Document   : checkout_direccion
    Created on : 27/04/2026, 1:34:52 p. m.
    Author     : annym
--%>

<%--  Modulo 4 - Paso 2: Direccion de envio (RF012 / CA027-CA028) --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.CarritoItem, model.Persona" %>
<%
    List<CarritoItem> carrito = (List<CarritoItem>) request.getAttribute("carrito");
    if (carrito == null) carrito = new java.util.ArrayList<>();
    Persona usuario = (Persona) session.getAttribute("usuario");
    String  nombre  = usuario != null ? usuario.getNombre() : "";
    String  rol     = usuario != null ? usuario.getTipo()   : "";
    String  ctx     = request.getContextPath();
    String  error   = (String) request.getAttribute("error");

    String prevDir = (String) session.getAttribute("envio_direccion");
    String prevCiu = (String) session.getAttribute("envio_ciudad");
    String prevDep = (String) session.getAttribute("envio_departamento");
    if (prevDir == null) prevDir = "";
    if (prevCiu == null) prevCiu = "";
    if (prevDep == null) prevDep = "";

    double total = 0;
    for (CarritoItem i : carrito) total += i.getSubtotal();
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>MercadoRed — Direccion de envio</title>
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <style>
    .user-info { display:flex; align-items:center; gap:14px; font-size:.82rem; }
    .rol-badge  { padding:3px 10px; border-radius:20px; font-size:.68rem; font-weight:700; letter-spacing:1px; text-transform:uppercase; }
    .rol-comprador { background:#c8a882; color:#2c2217; }

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
      background:var(--white); color:var(--muted);
    }
    .step-circle.activo { background:var(--dark);  color:var(--cream); border-color:var(--dark); }
    .step-circle.listo  { background:var(--green); color:#fff; border-color:var(--green); }
    .step-info { display:flex; flex-direction:column; }
    .step-num  { font-size:.6rem; letter-spacing:2px; text-transform:uppercase; color:var(--muted); }
    .step-name { font-size:.84rem; font-weight:600; color:var(--dark); }
    .step-name.inactivo { color:var(--muted); font-weight:400; }

    .checkout-layout { display:grid; grid-template-columns:1fr 300px; gap:36px; align-items:start; padding-bottom:80px; }

    .form-card { background:var(--white); border-radius:var(--radius); box-shadow:var(--shadow-sm); overflow:hidden; }
    .form-card-head { background:var(--dark); color:var(--cream); padding:16px 24px; font-family:var(--font-body); font-size:.7rem; font-weight:600; letter-spacing:2.5px; text-transform:uppercase; }
    .form-card-body { padding:28px 24px; }

    .form-group { display:flex; flex-direction:column; margin-bottom:18px; }
    .form-group label { font-size:.62rem; font-weight:700; letter-spacing:2px; text-transform:uppercase; color:var(--muted); margin-bottom:7px; }
    .form-group input, .form-group select {
      padding:10px 13px; border:1.5px solid var(--sand); border-radius:var(--radius-sm);
      font-family:var(--font-body); font-size:.9rem; color:var(--dark);
      background:var(--cream); outline:none; transition:border-color .2s;
    }
    .form-group input:focus, .form-group select:focus { border-color:var(--terra); background:var(--white); }
    .form-group input::placeholder { color:var(--warm); }
    .form-row2 { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
    .requerido { color:var(--red); }

    .select-custom { appearance:none; background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'%3E%3Cpath d='M1 1l5 5 5-5' stroke='%238b6247' stroke-width='1.5' fill='none' stroke-linecap='round'/%3E%3C/svg%3E"); background-repeat:no-repeat; background-position:right 12px center; padding-right:32px; }

    .mini-resumen { background:var(--white); border-radius:var(--radius); box-shadow:var(--shadow-sm); overflow:hidden; position:sticky; top:88px; }
    .mini-head { background:var(--terra); color:var(--cream); padding:16px 22px; font-family:var(--font-body); font-size:.7rem; font-weight:600; letter-spacing:2.5px; text-transform:uppercase; }
    .mini-body { padding:20px 22px; }
    .mini-row  { display:flex; justify-content:space-between; margin-bottom:9px; font-size:.84rem; color:var(--muted); }
    .mini-row strong { color:var(--dark); }
    .mini-div  { height:1px; background:var(--sand); margin:13px 0; }
    .mini-total { display:flex; justify-content:space-between; align-items:baseline; }
    .mini-total .lbl { font-size:.68rem; letter-spacing:1.5px; text-transform:uppercase; color:var(--muted); font-weight:600; }
    .mini-total .amt { font-family:var(--font-display); font-size:1.4rem; color:var(--terra); }
  </style>
</head>
<body>

<header class="navbar">
  <div class="brand">Mercado<span>Red</span></div>
  <nav>
    <a href="<%= ctx %>/">Inicio</a>
    <a href="<%= ctx %>/producto?accion=listar">Catalogo</a>
    <a href="<%= ctx %>/carrito?accion=ver">Carrito (<%= carrito.size() %>)</a>
    <div class="user-info">
      <span class="rol-badge rol-<%= rol %>"><%= rol %></span>
      <span style="color:var(--muted);">Hola, <strong style="color:var(--dark);"><%= nombre %></strong></span>
      <a href="<%= ctx %>/logout" class="btn btn-secondary btn-sm">Salir</a>
    </div>
  </nav>
</header>

<div class="container">
  <div class="wizard">
    <div class="wizard-step">
      <div class="step-circle listo">v</div>
      <div class="step-info"><span class="step-num">Paso 1</span><span class="step-name">Carrito</span></div>
    </div>
    <div class="wizard-step">
      <div class="step-circle activo">2</div>
      <div class="step-info"><span class="step-num">Paso 2</span><span class="step-name">Direccion</span></div>
    </div>
    <div class="wizard-step">
      <div class="step-circle">3</div>
      <div class="step-info"><span class="step-num">Paso 3</span><span class="step-name inactivo">Pago</span></div>
    </div>
  </div>

  <% if (error != null) { %>
    <div class="alert alert-error" style="margin-bottom:20px;"><%= error %></div>
  <% } %>

  <div class="checkout-layout">
    <div class="form-card">
      <div class="form-card-head">Direccion de entrega</div>
      <div class="form-card-body">
        <p style="font-size:.86rem; color:var(--muted); margin-bottom:24px;">
          Los campos marcados con <span class="requerido">*</span> son obligatorios.
        </p>

        <form method="post" action="<%= ctx %>/carrito">
          <input type="hidden" name="accion" value="confirmarDir">

          <div class="form-group">
            <label>Direccion completa <span class="requerido">*</span></label>
            <input type="text" name="direccion" required
                   placeholder="Ej: Cra 7 No. 32-16, Apto 401"
                   value="<%= prevDir %>">
          </div>

          <div class="form-row2">
            <div class="form-group">
              <label>Ciudad <span class="requerido">*</span></label>
              <input type="text" name="ciudad" required
                     placeholder="Ej: Bogota" value="<%= prevCiu %>">
            </div>
            <div class="form-group">
              <label>Departamento</label>
              <select name="departamento" class="select-custom">
                <option value="">Seleccionar...</option>
                <% String[] deptos = {"Amazonas","Antioquia","Arauca","Atlantico","Bolivar","Boyaca",
                   "Caldas","Caqueta","Casanare","Cauca","Cesar","Choco","Cordoba","Cundinamarca",
                   "Guainia","Guaviare","Huila","La Guajira","Magdalena","Meta","Narino",
                   "Norte de Santander","Putumayo","Quindio","Risaralda","San Andres","Santander",
                   "Sucre","Tolima","Valle del Cauca","Vaupes","Vichada"};
                   for (String d : deptos) { %>
                <option value="<%= d %>" <%= d.equals(prevDep) ? "selected" : "" %>><%= d %></option>
                <% } %>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label>Indicaciones adicionales</label>
            <input type="text" name="adicional"
                   placeholder="Ej: Conjunto residencial, portar cedula">
          </div>

          <div style="display:flex; gap:10px; margin-top:8px;">
            <a href="<%= ctx %>/carrito?accion=ver" class="btn btn-secondary">Volver al carrito</a>
            <button type="submit" class="btn btn-primary">
              Continuar — Metodo de pago
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Mini resumen -->
    <aside class="mini-resumen">
      <div class="mini-head">Tu pedido</div>
      <div class="mini-body">
        <% for (CarritoItem item : carrito) { %>
        <div class="mini-row">
          <span><%= item.getTitulo() %> x<%= item.getCantidad() %></span>
          <strong>$ <%= String.format("%,.0f", item.getSubtotal()) %></strong>
        </div>
        <% } %>
        <div class="mini-div"></div>
        <div class="mini-total">
          <span class="lbl">Total</span>
          <span class="amt">$ <%= String.format("%,.0f", total) %></span>
        </div>
        <p style="font-size:.68rem;color:var(--muted);text-align:right;margin-top:4px;">COP</p>
        <div style="margin-top:16px;padding-top:14px;border-top:1px solid var(--sand);font-size:.73rem;color:var(--muted);line-height:1.9;text-align:center;">
          Pago seguro<br>Envio a todo Colombia<br>Garantia de compra
        </div>
      </div>
    </aside>
  </div>
</div>

<footer class="footer">
  <div class="footer-brand">MercadoRed</div>
  <p>© 2026 MercadoRed S.A.S. · Bogota, Colombia</p>
</footer>
</body>
</html>

