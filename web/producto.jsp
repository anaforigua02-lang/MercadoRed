<%-- 
    Document   : producto
    Created on : 27/04/2026, 1:36:57?p. m.
    Author     : annym
--%>

<%@ page import="java.util.List" %>
<%@ page import="model.Producto" %>

<h2>Catalogo de Productos</h2>

<form method="get" action="ProductoServlet">

 <input type="text" name="buscar" placeholder="Buscar producto">

 <select name="categoria">
 <option value="">Todas</option>
 <option value="Tecnologa">Tecnologa</option>
 <option value="Muebles">Muebles</option>
 </select>

 <input type="number" name="min" placeholder="Precio mnimo">
 <input type="number" name="max" placeholder="Precio mximo">

 <button type="submit">Buscar</button>

</form>

<hr>

<%
List<Producto> lista = (List<Producto>) request.getAttribute("listaProductos");

if (lista == null || lista.isEmpty()) {
%>
 <p>No se encontraron productos</p>
<%
} else {
 for (Producto p : lista) {
%>
 <div>
 <h3><%= p.getTitulo() %></h3>
 <p><%= p.getDescripcion() %></p>
 <p>$<%= p.getPrecio() %></p>
 </div>
<%
 }
}
%>
