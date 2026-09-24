# better-orca-workspace-cycle

Orca gives Ctrl+number one job. This gives it two. Tap a number and jump to that Orca workspace. Tap the same number again and step to the next terminal tab inside it. Cycling continues until you tap a different number, which jumps and re-arms.

Windows runs it through AutoHotkey v2. Linux runs it through Hyprland.

## Orca keybindings

The helper sends two chords, so Orca must read them as two commands. Open `~/.orca/keybindings.json` and check the block for your platform, `win32` or `linux`.

- `workspace.selectByIndex` must be `Mod+Shift+1`. Orca maps `Mod` to `Ctrl`, so this is the `Ctrl+Shift+digit` jump chord.
- `tab.nextTerminal` must be `Ctrl+PageDown`, the Orca default. The cycle step sends that chord, so leave the binding alone unless you change the send to match.
- On Linux, clear `tab.selectByIndex` to `[]`. The Linux helper lets the real Ctrl+digit reach Orca while it works, which would otherwise also select a tab. The Windows helper swallows the key before Orca sees it, so the `win32` block may keep its binding.

`keybindings.example.json` shows a working block for both platforms. Copy the lines you need if your keybindings have other entries.

## Windows

Install AutoHotkey v2 and double-click `start-tap-cycle.cmd`. The launcher checks the per-user and per-machine install paths and then `PATH`, and it fails with a message if the exe or `orca-tap-cycle.ahk` is missing. Keep the launcher and the `.ahk` file in the same folder.

The hotkeys exist only while the Orca window is focused, so Ctrl+number behaves normally in every other app. `Ctrl+3` jumps to workspace 3 and `Ctrl+3` again steps to the next terminal tab there. `Ctrl+4` jumps to workspace 4 and arms 4.

Put a shortcut to `start-tap-cycle.cmd` in `shell:startup` to run it at every login.

## Linux (Hyprland)

Link `orca-tap-cycle` somewhere on `PATH`, then bind one non-consuming keybind per digit. Non-consuming is the part that keeps Ctrl+number working in browsers and terminals, because a normal Hyprland bind swallows the keystroke before the app sees it.

```lua
for i = 1, 9 do
    local key = tostring(i % 10)
    hl.bind("CTRL + " .. key, hl.dsp.exec_cmd(
        os.getenv("HOME") .. "/.local/bin/orca-tap-cycle " .. key), { non_consuming = true })
end
```

The helper checks the focused window and exits immediately outside Orca. Inside Orca it runs the same sticky jump-then-cycle behavior as Windows. The last digit it acted on lives in `~/.local/state/orca-tap-cycle.json`.

## Files

`orca-tap-cycle` is the Linux helper. `orca-tap-cycle.ahk` is the Windows helper and `start-tap-cycle.cmd` is its launcher. `keybindings.example.json` is the Orca keybindings reference. `docs/keybindings.md` goes deeper on the chord contract and `docs/troubleshooting.md` covers the common failures.

## License

MIT
