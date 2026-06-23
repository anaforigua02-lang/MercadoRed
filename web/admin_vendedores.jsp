<%-- 
    Document   : admin_vendedores
    Created on : 26/04/2026, 11:24:16 p. m.
    Author     : annym
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.Vendedor, model.Persona" %>
<%
    List<Vendedor> vendedores = (List<Vendedor>) request.getAttribute("vendedores");
    String msg   = request.getParameter("msg");
    String ctx   = request.getContextPath();
    Persona usuario = (Persona) session.getAttribute("usuario");
    String  nombre  = usuario != null ? usuario.getNombre() : "";
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MercadoRed — Panel Admin</title>
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <style>
    .user-info { display:flex; align-items:center; gap:16px; font-size:.82rem; }
    .rol-badge-admin { padding:3px 10px; border-radius:20px; font-size:.68rem; font-weight:700; letter-spacing:1px; text-transform:uppercase; background:#2c2217; color:#f5f0e8; }
    .tabla { width:100%; border-collapse:collapse; background:var(--white); border-radius:12px; overflow:hidden; box-shadow:var(--shadow-sm); margin-bottom:60px; }
    .tabla thead th { background:var(--dark); color:var(--cream); padding:14px 18px; text-align:left; font-size:.78rem; letter-spacing:1px; text-transform:uppercase; }
    .tabla tbody td { padding:13px 18px; border-bottom:1px solid var(--sand); font-size:.88rem; vertical-align:middle; }
    .tabla tbody tr:hover { background:var(--cream); }
    .validado   { color:#2e7d32; font-weight:700; }
    .pendiente  { color:#e37400; font-weight:700; }
    .sancionado { color:#d93025; font-weight:700; }
    .doc-link   { color:var(--terra); font-size:.8rem; text-decoration:none; }
    .doc-link:hover { text-decoration:underline; }
  </style>
</head>
<body>

<header class="navbar">
  <div class="brand">Mercado<span>Red</span></div>
  <nav>
    <a href="<%= ctx %>/producto?accion=listar">Catálogo</a>
    <a href="<%= ctx %>/admin?accion=vendedores">Panel Admin</a>
    <a href="<%= ctx %>/orden?accion=listar">Pedidos</a>
    <div class="user-info">
      <span class="rol-badge-admin">admin</span>
      <span style="color:var(--muted);">Hola, <strong style="color:var(--dark);"><%= nombre %></strong></span>
      <a href="<%= ctx %>/logout" class="btn btn-secondary btn-sm">Salir</a>
    </div>
  </nav>
</header>

<div class="container">

  <div class="section-header">
    <div>
      <p class="sub">Panel de administración</p>
      <h2>🔍 Validación de Vendedores</h2>
    </div>
  </div>

  <% if ("validado".equals(msg)) { %>
    <div class="alert alert-success">✅ Identidad validada. El vendedor ya puede publicar productos.</div>
  <% } else if ("rechazado".equals(msg)) { %>
    <div class="alert alert-warning">⛔ Vendedor rechazado y cuenta sancionada.</div>
  <% } %>

  <% if (vendedores == null || vendedores.isEmpty()) { %>
    <div class="empty-state">
      <div class="icon">👥</div>
      <h3>No hay vendedores registrados</h3>
    </div>
  <% } else { %>
    <div style="overflow-x:auto;">
    <table class="tabla">
      <thead>
        <tr>
          <th>#</th>
          <th>Nombre</th>
          <th>Documento</th>
          <th>Correo</th>
          <th>Banco</th>
          <th>Doc. Digital</th>
          <th>Estado cuenta</th>
          <th>Identidad</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <% for (Vendedor v : vendedores) { %>
        <tr>
          <td><strong>#<%= v.getIdVendedor() %></strong></td>
          <td><strong><%= v.getNombre() %></strong></td>
          <td><%= v.getDocumento() %></td>
          <td style="font-size:.8rem;"><%= v.getCorreo() %></td>
          <td><%= v.getBanco() != null ? v.getBanco() : "—" %></td>
          <td>
            <% if (v.getDocumentoPath() != null && !v.getDocumentoPath().isEmpty()) { %>
              <a href="<%= ctx %>/<%= v.getDocumentoPath() %>" target="_blank" class="doc-link">
                📄 Ver documento
              </a>
            <% } else { %>
              <span style="color:var(--muted);font-size:.8rem;">Sin documento</span>
            <% } %>
          </td>
          <td>
            <span class="<%= v.getEstado() %>"><%= v.getEstado() %></span>
          </td>
          <td>
            <% if (v.isIdentidadValidada()) { %>
              <span class="validado">✅ Validada</span>
            <% } else { %>
              <span class="pendiente">⏳ Pendiente</span>
            <% } %>
          </td>
          <td style="display:flex;gap:6px;flex-wrap:wrap;">
            <% if (!v.isIdentidadValidada()) { %>
              <a href="<%= ctx %>/admin?accion=validar&id=<%= v.getIdVendedor() %>"
                 class="btn btn-sm btn-edit"
                 onclick="return confirm('¿Validar identidad de <%= v.getNombre() %>?')">
                 ✅ Validar
              </a>
              <a href="<%= ctx %>/admin?accion=rechazar&id=<%= v.getIdVendedor() %>"
                 class="btn btn-sm btn-delete"
                 onclick="return confirm('¿Rechazar y sancionar a <%= v.getNombre() %>?')">
                 ❌ Rechazar
              </a>
            <% } else { %>
              <span style="color:var(--muted);font-size:.8rem;">Ya validado</span>
            <% } %>
          </td>
        </tr>
        <% } %>
      </tbody>
    </table>
    </div>
  <% } %>

</div>

<footer class="footer">
  <div class="footer-brand">MercadoRed</div>
  <p>© 2026 MercadoRed S.A.S. · Bogotá, Colombia</p>
</footer>
</body>
</html>
