<?php
session_start();
$usuario = $_SESSION['usuario'] ?? null;
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>CineWiki | Películas y Series</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <header>
    <nav>
      <h1>CineWiki</h1>
      <ul>
        <li><a href="index.php">Inicio</a></li>
        <li><a href="wiki.html">Wiki</a></li>
        <li><a href="foro.html">Foro</a></li>
        <li><a href="noticias.html">Noticias</a></li>
        <li><a href="contacto.html">Contacto</a></li>
        <?php if($usuario): ?>
        <li><span class="user-name"><?= htmlspecialchars($usuario) ?></span></li>
        <li><a href="backend/logout.php" class="btn-logout">Cerrar sesión</a></li>
        <?php else: ?>
        <li><a href="login.php">Login</a></li>
        <li><a href="registro.html">Registrarse</a></li>
        <?php endif; ?>
      </ul>
    </nav>
  </header>

  <section class="hero">
    <div>
      <h2>Tu comunidad de cine y series</h2>
      <p>Descubre información detallada, curiosidades, debates y noticias sobre tus películas y series favoritas.</p>
      <a href="wiki.html" class="btn-explorar">Explorar</a>
    </div>
    <div class="card">
      <h3>Obra destacada</h3>
      <p>Análisis, curiosidades y datos de la película o serie más popular del momento.</p>
    </div>
  </section>

  <section class="card-grid">
    <div class="card">
      <h3>Wiki</h3>
      <p>Información completa sobre películas y series: reparto, trama, datos técnicos y curiosidades.</p>
      <a href="wiki.html">Ir a la Wiki</a>
    </div>

    <div class="card">
      <h3>Foro</h3>
      <p>Debate teorías, finales, opiniones y recomendaciones con otros fans.</p>
      <a href="foro.html">Ir al Foro</a>
    </div>

    <div class="card">
      <h3>Noticias</h3>
      <p>Estrenos, tráilers, premios y novedades del mundo audiovisual.</p>
      <a href="noticias.html">Ver Noticias</a>
    </div>
  </section>

  <footer>
    <p>© 2026 CineWiki · Películas y Series</p>
  </footer>
</body>
</html>