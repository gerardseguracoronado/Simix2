<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>CineWiki - Iniciar sesión</title>
  <link rel="stylesheet" href="styles.css">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body class="auth-page">
  <div class="auth-bg"></div>
  
  <div class="auth-container">
    <div class="auth-box">
      <div class="auth-logo">🎬</div>
      <h1>CineWiki</h1>
      <h2>Iniciar sesión en tu cuenta</h2>
      
      <?php if(isset($_GET['registrado'])): ?>
      <p class="success-msg">¡Registro exitoso! Ya puedes iniciar sesión.</p>
      <?php endif; ?>
      
      <?php if(isset($_GET['error'])): ?>
      <p class="error-msg">Credenciales incorrectas. Inténtalo de nuevo.</p>
      <?php endif; ?>
      
      <form action="backend/login.php" method="POST">
        <div class="input-group">
          <input type="email" name="email" placeholder="Correo electrónico" required>
          <span class="input-icon">📧</span>
        </div>
        
        <div class="input-group">
          <input type="password" name="password" placeholder="Contraseña" required>
          <span class="input-icon">🔒</span>
        </div>
        
        <div class="remember-row">
          <label>
            <input type="checkbox" name="recordar">
            Recordarme
          </label>
          <a href="#">¿Olvidaste tu contraseña?</a>
        </div>
        
        <button type="submit">Entrar</button>
      </form>
      
      <div class="auth-links">
        <p class="auth-link"><a href="index.php">← Volver al inicio</a></p>
        <p class="auth-link" style="margin-top: 0.5rem;">¿No tienes cuenta? <a href="registro.html">Regístrate gratis</a></p>
      </div>
    </div>
  </div>
</body>
</html>