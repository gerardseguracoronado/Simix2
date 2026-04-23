<?php
include("conexion.php");

$usuario = $_POST['usuario'] ?? '';
$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';

if (empty($usuario) || empty($email) || empty($password)) {
    echo "Por favor completa todos los campos. <a href='../registro.html'>Volver</a>";
    exit();
}

$usuario = $conexion->real_escape_string($usuario);
$email = $conexion->real_escape_string($email);

if (!str_ends_with($email, "@gmail.com")) {
    echo "Solo se permiten correos @gmail.com. <a href='../registro.html'>Volver</a>";
    exit();
}

$check_sql = "SELECT id FROM usuarios WHERE email = '$email'";
$check_result = $conexion->query($check_sql);

if ($check_result && $check_result->num_rows > 0) {
    echo "El correo ya está registrado. <a href='../registro.html'>Volver</a>";
    exit();
}

$password_hash = password_hash($password, PASSWORD_DEFAULT);

$sql = "INSERT INTO usuarios (usuario, email, password) VALUES ('$usuario', '$email', '$password_hash')";

if ($conexion->query($sql)) {
    header("Location: ../login.php?registrado=1");
    exit();
} else {
    echo "Error al registrar. <a href='../registro.html'>Volver</a>";
}
?>