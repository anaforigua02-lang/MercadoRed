<%-- 
    Document   : registro
    Created on : 9/04/2026, 10:53:10 a. m.
    Author     : annym
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String error = (String) request.getAttribute("error");
    String ctx   = request.getContextPath();
    java.util.Map params = (java.util.Map) request.getAttribute("datos");
    java.util.function.Function<String,String> val = k -> {
        if (params == null) return "";
        String[] v = (String[]) params.get(k);
        return (v != null && v.length > 0) ? v[0] : "";
    };
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MercadoRed — Registro</title>
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <style>
    body { background:var(--cream); }
    .reg-wrap { min-height:100vh; display:flex; align-items:center; justify-content:center; padding:40px 20px; }
    .reg-card  { background:var(--white); border-radius:20px; padding:48px 44px; width:100%; max-width:580px; box-shadow:var(--shadow); }
    .reg-brand { font-family:var(--font-display); font-size:1.8rem; color:var(--dark); text-align:center; margin-bottom:4px; }
    .reg-brand span { color:var(--accent); font-style:italic; }
    .reg-sub   { text-align:center; color:var(--muted); font-size:.83rem; margin-bottom:28px; }
    .tab-sel   { display:flex; margin-bottom:24px; border:2px solid var(--sand); border-radius:8px; overflow:hidden; }
    .tab-sel button { flex:1; padding:12px; border:none; background:transparent; cursor:pointer; font-family:var(--font-body); font-size:.82rem; font-weight:600; letter-spacing:1px; text-transform:uppercase; color:var(--muted); transition:all .2s; }
    .tab-sel button.activo { background:var(--dark); color:var(--cream); }
    .form-group { margin-bottom:16px; }
    .form-group label { display:block; font-size:.72rem; font-weight:600; letter-spacing:1.5px; text-transform:uppercase; color:var(--muted); margin-bottom:6px; }
    .form-group input, .form-group select { width:100%; padding:11px 14px; border:1.5px solid var(--sand); border-radius:6px; font-family:var(--font-body); font-size:.93rem; color:var(--dark); background:var(--cream); outline:none; transition:border-color .2s; box-sizing:border-box; }
    .form-group input:focus, .form-group select:focus { border-color:var(--terra); background:#fff; }
    .form-group input[type=file] { padding:8px; background:#fff; cursor:pointer; }
    .form-row  { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
    .seccion-vendedor { display:none; border-top:1px solid var(--sand); padding-top:20px; margin-top:12px; }
    .seccion-vendedor.visible { display:block; }
    .nota-card { border-radius:8px; padding:14px 16px; font-size:.82rem; margin-bottom:16px; }
    .nota-info { background:var(--sand); color:var(--muted); }
    .nota-warn { background:#fff8e1; color:#8b6000; border-left:3px solid #f9ab00; }

   
    .contrato-box { border:1.5px solid var(--sand); border-radius:10px; padding:16px; margin-bottom:16px; background:#fafaf8; }
    .contrato-box h4 { font-size:.85rem; color:var(--dark); margin-bottom:10px; font-family:var(--font-display); }
    .contrato-texto { max-height:120px; overflow-y:auto; font-size:.78rem; color:var(--muted); line-height:1.6; margin-bottom:12px; padding:10px; background:#f0eeec; border-radius:6px; }
    .check-contrato { display:flex; align-items:flex-start; gap:10px; cursor:pointer; }
    .check-contrato input[type=checkbox] { margin-top:2px; width:16px; height:16px; accent-color:var(--terra); flex-shrink:0; }
    .check-contrato span { font-size:.82rem; color:var(--dark); line-height:1.5; }


    .doc-upload { border:2px dashed var(--sand); border-radius:10px; padding:20px; text-align:center; cursor:pointer; transition:border-color .2s; background:#fafaf8; }
    .doc-upload:hover { border-color:var(--terra); }
    .doc-upload .icon { font-size:2rem; margin-bottom:8px; }
    .doc-upload p { font-size:.82rem; color:var(--muted); margin:0; }
    .doc-upload input[type=file] { display:none; }
    .doc-nombre { font-size:.8rem; color:var(--terra); font-weight:600; margin-top:8px; display:none; }

    .btn-block { width:100%; justify-content:center; padding:14px; font-size:.85rem; margin-top:8px; }
    .ya-cuenta { text-align:center; margin-top:16px; font-size:.83rem; color:var(--muted); }
    .ya-cuenta a { color:var(--terra); font-weight:600; text-decoration:none; }
  </style>
  <script>
    function selTipo(tipo) {
      document.getElementById('tipo').value = tipo;
      document.getElementById('tab-comprador').classList.toggle('activo', tipo === 'comprador');
      document.getElementById('tab-vendedor').classList.toggle('activo',  tipo === 'vendedor');
      var sv = document.getElementById('seccion-vendedor');
      sv.classList.toggle('visible', tipo === 'vendedor');
      document.getElementById('cuentaBancaria').required = (tipo === 'vendedor');
      document.getElementById('banco').required          = (tipo === 'vendedor');
      document.getElementById('docDigital').required     = (tipo === 'vendedor');
      document.getElementById('aceptaContrato').required = (tipo === 'vendedor');
    }

    function mostrarNombreDoc(input) {
      var nombre = document.getElementById('doc-nombre');
      if (input.files && input.files[0]) {
        nombre.textContent = '📎 ' + input.files[0].name;
        nombre.style.display = 'block';
      }
    }
  </script>
</head>
<body>
<div class="reg-wrap">
  <div class="reg-card">

    <div class="reg-brand">Mercado<span>Red</span></div>
    <p class="reg-sub">Crea tu cuenta — es gratis</p>

    <% if (error != null) { %>
      <div class="alert alert-error" style="margin-bottom:16px;"><%= error %></div>
    <% } %>

    <div class="tab-sel">
      <button type="button" id="tab-comprador" class="activo" onclick="selTipo('comprador')">🛒 Quiero comprar</button>
      <button type="button" id="tab-vendedor"              onclick="selTipo('vendedor')">🏪 Quiero vender</button>
    </div>

 
    <form action="<%= ctx %>/registro" method="post" enctype="multipart/form-data">
      <input type="hidden" name="paso" value="1"/>
      <input type="hidden" name="tipo" id="tipo" value="comprador"/>

 
      <div class="form-group">
        <label>Nombre completo *</label>
        <input type="text" name="nombre" required maxlength="150"
               placeholder="Ana María Forigua" value="<%= val.apply("nombre") %>"/>
      </div>
      <div class="form-row">
        <div class="form-group">
          <label>Documento de identidad *</label>
          <input type="text" name="documento" required maxlength="20"
                 placeholder="1234567890" value="<%= val.apply("documento") %>"/>
        </div>
        <div class="form-group">
          <label>Celular *</label>
          <input type="tel" name="celular" required maxlength="20"
                 placeholder="300 123 4567" value="<%= val.apply("celular") %>"/>
        </div>
      </div>
      <div class="form-group">
        <label>Correo electrónico *</label>
        <input type="email" name="correo" required maxlength="150"
               placeholder="correo@ejemplo.com" value="<%= val.apply("correo") %>"/>
      </div>
      <div class="form-group">
        <label>Dirección *</label>
        <input type="text" name="direccion" required maxlength="250"
               placeholder="Calle 123 # 45-67, Bogotá" value="<%= val.apply("direccion") %>"/>
      </div>
      <div class="form-group">
        <label>Contraseña *</label>
        <input type="password" name="contrasena" required minlength="6"
               placeholder="Mínimo 6 caracteres"/>
      </div>

  
      <div class="seccion-vendedor" id="seccion-vendedor">


        <p style="font-size:.72rem;font-weight:600;letter-spacing:1.5px;text-transform:uppercase;color:var(--muted);margin-bottom:12px;">Datos bancarios</p>
        <div class="form-row">
          <div class="form-group">
            <label>Número de cuenta</label>
            <input type="text" id="cuentaBancaria" name="cuentaBancaria"
                   maxlength="30" placeholder="0012345678901"/>
          </div>
          <div class="form-group">
            <label>Banco</label>
            <select id="banco" name="banco">
              <option value="">— Selecciona —</option>
              <option value="Bancolombia">Bancolombia</option>
              <option value="Banco Bogotá">Banco de Bogotá</option>
              <option value="Davivienda">Davivienda</option>
              <option value="BBVA">BBVA</option>
              <option value="Nequi">Nequi</option>
              <option value="Daviplata">Daviplata</option>
              <option value="Otro">Otro</option>
            </select>
          </div>
        </div>

        
        <div class="form-group">
          <label>Documento de identidad digital * (CA011)</label>
          <div class="nota-card nota-warn">
            📋 Sube una foto o PDF de tu cédula o pasaporte. Tu identidad será validada por el equipo de MercadoRed antes de poder publicar productos.
          </div>
          <div class="doc-upload" onclick="document.getElementById('docDigital').click()">
            <div class="icon">📄</div>
            <p>Haz clic para subir tu documento<br>
               <small>JPG, PNG o PDF · Máx 5MB</small></p>
            <input type="file" id="docDigital" name="docDigital"
                   accept=".jpg,.jpeg,.png,.pdf"
                   onchange="mostrarNombreDoc(this)"/>
          </div>
          <div id="doc-nombre" class="doc-nombre"></div>
        </div>

       
        <div class="contrato-box">
          <h4>📜 Contrato de comisión — MercadoRed (CA005)</h4>
          <div class="contrato-texto">
            <strong>Términos y condiciones para vendedores:</strong><br><br>
            1. MercadoRed cobra una comisión del <strong>5%</strong> sobre el valor de cada venta exitosa realizada a través de la plataforma.<br><br>
            2. El pago al vendedor se realizará dentro de los <strong>5 días hábiles</strong> siguientes a la confirmación de recepción por parte del comprador.<br><br>
            3. En caso de reclamo válido, MercadoRed tiene la facultad de retener los fondos hasta resolver la disputa.<br><br>
            4. El vendedor es responsable de la veracidad de la información publicada y del estado del producto descrito.<br><br>
            5. MercadoRed puede suspender al vendedor si detecta prácticas fraudulentas o reputación inferior a 2.0 estrellas.<br><br>
            6. El vendedor autoriza a MercadoRed a publicar sus productos en el catálogo y a mostrar su información de contacto a compradores verificados.
          </div>
          <label class="check-contrato">
            <input type="checkbox" id="aceptaContrato" name="aceptaContrato" value="si"/>
            <span>He leído y acepto el contrato de comisión y los términos y condiciones de MercadoRed para vendedores. *</span>
          </label>
        </div>

      </div>

      <button type="submit" class="btn btn-primary btn-block">Crear cuenta →</button>
    </form>

    <p class="ya-cuenta">¿Ya tienes cuenta? <a href="<%= ctx %>/login">Inicia sesión</a></p>
  </div>
</div>
</body>
</html>
