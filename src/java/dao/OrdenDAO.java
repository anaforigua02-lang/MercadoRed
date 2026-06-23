/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author annym
 */
import model.Orden;
import util.DBConexion;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrdenDAO {

    // RF013: crear orden con método de pago y dirección (CA027, CA029)
    public int crear(Orden o) throws SQLException {
        String sql = "INSERT INTO orden (id_comprador, total, estado_orden, fondos_retenidos, metodo_pago, direccion_envio) "
                   + "VALUES (?, ?, 'pendiente', TRUE, ?, ?)";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt   (1, o.getIdComprador());
            ps.setDouble(2, o.getTotal());
            ps.setString(3, o.getMetodoPago()     != null ? o.getMetodoPago()     : "");
            ps.setString(4, o.getDireccionEnvio() != null ? o.getDireccionEnvio() : "");
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        } finally { DBConexion.cerrar(conn); }
        return -1;
    }

    public List<Orden> listarTodas() throws SQLException {
        List<Orden> lista = new ArrayList<>();
        String sql = "SELECT o.*, p.nombre AS nombre_comprador "
                   + "FROM orden o JOIN persona p ON o.id_comprador = p.id_persona "
                   + "ORDER BY o.id_orden DESC";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            ResultSet rs = conn.createStatement().executeQuery(sql);
            while (rs.next()) lista.add(mapear(rs));
        } finally { DBConexion.cerrar(conn); }
        return lista;
    }

    public List<Orden> listarPorComprador(int idComprador) throws SQLException {
        List<Orden> lista = new ArrayList<>();
        String sql = "SELECT o.*, p.nombre AS nombre_comprador "
                   + "FROM orden o JOIN persona p ON o.id_comprador = p.id_persona "
                   + "WHERE o.id_comprador = ? ORDER BY o.id_orden DESC";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, idComprador);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) lista.add(mapear(rs));
        } finally { DBConexion.cerrar(conn); }
        return lista;
    }

    public boolean cambiarEstado(int idOrden, String estado) throws SQLException {
        String sql = "UPDATE orden SET estado_orden = ? WHERE id_orden = ?";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, estado);
            ps.setInt   (2, idOrden);
            return ps.executeUpdate() > 0;
        } finally { DBConexion.cerrar(conn); }
    }

    public boolean liberarFondos(int idOrden) throws SQLException {
        String sql = "UPDATE orden SET fondos_retenidos = FALSE WHERE id_orden = ?";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, idOrden);
            return ps.executeUpdate() > 0;
        } finally { DBConexion.cerrar(conn); }
    }

    private Orden mapear(ResultSet rs) throws SQLException {
        Orden o = new Orden();
        o.setIdOrden        (rs.getInt      ("id_orden"));
        o.setIdComprador    (rs.getInt      ("id_comprador"));
        o.setTotal          (rs.getDouble   ("total"));
        o.setEstadoOrden    (rs.getString   ("estado_orden"));
        o.setFondosRetenidos(rs.getBoolean  ("fondos_retenidos"));
        o.setFechaCreacion  (rs.getTimestamp("fecha_creacion"));
        o.setNombreComprador(rs.getString   ("nombre_comprador"));
        try { o.setMetodoPago    (rs.getString("metodo_pago"));     } catch (Exception ignored) {}
        try { o.setDireccionEnvio(rs.getString("direccion_envio")); } catch (Exception ignored) {}
        return o;
    }
}

