/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author annym
 */
import java.io.Serializable;

public class CarritoItem implements Serializable {
    private static final long serialVersionUID = 1L;

    private int    idProducto;
    private String titulo;
    private String categoria;
    private String estadoProducto;
    private double precioUnitario;
    private int    cantidad;
    private int    stockDisponible;

    public CarritoItem() {}

    public CarritoItem(Producto p, int cantidad) {
        this.idProducto      = p.getIdProducto();
        this.titulo          = p.getTitulo();
        this.categoria       = p.getCategoria();
        this.estadoProducto  = p.getEstadoProducto();
        this.precioUnitario  = p.getPrecio();
        this.cantidad        = cantidad;
        this.stockDisponible = p.getStock();
    }

    public double getSubtotal() { return precioUnitario * cantidad; }

    public int    getIdProducto()              { return idProducto; }
    public void   setIdProducto(int v)         { this.idProducto = v; }
    public String getTitulo()                  { return titulo; }
    public void   setTitulo(String v)          { this.titulo = v; }
    public String getCategoria()               { return categoria; }
    public void   setCategoria(String v)       { this.categoria = v; }
    public String getEstadoProducto()          { return estadoProducto; }
    public void   setEstadoProducto(String v)  { this.estadoProducto = v; }
    public double getPrecioUnitario()          { return precioUnitario; }
    public void   setPrecioUnitario(double v)  { this.precioUnitario = v; }
    public int    getCantidad()                { return cantidad; }
    public void   setCantidad(int v)           { this.cantidad = v; }
    public int    getStockDisponible()         { return stockDisponible; }
    public void   setStockDisponible(int v)    { this.stockDisponible = v; }
}
