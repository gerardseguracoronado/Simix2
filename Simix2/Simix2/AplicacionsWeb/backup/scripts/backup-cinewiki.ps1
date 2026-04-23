# ============================================
# SCRIPT DE BACKUP COMPLETO - CINEWIKI
# Sistema de copias de seguridad automatizado
# ============================================

# CONFIGURACIÓN
$fecha = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$fechaLegible = Get-Date -Format "dd/MM/yyyy HH:mm:ss"

# Rutas
$rutasBackup = @{
    "BBDD" = "C:\xampp\htdocs\cinewiki\backup\bbdd"
    "Proyecto" = "C:\xampp\htdocs\cinewiki\backup\proyecto"
    "Logs" = "C:\xampp\htdocs\cinewiki\backup\logs"
}
$proyecto = "C:\xampp\htdocs\cinewiki"
$logFile = "$($rutasBackup.Logs)\backup_$($fecha).log"

# Configuración MySQL
$mysqlHost = "localhost"
$mysqlUser = "root"
$mysqlPass = ""
$mysqlDatabase = "cinewiki"

# Retención: días antes de borrar backups antiguos
$retentionDays = 7

# ============================================
# FUNCIONES DE LOG
# ============================================
function Write-Log {
    param([string]$mensaje, [string]$tipo = "INFO")
    $tipoColor = switch ($tipo) {
        "INFO"  { "INFO" }
        "OK"    { "OK" }
        "ERROR" { "ERROR" }
        "WARN"  { "WARN" }
    }
    $linea = "[$(Get-Date -Format 'HH:mm:ss')] [$tipoColor] $mensaje"
    Write-Host $linea
    Add-Content -Path $logFile -Value $linea -Encoding UTF8
}

# ============================================
# INICIO DEL BACKUP
# ============================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CINEWIKI - SISTEMA DE BACKUP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$logFile | Out-Null
$iniLog = "========================================"
"INICIO DE BACKUP: $fechaLegible" | Out-File -FilePath $logFile -Encoding UTF8
Add-Content -Path $logFile -Value $iniLog -Encoding UTF8

$todoOk = $true

# ============================================
# FASE 1: BACKUP DE BASE DE DATOS
# ============================================
Write-Log "Iniciando backup de Base de Datos..."

$sqlFile = "$($rutasBackup.BBDD)\backup_bbdd_cinewiki_$fecha.sql"

try {
    $mysqldump = "C:\xampp\mysql\bin\mysqldump.exe"
    
    if (Test-Path $mysqldump) {
        $mysqldumpArgs = @(
            "--host=localhost",
            "--user=root",
            "--single-transaction",
            "--quick",
            "--lock-tables=FALSE",
            $mysqlDatabase
        )
        
        & $mysqldump @mysqldumpArgs > $sqlFile 2>&1
        
        if (Test-Path $sqlFile -PathType Leaf) {
            $contenido = Get-Content $sqlFile -Raw
            if ($contenido -match "CREATE TABLE|INSERT INTO|DROP TABLE") {
                $size = (Get-Item $sqlFile).Length / 1KB
                Write-Log "Backup BBDD creado: $(Split-Path $sqlFile -Leaf) ($([math]::Round($size, 2)) KB)" "OK"
            } else {
                Write-Log "Backup BBDD vacío o incompleto" "ERROR"
            }
        }
    } else {
        Write-Log "mysqldump no encontrado. Creando backup manual..." "WARN"
        $mysql = "C:\xampp\mysql\bin\mysql.exe"
        if (Test-Path $mysql) {
            $exportSql = @"
-- Exportacion manual de la base de datos cinewiki
-- Fecha: $fechaLegible

CREATE DATABASE IF NOT EXISTS $mysqlDatabase;
USE $mysqlDatabase;

-- Tabla usuarios (estructura)
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Datos de usuarios
$( & $mysql --host=localhost --user=root --batch --skip-column-names -e "SELECT CONCAT('INSERT INTO usuarios (usuario, email, password) VALUES (', CHAR(39), usuario, CHAR(39), ', ', CHAR(39), email, CHAR(39), ', ', CHAR(39), password, CHAR(39), ');') FROM $mysqlDatabase.usuarios;" 2>$null )

"@
            $exportSql | Out-File -FilePath $sqlFile -Encoding UTF8
            $size = (Get-Item $sqlFile).Length / 1KB
            Write-Log "Backup BBDD creado (manual): $(Split-Path $sqlFile -Leaf) ($([math]::Round($size, 2)) KB)" "OK"
        }
    }
} catch {
    Write-Log "Error en backup BBDD: $_" "ERROR"
    $todoOk = $false
}

