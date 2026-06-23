<%-- 
    Document   : formulario
    Created on : 4/04/2026, 11:40:01 p. m.
    Author     : annym
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Producto, model.Persona" %>
<%
    Producto p   = (Producto) request.getAttribute("producto");
    boolean  es  = (p != null);
    String   ctx = request.getContextPath();

    Persona usuario = (Persona) session.getAttribute("usuario");
    String  rol     = usuario != null ? usuario.getTipo() : "";
    String  nombre  = usuario != null ? usuario.getNombre() : "";

    String titulo            = es ? p.getTitulo()          : "";
    String descripcion       = es ? p.getDescripcion()     : "";
    String precio            = es ? String.valueOf(p.getPrecio()) : "";
    String stock             = es ? String.valueOf(p.getStock())  : "";
    String categoria         = es ? p.getCategoria()       : "";
    String imagenUrl         = es ? (p.getImagenUrl() != null ? p.getImagenUrl() : "") : "";
    String estadoProducto    = es ? p.getEstadoProducto()  : "nuevo";
    String visibilidad       = es ? p.getVisibilidad()     : "activo";
    String politicaDev       = es ? (p.getPoliticaDevolucion() != null ? p.getPoliticaDevolucion() : "") : "";
    String accion            = es ? "actualizar" : "guardar";
    String tituloPage        = es ? "Editar producto" : "Nuevo producto";
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MercadoRed — <%= tituloPage %></title>
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <style>
    .user-info { display:flex; align-items:center; gap:16px; font-size:.82rem; }
    .rol-badge { padding:3px 10px; border-radius:20px; font-size:.68rem; font-weight:700; letter-spacing:1px; text-transform:uppercase; }
    .rol-admin    { background:#2c2217; color:#f5f0e8; }
    .rol-vendedor { background:#8b6247; color:#fff; }

    /* Preview imagen */
    .img-preview-wrap { margin-top:10px; display:none; }
    .img-preview-wrap img { max-width:100%; max-height:200px; border-radius:8px; border:1.5px solid var(--sand); object-fit:cover; }
    .img-preview-wrap.visible { display:block; }
  </style>
  <script>
    function previewImagen(url) {
      var img  = document.getElementById('imgPreview');
      var wrap = document.getElementById('imgWrap');
      if (url && url.startsWith('http')) {
        img.src = url;
        img.onerror = function() { wrap.classList.remove('visible'); };
        img.onload  = function() { wrap.classList.add('visible'); };
      } else {
        wrap.classList.remove('visible');
      }
    }
    window.onload = function() {
      var url = document.getElementById('imagenUrl').value;
      if (url) previewImagen(url);
    };
  </script>
</head>
<body>

<header class="navbar">
  <div class="brand">Mercado<span>Red</span></div>
  <nav>
    <a href="<%= ctx %>/producto?accion=listar">← Volver al catálogo</a>
    <div class="user-info">
      <span class="rol-badge rol-<%= rol %>"><%= rol %></span>
      <span style="color:var(--muted);">Hola, <strong style="color:var(--dark);"><%= nombre %></strong></span>
      <a href="<%= ctx %>/logout" class="btn btn-secondary btn-sm">Salir</a>
    </div>
  </nav>
</header>

<div class="container">
  <div class="form-page">

    <div>
      <form action="<%= ctx %>/producto" method="post" class="form-card">

        <input type="hidden" name="accion" value="<%= accion %>"/>
        <% if (es) { %>
          <input type="hidden" name="idProducto" value="<%= p.getIdProducto() %>"/>
        <% } %>

        <h1 class="form-title"><%= es ? "✏️ " : "🌿 " %><%= tituloPage %></h1>
        <p class="form-subtitle" style="margin-bottom:32px;">
          <%= es ? "Modifica los datos del producto #" + p.getIdProducto() : "Completa la información para publicar en el catálogo" %>
        </p>

        <%-- Título --%>
        <div class="form-group">
          <label for="titulo">Título del producto *</label>
          <input type="text" id="titulo" name="titulo" required maxlength="200"
                 placeholder="Ej: Laptop HP 15 pulgadas" value="<%= titulo %>"/>
        </div>

        <%-- Descripción --%>
        <div class="form-group">
          <label for="descripcion">Descripción detallada *</label>
          <textarea id="descripcion" name="descripcion" required rows="4"
                    placeholder="Describe el producto: características, materiales, dimensiones, colores..."><%= descripcion %></textarea>
        </div>

        <%-- Precio / Stock --%>
        <div class="form-row">
          <div class="form-group">
            <label for="precio">Precio (COP) *</label>
            <input type="number" id="precio" name="precio" required
                   min="0" step="0.01" placeholder="0.00" value="<%= precio %>"/>
          </div>
          <div class="form-group">
            <label for="stock">Unidades disponibles *</label>
            <input type="number" id="stock" name="stock" required
                   min="0" placeholder="0" value="<%= stock %>"/>
          </div>
        </div>

        <%-- Categoría --%>
        <div class="form-group">
          <label for="categoria">Categoría *</label>
          <select id="categoria" name="categoria" required>
            <option value="">— Selecciona una categoría —</option>
            <%
              String[] cats = {"Tecnología","Ropa","Muebles","Hogar","Deportes","Libros","Juguetes","Otro"};
              for (String cat : cats) {
            %>
              <option value="<%= cat %>" <%= cat.equals(categoria) ? "selected" : "" %>><%= cat %></option>
            <% } %>
          </select>
        </div>

        <%-- URL Imagen (CA019) --%>
        <div class="form-group">
          <label for="imagenUrl">URL de imagen <span style="color:var(--warm);font-weight:400;">(CA019 — opcional)</span></label>
          <input type="url" id="imagenUrl" name="imagenUrl"
                 placeholder="https://ejemplo.com/imagen.jpg"
                 value="<%= imagenUrl %>"
                 oninput="previewImagen(this.value)"
                 onchange="previewImagen(this.value)"/>
          <div id="imgWrap" class="img-preview-wrap <%= imagenUrl.isEmpty() ? "" : "visible" %>">
            <p style="font-size:.75rem;color:var(--muted);margin-bottom:6px;">Vista previa:</p>
            <img id="imgPreview" src="<%= imagenUrl %>" alt="Vista previa del producto"/>
          </div>
        </div>

        <%-- Estado / Visibilidad --%>
        <div class="form-row">
          <div class="form-group">
            <label for="estadoProducto">Estado del producto *</label>
            <select id="estadoProducto" name="estadoProducto" required>
              <option value="nuevo" <%= "nuevo".equals(estadoProducto) ? "selected" : "" %>>🆕 Nuevo</option>
              <option value="usado" <%= "usado".equals(estadoProducto) ? "selected" : "" %>>♻️ Usado</option>
            </select>
          </div>
          <div class="form-group">
            <label for="visibilidad">Visibilidad *</label>
            <select id="visibilidad" name="visibilidad" required>
              <option value="activo" <%= "activo".equals(visibilidad) ? "selected" : "" %>>✅ Activo — visible</option>
              <option value="oculto" <%= "oculto".equals(visibilidad) ? "selected" : "" %>>🚫 Oculto</option>
            </select>
          </div>
        </div>

        <%-- Política de devolución (CA018) --%>
        <div class="form-group">
          <label for="politicaDevolucion">Política de devolución <span style="color:var(--warm);font-weight:400;">(CA018)</span></label>
          <textarea id="politicaDevolucion" name="politicaDevolucion" rows="3"
                    placeholder="Ej: Acepto devoluciones dentro de los 15 días siguientes a la entrega. El producto debe estar en su estado original..."><%= politicaDev %></textarea>
        </div>

        <%-- Acciones --%>
        <div class="form-actions">
          <a href="<%= ctx %>/producto?accion=listar" class="btn btn-secondary">Cancelar</a>
          <button type="submit" class="btn btn-primary">
            <%= es ? "💾 Guardar cambios" : "🌿 Publicar producto" %>
          </button>
        </div>

      </form>
    </div>

    <%-- Sidebar --%>
    <aside class="form-sidebar">
      <div class="sidebar-card">
        <h4>💡 Consejos para publicar</h4>
        <ul class="tip-list">
          <li>Usa un título claro con palabras clave del producto.</li>
          <li>Describe materiales, dimensiones, colores y garantía.</li>
          <li>Pega la URL de una imagen clara y bien iluminada.</li>
          <li>Define una política de devolución clara para generar confianza.</li>
          <li>Mantén el stock actualizado para evitar cancelaciones.</li>
        </ul>
      </div>
      <div class="sidebar-card" style="background:var(--white);">
        <h4>📋 Campos obligatorios</h4>
        <ul class="tip-list">
          <li>Título del producto</li>
          <li>Descripción detallada</li>
          <li>Precio en COP</li>
          <li>Unidades disponibles</li>
          <li>Categoría</li>
          <li>Estado (nuevo / usado)</li>
        </ul>
      </div>
    </aside>

  </div>
</div>

<footer class="footer">
  <div class="footer-brand">MercadoRed</div>
  <p>© 2026 MercadoRed S.A.S. · Bogotá, Colombia</p>
</footer>
</body>
</html>
