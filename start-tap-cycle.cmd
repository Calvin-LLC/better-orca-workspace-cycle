@echo off
set "AHK=%LOCALAPPDATA%\Programs\AutoHotkey\v2\AutoHotkey64.exe"
if not exist "%AHK%" ( echo Missing AutoHotkey exe: %AHK% & pause & exit /b 1 )
if not exist "%~dp0orca-tap-cycle.ahk" ( echo Missing script next to this file: %~dp0orca-tap-cycle.ahk & pause & exit /b 1 )
start "" "%AHK%" "%~dp0orca-tap-cycle.ahk"
echo tap-cycle started.
