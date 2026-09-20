# Troubleshooting

## Nothing happens when I press Ctrl+number

Look for `AutoHotkey64.exe` in Task Manager. If it is gone, double-click `start-tap-cycle.cmd` again. Closing the script, logging out, or rebooting stops it. While Orca runs, keep the helper running too.

## A dialog says the script file was not found

Keep `start-tap-cycle.cmd` next to `orca-tap-cycle.ahk`. The launcher looks beside itself and fails if you move one file without the other.

## A dialog says the AutoHotkey exe is missing

Install AutoHotkey v2, or fix the path at the top of `start-tap-cycle.cmd` if you installed it somewhere unusual. The default it looks for is `%LOCALAPPDATA%\Programs\AutoHotkey\v2\AutoHotkey64.exe`.

## First press jumps, repeat press does nothing

Your `tab.nextTerminal` binding is not on `Ctrl+PageDown`. Restore the default or edit the `Send "^{PgDn}"` line. See `docs/keybindings.md`.

## First press does not jump

Your `workspace.selectByIndex` binding is not on `Ctrl+Shift+digit`. Restore it or edit the `Send "^+" . digit` line. See `docs/keybindings.md`.

## It cycles when I wanted a jump

You tapped the same digit twice. The script cannot see mouse navigation, so tap any other digit first to re-arm the jump.

## It fires outside Orca

The hotkeys only act when the Orca window is focused. If they fire in another app, a second copy of the script is running from an old path. Kill extra `AutoHotkey64.exe` processes and start one copy from this repo.

## Two AutoHotkey tray icons

Same cause. A fresh start replaces the old copy from the same path, but a copy in a different folder counts as a different script. Keep one copy and close the rest.
