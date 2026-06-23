/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

/**
 *
 * @author annym
 */
package util;

import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;

/**
 * EmailService.java
 * Usa jakarta.mail que viene incluido en TomEE.
 * Si usas Tomcat puro, necesitas agregar el JAR manualmente.
 */
public class EmailService {

    private static final String REMITENTE = "anaforigua02@gmail.com";
    private static final String APP_PASS  = "wpvolfvpovkptyep"; // sin espacios

    public static void enviarCodigo(String destinatario, String nombre,
                                    String codigo, String contexto)
            throws MessagingException {

        Properties props = new Properties();
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host",            "smtp.gmail.com");
        props.put("mail.smtp.port",            "587");
        props.put("mail.smtp.ssl.trust",       "smtp.gmail.com");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(REMITENTE, APP_PASS);
            }
        });

        Message msg = new MimeMessage(session);
        try {
            msg.setFrom(new InternetAddress(REMITENTE, "MercadoRed S.A.S"));
        } catch (Exception e) {
            msg.setFrom(new InternetAddress(REMITENTE));
        }
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(destinatario));
        msg.setSubject(" Tu código de verificación — MercadoRed");

        String html =
            "<!DOCTYPE html><html><body style='font-family:Arial,sans-serif;background:#f5f0e8;margin:0;padding:20px'>" +
            "<div style='max-width:480px;margin:0 auto;background:#fff;border-radius:16px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,.1)'>" +
            "<div style='background:#1F3864;padding:28px 32px'>" +
            "<h1 style='color:#fff;margin:0;font-size:1.5rem'>Mercado<em style=\"color:#c8a882\">Red</em></h1>" +
            "<p style='color:#aac4e8;margin:4px 0 0;font-size:.82rem'>Marketplace colombiano · Bogotá</p>" +
            "</div>" +
            "<div style='padding:32px'>" +
            "<p style='color:#333'>Hola, <strong>" + nombre + "</strong> 👋</p>" +
            "<p style='color:#555;line-height:1.6'>Detectamos un intento de <strong>" + contexto + "</strong> en tu cuenta.<br>Tu código es:</p>" +
            "<div style='text-align:center;margin:28px 0'>" +
            "<span style='background:#1F3864;color:#fff;font-size:2rem;font-weight:900;letter-spacing:12px;padding:14px 24px;border-radius:10px;font-family:monospace'>" +
            codigo +
            "</span>" +
            "</div>" +
            "<p style='color:#888;font-size:.85rem;text-align:center'>⏱ Válido por <strong>10 minutos</strong>.</p>" +
            "<p style='color:#aaa;font-size:.78rem;text-align:center;margin-top:20px'>Si no fuiste tú, ignora este mensaje.</p>" +
            "</div>" +
            "<div style='background:#f5f0e8;padding:14px 32px;text-align:center'>" +
            "<p style='color:#aaa;font-size:.72rem;margin:0'>© 2026 MercadoRed S.A.S · Bogotá, Colombia</p>" +
            "</div>" +
            "</div></body></html>";

        msg.setContent(html, "text/html; charset=UTF-8");
        Transport.send(msg);
    }
}
