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

## License

MIT
