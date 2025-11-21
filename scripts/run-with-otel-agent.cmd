@echo off
setlocal
set SCRIPT_DIR=%~dp0
set PROJ_DIR=%SCRIPT_DIR%..
pushd %PROJ_DIR%
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%run-with-otel-agent.ps1"
popd