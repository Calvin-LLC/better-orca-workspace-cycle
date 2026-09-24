# better-orca-workspace-cycle

One key, two jobs. Press a number and you swap to that Orca workspace. Press the same number again while you are there and you step to the next terminal tab. Press a different number and you swap again.

The behavior is identical everywhere. Windows runs it through AutoHotkey v2. Linux runs `orca-tap-cycle`, a portable handler any hotkey system can invoke, with an optional zero-fork Hyprland fast path.

## Behavior

In Orca, Ctrl+N jumps to workspace N, or steps to the next terminal tab when N is the workspace you are already in. Everywhere else Ctrl+number does exactly what that app expects. A 150ms per-digit guard swallows key auto-repeat.

## Orca keybindings

Open `~/.orca/keybindings.json` and check the block for your platform, `win32` or `linux`. Orca maps `Mod` to `Ctrl`.

- `workspace.selectByIndex` must be `Mod+Shift+1` on both platforms. The helper sends `Ctrl+Shift+digit` to jump, and that chord is what Orca answers.
- `tab.nextTerminal` must be `Ctrl+PageDown`, the Orca default. The cycle step sends that chord.
- On Linux, keep `tab.selectByIndex` at `[]`. One press then does exactly one thing.

`keybindings.example.json` shows a working block for both platforms. Copy the lines you need if your keybindings have other entries.

Orca reads keybindings.json at startup. Restart it after editing the file.

## Platform support

| Platform | Mechanism | Status |
| --- | --- | --- |
| Windows | `orca-tap-cycle.ahk` on AutoHotkey v2 | Full |
| Linux, Hyprland | `orca-tap-cycle.lua` inside the compositor | Full, zero forks |
| Linux, Sway | `orca-tap-cycle` with `swaymsg` and `wtype` | Full |
| Linux, X11 | `orca-tap-cycle` with `xdotool` | Full |
| Linux, other Wayland | `orca-tap-cycle` with `wtype` | Pass-through only. Wayland hides the focused window from scripts, so Ctrl+number keeps working in apps while tap-cycle stays inert |

## Linux (portable handler)

Link `orca-tap-cycle` somewhere on `PATH`, then bind Ctrl+1 through Ctrl+9 to `orca-tap-cycle 1` through `orca-tap-cycle 9` in your desktop's global shortcut settings. The hotkey must consume the key. The handler re-emits the chord itself, so a second delivery of the original key would double-fire.

- sxhkd binds `ctrl + {1-9}` to `orca-tap-cycle {1-9}`.
- GNOME takes one custom shortcut per digit in Settings, Keyboard.
- KDE takes one command per digit in System Settings, Shortcuts.
- i3 and sway take `bindsym ctrl+1 exec orca-tap-cycle 1` and friends.

Install the tool your session needs for chords. Hyprland uses `hyprctl`, Sway uses `swaymsg` and `wtype`, X11 uses `xdotool`, other Wayland uses `wtype`.

## Linux (Hyprland fast path)

`orca-tap-cycle.lua` is the same state machine compiled into the compositor. Paste it at the end of your Hyprland Lua config or `dofile` it, then reload. Nothing forks per keypress, so the chord lands instantly even on a loaded box. The keybindings contract above is identical.

## Windows

Install AutoHotkey v2 and double-click `start-tap-cycle.cmd`. The launcher checks the per-user and per-machine install paths and then `PATH`, and it fails with a message if the exe or `orca-tap-cycle.ahk` is missing. Keep the launcher and the `.ahk` file in the same folder.

The hotkeys exist only while the Orca window is focused, so Ctrl+number behaves normally in every other app.

Put a shortcut to `start-tap-cycle.cmd` in `shell:startup` to run it at every login.

## Files

`orca-tap-cycle` is the portable Linux handler. `orca-tap-cycle.lua` is the Hyprland fast path. `orca-tap-cycle.ahk` is the Windows helper and `start-tap-cycle.cmd` is its launcher. `keybindings.example.json` is the Orca keybindings reference. `docs/keybindings.md` goes deeper on the chord contract and `docs/troubleshooting.md` covers the common failures.

## License

MIT
