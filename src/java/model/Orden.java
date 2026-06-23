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

public class Orden {
    private int       idOrden;
    private int       idComprador;
    private double    total;
    private String    estadoOrden;
    private boolean   fondosRetenidos;
    private Timestamp fechaCreacion;
    private String    nombreComprador;
    // RF012 dirección / RF013 método de pago
    private String    metodoPago;
    private String    direccionEnvio;

    public Orden() {}

    public int       getIdOrden()                 { return idOrden; }
    public void      setIdOrden(int v)            { this.idOrden = v; }
    public int       getIdComprador()             { return idComprador; }
    public void      setIdComprador(int v)        { this.idComprador = v; }
    public double    getTotal()                   { return total; }
    public void      setTotal(double v)           { this.total = v; }
    public String    getEstadoOrden()             { return estadoOrden; }
    public void      setEstadoOrden(String v)     { this.estadoOrden = v; }
    public boolean   isFondosRetenidos()          { return fondosRetenidos; }
    public void      setFondosRetenidos(boolean v){ this.fondosRetenidos = v; }
    public Timestamp getFechaCreacion()           { return fechaCreacion; }
    public void      setFechaCreacion(Timestamp v){ this.fechaCreacion = v; }
    public String    getNombreComprador()         { return nombreComprador; }
    public void      setNombreComprador(String v) { this.nombreComprador = v; }
    public String    getMetodoPago()              { return metodoPago; }
    public void      setMetodoPago(String v)      { this.metodoPago = v; }
    public String    getDireccionEnvio()          { return direccionEnvio; }
    public void      setDireccionEnvio(String v)  { this.direccionEnvio = v; }
}
