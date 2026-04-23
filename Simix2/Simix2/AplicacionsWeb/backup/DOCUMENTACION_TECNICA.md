# CINEWIKI - SISTEMA DE COPIAS DE SEGURIDAD
## Documento Técnico

---

## FASE 1: ANÁLISIS DEL PROYECTO

### 1.1 Elementos a proteger

| Elemento | Descripción | Criticidad |
|----------|-------------|-------------|
| **Código fuente** | PHP, HTML, CSS, JS del proyecto | ALTA |
| **Base de datos** | Usuarios, contraseñas, sesiones | CRÍTICA |
| **Imágenes** | Carátulas películas/series | MEDIA |
| **Logs** | Registro de actividad | BAJA |

### 1.2 Estructura del proyecto

```
C:\xampp\htdocs\cinewiki\
├── index.php          # Página principal
├── login.php          # Sistema login
├── registro.html      # Registro usuarios
├── Wiki.html          # Catálogo
├── styles.css         # Estilos
├── backend/
│   ├── conexion.php   # Conexión BBDD
│   ├── login.php      # Procesamiento login
│   ├── registro.php  # Procesamiento registro
│   └── logout.php     # Cerrar sesión
├── peliculas/         # 5 películas
├── series/            # 5 series
└── img/               # Imágenes
```

### 1.3 Base de datos: `cinewiki`

**Tabla `usuarios`:**
- id (INT, PRIMARY KEY)
- usuario (VARCHAR)
- email (VARCHAR, UNIQUE)
- password (VARCHAR, encriptado)
- created_at (TIMESTAMP)

### 1.4 Riesgos identificados

| Riesgo | Probabilidad | Impacto | Prioridad |
|--------|--------------|---------|----------|
| Fallo disco duro | Baja | Critico | ALTA |
| Error humano | Media | Alto | ALTA |
| Corrupción BBDD | Baja | Critico | ALTA |
| Ataque malware | Baja | Muy Alto | MEDIA |
| Actualización fallida | Media | Medio | MEDIA |

### 1.5 Justificación de frecuencia

**Base de datos:** La BBDD cambia frecuentemente (registros de usuarios). Se requiere **backup diario** porque:
- Cada nuevo usuario es un dato irrecuperable
- Las contraseñas están hasheadas - sin backup no se recuperan
- El riesgo de pérdida de usuarios es alto

**Proyecto:** Cambios menos frecuentes pero importantes. Se requiere **backup semanal + antes de cambios mayores**.

---

## FASE 2: DISEÑO DEL SISTEMA

### 2.1 Tipo de copias

| Tipo | Base Datos | Proyecto |
|------|------------|----------|
| Completa | Sí | Sí |
| Incremental | No necesario | No necesario |

### 2.2 Frecuencia

- **Base de datos:** Diaria automática
- **Proyecto:** Semanal + manual antes de cambios

### 2.3 Política de retención

- **Mantener:** 7 días de backups
- **Motivo:** Compromiso entre espacio y recuperación ante desastres
- **Automatización:** Script elimina backups antiguos

### 2.4 Estructura de almacenamiento

```
C:\xampp\htdocs\cinewiki\backup\
├── scripts/
│   ├── backup-cinewiki.ps1      # Copia de seguridad
│   ├── restaurar-cinewiki.ps1  # Restauración
│   ├── programar-backup.ps1    # Automatización
│   ├── EJECUTAR-BACKUP.bat      # Acceso directo
│   └── EJECUTAR-RESTAURAR.bat  # Acceso directo
├── logs/
│   └── backup_YYYY-MM-DD_HH-MM-SS.log
├── bbdd/
│   ├── backup_bbdd_cinewiki_YYYY-MM-DD_HH-MM-SS.sql
│   └── hash_YYYY-MM-DD_HH-MM-SS.txt
└── proyecto/
    └── backup_proyecto_cinewiki_YYYY-MM-DD_HH-MM-SS.zip
```
C:\xampp\backup\
├── scripts/
│   ├── backup-cinewiki.ps1      # Copia de seguridad
│   └── restaurar-cinewiki.ps1  # Restauración
├── logs/
│   └── backup_YYYY-MM-DD_HH-MM-SS.log
├── bbdd/
│   ├── backup_bbdd_cinewiki_YYYY-MM-DD_HH-MM-SS.sql
│   └── hash_YYYY-MM-DD_HH-MM-SS.txt
└── proyecto/
    └── backup_proyecto_cinewiki_YYYY-MM-DD_HH-MM-SS.zip
