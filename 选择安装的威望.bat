@echo off
setlocal EnableExtensions
title CMRE Prestige Selector

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File "%~dp0scripts\Select-CMRECustomPrestiges.ps1"
exit /b %ERRORLEVEL%
