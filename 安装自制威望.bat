@echo off
setlocal EnableExtensions
title CMRE Custom Prestige Installer

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Invoke-CMRECustomPrestiges.ps1" -Action Install
set "RESULT=%ERRORLEVEL%"

if not defined CMCP_NO_PAUSE (
    echo.
    pause
)

exit /b %RESULT%
