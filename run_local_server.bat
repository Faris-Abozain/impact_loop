@echo off
title ImpactLoop Local API Server
echo ====================================================
echo   Starting ImpactLoop Local Mock API Server
echo   OpenAPI 3.0.3 Contract Implementation
echo ====================================================

REM Bridge port 3000 to all connected Android devices/emulators via ADB
set ADB_BIN="%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
if not exist %ADB_BIN% (
    where adb >nul 2>&1 && set ADB_BIN=adb
)

if defined ADB_BIN (
    echo [INFO] Bridging Android emulator/device port 3000 via adb reverse...
    %ADB_BIN% reverse tcp:3000 tcp:3000 >nul 2>&1
    for /f "tokens=1" %%d in ('%ADB_BIN% devices ^| findstr /r "device$"') do (
        echo   - Bridging device %%d
        %ADB_BIN% -s %%d reverse tcp:3000 tcp:3000 >nul 2>&1
    )
)

cd /d "%~dp0server"
if not exist node_modules (
    echo [INFO] Installing server dependencies...
    call npm.cmd install
)

echo [INFO] Starting Node.js server on port 3000...
node server.js
pause
