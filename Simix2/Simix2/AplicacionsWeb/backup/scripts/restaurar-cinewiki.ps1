# ============================================
# SCRIPT DE RESTAURACIÓN - CINEWIKI
# Restaura base de datos y proyecto desde backup
# ============================================

# CONFIGURACIÓN
$mysqlHost = "localhost"
$mysqlUser = "root"
$mysqlPass = ""
$mysqlDatabase = "cinewiki"

$rutasBackup = @{
    "BBDD" = "C:\xampp\htdocs\cinewiki\backup\bbdd"
    "Proyecto" = "C:\xampp\htdocs\cinewiki\backup\proyecto"
}

$proyectoOriginal = "C:\xampp\htdocs\cinewiki"
$proyectoBackup = "C:\xampp\htdocs\cinewiki_backup_temp"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CINEWIKI - SISTEMA DE RESTAURACIÓN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

function Write-Log {
    param([string]$mensaje, [string]$tipo = "INFO")
    switch ($tipo) {
        "OK"   { Write-Host "[OK] $mensaje" -ForegroundColor Green }
        "ERROR" { Write-Host "[ERROR] $mensaje" -ForegroundColor Red }
        "WARN"  { Write-Host "[WARN] $mensaje" -ForegroundColor Yellow }
        default { Write-Host "[INFO] $mensaje" -ForegroundColor Gray }
    }
}

# ============================================
# MENÚ DE SELECCIÓN
# ============================================
Write-Host "Selecciona qué quieres restaurar:" -ForegroundColor White
Write-Host "1. Base de Datos" -ForegroundColor White
Write-Host "2. Proyecto completo" -ForegroundColor White
Write-Host "3. Ambos" -ForegroundColor White
Write-Host ""
$opcion = Read-Host "Opción (1/2/3)"

# ============================================
# MOSTRAR BACKUPS DISPONIBLES
# ============================================
Write-Host ""

if ($opcion -eq "1" -or $opcion -eq "3") {
    Write-Host "BACKUPS DE BASE DE DATOS DISPONIBLES:" -ForegroundColor Yellow
    $bbddBackups = Get-ChildItem -Path $rutasBackup.BBDD -Filter "*.sql" | Sort-Object LastWriteTime -Descending
    if ($bbddBackups) {
        $bbddBackups | ForEach-Object -Begin { $i = 1 } -Process {
            Write-Host "  $i - $($_.Name)" -ForegroundColor White
            $i++
        }
    } else {
        Write-Log "No hay backups de BBDD disponibles" "WARN"
        $opcion = "2"
    }
    Write-Host ""
}

if ($opcion -eq "2" -or $opcion -eq "3") {
    Write-Host "BACKUPS DE PROYECTO DISPONIBLES:" -ForegroundColor Yellow
    $proyectoBackups = Get-ChildItem -Path $rutasBackup.Proyecto -Filter "*.zip" | Sort-Object LastWriteTime -Descending
    if ($proyectoBackups) {
        $proyectoBackups | ForEach-Object -Begin { $i = 1 } -Process {
            Write-Host "  $i - $($_.Name)" -ForegroundColor White
            $i++
        }
    } else {
        Write-Log "No hay backups de proyecto disponibles" "WARN"
        $opcion = "1"
    }
    Write-Host ""
}

# ============================================
# RESTAURACIÓN BASE DE DATOS
# ============================================
if ($opcion -eq "1" -or $opcion -eq "3") {
    Write-Host "--- RESTAURANDO BASE DE DATOS ---" -ForegroundColor Magenta
    
    $bbddBackups = Get-ChildItem -Path $rutasBackup.BBDD -Filter "*.sql" | Sort-Object LastWriteTime -Descending
    if ($bbddBackups) {
        Write-Host "Selecciona backup (1-$($bbddBackups.Count)):"
        $sel = Read-Host
        
        if ($sel -match '^\d+$' -and $sel -gt 0 -and $sel -le $bbddBackups.Count) {
            $backupFile = $bbddBackups[$sel - 1].FullName
            
            Write-Log "Eliminando base de datos actual..."
            $mysql = "C:\xampp\mysql\bin\mysql.exe"
            
            # Eliminar y crear BBDD
            & $mysql -h$mysqlHost -u$mysqlUser -e "DROP DATABASE IF EXISTS $mysqlDatabase;" 2>$null
            & $mysql -h$mysqlHost -u$mysqlUser -e "CREATE DATABASE $mysqlDatabase CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>$null
            
            Write-Log "Restaurando desde: $($bbddBackups[$sel - 1].Name)"
            & $mysql -h$mysqlHost -u$mysqlUser $mysqlDatabase < $backupFile 2>$null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Base de datos restaurada correctamente" "OK"
            } else {
                Write-Log "Error al restaurar base de datos" "ERROR"
            }
        }
    }
}

# ============================================
# RESTAURACIÓN PROYECTO
# ============================================
if ($opcion -eq "2" -or $opcion -eq "3") {
    Write-Host "--- RESTAURANDO PROYECTO ---" -ForegroundColor Magenta
    
    $proyectoBackups = Get-ChildItem -Path $rutasBackup.Proyecto -Filter "*.zip" | Sort-Object LastWriteTime -Descending
    if ($proyectoBackups) {
        Write-Host "Selecciona backup (1-$($proyectoBackups.Count)):"
        $sel = Read-Host
        
        if ($sel -match '^\d+$' -and $sel -gt 0 -and $sel -le $proyectoBackups.Count) {
            $backupZip = $proyectoBackups[$sel - 1].FullName
            
            if (Test-Path $proyectoOriginal) {
                Write-Log "Respaldando proyecto actual..."
                if (Test-Path "$proyectoOriginal\_old") {
                    Remove-Item "$proyectoOriginal\_old" -Recurse -Force
                }
                Move-Item $proyectoOriginal "$proyectoOriginal\_old" -Force
            }
            
            Write-Log "Restaurando desde: $($proyectoBackups[$sel - 1].Name)"
            Expand-Archive -Path $backupZip -DestinationPath "C:\xampp\htdocs" -Force
            
            # Limpiar backup old si todo OK
            if (Test-Path "$proyectoOriginal\_old") {
                Remove-Item "$proyectoOriginal\_old" -Recurse -Force
            }
            
            Write-Log "Proyecto restaurado correctamente" "OK"
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESTAURACIÓN FINALIZADA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""