```

### 2.5 Nomenclatura archivos

```
backup_bbdd_cinewiki_2026-04-23_14-30-00.sql
backup_proyecto_cinewiki_2026-04-23_14-30-00.zip
backup_2026-04-23_14-30-00.log
```

---

## FASE 3: IMPLEMENTACIÓN

### 3.1 Script de Backup

```powershell
# Ubicación: C:\xampp\htdocs\cinewiki\backup\scripts\backup-cinewiki.ps1
```

### 3.2 Script de Restauración

```powershell
# Ubicación: C:\xampp\htdocs\cinewiki\backup\scripts\restaurar-cinewiki.ps1
```

### 3.3 Automatización (Windows Task Scheduler)

Para programar backup diario a las 02:00:

```powershell
# Crear tarea programada
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File C:\xampp\htdocs\cinewiki\backup\scripts\backup-cinewiki.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At "02:00"
Register-ScheduledTask -TaskName "CineWiki_Backup" -Action $action -Trigger $trigger -Description "Backup diario CineWiki" -RunLevel Highest
```

**Funcionalidades:**
1. Exporta BBDD con mysqldump
2. Comprime proyecto en ZIP
3. Genera hash SHA256 para verificación
4. Elimina backups > 7 días
5. Genera logs detallados

### 3.2 Script de Restauración

```powershell
# Ubicación: C:\xampp\backup\scripts\restaurar-cinewiki.ps1
```

**Funcionalidades:**
1. Menú interactivo
2. Seleccionar backup a restaurar
3. Restaurar BBDD o proyecto
4. Respaldo automático antes de restaurar

### 3.3 Automatización (Windows Task Scheduler)

Para programar backup diario a las 02:00:

```powershell
# Crear tarea programada
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File C:\xampp\backup\scripts\backup-cinewiki.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At "02:00"
Register-ScheduledTask -TaskName "CineWiki_Backup" -Action $action -Trigger $trigger -Description "Backup diario CineWiki" -RunLevel Highest
```

---

## FASE 4: MEJORAS IMPLEMENTADAS

### 4.1 Eliminación automática
- Script limpia backups con más de 7 días automáticamente

### 4.2 Verificación de integridad
- Hash SHA256 generado para cada backup
- Permite detectar corrupciones

### 4.3 Logs detallados
- Cada ejecución genera log con:
  - Timestamp
  - Archivos creados
  - Errores
  - Hash generado

---

## FASE 5: PROCEDIMIENTO DE RESTAURACIÓN

### 5.1 Restaurar Base de Datos

```powershell
# Ejecutar script
.\restaurar-cinewiki.ps1

# Seleccionar opción 1 (BBDD) o 3 (Ambos)
# Seleccionar backup de la lista
# Confirmar restauración
```

### 5.2 Restaurar Proyecto

```powershell
# Ejecutar script
.\restaurar-cinewiki.ps1

# Seleccionar opción 2 (Proyecto) o 3 (Ambos)
# Seleccionar backup .zip
# El script respalda versión actual antes de restaurar
```

### 5.3 Verificación post-restauración

1. Abrir navegador: http://localhost/cinewiki/
2. Probar login con usuario existente
3. Verificar imágenes cargan
4. Verificar enlaces funcionan

---

## USO DE SCRIPTS

### Ejecutar backup manual
```powershell
powershell -ExecutionPolicy Bypass -File C:\xampp\htdocs\cinewiki\backup\scripts\backup-cinewiki.ps1
```

### Restaurar desde backup
```powershell
powershell -ExecutionPolicy Bypass -File C:\xampp\htdocs\cinewiki\backup\scripts\restaurar-cinewiki.ps1
```

### Programar backup automático
```powershell
powershell -ExecutionPolicy Bypass -File C:\xampp\htdocs\cinewiki\backup\scripts\programar-backup.ps1
```

---

## RESPONSABLE: Alumno de Desarrollo Web
## FECHA: 23/04/2026
## VERSIÓN: 1.0