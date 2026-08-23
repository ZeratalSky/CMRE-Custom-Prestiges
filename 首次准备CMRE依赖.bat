@echo off
setlocal EnableExtensions
title CMRE First-Time Dependency Setup

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Invoke-CMRECustomPrestiges.ps1" -Action PrepareDependencies
set "RESULT=%ERRORLEVEL%"

if not defined CMCP_NO_PAUSE (
    echo.
    pause
)

exit /b %RESULT%
