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
import model.CarritoItem;
import model.Orden;
import model.Persona;
import model.Producto;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Modulo 4 — Compras
 * RF011 Carrito (CA024-CA026) · RF012 Dirección (CA027-CA028) · RF013 Pago (CA029-CA030)
 */
@WebServlet("/carrito")
public class CarritoServlet extends HttpServlet {

    private final ProductoDAO productoDAO = new ProductoDAO();
    private final OrdenDAO    ordenDAO    = new OrdenDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String accion = req.getParameter("accion");
        if (accion == null) accion = "ver";
        HttpSession session = req.getSession();

        switch (accion) {

            case "ver" -> {
                req.setAttribute("carrito", getCarrito(session));
                dispatch(req, resp, "/carrito.jsp");
            }

            case "eliminar" -> {
                // CA025 — retirar producto
                String idStr = req.getParameter("id");
                if (idStr != null) {
                    List<CarritoItem> carrito = getCarrito(session);
                    carrito.removeIf(i -> i.getIdProducto() == Integer.parseInt(idStr));
                    session.setAttribute("carrito", carrito);
                }
                resp.sendRedirect(req.getContextPath() + "/carrito?accion=ver");
            }

            case "vaciar" -> {
                session.removeAttribute("carrito");
                resp.sendRedirect(req.getContextPath() + "/carrito?accion=ver");
            }

            case "checkout" -> {
                // CA026 — mostrar resumen antes de cerrar compra
                List<CarritoItem> carrito = getCarrito(session);
                if (carrito.isEmpty()) {
                    resp.sendRedirect(req.getContextPath() + "/carrito?accion=ver&error=vacio");
                    return;
                }
                req.setAttribute("carrito", carrito);
                dispatch(req, resp, "/checkout_direccion.jsp");
            }

            default -> resp.sendRedirect(req.getContextPath() + "/carrito?accion=ver");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String accion = req.getParameter("accion");
        if (accion == null) accion = "";
        HttpSession session = req.getSession();
        Persona usuario = (Persona) session.getAttribute("usuario");

        try {
            switch (accion) {

                case "agregar" -> {
                    // CA024 — agregar al carrito
                    int idProducto = Integer.parseInt(req.getParameter("idProducto"));
                    int cantidad   = Integer.parseInt(req.getParameter("cantidad"));
                    Producto prod  = productoDAO.buscarPorId(idProducto);

                    if (prod == null || prod.getStock() < 1) {
                        resp.sendRedirect(req.getContextPath() + "/producto?accion=listar&error=nostock");
                        return;
                    }

                    List<CarritoItem> carrito = getCarrito(session);
                    boolean encontrado = false;
                    for (CarritoItem item : carrito) {
                        if (item.getIdProducto() == idProducto) {
                            item.setCantidad(Math.min(item.getCantidad() + cantidad, prod.getStock()));
                            item.setStockDisponible(prod.getStock());
                            encontrado = true;
                            break;
                        }
                    }
                    if (!encontrado) {
                        carrito.add(new CarritoItem(prod, Math.min(cantidad, prod.getStock())));
                    }
                    session.setAttribute("carrito", carrito);
                    resp.sendRedirect(req.getContextPath() + "/producto?accion=listar&msg=agregado");
                }

                case "actualizar" -> {
                    // CA025 — modificar cantidad
                    int idProducto = Integer.parseInt(req.getParameter("idProducto"));
                    int cantidad   = Integer.parseInt(req.getParameter("cantidad"));
                    List<CarritoItem> carrito = getCarrito(session);
                    if (cantidad < 1) {
                        carrito.removeIf(i -> i.getIdProducto() == idProducto);
                    } else {
                        for (CarritoItem item : carrito) {
                            if (item.getIdProducto() == idProducto) {
                                item.setCantidad(Math.min(cantidad, item.getStockDisponible()));
                                break;
                            }
                        }
                    }
                    session.setAttribute("carrito", carrito);
                    resp.sendRedirect(req.getContextPath() + "/carrito?accion=ver");
                }

                case "confirmarDir" -> {
                    // CA027 / CA028 — confirmar dirección
                    String direccion = req.getParameter("direccion");
                    String ciudad    = req.getParameter("ciudad");
                    String depto     = req.getParameter("departamento");

                    if (direccion == null || direccion.isBlank()
                     || ciudad    == null || ciudad.isBlank()) {
                        // CA028: bloquear si falta dirección
                        req.setAttribute("carrito", getCarrito(session));
                        req.setAttribute("error", "Completa la dirección y la ciudad para continuar.");
                        dispatch(req, resp, "/checkout_direccion.jsp");
                        return;
                    }

                    session.setAttribute("envio_direccion",    direccion.trim());
                    session.setAttribute("envio_ciudad",       ciudad.trim());
                    session.setAttribute("envio_departamento", depto != null ? depto.trim() : "");

                    req.setAttribute("carrito", getCarrito(session));
                    dispatch(req, resp, "/checkout_pago.jsp");
                }

                case "pagar" -> {
                    // CA029 / CA030 — procesar pago
                    String metodoPago = req.getParameter("metodoPago");
                    String direccion  = (String) session.getAttribute("envio_direccion");

                    if (metodoPago == null || metodoPago.isBlank()) {
                        // CA030: método obligatorio
                        req.setAttribute("carrito", getCarrito(session));
                        req.setAttribute("error", "Selecciona un método de pago para continuar.");
                        dispatch(req, resp, "/checkout_pago.jsp");
                        return;
                    }

                    if (direccion == null || direccion.isBlank()) {
                        req.setAttribute("carrito", getCarrito(session));
                        req.setAttribute("error", "La dirección de envío es requerida.");
                        dispatch(req, resp, "/checkout_direccion.jsp");
                        return;
                    }

                    List<CarritoItem> carrito = getCarrito(session);
                    if (carrito.isEmpty()) {
                        resp.sendRedirect(req.getContextPath() + "/carrito?accion=ver&error=vacio");
                        return;
                    }

                    double total = carrito.stream().mapToDouble(CarritoItem::getSubtotal).sum();
                    Orden o = new Orden();
                    o.setIdComprador(usuario.getIdPersona());
                    o.setTotal(total);
                    o.setMetodoPago(metodoPago);
                    o.setDireccionEnvio(direccion + ", "
                        + session.getAttribute("envio_ciudad") + " - "
                        + session.getAttribute("envio_departamento"));

                    int idOrden = ordenDAO.crear(o);
                    if (idOrden > 0) {
                        for (CarritoItem item : carrito) {
                            productoDAO.descontarStock(item.getIdProducto(), item.getCantidad());
                        }
                        ordenDAO.cambiarEstado(idOrden, "pagado");

                        session.removeAttribute("carrito");
                        session.removeAttribute("envio_direccion");
                        session.removeAttribute("envio_ciudad");
                        session.removeAttribute("envio_departamento");

                        resp.sendRedirect(req.getContextPath() + "/orden?accion=listar&msg=creado");
                    } else {
                        req.setAttribute("carrito", carrito);
                        req.setAttribute("error", "No se pudo procesar la orden. Inténtalo de nuevo.");
                        dispatch(req, resp, "/checkout_pago.jsp");
                    }
                }

                default -> resp.sendRedirect(req.getContextPath() + "/carrito?accion=ver");
            }

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/carrito?accion=ver&error=datos");
        } catch (SQLException e) {
            req.setAttribute("error", "Error de base de datos: " + e.getMessage());
            dispatch(req, resp, "/error.jsp");
        }
    }

    @SuppressWarnings("unchecked")
    private List<CarritoItem> getCarrito(HttpSession session) {
        List<CarritoItem> c = (List<CarritoItem>) session.getAttribute("carrito");
        if (c == null) { c = new ArrayList<>(); session.setAttribute("carrito", c); }
        return c;
    }

    private void dispatch(HttpServletRequest req, HttpServletResponse resp, String jsp)
            throws ServletException, IOException {
        req.getRequestDispatcher(jsp).forward(req, resp);
    }
}

