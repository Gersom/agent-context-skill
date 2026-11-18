@echo off
cd /d "%~dp0"
where acsuite >nul 2>&1
if errorlevel 1 (
  echo Falta instalar el programa de tareas (acsuite^).
  echo Pide ayuda a quien te preparo esta carpeta.
  pause
  exit /b 1
)
acsuite board
