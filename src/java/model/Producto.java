/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author annym
 */
import java.sql.Timestamp;

public class Producto {
    private int       idProducto;
    private int       idVendedor;
    private String    titulo;
    private String    descripcion;
    private double    precio;
    private int       stock;
    private String    categoria;
    private String    imagenUrl;
    private String    estadoProducto;
    private String    visibilidad;
    private String    politicaDevolucion;  // CA018
    private Timestamp fechaCreacion;
    private String    nombreVendedor;

    public Producto() {}

    public int       getIdProducto()                  { return idProducto; }
    public void      setIdProducto(int v)             { this.idProducto = v; }
    public int       getIdVendedor()                  { return idVendedor; }
    public void      setIdVendedor(int v)             { this.idVendedor = v; }
    public String    getTitulo()                      { return titulo; }
    public void      setTitulo(String v)              { this.titulo = v; }
    public String    getDescripcion()                 { return descripcion; }
    public void      setDescripcion(String v)         { this.descripcion = v; }
    public double    getPrecio()                      { return precio; }
    public void      setPrecio(double v)              { this.precio = v; }
    public int       getStock()                       { return stock; }
    public void      setStock(int v)                  { this.stock = v; }
    public String    getCategoria()                   { return categoria; }
    public void      setCategoria(String v)           { this.categoria = v; }
    public String    getImagenUrl()                   { return imagenUrl; }
    public void      setImagenUrl(String v)           { this.imagenUrl = v; }
    public String    getEstadoProducto()              { return estadoProducto; }
    public void      setEstadoProducto(String v)      { this.estadoProducto = v; }
    public String    getVisibilidad()                 { return visibilidad; }
    public void      setVisibilidad(String v)         { this.visibilidad = v; }
    public String    getPoliticaDevolucion()          { return politicaDevolucion; }
    public void      setPoliticaDevolucion(String v)  { this.politicaDevolucion = v; }
    public Timestamp getFechaCreacion()               { return fechaCreacion; }
    public void      setFechaCreacion(Timestamp v)    { this.fechaCreacion = v; }
    public String    getNombreVendedor()              { return nombreVendedor; }
    public void      setNombreVendedor(String v)      { this.nombreVendedor = v; }
}
