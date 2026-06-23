/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author annym
 */
import dao.OrdenDAO;
import dao.ProductoDAO;
import model.Orden;
import model.Producto;
import model.Persona;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/orden")
public class OrdenServlet extends HttpServlet {

    private final OrdenDAO    ordenDAO    = new OrdenDAO();
    private final ProductoDAO productoDAO = new ProductoDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String accion = req.getParameter("accion");
        if (accion == null) accion = "listar";

        HttpSession session = req.getSession(false);
        Persona usuario = (Persona) session.getAttribute("usuario");

        try {
            switch (accion) {

                case "listar" -> {
                    List<Orden> ordenes;
                    if ("comprador".equals(usuario.getTipo())) {
                        ordenes = ordenDAO.listarPorComprador(usuario.getIdPersona());
                    } else {
                        ordenes = ordenDAO.listarTodas();
                    }
                    req.setAttribute("ordenes", ordenes);
                    req.getRequestDispatcher("/ordenes.jsp").forward(req, resp);
                }

                case "nueva" -> {
                    // Cargar productos activos con stock
                    List<Producto> productos = productoDAO.listarActivos();
                    req.setAttribute("productos", productos);
                    //Pasar al jsp si ya se le asigno id al producto comprado
                    req.getRequestDispatcher("/orden_form.jsp").forward(req, resp);
                }

                case "confirmarRecepcion" -> {
                    int id = Integer.parseInt(req.getParameter("id"));
                    ordenDAO.cambiarEstado(id, "entregado");
                    ordenDAO.liberarFondos(id);
                    resp.sendRedirect(req.getContextPath() + "/orden?accion=listar&msg=recibido");
                }

                case "cancelar" -> {
                    int id = Integer.parseInt(req.getParameter("id"));
                    ordenDAO.cambiarEstado(id, "cancelado");
                    resp.sendRedirect(req.getContextPath() + "/orden?accion=listar&msg=cancelado");
                }

                case "cambiarEstado" -> {
                    int    id     = Integer.parseInt(req.getParameter("id"));
                    String estado = req.getParameter("estado");
                    ordenDAO.cambiarEstado(id, estado);
                    resp.sendRedirect(req.getContextPath() + "/orden?accion=listar&msg=actualizado");
                }

                default -> resp.sendRedirect(req.getContextPath() + "/orden?accion=listar");
            }

        } catch (SQLException e) {
            req.setAttribute("error", "Error de base de datos: " + e.getMessage());
            req.getRequestDispatcher("/error.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/orden?accion=listar");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session  = req.getSession(false);
        Persona     usuario  = (Persona) session.getAttribute("usuario");

        try {
            int      idProducto = Integer.parseInt(req.getParameter("idProducto"));
            int      cantidad   = Integer.parseInt(req.getParameter("cantidad"));
            Producto prod       = productoDAO.buscarPorId(idProducto);

            // Validaciones
            if (prod == null) {
                req.setAttribute("error", "Producto no encontrado.");
                req.setAttribute("productos", productoDAO.listarActivos());
                req.getRequestDispatcher("/orden_form.jsp").forward(req, resp);
                return;
            }

            if (prod.getStock() < cantidad) {
                req.setAttribute("error", "Stock insuficiente. Disponible: " + prod.getStock());
                req.setAttribute("productos", productoDAO.listarActivos());
                req.getRequestDispatcher("/orden_form.jsp").forward(req, resp);
                return;
            }

            if (cantidad < 1) {
                req.setAttribute("error", "La cantidad debe ser al menos 1.");
                req.setAttribute("productos", productoDAO.listarActivos());
                req.getRequestDispatcher("/orden_form.jsp").forward(req, resp);
                return;
            }

            // Crear orden
            double total = prod.getPrecio() * cantidad;
            Orden o = new Orden();
            o.setIdComprador(usuario.getIdPersona());
            o.setTotal(total);

            int idOrden = ordenDAO.crear(o);

            if (idOrden > 0) {
                productoDAO.descontarStock(idProducto, cantidad); // RF-AN-08
                ordenDAO.cambiarEstado(idOrden, "pagado");
                resp.sendRedirect(req.getContextPath() + "/orden?accion=listar&msg=creado");
            } else {
                req.setAttribute("error", "No se pudo registrar la orden. Inténtalo de nuevo.");
                req.setAttribute("productos", productoDAO.listarActivos());
                req.getRequestDispatcher("/orden_form.jsp").forward(req, resp);
            }

        } catch (NumberFormatException e) {
            req.setAttribute("error", "Datos inválidos. Selecciona un producto y cantidad correcta.");
            try {
                req.setAttribute("productos", productoDAO.listarActivos());
            } catch (SQLException ex) { /* ignorar */ }
            req.getRequestDispatcher("/orden_form.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", "Error de base de datos: " + e.getMessage());
            req.getRequestDispatcher("/error.jsp").forward(req, resp);
        }
    }
}


