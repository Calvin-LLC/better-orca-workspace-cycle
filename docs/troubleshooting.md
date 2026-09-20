# Troubleshooting

## Nothing happens when I press Ctrl+number

Check that `AutoHotkey64.exe` is running in Task Manager. If it is not, double-click `start-tap-cycle.cmd` again. The script exits if you close it, log out, or reboot.

## A dialog says the script file was not found

Run `start-tap-cycle.cmd` from the folder that holds `orca-tap-cycle.ahk`. The launcher finds the script next to itself and fails if you move one file without the other.

## A dialog says the AutoHotkey exe is missing

Install AutoHotkey v2, or fix the path at the top of `start-tap-cycle.cmd` if you installed it somewhere unusual. The default it looks for is `%LOCALAPPDATA%\Programs\AutoHotkey\v2\AutoHotkey64.exe`.

## First press jumps, repeat press does nothing

Your `tab.nextTerminal` binding is not on `Ctrl+PageDown`. Restore the default or edit the `Send "^{PgDn}"` line. See `docs/keybindings.md`.

## First press does not jump

Your `workspace.selectByIndex` binding is not on `Ctrl+Shift+digit`. Restore it or edit the `Send "^+" . digit` line. See `docs/keybindings.md`.

## It cycles when I wanted a jump

You pressed the same digit twice. The script cannot tell you switched workspaces with the mouse in between. Press any other digit first to re-arm the jump.

## It works in Orca but also fires elsewhere

It should not. The hotkeys only act when the Orca window is focused. If they fire in another app, you have a second copy of the script running from an old path. Kill extra `AutoHotkey64.exe` processes and start one copy from this repo.

## Two AutoHotkey icons in the tray

Same cause. `#SingleInstance Force` means a fresh start replaces the old one from the same path, but a copy launched from a different folder counts as a different script. Keep one copy and close the rest.
