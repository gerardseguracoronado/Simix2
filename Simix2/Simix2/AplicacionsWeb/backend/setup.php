<?php
$conexion = new mysqli("localhost", "root", "");

if ($conexion->connect_error) {
    die("Error de conexión: " . $conexion->connect_error);
}

$sql = "CREATE DATABASE IF NOT EXISTS cinewiki";
if ($conexion->query($sql)) {
    echo "Base de datos 'cinewiki' creada/o existente.<br>";
} else {
    die("Error al crear base de datos: " . $conexion->error);
}

$conexion->select_db("cinewiki");

$sql = "CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)";

if ($conexion->query($sql)) {
    echo "Tabla 'usuarios' creada/o existente.<br>";
} else {
    die("Error al crear tabla: " . $conexion->error);
}

echo "<br>¡Todo listo! <a href='../index.php'>Ir a CineWiki</a>";
?>