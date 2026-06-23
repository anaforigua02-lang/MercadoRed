/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author annym
 */
import model.Persona;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String uri = req.getRequestURI();
        String ctx = req.getContextPath();

        // Rutas públicas
        boolean esPublica = uri.equals(ctx + "/login")
                         || uri.equals(ctx + "/logout")
                         || uri.equals(ctx + "/registro")
                         || uri.endsWith(".css")
                         || uri.endsWith(".js")
                         || uri.endsWith(".png")
                         || uri.endsWith(".jpg");

        if (esPublica) { chain.doFilter(request, response); return; }

        HttpSession session = req.getSession(false);

        // verificar.jsp necesita sesión temporal
        if (uri.contains("verificar.jsp")) {
            boolean ok = session != null &&
                (session.getAttribute("usuarioPendiente") != null ||
                 session.getAttribute("codigoVerif") != null);
            if (ok) { chain.doFilter(request, response); return; }
            resp.sendRedirect(ctx + "/login");
            return;
        }

        Persona usuario = (session != null) ? (Persona) session.getAttribute("usuario") : null;
        if (usuario == null) { resp.sendRedirect(ctx + "/login"); return; }

        String  rol    = usuario.getTipo();
        String  accion = req.getParameter("accion");
        boolean esProducto = uri.contains("/producto");
        boolean esOrden    = uri.contains("/orden");
        boolean esCarrito  = uri.contains("/carrito");
        boolean esAdmin    = uri.contains("/admin");

        // Solo admin puede acceder al panel admin
        if (esAdmin && !"admin".equals(rol)) {
            resp.sendRedirect(ctx + "/producto?accion=listar");
            return;
        }

        // Comprador no puede crear/editar/eliminar productos
        if ("comprador".equals(rol) && esProducto && accion != null) {
            if (accion.equals("nuevo") || accion.equals("guardar")
             || accion.equals("editar") || accion.equals("actualizar")
             || accion.equals("eliminar")) {
                resp.sendRedirect(ctx + "/producto?accion=listar");
                return;
            }
        }

        // Vendedor/Admin no pueden usar el carrito ni crear órdenes directas
        if (!"comprador".equals(rol)) {
            if (esCarrito) {
                resp.sendRedirect(ctx + "/producto?accion=listar");
                return;
            }
            if (esOrden && "nueva".equals(accion)) {
                resp.sendRedirect(ctx + "/orden?accion=listar");
                return;
            }
        }

        chain.doFilter(request, response);
    }
}
