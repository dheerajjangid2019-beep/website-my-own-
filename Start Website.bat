@echo off
setlocal
cd /d "%~dp0"
set "SITE_URL=http://127.0.0.1:3001/"

call :checkServer
if not errorlevel 1 goto openSite

echo Starting Bhawani Interior website...
start "Bhawani Interior Server" /D "%~dp0" cmd /k "node backend\server.js"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$uri = '%SITE_URL%'; for ($attempt = 0; $attempt -lt 20; $attempt++) { try { $null = Invoke-WebRequest -Uri $uri -TimeoutSec 1; exit 0 } catch { Start-Sleep -Milliseconds 500 } }; exit 1" >nul 2>&1
if not errorlevel 1 goto openSite

echo.
echo The website did not start. Check the Bhawani Interior Server window for the error.
pause
exit /b 1

:checkServer
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $null = Invoke-WebRequest -Uri '%SITE_URL%' -TimeoutSec 2; exit 0 } catch { exit 1 }" >nul 2>&1
exit /b %errorlevel%

:openSite
start "" "%SITE_URL%"
echo Website opened at %SITE_URL%
exit /b 0
