@echo off
rem Double-click to install or repair tap-cycle: pins the login shortcut to this
rem folder, restarts the script, and checks Orca's keybindings.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
echo.
pause
