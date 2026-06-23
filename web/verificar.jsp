<%-- 
    Document   : verificar
    Created on : 9/04/2026, 10:53:22 a. m.
    Author     : annym
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String error   = (String)  request.getAttribute("error");
    String nombre  = (String)  request.getAttribute("nombre");
    String correo  = (String)  request.getAttribute("correo");
    Boolean esLogin = (Boolean) request.getAttribute("esLogin");
    String ctx     = request.getContextPath();

    if (nombre  == null) nombre  = "";
    if (correo  == null) correo  = "";
    if (esLogin == null) esLogin = false;

    String formAction = esLogin ? ctx + "/login"   : ctx + "/registro";
    String pasoValor  = esLogin ? "verificar"      : "2";
    String volverUrl  = esLogin ? ctx + "/login"   : ctx + "/registro";
    String contexto   = esLogin ? "inicio de sesión" : "registro";
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MercadoRed — Verificar identidad</title>
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <style>
    body { background:var(--cream); }
    .wrap { min-height:100vh; display:flex; align-items:center; justify-content:center; padding:40px 20px; }
    .card { background:var(--white); border-radius:20px; padding:48px 44px; width:100%; max-width:460px; box-shadow:var(--shadow); text-align:center; }
    .brand { font-family:var(--font-display); font-size:1.8rem; color:var(--dark); margin-bottom:4px; }
    .brand span { color:var(--accent); font-style:italic; }

    .mail-box {
        background:#f0f4ff;
        border:2px solid #d0dcff;
        border-radius:14px;
        padding:24px;
        margin:28px 0;
        text-align:left;
    }
    .mail-header { display:flex; align-items:center; gap:12px; margin-bottom:14px; }
    .mail-icon   { width:44px; height:44px; background:#1F3864; border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:1.3rem; flex-shrink:0; }
    .mail-info   { display:flex; flex-direction:column; }
    .mail-from   { font-weight:700; font-size:.88rem; color:#1F3864; }
    .mail-to     { font-size:.78rem; color:var(--muted); }
    .mail-body   { font-size:.9rem; color:#333; line-height:1.6; }
    .mail-body strong { color:#1F3864; }

    .cod-input input {
        width:100%; padding:16px; text-align:center; font-size:1.8rem;
        font-weight:900; letter-spacing:10px; border:2px solid var(--sand);
        border-radius:10px; background:var(--cream); outline:none;
        font-family:monospace; transition:border-color .2s; box-sizing:border-box;
        margin:20px 0 8px;
    }
    .cod-input input:focus { border-color:var(--terra); background:#fff; }
    .hint  { color:var(--muted); font-size:.8rem; margin-bottom:18px; }
    .btn-block { width:100%; justify-content:center; padding:14px; font-size:.88rem; }
    .volver { display:block; margin-top:16px; color:var(--muted); font-size:.82rem; text-decoration:none; }
    .volver:hover { color:var(--dark); }
    .spam-tip { background:#fff8e1; border-radius:8px; padding:10px 14px; font-size:.78rem; color:#8b6000; margin-top:16px; text-align:left; }
  </style>
</head>
<body>
<div class="wrap">
  <div class="card">

    <div class="brand">Mercado<span>Red</span></div>
    <p style="color:var(--muted);font-size:.85rem;margin:4px 0 0;">Verificación de identidad</p>

    <% if (error != null) { %>
      <div class="alert alert-error" style="margin-top:20px;text-align:left;"><%= error %></div>
    <% } %>

    <%-- Info del correo enviado --%>
    <div class="mail-box">
      <div class="mail-header">
        <div class="mail-icon">✉️</div>
        <div class="mail-info">
          <span class="mail-from">MercadoRed S.A.S &lt;annymendez2005@gmail.com&gt;</span>
          <span class="mail-to">Para: <%= correo %></span>
        </div>
      </div>
      <div class="mail-body">
        Hola, <strong><%= nombre %></strong> 👋<br><br>
        Enviamos un código de 6 dígitos a tu correo para confirmar tu <strong><%= contexto %></strong>.<br><br>
        📬 Revisa tu bandeja de entrada — el asunto es:<br>
        <strong>"🔐 Tu código de verificación — MercadoRed"</strong>
      </div>
    </div>

    <p style="color:var(--dark);font-size:.9rem;font-weight:600;margin-bottom:2px;">
      Ingresa el código de 6 dígitos
    </p>
    <p class="hint">Cópialo desde el correo que te enviamos</p>

    <form action="<%= formAction %>" method="post">
      <input type="hidden" name="paso" value="<%= pasoValor %>"/>
      <div class="cod-input">
        <input type="text" name="codigo" required
               maxlength="6" minlength="6"
               placeholder="000000"
               autocomplete="one-time-code"
               autofocus/>
      </div>
      <button type="submit" class="btn btn-primary btn-block">
        ✅ Confirmar y continuar
      </button>
    </form>

    <div class="spam-tip">
      ⚠️ ¿No ves el correo? Revisa la carpeta de <strong>spam o correo no deseado</strong>. El código expira en <strong>10 minutos</strong>.
    </div>

    <a href="<%= volverUrl %>" class="volver">← Volver</a>

  </div>
</div>
</body>
</html>

