/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author annym
 */
public class Vendedor {
 
    private int     idVendedor;
    private int     idPersona;
    private String  cuentaBancaria;
    private String  banco;
    private boolean identidadValidada;
    private double  reputacion;
    private String  documentoPath;
    private String  nombre;
    private String  documento;
    private String  correo;
    private String  estado;
 
    public Vendedor() {}
 
    public int getIdVendedor() { return idVendedor; }
    public void setIdVendedor(int idVendedor) { this.idVendedor = idVendedor; }
 
    public int getIdPersona() { return idPersona; }
    public void setIdPersona(int idPersona) { this.idPersona = idPersona; }
 
    public String getCuentaBancaria() { return cuentaBancaria; }
    public void setCuentaBancaria(String cuentaBancaria) { this.cuentaBancaria = cuentaBancaria; }
 
    public String getBanco() { return banco; }
    public void setBanco(String banco) { this.banco = banco; }
 
    public boolean isIdentidadValidada() { return identidadValidada; }
    public void setIdentidadValidada(boolean identidadValidada) { this.identidadValidada = identidadValidada; }
 
    public double getReputacion() { return reputacion; }
    public void setReputacion(double reputacion) { this.reputacion = reputacion; }
 
    public String getDocumentoPath() { return documentoPath; }
    public void setDocumentoPath(String documentoPath) { this.documentoPath = documentoPath; }
 
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
 
    public String getDocumento() { return documento; }
    public void setDocumento(String documento) { this.documento = documento; }
 
    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }
 
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
}
 