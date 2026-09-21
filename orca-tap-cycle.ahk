#Requires AutoHotkey v2.0
#SingleInstance Force

RepeatGuardMs := 150

#HotIf WinActive("ahk_exe Orca.exe") and !GetKeyState("Shift", "P") and !GetKeyState("Alt", "P") and !GetKeyState("LWin", "P") and !GetKeyState("RWin", "P")
$^1::WorkspaceJumpOrCycleTerminal("1")
$^2::WorkspaceJumpOrCycleTerminal("2")
$^3::WorkspaceJumpOrCycleTerminal("3")
$^4::WorkspaceJumpOrCycleTerminal("4")
$^5::WorkspaceJumpOrCycleTerminal("5")
$^6::WorkspaceJumpOrCycleTerminal("6")
$^7::WorkspaceJumpOrCycleTerminal("7")
$^8::WorkspaceJumpOrCycleTerminal("8")
$^9::WorkspaceJumpOrCycleTerminal("9")
#HotIf

WorkspaceJumpOrCycleTerminal(digit) {
    global RepeatGuardMs
    static lastDigit := "", lastTime := 0
    now := A_TickCount
    gap := now - lastTime
    if (gap < RepeatGuardMs) {
        return
    }
    lastTime := now
    if (digit = lastDigit) {
        Send "^{PgDn}"
    } else {
        Send "^+" . digit
        lastDigit := digit
    }
}
