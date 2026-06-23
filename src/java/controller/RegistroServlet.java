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
import util.EmailService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Random;

/**
 * RegistroServlet — maneja registro con:
 * CA005: validación de aceptación del contrato de comisión
 * CA011: carga del documento digital del vendedor
 */
@WebServlet("/registro")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB en memoria antes de escribir a disco
    maxFileSize       = 5 * 1024 * 1024,  // 5 MB por archivo
    maxRequestSize    = 10 * 1024 * 1024  // 10 MB total
)
public class RegistroServlet extends HttpServlet {

    private final PersonaDAO  personaDAO  = new PersonaDAO();
    private final VendedorDAO vendedorDAO = new VendedorDAO();

    // Carpeta donde se guardan los documentos subidos
    // Ajusta esta ruta según tu sistema
    private static final String UPLOAD_DIR = "documentos_vendedor";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/registro.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String paso = req.getParameter("paso");
        try {
            if ("2".equals(paso)) {
                procesarVerificacion(req, resp);
            } else {
                procesarRegistro(req, resp);
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Error del sistema: " + e.getMessage());
            req.getRequestDispatcher("/registro.jsp").forward(req, resp);
        }
    }

    // ── PASO 1: guardar datos ─────────────────────────────────────
    private void procesarRegistro(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {

        String nombre     = req.getParameter("nombre");
        String documento  = req.getParameter("documento");
        String correo     = req.getParameter("correo");
        String celular    = req.getParameter("celular");
        String direccion  = req.getParameter("direccion");
        String contrasena = req.getParameter("contrasena");
        String tipo       = req.getParameter("tipo");

        // ── Validación duplicados (CA001, CA002) ──────────────────
        if (personaDAO.existeDocumentoOCorreo(documento, correo)) {
            req.setAttribute("error", "Ya existe una cuenta con ese documento o correo.");
            req.setAttribute("datos", req.getParameterMap());
            req.getRequestDispatcher("/registro.jsp").forward(req, resp);
            return;
        }

        // ── CA005: validar aceptación del contrato (solo vendedor) ─
        if ("vendedor".equals(tipo)) {
            String acepta = req.getParameter("aceptaContrato");
            if (!"si".equals(acepta)) {
                req.setAttribute("error", "Debes aceptar el contrato de comisión para registrarte como vendedor.");
                req.setAttribute("datos", req.getParameterMap());
                req.getRequestDispatcher("/registro.jsp").forward(req, resp);
                return;
            }
        }

        // ── Crear persona ─────────────────────────────────────────
        Persona p = new Persona();
        p.setNombre    (nombre);
        p.setDocumento (documento);
        p.setCorreo    (correo);
        p.setCelular   (celular);
        p.setDireccion (direccion);
        p.setContrasena(contrasena);
        p.setTipo      (tipo);

        int idPersona = personaDAO.crear(p);
        if (idPersona < 0) {
            req.setAttribute("error", "No se pudo crear la cuenta. Inténtalo de nuevo.");
            req.getRequestDispatcher("/registro.jsp").forward(req, resp);
            return;
        }

        // ── Vendedor: guardar datos bancarios + documento (CA011) ──
        if ("vendedor".equals(tipo)) {
            String docPath = null;

            // Procesar el archivo subido
            Part filePart = req.getPart("docDigital");
            if (filePart != null && filePart.getSize() > 0) {
                String nombreArchivo = idPersona + "_" + obtenerNombreArchivo(filePart);

                // Guardar en carpeta dentro de la aplicación desplegada
                String appPath  = getServletContext().getRealPath("");
                String uploadPath = appPath + File.separator + UPLOAD_DIR;
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();

                String rutaCompleta = uploadPath + File.separator + nombreArchivo;
                filePart.write(rutaCompleta);
                docPath = UPLOAD_DIR + "/" + nombreArchivo;
            }

            Vendedor v = new Vendedor();
            v.setIdPersona      (idPersona);
            v.setCuentaBancaria (req.getParameter("cuentaBancaria"));
            v.setBanco          (req.getParameter("banco"));
            v.setDocumentoPath  (docPath);
            vendedorDAO.crear(v);
        }


        String codigo = String.format("%06d", new Random().nextInt(999999));
        try {
            EmailService.enviarCodigo(correo, nombre, codigo, "registro de cuenta");
        } catch (Exception e) {
            req.setAttribute("error", "Cuenta creada pero no se pudo enviar el correo: " + e.getMessage());
            req.getRequestDispatcher("/registro.jsp").forward(req, resp);
            return;
        }

        HttpSession session = req.getSession(true);
        session.setAttribute("codigoVerif",    codigo);
        session.setAttribute("idPersonaVerif", idPersona);
        session.setAttribute("nombreVerif",    nombre);
        session.setAttribute("correoVerif",    correo);

        req.setAttribute("nombre",  nombre);
        req.setAttribute("correo",  correo);
        req.setAttribute("esLogin", false);
        req.getRequestDispatcher("/verificar.jsp").forward(req, resp);
    }

    
    private void procesarVerificacion(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {

        String      codigoIngresado = req.getParameter("codigo");
        HttpSession session         = req.getSession(false);

        if (session == null) { resp.sendRedirect(req.getContextPath() + "/registro"); return; }

        String  codigoReal = (String)  session.getAttribute("codigoVerif");
        int     idPersona  = (Integer) session.getAttribute("idPersonaVerif");
        String  nombre     = (String)  session.getAttribute("nombreVerif");
        String  correo     = (String)  session.getAttribute("correoVerif");

        if (!codigoReal.equals(codigoIngresado)) {
            req.setAttribute("error",   "Código incorrecto. Revisa tu correo.");
            req.setAttribute("nombre",  nombre);
            req.setAttribute("correo",  correo);
            req.setAttribute("esLogin", false);
            req.getRequestDispatcher("/verificar.jsp").forward(req, resp);
            return;
        }

        personaDAO.activarCuenta(idPersona);
        session.removeAttribute("codigoVerif");
        session.removeAttribute("idPersonaVerif");
        session.removeAttribute("nombreVerif");
        session.removeAttribute("correoVerif");

        resp.sendRedirect(req.getContextPath() + "/login?msg=registrado");
    }

    
    private String obtenerNombreArchivo(Part part) {
        String header = part.getHeader("content-disposition");
        if (header == null) return "documento";
        for (String token : header.split(";")) {
            if (token.trim().startsWith("filename")) {
                String nombre = token.substring(token.indexOf('=') + 1).trim()
                                     .replace("\"", "");
                
                return new File(nombre).getName();
            }
        }
        return "documento";
    }
}
