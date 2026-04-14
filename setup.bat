@echo off
:: ============================================================
:: Mercury General Hospital CTF - Windows Setup Script
:: Run this script once to set up and start the CTF machine
:: ============================================================

echo.
echo  =====================================================
echo   Mercury General Hospital - CTF Machine 2 Setup
echo  =====================================================
echo.

:: Check if Node.js is installed
where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Node.js is not installed or not in PATH.
    echo         Download from: https://nodejs.org/
    echo         Install Node.js LTS, then re-run this script.
    pause
    exit /b 1
)

:: Show Node version
echo [INFO] Node.js found:
node --version
echo.

:: Install dependencies
echo [INFO] Installing dependencies...
call npm install
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] npm install failed. Check your internet connection.
    pause
    exit /b 1
)
echo [OK] Dependencies installed.
echo.

:: Choose port
set /p USEPORT="Enter port to listen on (press ENTER for default 80): "
if "%USEPORT%"=="" set USEPORT=80

echo.
echo [INFO] Starting server on port %USEPORT%...
echo [INFO] Open your browser to: http://localhost:%USEPORT%
echo [INFO] Press Ctrl+C to stop the server.
echo.

set PORT=%USEPORT%
node server.js

pause
