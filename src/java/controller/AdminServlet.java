/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author annym
 */
import dao.PersonaDAO;
import dao.VendedorDAO;
import model.Persona;
import model.Vendedor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    private final VendedorDAO vendedorDAO = new VendedorDAO();
    private final PersonaDAO  personaDAO  = new PersonaDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Persona usuario = (Persona) session.getAttribute("usuario");

        // Solo admins pueden entrar
        if (usuario == null || !"admin".equals(usuario.getTipo())) {
            resp.sendRedirect(req.getContextPath() + "/producto?accion=listar");
            return;
        }

        String accion = req.getParameter("accion");
        if (accion == null) accion = "vendedores";

        try {
            switch (accion) {

                case "vendedores" -> {
                    List<Vendedor> vendedores = vendedorDAO.listarTodos();
                    req.setAttribute("vendedores", vendedores);
                    req.getRequestDispatcher("/admin_vendedores.jsp").forward(req, resp);
                }

                case "validar" -> {
                    int idVendedor = Integer.parseInt(req.getParameter("id"));
                    Vendedor v = vendedorDAO.buscarPorId(idVendedor);
                    if (v != null) {
                        vendedorDAO.validarIdentidad(idVendedor);
                        personaDAO.cambiarEstado(v.getIdPersona(), "activo");
                    }
                    resp.sendRedirect(req.getContextPath() + "/admin?accion=vendedores&msg=validado");
                }

                case "rechazar" -> {
                    int idVendedor = Integer.parseInt(req.getParameter("id"));
                    Vendedor v = vendedorDAO.buscarPorId(idVendedor);
                    if (v != null) {
                        personaDAO.cambiarEstado(v.getIdPersona(), "sancionado");
                    }
                    resp.sendRedirect(req.getContextPath() + "/admin?accion=vendedores&msg=rechazado");
                }

                default -> resp.sendRedirect(req.getContextPath() + "/admin?accion=vendedores");
            }

        } catch (SQLException e) {
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/error.jsp").forward(req, resp);
        }
    }
}

