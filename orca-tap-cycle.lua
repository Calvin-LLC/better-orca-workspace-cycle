-- better-orca-workspace-cycle, Hyprland half (Hyprland 0.55+ Lua config).
-- Same contract as orca-tap-cycle.ahk:
--   Ctrl+N in Orca              -> Ctrl+Shift+N    (Orca's workspace.selectByIndex)
--   Ctrl+N again, same N        -> Ctrl+Page_Down  (Orca's tab.nextTerminal)
--   Ctrl+N anywhere else        -> Ctrl+N, re-sent unchanged
-- Orca resolves both chords itself, so sidebar order and tab order are always
-- Orca's own. install.sh adds a dofile() of this file to your Hyprland Lua
-- config; run it again whenever the checkout moves.
--
-- Runs inside the compositor: no process starts per keypress, and the bind is
-- non-repeating, so holding a digit is one press.

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
    if is_orca(hl.get_active_window()) then
        if last_digit == key then
            hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL", key = "Page_Down" }))
        else
            hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL SHIFT", key = key }))
            last_digit = key
        end
    else
        -- The bind consumed the key to make this decision, so give it back.
        hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL", key = key }))
    end
end

-- Exposed so `hyprctl eval "orca_tap_cycle('3')"` drives the same code path
-- the keypress does (install.sh --check and manual debugging use it).
_G.orca_tap_cycle = tap

for i = 1, 9 do
    local key = tostring(i)
    hl.bind("CTRL + " .. key, function()
        tap(key)
    end)
end
