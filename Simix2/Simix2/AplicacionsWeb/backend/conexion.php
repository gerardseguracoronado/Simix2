<?php
$conexion = new mysqli("localhost", "root", "", "cinewiki");

if ($conexion->connect_error) {
  die("Error de conexión");
}
?>
