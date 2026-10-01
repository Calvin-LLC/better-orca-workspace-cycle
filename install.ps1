<#
.SYNOPSIS
  Install, check, or remove better-orca-workspace-cycle on Windows.

.DESCRIPTION
  Safe to re-run. Each run points the login shortcut at THIS checkout's
  orca-tap-cycle.ahk, stops any copy running from another path, starts this
  one, and checks Orca's keybindings. Re-run it after moving the folder.

    powershell -ExecutionPolicy Bypass -File install.ps1             # install / repair
    powershell -ExecutionPolicy Bypass -File install.ps1 -Check      # verify only, exit 1 on problems
    powershell -ExecutionPolicy Bypass -File install.ps1 -Uninstall
#>
[CmdletBinding()]
param(
    [switch]$Check,
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'
$Script = Join-Path $PSScriptRoot 'orca-tap-cycle.ahk'
$StartupDir = [Environment]::GetFolderPath('Startup')
$LinkPath = Join-Path $StartupDir 'orca-tap-cycle.lnk'
$KeybindingsPath = Join-Path $env:USERPROFILE '.orca\keybindings.json'

function Find-AutoHotkey {
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA 'Programs\AutoHotkey\v2\AutoHotkey64.exe'),
        (Join-Path $env:ProgramFiles 'AutoHotkey\v2\AutoHotkey64.exe')
    )
    $onPath = Get-Command AutoHotkey64.exe -ErrorAction SilentlyContinue
    if ($onPath) { $candidates += $onPath.Source }
    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path $candidate)) { return $candidate }
    }
    return $null
}

function Get-TapCycleProcesses {
    Get-CimInstance Win32_Process -Filter "Name LIKE 'AutoHotkey%'" |
        Where-Object { $_.CommandLine -match 'orca-tap-cycle\.ahk' }
}

# Any login shortcut that launches a tap-cycle script, whatever it is named.
# Old installs used other names and paths; leaving one behind starts a second
# copy from a stale folder.
function Get-TapCycleShortcuts {
    $shell = New-Object -ComObject WScript.Shell
    Get-ChildItem -Path $StartupDir -Filter '*.lnk' -ErrorAction SilentlyContinue | Where-Object {
        $link = $shell.CreateShortcut($_.FullName)
        "$($link.TargetPath) $($link.Arguments)" -match 'orca-tap-cycle\.ahk|start-tap-cycle\.cmd'
    }
}

# Returns the text of one platform block ("win32") from keybindings.json.
# Brace matching instead of ConvertFrom-Json: Windows PowerShell 5.1 rejects
# files with duplicate keys, and hand-edited keybindings often have them.
function Get-PlatformBlock([string]$json, [string]$platform) {
    $match = [regex]::Match($json, '"' + $platform + '"\s*:\s*\{')
    if (-not $match.Success) { return $null }
    $depth = 0
    for ($i = $match.Index + $match.Length - 1; $i -lt $json.Length; $i++) {
        if ($json[$i] -eq '{') { $depth++ }
        elseif ($json[$i] -eq '}') {
            $depth--
            if ($depth -eq 0) { return $json.Substring($match.Index, $i - $match.Index + 1) }
        }
    }
    return $null
}

function Test-Keybindings {
    $problems = @()
    if (-not (Test-Path $KeybindingsPath)) {
        return @("no $KeybindingsPath yet (open Orca once, then re-run)")
    }
    $block = Get-PlatformBlock (Get-Content $KeybindingsPath -Raw) 'win32'
    if (-not $block) { $block = '' }
    if ($block -notmatch '"workspace\.selectByIndex"\s*:\s*\[[^\]]*"Mod\+Shift\+1"') {
        $problems += 'win32 "workspace.selectByIndex" must include "Mod+Shift+1" (the jump chord)'
    }
    # Ctrl+PageDown is Orca's default, so a missing entry is fine; only an
    # override that drops it breaks the cycle step.
    $next = [regex]::Match($block, '"tab\.nextTerminal"\s*:\s*\[([^\]]*)\]')
    if ($next.Success -and $next.Groups[1].Value -notmatch '"Ctrl\+PageDown"') {
        $problems += 'win32 "tab.nextTerminal" is overridden without "Ctrl+PageDown" (the cycle chord)'
    }
    return $problems
}

function Write-Problems([string[]]$problems) {
    foreach ($problem in $problems) { Write-Host "  !! $problem" -ForegroundColor Yellow }
}

if ($Uninstall) {
    Get-TapCycleProcesses | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
    Get-TapCycleShortcuts | Remove-Item -Force
    Write-Host 'tap-cycle removed: script stopped, login shortcut deleted.'
    exit 0
}

if ($Check) {
    $problems = @()
    $ahk = Find-AutoHotkey
    if (-not $ahk) { $problems += 'AutoHotkey v2 is not installed' }
    $shortcuts = @(Get-TapCycleShortcuts)
    $shell = New-Object -ComObject WScript.Shell
    $good = $shortcuts | Where-Object { $shell.CreateShortcut($_.FullName).Arguments -match [regex]::Escape($Script) }
    if (-not $good) { $problems += "no login shortcut points at $Script" }
    if ($shortcuts.Count -gt 1) { $problems += "$($shortcuts.Count) login shortcuts start tap-cycle; expected 1" }
    $running = @(Get-TapCycleProcesses)
    if (-not ($running | Where-Object { $_.CommandLine -match [regex]::Escape($Script) })) {
        $problems += 'tap-cycle is not running from this checkout'
    }
    if ($running.Count -gt 1) { $problems += "$($running.Count) tap-cycle processes running; expected 1" }
    $problems += Test-Keybindings
    if ($problems.Count -gt 0) {
        Write-Host 'tap-cycle check FAILED:'
        Write-Problems $problems
        exit 1
    }
    Write-Host "tap-cycle OK: running from $Script, starts at login, keybindings match."
    exit 0
}

$ahk = Find-AutoHotkey
if (-not $ahk) {
    Write-Host 'AutoHotkey v2 is not installed. Get it from https://www.autohotkey.com/ (per-user install is fine), then re-run.' -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $Script)) {
    Write-Host "Missing $Script. Run install.ps1 from inside the repo checkout." -ForegroundColor Red
    exit 1
}

Get-TapCycleShortcuts | Remove-Item -Force
$shell = New-Object -ComObject WScript.Shell
$link = $shell.CreateShortcut($LinkPath)
$link.TargetPath = $ahk
$link.Arguments = "`"$Script`""
$link.WorkingDirectory = $PSScriptRoot
$link.Description = 'Orca tap-cycle (better-orca-workspace-cycle)'
$link.Save()

Get-TapCycleProcesses | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Process -FilePath $ahk -ArgumentList "`"$Script`"" -WorkingDirectory $PSScriptRoot
Start-Sleep -Milliseconds 800

$running = Get-TapCycleProcesses | Where-Object { $_.CommandLine -match [regex]::Escape($Script) }
if (-not $running) {
    Write-Host 'tap-cycle did not stay running. Run the .ahk by hand to see the AutoHotkey error.' -ForegroundColor Red
    exit 1
}
Write-Host "tap-cycle running (pid $($running.ProcessId)) from $Script"
Write-Host "login shortcut: $LinkPath"
$problems = Test-Keybindings
if ($problems.Count -gt 0) {
    Write-Host 'Orca keybindings need attention (see docs/keybindings.md), then restart Orca:'
    Write-Problems $problems
    exit 1
}
Write-Host 'Orca keybindings match.'
