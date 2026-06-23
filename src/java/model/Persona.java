/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author annym
 */
public class Persona {
    private int    idPersona;
    private String nombre;
    private String documento;
    private String correo;
    private String celular;
    private String direccion;
    private String contrasena;
    private String estado;   // activo | inactivo | sancionado
    private String tipo;     // comprador | vendedor | admin

    public Persona() {}

    public int    getIdPersona()           { return idPersona; }
    public void   setIdPersona(int v)      { this.idPersona = v; }
    public String getNombre()              { return nombre; }
    public void   setNombre(String v)      { this.nombre = v; }
    public String getDocumento()           { return documento; }
    public void   setDocumento(String v)   { this.documento = v; }
    public String getCorreo()              { return correo; }
    public void   setCorreo(String v)      { this.correo = v; }
    public String getCelular()             { return celular; }
    public void   setCelular(String v)     { this.celular = v; }
    public String getDireccion()           { return direccion; }
    public void   setDireccion(String v)   { this.direccion = v; }
    public String getContrasena()          { return contrasena; }
    public void   setContrasena(String v)  { this.contrasena = v; }
    public String getEstado()              { return estado; }
    public void   setEstado(String v)      { this.estado = v; }
    public String getTipo()                { return tipo; }
    public void   setTipo(String v)        { this.tipo = v; }
}
