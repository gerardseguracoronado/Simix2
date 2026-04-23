<?php
session_start();
include("conexion.php");

$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';

if (empty($email) || empty($password)) {
    echo "Por favor completa todos los campos";
    exit();
}

$email = $conexion->real_escape_string($email);

$sql = "SELECT * FROM usuarios WHERE email = '$email'";
$resultado = $conexion->query($sql);

if ($resultado && $resultado->num_rows > 0) {
    $usuario = $resultado->fetch_assoc();
    
    if (password_verify($password, $usuario['password'])) {
        $_SESSION['usuario'] = $usuario['usuario'];
        $_SESSION['email'] = $usuario['email'];
        header("Location: ../index.php");
        exit();
    } else {
        echo "Contraseña incorrecta. <a href='../login.php'>Volver</a>";
    }
} else {
    echo "Usuario no encontrado. <a href='../login.php'>Volver</a>";
}
?>