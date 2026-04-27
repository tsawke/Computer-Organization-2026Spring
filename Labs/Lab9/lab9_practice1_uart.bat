@echo off
setlocal
if "%~1"=="" (
  echo Usage: %~nx0 COMx
  echo Example: %~nx0 COM3
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0lab9_uart_test.ps1" -Port "%~1" -Mode Practice1
