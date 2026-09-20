# better-orca-workspace-cycle

Orca gives Ctrl+number one job. This gives it two. Tap the number once and
you jump to that workspace. Tap it again and you step through the terminal
tabs inside it. It keeps cycling until you tap a different number.

Needs Windows, Orca, and AutoHotkey v2.

## Use

Check your Orca keybindings first. Open `~/.orca/keybindings.json` and make
sure the `win32` block has:

```json
"workspace.selectByIndex": ["Mod+Shift+1"],
"tab.nextTerminal": ["Ctrl+PageDown"]
```

`tab.nextTerminal` is the Orca default. `keybindings.example.json` in this
repo shows both lines in place. Set `workspace.selectByIndex` to
`Mod+Shift+1` if yours differs. Orca maps `Mod` to `Ctrl`.

Then:

1. Install AutoHotkey v2.
2. Double-click `start-tap-cycle.cmd`.

`Ctrl+3` jumps to workspace 3. `Ctrl+3` again steps to the next terminal
tab there. `Ctrl+4` jumps to workspace 4 and arms 4 for cycling.

Put a shortcut to `start-tap-cycle.cmd` in `shell:startup` to run it on
every login.

## How it works

The script grabs plain `Ctrl+1` through `Ctrl+9` while the Orca window is
focused and remembers one thing: the digit you pressed last.

A different digit sends `Ctrl+Shift+digit`, which Orca reads as
`workspace.selectByIndex`, and remembers that digit. The same digit again
sends `Ctrl+PgDn`, which Orca reads as `tab.nextTerminal`. There is no
timer. A repeat press cycles no matter how long you wait.

Presses under 150 ms apart are key repeat from holding the key down and get
ignored. `Ctrl+Shift+N`, `Ctrl+Alt+N`, and `Ctrl+Win+N` pass through to
Orca untouched.

## Limits

The digit follows workspace position, not identity. If workspaces reorder,
the digit points at whatever sits in that slot now.

It cycles terminal tabs, not split panes inside one tab.

The script cannot see mouse navigation. If you click into another workspace
and tap the same digit, it cycles instead of jumping. Tap any other digit
first to re-arm the jump.

The helper must be running. If keys stop working, look for
`AutoHotkey64.exe` in Task Manager and rerun the `.cmd`.

## Files

- `orca-tap-cycle.ahk` holds the hotkeys and the jump-or-cycle logic.
- `start-tap-cycle.cmd` launches the script with your per-user AutoHotkey
  install. It names the missing path if the exe or script is gone.
- `keybindings.example.json` shows the two Orca bindings the script needs.
- `docs/keybindings.md` covers what breaks if your bindings differ.
- `docs/troubleshooting.md` covers the failures I have hit.

Tested on Orca 1.4.204.

## License

MIT
