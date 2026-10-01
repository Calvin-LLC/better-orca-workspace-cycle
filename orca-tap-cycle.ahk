#Requires AutoHotkey v2.0
#SingleInstance Force

; better-orca-workspace-cycle, Windows half. The Hyprland half is
; orca-tap-cycle.lua and follows the same contract:
;   Ctrl+N in Orca              -> Ctrl+Shift+N  (Orca's workspace.selectByIndex)
;   Ctrl+N again, same N        -> Ctrl+PgDn     (Orca's tab.nextTerminal)
;   Ctrl+N anywhere else        -> untouched
; Orca resolves both chords itself, so sidebar order and tab order are always
; Orca's own. Run install.ps1 instead of this file directly: it pins the login
; shortcut to this checkout and restarts the script.

A_IconTip := "Orca tap-cycle"

LastDigit := ""
Held := Map()

#HotIf WinActive("ahk_exe Orca.exe") and !GetKeyState("Shift", "P") and !GetKeyState("Alt", "P") and !GetKeyState("LWin", "P") and !GetKeyState("RWin", "P")
$^1::Tap("1")
$^2::Tap("2")
$^3::Tap("3")
$^4::Tap("4")
$^5::Tap("5")
$^6::Tap("6")
$^7::Tap("7")
$^8::Tap("8")
$^9::Tap("9")
#HotIf

; Why: Windows auto-repeats a held key, and every repeat would cycle another
; tab. Tracking the release makes one physical press do exactly one thing.
; These run outside the #HotIf and pass through (~), so a digit released after
; focus left Orca still clears and other apps still see the key-up.
~*1 up::Held["1"] := false
~*2 up::Held["2"] := false
~*3 up::Held["3"] := false
~*4 up::Held["4"] := false
~*5 up::Held["5"] := false
~*6 up::Held["6"] := false
~*7 up::Held["7"] := false
~*8 up::Held["8"] := false
~*9 up::Held["9"] := false

Tap(digit) {
    global LastDigit, Held
    if Held.Get(digit, false)
        return
    Held[digit] := true
    if (digit = LastDigit) {
        Send "^{PgDn}"
    } else {
        Send "^+" . digit
        LastDigit := digit
    }
}
