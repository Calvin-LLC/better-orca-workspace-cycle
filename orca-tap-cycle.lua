-- better-orca-workspace-cycle, Hyprland half (Hyprland 0.55+ Lua config).
-- Same contract as orca-tap-cycle.ahk:
--   Ctrl+N in Orca              -> Ctrl+Shift+N    (Orca's workspace.selectByIndex)
--   Ctrl+N again, same N        -> Ctrl+Page_Down  (Orca's tab.nextTerminal)
--   Ctrl+N anywhere else        -> Ctrl+N, delivered by the compositor itself
--     (non-consuming binds never swallow it)
-- Orca resolves both chords itself, so sidebar order and tab order are always
-- Orca's own. install.sh adds a dofile() of this file to your Hyprland Lua
-- config; run it again whenever the checkout moves.
--
-- Runs inside the compositor: no process starts per keypress. The binds are
-- non-consuming, so the real key always reaches the focused app; Orca only
-- gets an extra jump/cycle shortcut when it is focused.

-- Last digit sent to Orca. Lives as long as the config; `hyprctl reload`
-- clears it, which only means the next press jumps instead of cycling.
local last_digit = nil

local function is_orca(win)
    if not win then
        return false
    end
    -- Exact match, so a window whose class merely contains "orca" keeps its
    -- own Ctrl+digit.
    return win.class == "orca" or win.initial_class == "orca"
end

local function tap(key)
    -- Non-consuming binds already delivered the real Ctrl+digit to Orca.
    -- Only send the tap-cycle chords when Orca is focused; elsewhere there
    -- is nothing to do (the app already got the key).
    if not is_orca(hl.get_active_window()) then
        return
    end
    if last_digit == key then
        hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL", key = "Page_Down" }))
    else
        hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL SHIFT", key = key }))
        last_digit = key
    end
end

-- Exposed so `hyprctl eval "orca_tap_cycle('3')"` drives the same code path
-- the keypress does (install.sh --check and manual debugging use it).
_G.orca_tap_cycle = tap

for i = 1, 9 do
    local key = tostring(i)
    -- Non-consuming: the real key reaches non-Orca apps untouched, so
    -- Brave/LibreWolf Ctrl+1..9 tab switching never depends on re-emit.
    hl.bind("CTRL + " .. key, function()
        if is_orca(hl.get_active_window()) then
            tap(key)
        end
    end, { non_consuming = true })
end
