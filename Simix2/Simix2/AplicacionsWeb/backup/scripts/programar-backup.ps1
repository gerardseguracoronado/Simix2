# ============================================
# PROGRAMAR BACKUP AUTOMATICO - CINEWIKI
# Crea tarea en Windows Task Scheduler
# ============================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PROGRAMAR BACKUP AUTOMATICO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Opciones de frecuencia:" -ForegroundColor Yellow
Write-Host "1. Diaria (todos los dias a las 02:00)"
Write-Host "2. Semanal (domingos a las 02:00)"
Write-Host "3. Solo crear tarea (no programar)"
Write-Host ""

$opcion = Read-Host "Selecciona opcion (1/2/3)"

$scriptPath = "C:\xampp\htdocs\cinewiki\backup\scripts\backup-cinewiki.ps1"
$taskName = "CineWiki_AutoBackup"

if (Test-Path $scriptPath) {
    # Eliminar tarea existente si hay
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
    
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`""
    
    switch ($opcion) {
        "1" {
            $trigger = New-ScheduledTaskTrigger -Daily -At "02:00"
            $descripcion = "Backup diario automatico de CineWiki"
        }
        "2" {
            $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At "02:00"
            $descripcion = "Backup semanal automatico de CineWiki"
        }
        default {
            Write-Host "No se programara tarea automatica" -ForegroundColor Yellow
            exit
        }
    }
    
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Description $descripcion -RunLevel Highest | Out-Null
    
    Write-Host ""
    Write-Host "Tarea creada correctamente!" -ForegroundColor Green
    Write-Host "Nombre: $taskName" -ForegroundColor White
    Write-Host "Frecuencia: $(if($opcion -eq '1'){'Diaria'}else{'Semanal'})" -ForegroundColor White
    Write-Host "Hora: 02:00" -ForegroundColor White
    Write-Host ""
    Write-Host "Para ver la tarea: Programador de tareas de Windows" -ForegroundColor Gray
    Write-Host "Para eliminar: Unregister-ScheduledTask -TaskName '$taskName'" -ForegroundColor Gray
} else {
    Write-Host "Error: No se encontro el script de backup" -ForegroundColor Red
}