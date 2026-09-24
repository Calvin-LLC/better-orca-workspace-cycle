# Keybindings

One chord does the cycling and each platform decides who performs the swap.

## Expected

- `Ctrl+PgDn` triggers `tab.nextTerminal`. This is the Orca default. Leave it alone unless you change the cycle send to match.
- Linux. `workspace.selectByIndex` must be `Mod+1` and `tab.selectByIndex` must be `[]`. The real Ctrl+digit swaps the workspace natively and the Lua helper only sends the cycle chord.
- Windows. `workspace.selectByIndex` must be `Mod+Shift+1` in the `win32` block. The hotkey swallows Ctrl+digit and sends `Ctrl+Shift+digit`, so `tab.selectByIndex` may keep `Mod+1`.

## What breaks if they differ

If `tab.nextTerminal` sits on another chord, repeat presses do nothing or the wrong thing. Restore `Ctrl+PageDown` or edit the cycle send to match.

If Linux keeps `tab.selectByIndex` on `Mod+1`, one press both selects a tab and swaps a workspace. If Linux puts `workspace.selectByIndex` on anything but `Mod+1`, the swap stops working because the keybinding no longer owns the key Orca receives.

`keybindings.example.json` in the repo root shows a working block for both platforms. Copy the relevant lines, not the whole file, if your keybindings have other custom entries.
