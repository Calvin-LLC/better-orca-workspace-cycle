# better-orca-workspace-cycle

One key, two jobs. Press a number and you swap to that Orca workspace. Press the same number again while you are there and you step to the next terminal tab. Press a different number and you swap again.

Windows runs it through AutoHotkey v2. Linux runs it inside Hyprland's config with no helper process.

## Orca keybindings

Open `~/.orca/keybindings.json` and check the block for your platform, `win32` or `linux`. Orca maps `Mod` to `Ctrl`.

- `tab.nextTerminal` must be `Ctrl+PageDown`, the Orca default. The cycle step sends that chord.
- On Linux, `workspace.selectByIndex` must be `Mod+1` and `tab.selectByIndex` must be `[]`. The real Ctrl+digit does the swap natively, so the keybinding has to own that chord, and the cleared tab binding keeps one press from doing two things.
- On Windows, `workspace.selectByIndex` must be `Mod+Shift+1`. The hotkey swallows Ctrl+digit and sends that chord itself, so `tab.selectByIndex` may keep `Mod+1`.

`keybindings.example.json` shows a working block for both platforms. Copy the lines you need if your keybindings have other entries.

Restart Orca after editing keybindings.json. Orca reads the file at startup, so a live edit silently does nothing.

## Windows

Install AutoHotkey v2 and double-click `start-tap-cycle.cmd`. The launcher checks the per-user and per-machine install paths and then `PATH`, and it fails with a message if the exe or `orca-tap-cycle.ahk` is missing. Keep the launcher and the `.ahk` file in the same folder.

The hotkeys exist only while the Orca window is focused, so Ctrl+number behaves normally in every other app.

Put a shortcut to `start-tap-cycle.cmd` in `shell:startup` to run it at every login.

## Linux (Hyprland)

Paste this block into your Hyprland Lua config and reload. On this setup it lives at the end of `hypr-user.lua`.

```lua
-- /proc/uptime supplies sub-second time; os.time() is whole seconds.
local tapStatePath = os.getenv("HOME") .. "/.local/state/orca-tap-cycle.json"

local function tap_now()
    local f = io.open("/proc/uptime", "r")
    if not f then return os.time() end
    local v = tonumber((f:read("*l") or ""):match("^([%d%.]+)"))
    f:close()
    return v or os.time()
end

local function tap_load()
    local f = io.open(tapStatePath, "r")
    if not f then return nil, -1 end
    local raw = f:read("*a") or ""
    f:close()
    return raw:match('"digit"%s*:%s*"?(%d)"?'), tonumber(raw:match('"ts"%s*:%s*([%d%.]+)')) or -1
end

local function tap_save(digit, ts)
    local f = io.open(tapStatePath, "w")
    if not f then return end
    f:write(string.format('{"digit": "%s", "ts": %.2f}', digit, ts))
    f:close()
end

for i = 1, 9 do
    local key = tostring(i % 10)
    hl.bind("CTRL + " .. key, function()
        local win = hl.get_active_window()
        local cls = win and ((win.class or "") .. " " .. (win.initial_class or "")):lower() or ""
        if not cls:find("orca", 1, true) then return end
        local now = tap_now()
        local last, last_ts = tap_load()
        if last == key and now - last_ts < 0.15 then return end
        if last == key then
            hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL", key = "Page_Down", window = "class:orca" }))
        end
        tap_save(key, now)
    end, { non_consuming = true })
end
```

The block runs inside the compositor. Ctrl+digit reaches whatever app is focused untouched, and in Orca the keybinding does the swap instantly. The helper only fires when the pressed digit matches the workspace it believes you are in, sending `Ctrl+PageDown` to step the terminal tab. A 150ms per-digit guard swallows key auto-repeat.

The believed workspace lives in `~/.local/state/orca-tap-cycle.json`. If you switch workspaces with the mouse, the next press of the digit you are really on may step a tab before the state resyncs. Any other digit swaps normally.

## Files

`orca-tap-cycle.ahk` is the Windows helper and `start-tap-cycle.cmd` is its launcher. `keybindings.example.json` is the Orca keybindings reference. `docs/keybindings.md` goes deeper on the chord contract and `docs/troubleshooting.md` covers the common failures.

## License

MIT
