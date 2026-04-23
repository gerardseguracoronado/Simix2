# CineWiki

Plataforma web de información sobre películas y series.

## Estructura
```
cinewiki/
├── index.php           # Página principal
├── login.php          # Login de usuarios
├── registro.html      # Registro
├── Wiki.html          # Catálogo de películas y series
├── styles.css         # Estilos
├── backend/          # Lógica PHP
│   ├── conexion.php
│   ├── login.php
│   ├── registro.php
│   └── logout.php
├── peliculas/         # Detalles de películas
├── series/           # Detalles de series
├── img/              # Imágenes
└── backup/           # Sistema de backup
    ├── scripts/
    └── DOCUMENTACION_TECNICA.md
```

## Requisitos
- XAMPP (PHP 7.4+)
- MySQL/MariaDB
- Navegador web

## Instalación
1. Clonar en `C:\xampp\htdocs\cinewiki\`
2. Importar base de datos `cinewiki`
3. Ejecutar `setup.php` del backend
4. Acceder a `http://localhost/cinewiki/`

## Base de Datos
- Host: localhost
- Usuario: root
- Base: cinewiki
- Tabla: usuarios

## Autor
Gerard Segur Coronado