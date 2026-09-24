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
    if not f then return nil, nil, -1 end
    local raw = f:read("*a") or ""
    f:close()
    return raw:match('"digit"%s*:%s*"?(%d)"?'), raw:match('"last"%s*:%s*"?(%d)"?'), tonumber(raw:match('"ts"%s*:%s*([%d%.]+)')) or -1
end

local function tap_save(digit, last, ts)
    local f = io.open(tapStatePath, "w")
    if not f then return end
    f:write(string.format('{"digit": "%s", "last": "%s", "ts": %.2f}', digit, last, ts))
    f:close()
end

for i = 1, 9 do
    local key = tostring(i % 10)
    -- Consuming on purpose. Forwarding the real key drops Ctrl and types the digit.
    hl.bind("CTRL + " .. key, function()
        local win = hl.get_active_window()
        local cls = win and ((win.class or "") .. " " .. (win.initial_class or "")):lower() or ""
        local now = tap_now()
        local digit_state, last, last_ts = tap_load()
        if last == key and now - last_ts < 0.15 then return end
        if cls:find("orca", 1, true) then
            if digit_state == key then
                hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL", key = "Page_Down", window = "class:orca" }))
            else
                hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL SHIFT", key = key, window = "class:orca" }))
            end
            tap_save(key, key, now)
        else
            hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL", key = key }))
            tap_save(digit_state or "-", key, now)
        end
    end)
end
