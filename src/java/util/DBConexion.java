/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util;

/**
 *
 * @author annym
 */
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;


public class DBConexion {

    // ── Ajusta estos valores según tu instalación de MySQL Workbench ──
    private static final String URL      = "jdbc:mysql://localhost:3306/mercadored"
                                         + "?useSSL=false&serverTimezone=America/Bogota"
                                         + "&allowPublicKeyRetrieval=true";
    private static final String USUARIO  = "root";
    private static final String PASSWORD = "1234";
    private static final String DRIVER   = "com.mysql.cj.jdbc.Driver";

    /**
     * Devuelve una conexión activa a la base de datos.
     */
    public static Connection getConexion() throws SQLException {
        try {
            Class.forName(DRIVER);
            return DriverManager.getConnection(URL, USUARIO, PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException(
                "Driver MySQL no encontrado. Verifica que agregaste " +
                "mysql-connector-j-9.1.0.jar a las librerías del proyecto.", e);
        }
    }

    /**
     * Cierra una conexión de forma segura (sin lanzar excepción).
     */
    public static void cerrar(Connection conn) {
        if (conn != null) {
            try { conn.close(); } catch (SQLException ignored) {}
        }
    }
}
