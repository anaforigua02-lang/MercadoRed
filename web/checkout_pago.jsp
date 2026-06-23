<%-- 
    Document   : checkout_pago
    Created on : 27/04/2026, 1:33:52 p. m.
    Author     : annym
--%>
<%--  Modulo 4 - Paso 3: Metodo de pago (RF013 / CA029-CA030) --%>
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

    String envDir = (String) session.getAttribute("envio_direccion");
    String envCiu = (String) session.getAttribute("envio_ciudad");
    String envDep = (String) session.getAttribute("envio_departamento");
    if (envDir == null) envDir = "";
    if (envCiu == null) envCiu = "";
    if (envDep == null) envDep = "";
    String dirCompleta = envDir + (envCiu.isEmpty() ? "" : ", " + envCiu)
                                + (envDep.isEmpty() ? "" : " — " + envDep);

    double subtotal = 0;
    for (CarritoItem i : carrito) subtotal += i.getSubtotal();
    double envio = 8900;
    double total = subtotal + envio;

    // Metodos de pago habilitados (CA029)
    String[][] metodos = {
        {"tarjeta_credito", "Tarjeta credito",  "Visa, Mastercard, Amex"},
        {"tarjeta_debito",  "Tarjeta debito",   "Debito bancario nacional"},
        {"pse",             "PSE",              "Transferencia bancaria en linea"},
        {"nequi",           "Nequi",            "Billetera digital Bancolombia"},
        {"daviplata",       "Daviplata",        "Billetera Davivienda"},
        {"contraentrega",   "Contra entrega",   "Pago en efectivo al recibir"}
    };
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>MercadoRed — Metodo de pago</title>
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

    .pago-layout { display:grid; grid-template-columns:1fr 300px; gap:36px; align-items:start; padding-bottom:80px; }

    .pago-card { background:var(--white); border-radius:var(--radius); box-shadow:var(--shadow-sm); overflow:hidden; }
    .pago-head { background:var(--dark); color:var(--cream); padding:16px 24px; font-family:var(--font-body); font-size:.7rem; font-weight:600; letter-spacing:2.5px; text-transform:uppercase; }
    .pago-body { padding:28px 24px; }

    /* Caja de direccion confirmada */
    .dir-confirmada {
      background:var(--sand); border-radius:var(--radius-sm);
      padding:14px 18px; margin-bottom:24px;
      display:flex; align-items:flex-start; justify-content:space-between; gap:12px;
    }
    .dir-titulo { font-size:.6rem; letter-spacing:2px; text-transform:uppercase; color:var(--muted); font-weight:700; margin-bottom:4px; }
    .dir-texto  { font-size:.86rem; color:var(--dark); line-height:1.5; }
    .dir-change { font-size:.72rem; color:var(--terra); text-decoration:none; white-space:nowrap; transition:color .2s; }
    .dir-change:hover { color:var(--dark); }

    /* Grid de metodos (CA029) */
    .metodos-grid { display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:24px; }
    .metodo-card {
      border:2px solid var(--sand); border-radius:var(--radius);
      padding:16px 14px; cursor:pointer; transition:all .2s;
      background:var(--white); display:flex; align-items:center; gap:12px;
    }
    .metodo-card:hover { border-color:var(--warm); background:var(--cream); }
    .metodo-card.sel   { border-color:var(--terra); background:var(--cream); box-shadow:0 0 0 3px rgba(139,98,71,.1); }
    .metodo-card input[type="radio"] { display:none; }
    .metodo-inicial {
      width:36px; height:36px; border-radius:8px;
      background:var(--sand); color:var(--terra);
      display:flex; align-items:center; justify-content:center;
      font-family:var(--font-display); font-size:.9rem; font-weight:700;
      flex-shrink:0;
    }
    .metodo-nombre { font-weight:700; font-size:.86rem; color:var(--dark); display:block; }
    .metodo-desc   { font-size:.7rem; color:var(--muted); margin-top:2px; display:block; }

    /* Resumen final */
    .resumen-final { background:var(--white); border-radius:var(--radius); box-shadow:var(--shadow-sm); overflow:hidden; position:sticky; top:88px; }
    .res-head { background:var(--terra); color:var(--cream); padding:16px 22px; font-family:var(--font-body); font-size:.7rem; font-weight:600; letter-spacing:2.5px; text-transform:uppercase; }
    .res-body { padding:20px 22px; }
    .res-row  { display:flex; justify-content:space-between; margin-bottom:9px; font-size:.84rem; color:var(--muted); }
    .res-row strong { color:var(--dark); }
    .res-div  { height:1px; background:var(--sand); margin:13px 0; }
    .res-total { display:flex; justify-content:space-between; align-items:baseline; }
    .res-total .lbl { font-size:.68rem; letter-spacing:1.5px; text-transform:uppercase; color:var(--muted); font-weight:600; }
    .res-total .amt { font-family:var(--font-display); font-size:1.4rem; color:var(--terra); }
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
      <div class="step-circle listo">v</div>
      <div class="step-info"><span class="step-num">Paso 2</span><span class="step-name">Direccion</span></div>
    </div>
    <div class="wizard-step">
      <div class="step-circle activo">3</div>
      <div class="step-info"><span class="step-num">Paso 3</span><span class="step-name">Pago</span></div>
    </div>
  </div>

  <% if (error != null) { %>
    <div class="alert alert-error" style="margin-bottom:20px;"><%= error %></div>
  <% } %>

  <div class="pago-layout">
    <div class="pago-card">
      <div class="pago-head">Metodo de pago</div>
      <div class="pago-body">

        <!-- Direccion confirmada -->
        <div class="dir-confirmada">
          <div>
            <p class="dir-titulo">Entrega en</p>
            <p class="dir-texto"><%= dirCompleta.isEmpty() ? "Sin direccion" : dirCompleta %></p>
          </div>
          <a href="<%= ctx %>/carrito?accion=checkout" class="dir-change">Cambiar</a>
        </div>

        <form method="post" action="<%= ctx %>/carrito" id="pagoForm">
          <input type="hidden" name="accion" value="pagar">

          <p style="font-size:.62rem; letter-spacing:2px; text-transform:uppercase; color:var(--muted); font-weight:700; margin-bottom:14px;">
            Selecciona un medio de pago <span style="color:var(--red);">*</span>
          </p>

          <!-- CA029: medios habilitados -->
          <div class="metodos-grid">
            <% for (String[] m : metodos) { %>
            <label class="metodo-card" onclick="marcar(this)">
              <input type="radio" name="metodoPago" value="<%= m[0] %>" required>
              <div class="metodo-inicial"><%= m[1].substring(0,1).toUpperCase() %></div>
              <div>
                <span class="metodo-nombre"><%= m[1] %></span>
                <span class="metodo-desc"><%= m[2] %></span>
              </div>
            </label>
            <% } %>
          </div>

          <div style="display:flex; gap:10px; flex-wrap:wrap;">
            <a href="<%= ctx %>/carrito?accion=checkout" class="btn btn-secondary">Volver a direccion</a>
            <button type="submit" class="btn btn-primary" onclick="return validarPago()">
              Confirmar y pagar · $ <%= String.format("%,.0f", total) %> COP
            </button>
          </div>

          <p style="font-size:.7rem; color:var(--muted); margin-top:14px; text-align:center;">
            Todos los pagos son procesados de forma segura.
          </p>
        </form>
      </div>
    </div>

    <!-- Resumen final (CA026) -->
    <aside class="resumen-final">
      <div class="res-head">Resumen del pedido</div>
      <div class="res-body">
        <% for (CarritoItem item : carrito) { %>
        <div class="res-row">
          <span><%= item.getTitulo() %> x<%= item.getCantidad() %></span>
          <strong>$ <%= String.format("%,.0f", item.getSubtotal()) %></strong>
        </div>
        <% } %>
        <div class="res-div"></div>
        <div class="res-row"><span>Subtotal</span><strong>$ <%= String.format("%,.0f", subtotal) %></strong></div>
        <div class="res-row"><span>Envio</span><strong>$ <%= String.format("%,.0f", envio) %></strong></div>
        <div class="res-div"></div>
        <div class="res-total">
          <span class="lbl">Total</span>
          <span class="amt">$ <%= String.format("%,.0f", total) %></span>
        </div>
        <p style="font-size:.66rem;color:var(--muted);text-align:right;margin-top:4px;">COP · IVA incluido</p>
        <% if (!dirCompleta.isEmpty()) { %>
        <div style="margin-top:14px;padding-top:12px;border-top:1px solid var(--sand);font-size:.76rem;color:var(--muted);">
          <strong style="color:var(--dark);display:block;margin-bottom:4px;">Enviando a:</strong>
          <%= dirCompleta %>
        </div>
        <% } %>
      </div>
    </aside>
  </div>
</div>

<footer class="footer">
  <div class="footer-brand">MercadoRed</div>
  <p>© 2026 MercadoRed S.A.S. · Bogota, Colombia</p>
</footer>

<script>
function marcar(label) {
  document.querySelectorAll('.metodo-card').forEach(c => c.classList.remove('sel'));
  label.classList.add('sel');
}
function validarPago() {
  if (!document.querySelector('[name="metodoPago"]:checked')) {
    alert('Selecciona un metodo de pago para continuar.');
    return false;
  }
  return confirm('Confirmar la compra?');
}
</script>
</body>
</html>

