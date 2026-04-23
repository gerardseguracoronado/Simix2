@echo off
chcp 65001 >nul
title CineWiki - Sistema de Backup
echo.
echo ========================================
echo   CINEWIKI - COPIA DE SEGURIDAD
echo ========================================
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0backup-cinewiki.ps1"
echo.
pause