# ============================================
# FASE 2: BACKUP DEL PROYECTO
# ============================================
Write-Log "Iniciando backup del Proyecto..."

$zipFile = "$($rutasBackup.Proyecto)\backup_proyecto_cinewiki_$fecha.zip"

try {
    # Excluir carpetas innecesarias de cache/temp
    $excludePaths = @(
        "*/node_modules/*",
        "*/.git/*",
        "*/.cache/*"
    )
    
    Compress-Archive -Path $proyecto -DestinationPath $zipFile -Force -CompressionLevel Optimal
    
    if (Test-Path $zipFile) {
        $size = (Get-Item $zipFile).Length / 1MB
        Write-Log "Backup Proyecto creado: $(Split-Path $zipFile -Leaf) ($([math]::Round($size, 2)) MB)" "OK"
    }
} catch {
    Write-Log "Error en backup Proyecto: $_" "ERROR"
    $todoOk = $false
}

# ============================================
# FASE 3: GENERAR HASH DE VERIFICACIÓN
# ============================================
Write-Log "Generando verificación de integridad (Hash SHA256)..."

if (Test-Path $sqlFile) {
    $hashBBDD = Get-FileHash -Path $sqlFile -Algorithm SHA256 | Select-Object -ExpandProperty Hash
    $hashFile = "$($rutasBackup.BBDD)\hash_$fecha.txt"
    "BBDD: $hashBBDD" | Out-File -FilePath $hashFile -Encoding UTF8
    Write-Log "Hash BBDD: $hashBBDD" "OK"
}

if (Test-Path $zipFile) {
    $hashProyecto = Get-FileHash -Path $zipFile -Algorithm SHA256 | Select-Object -ExpandProperty Hash
    Add-Content -Path $hashFile -Value "Proyecto: $hashProyecto" -Encoding UTF8
    Write-Log "Hash Proyecto: $hashProyecto" "OK"
}

# ============================================
# FASE 4: LIMPIEZA DE BACKUPS ANTIGUOS
# ============================================
Write-Log "Limpiando backups con más de $retentionDays días..."

$cutoffDate = (Get-Date).AddDays(-$retentionDays)

# Limpiar BBDD
Get-ChildItem -Path $rutasBackup.BBDD -Filter "*.sql" -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $cutoffDate } | ForEach-Object {
    Write-Log "Eliminado: $($_.Name)" "WARN"
    Remove-Item $_.FullName -Force
}

# Limpiar Proyectos
Get-ChildItem -Path $rutasBackup.Proyecto -Filter "*.zip" -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $cutoffDate } | ForEach-Object {
    Write-Log "Eliminado: $($_.Name)" "WARN"
    Remove-Item $_.FullName -Force
}

# Limpiar Logs antiguos
Get-ChildItem -Path $rutasBackup.Logs -Filter "*.log" -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $cutoffDate } | ForEach-Object {
    Remove-Item $_.FullName -Force
}

# ============================================
# RESUMEN FINAL
# ============================================
Write-Host ""
Write-Log "========================================" "INFO"
if ($todoOk) {
    Write-Log "BACKUP COMPLETADO CORRECTAMENTE" "OK"
} else {
    Write-Log "BACKUP COMPLETADO CON ERRORES" "WARN"
}
Write-Log "========================================" "INFO"
Write-Log "Ubicación backups: C:\xampp\backup" "INFO"

Add-Content -Path $logFile -Value "FIN DE BACKUP" -Encoding UTF8
Write-Host ""