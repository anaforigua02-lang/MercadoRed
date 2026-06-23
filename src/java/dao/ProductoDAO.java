/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author annym
 */
import model.Producto;
import util.DBConexion;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductoDAO {

    public boolean crear(Producto p) throws SQLException {
        String sql = "INSERT INTO producto (id_vendedor, titulo, descripcion, precio, stock, "
                   + "categoria, imagen_url, estado_producto, visibilidad, politica_devolucion) "
                   + "VALUES (?,?,?,?,?,?,?,?,?,?)";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt   (1,  p.getIdVendedor());
            ps.setString(2,  p.getTitulo());
            ps.setString(3,  p.getDescripcion());
            ps.setDouble(4,  p.getPrecio());
            ps.setInt   (5,  p.getStock());
            ps.setString(6,  p.getCategoria());
            ps.setString(7,  p.getImagenUrl());
            ps.setString(8,  p.getEstadoProducto());
            ps.setString(9,  p.getVisibilidad());
            ps.setString(10, p.getPoliticaDevolucion());
            return ps.executeUpdate() > 0;
        } finally { DBConexion.cerrar(conn); }
    }

    // Admin: todos los productos
    public List<Producto> listarTodos() throws SQLException {
        String sql = "SELECT p.*, pe.nombre AS nombre_vendedor FROM producto p "
                   + "JOIN vendedor v ON p.id_vendedor=v.id_vendedor "
                   + "JOIN persona pe ON v.id_persona=pe.id_persona "
                   + "WHERE p.visibilidad != 'eliminado' ORDER BY p.id_producto DESC";
        return ejecutarLista(sql);
    }

    // Vendedor: solo sus propios productos
    public List<Producto> listarPorVendedor(int idVendedor) throws SQLException {
        List<Producto> lista = new ArrayList<>();
        String sql = "SELECT p.*, pe.nombre AS nombre_vendedor FROM producto p "
                   + "JOIN vendedor v ON p.id_vendedor=v.id_vendedor "
                   + "JOIN persona pe ON v.id_persona=pe.id_persona "
                   + "WHERE p.visibilidad != 'eliminado' AND p.id_vendedor=? "
                   + "ORDER BY p.id_producto DESC";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, idVendedor);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) lista.add(mapear(rs));
        } finally { DBConexion.cerrar(conn); }
        return lista;
    }

    // Comprador: todos activos con stock
    public List<Producto> listarActivos() throws SQLException {
        String sql = "SELECT p.*, pe.nombre AS nombre_vendedor FROM producto p "
                   + "JOIN vendedor v ON p.id_vendedor=v.id_vendedor "
                   + "JOIN persona pe ON v.id_persona=pe.id_persona "
                   + "WHERE p.visibilidad='activo' AND p.stock > 0 ORDER BY p.titulo";
        return ejecutarLista(sql);
    }

    // RF009/RF010: búsqueda y filtrado (CA020-CA023)
    public List<Producto> buscarFiltrado(String texto, String categoria, String estado,
                                         String orden, Double min, Double max) {
        List<Producto> lista = new ArrayList<>();
        Connection conn = null;

        StringBuilder sql = new StringBuilder(
            "SELECT p.*, pe.nombre AS nombre_vendedor "
          + "FROM producto p "
          + "JOIN vendedor v  ON p.id_vendedor = v.id_vendedor "
          + "JOIN persona  pe ON v.id_persona  = pe.id_persona "
          + "WHERE p.visibilidad = 'activo' AND p.stock > 0"
        );

        if (texto     != null && !texto.isEmpty())
            sql.append(" AND (p.titulo LIKE ? OR p.descripcion LIKE ?)");
        if (categoria != null && !categoria.isEmpty())
            sql.append(" AND p.categoria = ?");
        if (estado    != null && !estado.isEmpty())
            sql.append(" AND p.estado_producto = ?");
        if (min != null) sql.append(" AND p.precio >= ?");
        if (max != null) sql.append(" AND p.precio <= ?");

        if (orden != null) {
            switch (orden) {
                case "precio_asc"  -> sql.append(" ORDER BY p.precio ASC");
                case "precio_desc" -> sql.append(" ORDER BY p.precio DESC");
                case "nombre_asc"  -> sql.append(" ORDER BY p.titulo ASC");
                case "nombre_desc" -> sql.append(" ORDER BY p.titulo DESC");
                case "stock_desc"  -> sql.append(" ORDER BY p.stock DESC");
                case "reciente"    -> sql.append(" ORDER BY p.fecha_creacion DESC");
                default            -> sql.append(" ORDER BY p.titulo ASC");
            }
        } else {
            sql.append(" ORDER BY p.titulo ASC");
        }

        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql.toString());
            int i = 1;
            if (texto     != null && !texto.isEmpty()) {
                ps.setString(i++, "%" + texto + "%");
                ps.setString(i++, "%" + texto + "%");
            }
            if (categoria != null && !categoria.isEmpty()) ps.setString(i++, categoria);
            if (estado    != null && !estado.isEmpty())    ps.setString(i++, estado);
            if (min != null) ps.setDouble(i++, min);
            if (max != null) ps.setDouble(i++, max);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) lista.add(mapear(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        } finally { DBConexion.cerrar(conn); }
        return lista;
    }

    public Producto buscarPorId(int id) throws SQLException {
        String sql = "SELECT p.*, pe.nombre AS nombre_vendedor FROM producto p "
                   + "JOIN vendedor v ON p.id_vendedor=v.id_vendedor "
                   + "JOIN persona pe ON v.id_persona=pe.id_persona "
                   + "WHERE p.id_producto=?";
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

    public boolean actualizar(Producto p) throws SQLException {
        String sql = "UPDATE producto SET titulo=?, descripcion=?, precio=?, stock=?, "
                   + "categoria=?, imagen_url=?, estado_producto=?, visibilidad=?, "
                   + "politica_devolucion=? WHERE id_producto=?";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1,  p.getTitulo());
            ps.setString(2,  p.getDescripcion());
            ps.setDouble(3,  p.getPrecio());
            ps.setInt   (4,  p.getStock());
            ps.setString(5,  p.getCategoria());
            ps.setString(6,  p.getImagenUrl());
            ps.setString(7,  p.getEstadoProducto());
            ps.setString(8,  p.getVisibilidad());
            ps.setString(9,  p.getPoliticaDevolucion());
            ps.setInt   (10, p.getIdProducto());
            return ps.executeUpdate() > 0;
        } finally { DBConexion.cerrar(conn); }
    }

    public boolean descontarStock(int idProducto, int cantidad) throws SQLException {
        String sql = "UPDATE producto SET stock=stock-? WHERE id_producto=? AND stock>=?";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, cantidad);
            ps.setInt(2, idProducto);
            ps.setInt(3, cantidad);
            return ps.executeUpdate() > 0;
        } finally { DBConexion.cerrar(conn); }
    }

    public boolean eliminar(int id) throws SQLException {
        String sql = "UPDATE producto SET visibilidad='eliminado' WHERE id_producto=?";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } finally { DBConexion.cerrar(conn); }
    }

    private List<Producto> ejecutarLista(String sql) throws SQLException {
        List<Producto> lista = new ArrayList<>();
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            ResultSet rs = conn.createStatement().executeQuery(sql);
            while (rs.next()) lista.add(mapear(rs));
        } finally { DBConexion.cerrar(conn); }
        return lista;
    }

    private Producto mapear(ResultSet rs) throws SQLException {
        Producto p = new Producto();
        p.setIdProducto    (rs.getInt      ("id_producto"));
        p.setIdVendedor    (rs.getInt      ("id_vendedor"));
        p.setTitulo        (rs.getString   ("titulo"));
        p.setDescripcion   (rs.getString   ("descripcion"));
        p.setPrecio        (rs.getDouble   ("precio"));
        p.setStock         (rs.getInt      ("stock"));
        p.setCategoria     (rs.getString   ("categoria"));
        p.setImagenUrl     (rs.getString   ("imagen_url"));
        p.setEstadoProducto(rs.getString   ("estado_producto"));
        p.setVisibilidad   (rs.getString   ("visibilidad"));
        p.setFechaCreacion (rs.getTimestamp("fecha_creacion"));
        try { p.setNombreVendedor    (rs.getString("nombre_vendedor"));    } catch (Exception ignored) {}
        try { p.setPoliticaDevolucion(rs.getString("politica_devolucion"));} catch (Exception ignored) {}
        return p;
    }
}
