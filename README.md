# better-orca-workspace-cycle

One key, two jobs. Press a number and you swap to that Orca workspace. Press the same number again while you are there and you step to the next terminal tab. Press a different number and you swap again.

The behavior is identical everywhere. Windows runs it through AutoHotkey v2. Hyprland runs it inside the compositor. Other Linux desktops use `orca-tap-cycle`, a portable handler any hotkey system can invoke.

## Behavior

In Orca, Ctrl+N jumps to workspace N, or steps to the next terminal tab when N is the workspace you are already in. Everywhere else Ctrl+number does exactly what that app expects.

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

## Install

One command per machine. Re-run it any time: it repairs itself and follows the folder if you move it.

Windows (needs AutoHotkey v2):

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

Linux:

```bash
./install.sh
```

- **Windows:** points the login shortcut at this checkout, stops any copy running from an old path, starts the script, and checks Orca's keybindings. Double-clicking `start-tap-cycle.cmd` does the same.
- **Hyprland with a Lua config:** writes one marked `dofile()` block into `~/.config/caelestia/hypr-user.lua` (or `~/.config/hypr/hyprland.lua`), reloads Hyprland, and confirms all nine binds are live. It runs inside the compositor, so nothing forks per keypress.
- **Other Linux desktops:** links the portable `orca-tap-cycle` handler into `~/.local/bin`. Bind Ctrl+1 through Ctrl+9 to `orca-tap-cycle 1` through `orca-tap-cycle 9` in your shortcut settings (sway/i3: `bindsym ctrl+1 exec orca-tap-cycle 1`). The bind must consume the key; the handler re-sends it for other apps.

Add `-Check` (Windows) or `--check` (Linux) to verify without changing anything, and `-Uninstall` / `--uninstall` to remove it.

The hotkeys only act while the Orca window is focused, so Ctrl+number behaves normally everywhere else. Holding a number counts as one press.

## License

MIT
