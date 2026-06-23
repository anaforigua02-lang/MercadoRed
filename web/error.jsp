<%-- 
    Document   : error
    Created on : 4/04/2026, 11:26:46 p. m.
    Author     : annym
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String error = (String) request.getAttribute("error");
    String ctx   = request.getContextPath();
    if (error == null) error = "Error inesperado del sistema.";
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>MercadoRed — Error</title>
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
</head>
<body>
<header class="navbar">
  <div class="brand">Mercado<span>Red</span></div>
</header>
<div class="container">
  <div style="text-align:center;padding:100px 20px;">
    <div style="font-size:5rem;margin-bottom:24px;">🌿</div>
    <h2 style="font-family:var(--font-display);font-size:2rem;font-weight:400;color:var(--dark);margin-bottom:12px;">
      Algo salió mal
    </h2>
    <p style="color:var(--muted);max-width:480px;margin:0 auto 32px;font-size:.95rem;">
      <%= error %>
    </p>
    <a href="<%= ctx %>/producto?accion=listar" class="btn btn-primary">← Volver al catálogo</a>
  </div>
</div>
<footer class="footer">
  <div class="footer-brand">MercadoRed</div>
  <p>© 2026 MercadoRed S.A.S. · Bogotá, Colombia</p>
</footer>
</body>
</html>
