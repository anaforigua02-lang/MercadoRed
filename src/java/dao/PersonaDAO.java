/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author annym
 */
import model.Persona;
import util.DBConexion;

import java.sql.*;

public class PersonaDAO {

    public Persona autenticar(String correo, String contrasena) throws SQLException {
        String sql = "SELECT * FROM persona WHERE correo=? AND contrasena=?";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, correo);
            ps.setString(2, contrasena);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapear(rs);
        } finally { DBConexion.cerrar(conn); }
        return null;
    }

    public int crear(Persona p) throws SQLException {
        String sql = "INSERT INTO persona (nombre,documento,correo,celular,direccion,contrasena,estado,tipo) "
                   + "VALUES (?,?,?,?,?,?,'inactivo',?)";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, p.getNombre());
            ps.setString(2, p.getDocumento());
            ps.setString(3, p.getCorreo());
            ps.setString(4, p.getCelular());
            ps.setString(5, p.getDireccion());
            ps.setString(6, p.getContrasena());
            ps.setString(7, p.getTipo());
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        } finally { DBConexion.cerrar(conn); }
        return -1;
    }

    public boolean existeDocumentoOCorreo(String doc, String correo) throws SQLException {
        String sql = "SELECT COUNT(*) FROM persona WHERE documento=? OR correo=?";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, doc);
            ps.setString(2, correo);
            ResultSet rs = ps.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        } finally { DBConexion.cerrar(conn); }
    }

    public boolean activarCuenta(int idPersona) throws SQLException {
        return cambiarEstado(idPersona, "activo");
    }

    public boolean cambiarEstado(int idPersona, String estado) throws SQLException {
        String sql = "UPDATE persona SET estado=? WHERE id_persona=?";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, estado);
            ps.setInt   (2, idPersona);
            return ps.executeUpdate() > 0;
        } finally { DBConexion.cerrar(conn); }
    }

    public Persona buscarPorId(int id) throws SQLException {
        String sql = "SELECT * FROM persona WHERE id_persona=?";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapear(rs);
        } finally { DBConexion.cerrar(conn); }
        return null;
    }

    private Persona mapear(ResultSet rs) throws SQLException {
        Persona p = new Persona();
        p.setIdPersona (rs.getInt   ("id_persona"));
        p.setNombre    (rs.getString("nombre"));
        p.setDocumento (rs.getString("documento"));
        p.setCorreo    (rs.getString("correo"));
        p.setCelular   (rs.getString("celular"));
        p.setDireccion (rs.getString("direccion"));
        p.setContrasena(rs.getString("contrasena"));
        p.setEstado    (rs.getString("estado"));
        p.setTipo      (rs.getString("tipo"));
        return p;
    }
}
