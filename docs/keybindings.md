# Keybindings

The script sends two chords. Orca must read them as the two commands below.

## Expected

- `Ctrl+Shift+1` through `Ctrl+Shift+9` trigger `workspace.selectByIndex`. Orca maps `Mod` to `Ctrl`, so set `workspace.selectByIndex` to `Mod+Shift+1` in your platform block, `win32` or `linux`.
- `Ctrl+PgDn` triggers `tab.nextTerminal`. This is the Orca default. Leave it alone unless you changed it on purpose.

## What breaks if they differ

If `workspace.selectByIndex` sits on another chord, the first press jumps nowhere or triggers the wrong command. Move it back to `Mod+Shift+1` or edit the `Send "^+" . digit` line to match your chord.

If `tab.nextTerminal` sits on another chord, repeat presses do nothing or the wrong thing. Restore `Ctrl+PageDown` or edit the `Send "^{PgDn}"` line.

If plain `Ctrl+digit` is still bound to `tab.selectByIndex` in Orca, the Windows hotkeys swallow the key before Orca sees it, so the binding does not matter. On Linux the bind passes the key through to Orca, so clear `tab.selectByIndex` to `[]` or one press both selects a tab and jumps.

`keybindings.example.json` in the repo root shows a working block for both platforms. Copy the relevant lines, not the whole file, if your keybindings have other custom entries.
