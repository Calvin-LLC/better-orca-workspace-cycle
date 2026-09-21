# better-orca-workspace-cycle

Orca gives Ctrl+number one job. This gives it two. Tap the number once and
you jump to that workspace. Tap it again and you step through the terminal
tabs inside it. It keeps cycling until you tap a different number.

Needs Orca, plus AutoHotkey v2 on Windows or Hyprland on Linux.

## Keybindings

Check your Orca keybindings first. Open `~/.orca/keybindings.json` and make
sure the `win32` block (Windows) or `linux` block (Linux) has:

```json
"workspace.selectByIndex": ["Mod+Shift+1"],
"tab.nextTerminal": ["Ctrl+PageDown"]
```

`tab.nextTerminal` is the Orca default. `keybindings.example.json` in this
repo shows both lines in place. Set `workspace.selectByIndex` to
`Mod+Shift+1` if yours differs. Orca maps `Mod` to `Ctrl`. The cycle step sends plain `Ctrl+PageDown`,
so leave that binding on the default unless you edit the Send line
to match.

## Windows

1. Install AutoHotkey v2 (per-user default, or per-machine; the
   launcher also checks `where AutoHotkey64.exe`).
2. Double-click `start-tap-cycle.cmd`.

`Ctrl+3` jumps to workspace 3. `Ctrl+3` again steps to the next terminal
tab there. `Ctrl+4` jumps to workspace 4 and arms 4 for cycling.

Put a shortcut to `start-tap-cycle.cmd` in `shell:startup` to run it on
every login.

## Linux (Hyprland)

`orca-tap-cycle` is the same sticky helper for Hyprland: first tap of a
digit sends `Ctrl+Shift+digit` (jump), repeats send `Ctrl+PageDown`
(cycle). Outside Orca focus it re-emits the plain key so other apps keep
their Ctrl+digit behavior.

1. Link it somewhere on PATH.
2. Add one bind per digit to your Hyprland config.

## License

MIT
