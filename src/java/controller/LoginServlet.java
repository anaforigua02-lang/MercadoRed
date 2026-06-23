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
import model.Persona;
import util.EmailService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Random;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final PersonaDAO dao = new PersonaDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("usuario") != null) {
            resp.sendRedirect(req.getContextPath() + "/producto?accion=listar");
            return;
        }
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String paso = req.getParameter("paso");
        try {
            if ("verificar".equals(paso)) {
                procesarVerificacion(req, resp);
            } else {
                procesarCredenciales(req, resp);
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Error del sistema: " + e.getMessage());
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }

    private void procesarCredenciales(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {

        String correo     = req.getParameter("correo");
        String contrasena = req.getParameter("contrasena");

        Persona usuario = dao.autenticar(correo, contrasena);

        if (usuario == null) {
            req.setAttribute("error", "Correo o contraseña incorrectos.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }
        if ("inactivo".equals(usuario.getEstado())) {
            req.setAttribute("error", "Tu cuenta está inactiva. Confirma tu correo primero.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }
        if ("sancionado".equals(usuario.getEstado())) {
            req.setAttribute("error", "Tu cuenta está sancionada. Contacta al administrador.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        String codigo = String.format("%06d", new Random().nextInt(999999));

        try {
            EmailService.enviarCodigo(usuario.getCorreo(), usuario.getNombre(), codigo, "inicio de sesión");
        } catch (Exception e) {
            req.setAttribute("error", "No se pudo enviar el correo: " + e.getMessage());
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        HttpSession session = req.getSession(true);
        session.setAttribute("usuarioPendiente", usuario);
        session.setAttribute("codigoLogin",      codigo);
        session.setMaxInactiveInterval(10 * 60);

        req.setAttribute("nombre",  usuario.getNombre());
        req.setAttribute("correo",  usuario.getCorreo());
        req.setAttribute("esLogin", true);
        req.getRequestDispatcher("/verificar.jsp").forward(req, resp);
    }

    private void procesarVerificacion(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {

        String      codigoIngresado = req.getParameter("codigo");
        HttpSession session         = req.getSession(false);

        if (session == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String  codigoReal = (String)  session.getAttribute("codigoLogin");
        Persona usuario    = (Persona) session.getAttribute("usuarioPendiente");

        if (codigoReal == null || usuario == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if (!codigoReal.equals(codigoIngresado)) {
            req.setAttribute("error",   "Código incorrecto. Revisa tu correo.");
            req.setAttribute("nombre",  usuario.getNombre());
            req.setAttribute("correo",  usuario.getCorreo());
            req.setAttribute("esLogin", true);
            req.getRequestDispatcher("/verificar.jsp").forward(req, resp);
            return;
        }

        session.removeAttribute("usuarioPendiente");
        session.removeAttribute("codigoLogin");
        session.setAttribute("usuario", usuario);
        session.setAttribute("rol",     usuario.getTipo());
        session.setMaxInactiveInterval(30 * 60);

        resp.sendRedirect(req.getContextPath() + "/producto?accion=listar");
    }
}
