# Keybindings

The helper sends the chords, so Orca must read them as the two commands below.

## Expected

- `Ctrl+Shift+digit` triggers `workspace.selectByIndex`. Orca maps `Mod` to `Ctrl`, so set `workspace.selectByIndex` to `Mod+Shift+1` in your platform block, `win32` or `linux`.
- `Ctrl+PgDn` triggers `tab.nextTerminal`. This is the Orca default. Leave it alone unless you change the cycle send to match.
- On Linux keep `tab.selectByIndex` at `[]`. The helper consumes Ctrl+digit and re-emits its own chords, and an empty tab binding keeps a stray plain Ctrl+digit inert.

## What breaks if they differ

If `workspace.selectByIndex` sits on another chord, the jump sends land nowhere and Orca never swaps. Move it back to `Mod+Shift+1` or edit the jump send to match your chord.

If `tab.nextTerminal` sits on another chord, repeat presses do nothing or the wrong thing. Restore `Ctrl+PageDown` or edit the cycle send to match.

`keybindings.example.json` in the repo root shows a working block for both platforms. Copy the relevant lines, not the whole file, if your keybindings have other custom entries.
