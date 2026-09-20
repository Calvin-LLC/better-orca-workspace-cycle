# Keybindings

The script sends two chords and depends on Orca reading them the right way.

## Expected

- `Ctrl+Shift+1` through `Ctrl+Shift+9` trigger `workspace.selectByIndex`. Set `workspace.selectByIndex` to `Mod+Shift+1` in the `win32` block and Orca maps `Mod` to `Ctrl`.
- `Ctrl+PgDn` triggers `tab.nextTerminal`. This is the Orca default, so leave it alone unless you changed it on purpose.

## What breaks if they differ

- If `workspace.selectByIndex` sits on another chord, the first press jumps nowhere or triggers the wrong command. Either move it back to `Mod+Shift+1` or edit the `Send "^+" . digit` line to match your chord.
- If `tab.nextTerminal` sits on another chord, repeat presses do nothing or the wrong thing. Either restore `Ctrl+PageDown` or edit the `Send "^{PgDn}"` line.
- If plain `Ctrl+digit` is still bound to `tab.selectByIndex` in Orca, it does not matter. The script intercepts the keystroke before Orca sees it while the Orca window is focused.

`keybindings.example.json` in the repo root shows a working `win32` block. Copy the two relevant lines, not the whole file, if your keybindings have other custom entries.
