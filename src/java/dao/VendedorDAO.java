/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author annym
 */
import model.Vendedor;
import util.DBConexion;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VendedorDAO {

    public boolean crear(Vendedor v) throws SQLException {
        String sql = "INSERT INTO vendedor (id_persona, cuenta_bancaria, banco, "
                   + "identidad_validada, reputacion, documento_path) "
                   + "VALUES (?, ?, ?, FALSE, 0.0, ?)";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt   (1, v.getIdPersona());
            ps.setString(2, v.getCuentaBancaria());
            ps.setString(3, v.getBanco());
            ps.setString(4, v.getDocumentoPath());
            return ps.executeUpdate() > 0;
        } finally { DBConexion.cerrar(conn); }
    }

    public List<Vendedor> listarTodos() throws SQLException {
        List<Vendedor> lista = new ArrayList<>();
        String sql = "SELECT v.*, p.nombre, p.documento, p.correo, p.estado "
                   + "FROM vendedor v JOIN persona p ON v.id_persona=p.id_persona "
                   + "ORDER BY p.nombre";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            ResultSet rs = conn.createStatement().executeQuery(sql);
            while (rs.next()) lista.add(mapear(rs));
        } finally { DBConexion.cerrar(conn); }
        return lista;
    }

    public Vendedor buscarPorId(int id) throws SQLException {
        String sql = "SELECT v.*, p.nombre, p.documento, p.correo, p.estado "
                   + "FROM vendedor v JOIN persona p ON v.id_persona=p.id_persona "
                   + "WHERE v.id_vendedor=?";
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

    // CA012: buscar por idPersona (para el ProductoServlet)
    public Vendedor buscarPorIdPersona(int idPersona) throws SQLException {
        String sql = "SELECT v.*, p.nombre, p.documento, p.correo, p.estado "
                   + "FROM vendedor v JOIN persona p ON v.id_persona=p.id_persona "
                   + "WHERE v.id_persona=?";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, idPersona);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapear(rs);
        } finally { DBConexion.cerrar(conn); }
        return null;
    }

    public boolean validarIdentidad(int idVendedor) throws SQLException {
        String sql = "UPDATE vendedor SET identidad_validada=TRUE WHERE id_vendedor=?";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, idVendedor);
            return ps.executeUpdate() > 0;
        } finally { DBConexion.cerrar(conn); }
    }

    public boolean actualizar(Vendedor v) throws SQLException {
        String sql = "UPDATE vendedor SET cuenta_bancaria=?, banco=? WHERE id_vendedor=?";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, v.getCuentaBancaria());
            ps.setString(2, v.getBanco());
            ps.setInt   (3, v.getIdVendedor());
            return ps.executeUpdate() > 0;
        } finally { DBConexion.cerrar(conn); }
    }

    public boolean actualizarReputacion(int idVendedor, double rep) throws SQLException {
        String sql = "UPDATE vendedor SET reputacion=? WHERE id_vendedor=?";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setDouble(1, rep);
            ps.setInt   (2, idVendedor);
            return ps.executeUpdate() > 0;
        } finally { DBConexion.cerrar(conn); }
    }

    private Vendedor mapear(ResultSet rs) throws SQLException {
        Vendedor v = new Vendedor();
        v.setIdVendedor       (rs.getInt    ("id_vendedor"));
        v.setIdPersona        (rs.getInt    ("id_persona"));
        v.setCuentaBancaria   (rs.getString ("cuenta_bancaria"));
        v.setBanco            (rs.getString ("banco"));
        v.setIdentidadValidada(rs.getBoolean("identidad_validada"));
        v.setReputacion       (rs.getDouble ("reputacion"));
        v.setNombre           (rs.getString ("nombre"));
        v.setDocumento        (rs.getString ("documento"));
        v.setCorreo           (rs.getString ("correo"));
        v.setEstado           (rs.getString ("estado"));
        try { v.setDocumentoPath(rs.getString("documento_path")); } catch (Exception ignored) {}
        return v;
    }
}


