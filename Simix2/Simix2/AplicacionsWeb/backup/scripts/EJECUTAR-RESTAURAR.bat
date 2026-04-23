@echo off
chcp 65001 >nul
title CineWiki - Sistema de Restauracion
echo.
echo ========================================
echo   CINEWIKI - RESTAURAR DESDE BACKUP
echo ========================================
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0restaurar-cinewiki.ps1"
echo.
pause