# Better Orca workspace cycle

Ctrl+number keys in Orca get two jobs. The first press jumps to the workspace in that slot. Press the same number again and it steps through the terminal tabs in that workspace. It stays on cycle duty until you press a different number.

Tested on Orca 1.4.204 for Windows with AutoHotkey v2.

## Requirements

- Windows with Orca installed
- AutoHotkey v2 (`AutoHotkey64.exe`)
- These Orca bindings:
  - `workspace.selectByIndex` on `Mod+Shift+1` (sends `Ctrl+Shift+N` on Windows)
  - `tab.nextTerminal` on `Ctrl+PageDown` (the Orca default)

`keybindings.example.json` shows the exact shape. Merge the `win32` block into `~/.orca/keybindings.json` if yours differs.

## Install

1. Install AutoHotkey v2.
2. Clone this repo or copy the three files anywhere.
3. Check your Orca keybindings match the requirements above.
4. Double-click `start-tap-cycle.cmd`.

To run it on every login, put a shortcut to `start-tap-cycle.cmd` in `shell:startup`.

## Usage

- `Ctrl+3` jumps to workspace 3.
- `Ctrl+3` again steps to the next terminal tab there.
- Keep pressing `Ctrl+3` to keep stepping.
- `Ctrl+4` jumps to workspace 4 and arms 4 for cycling.

Holding the keys does nothing extra. Presses closer than 150 ms apart count as key repeat and get ignored.

`Ctrl+Shift+N`, `Ctrl+Alt+N`, and `Ctrl+Win+N` pass through to Orca untouched. The script only acts when the Orca window is focused.

## Files

- `orca-tap-cycle.ahk` holds the hotkeys and the jump-or-cycle logic.
- `start-tap-cycle.cmd` starts the script with your per-user AutoHotkey install and complains clearly if the exe or script is missing.
- `keybindings.example.json` shows the Orca bindings the script expects.

## Limits

- Workspaces are positional. If they reorder, the digit follows the new order.
- It cycles terminal tabs, not split panes inside one tab.
- The armed digit is memory in the script. If you switch workspaces with the mouse and then press the same digit, it cycles instead of jumping. Press any other digit first to re-arm the jump.
- The helper must be running. If nothing happens, check for `AutoHotkey64.exe` in Task Manager and rerun the `.cmd`.

## Docs

- `docs/how-it-works.md` explains the state machine in ten lines.
- `docs/keybindings.md` explains the expected bindings and what breaks if they differ.
- `docs/troubleshooting.md` covers the common failures.
