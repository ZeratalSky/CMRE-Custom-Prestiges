@echo off
setlocal EnableExtensions
title Open Local CMRE Test Map

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Invoke-CMRECustomPrestiges.ps1" -Action OpenTestMap
set "RESULT=%ERRORLEVEL%"

if not defined CMCP_NO_PAUSE (
    echo.
    pause
)

exit /b %RESULT%
