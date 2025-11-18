@echo off
REM Start the Godot Bridge Server

echo Starting Godot MCP Bridge Server...
echo Server will run on http://127.0.0.1:8765
echo.

REM Check if godot is in PATH
where godot >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: 'godot' command not found!
    echo Please install Godot 4.x and add it to your PATH
    echo Or download from: https://godotengine.org/
    pause
    exit /b 1
)

REM Navigate to godot-bridge directory
cd /d "%~dp0godot-bridge"

REM Run Godot in headless mode
echo Running: godot --headless --path . bridge_server.tscn
godot --headless --path . bridge_server.tscn
