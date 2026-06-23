<%-- 
    Document   : login
    Created on : 8/04/2026, 9:51:33 p. m.
    Author     : annym
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String error = (String) request.getAttribute("error");
    String msg   = request.getParameter("msg");
    String ctx   = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MercadoRed — Iniciar sesión</title>
    <link rel="stylesheet" href="<%= ctx %>/estilo.css">
    <style>
        .login-wrap { min-height:100vh; display:flex; align-items:center; justify-content:center; background:var(--cream); }
        .login-card { background:var(--white); border-radius:20px; padding:48px 40px; width:100%; max-width:420px; box-shadow:var(--shadow); }
        .brand { font-family:var(--font-display); font-size:2rem; color:var(--dark); text-align:center; margin-bottom:8px; }
        .brand span { color:var(--accent); font-style:italic; }
        .tagline { text-align:center; color:var(--muted); font-size:.85rem; margin-bottom:32px; }
        .form-group { margin-bottom:20px; }
        .form-group label { display:block; font-size:.72rem; font-weight:600; letter-spacing:1.5px; text-transform:uppercase; color:var(--muted); margin-bottom:8px; }
        .form-group input { width:100%; padding:12px 16px; border:1.5px solid var(--sand); border-radius:6px; font-size:.95rem; color:var(--dark); background:var(--cream); outline:none; transition:border-color .2s; box-sizing:border-box; }
        .form-group input:focus { border-color:var(--terra); background:#fff; }
        .btn-block { width:100%; padding:14px; font-size:.85rem; justify-content:center; margin-top:8px; }
        .divider { border:none; border-top:1px solid var(--sand); margin:24px 0; }
        .prueba { background:var(--sand); border-radius:8px; padding:16px; font-size:.8rem; color:var(--muted); }
        .prueba strong { color:var(--dark); display:block; margin-bottom:8px; font-size:.82rem; }
        .prueba p { margin:4px 0; }
        .registro-link { text-align:center; margin-top:20px; font-size:.85rem; color:var(--muted); }
        .registro-link a { color:var(--terra); font-weight:700; text-decoration:none; }
        .registro-link a:hover { text-decoration:underline; }
    </style>
</head>
<body>
<div class="login-wrap">
  <div class="login-card">

    <div class="brand">Mercado<span>Red</span></div>
    <p class="tagline">Marketplace colombiano · Bogotá</p>

    <% if ("logout".equals(msg)) { %>
      <div class="alert alert-success" style="margin-bottom:20px;">Sesión cerrada correctamente.</div>
    <% } %>
    <% if ("registrado".equals(msg)) { %>
      <div class="alert alert-success" style="margin-bottom:20px;">✅ ¡Cuenta activada! Ya puedes iniciar sesión.</div>
    <% } %>
    <% if (error != null) { %>
      <div class="alert alert-error" style="margin-bottom:20px;"><%= error %></div>
    <% } %>

    <form action="<%= ctx %>/login" method="post">
      <div class="form-group">
        <label>Correo electrónico</label>
        <input type="email" name="correo" required placeholder="correo@ejemplo.com" autocomplete="email"/>
      </div>
      <div class="form-group">
        <label>Contraseña</label>
        <input type="password" name="contrasena" required placeholder="••••••••" autocomplete="current-password"/>
      </div>
      <button type="submit" class="btn btn-primary btn-block">Iniciar sesión →</button>
    </form>

    <hr class="divider"/>

 

    <p class="registro-link">
      ¿No tienes cuenta? <a href="<%= ctx %>/registro">Regístrate gratis</a>
    </p>

  </div>
</div>
</body>
</html>
