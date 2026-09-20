# How it works

The script owns plain `Ctrl+1` through `Ctrl+9` while the Orca window is focused.

Each digit keeps one piece of state: the digit pressed last. Nothing else is stored.

- Different digit than last time: send `Ctrl+Shift+digit`, which Orca reads as `workspace.selectByIndex`. Remember this digit.
- Same digit as last time: send `Ctrl+PgDn`, which Orca reads as `tab.nextTerminal`. Keep the digit remembered, so the next same-digit press cycles again.
- Presses less than 150 ms apart: ignore, since that is key auto-repeat from holding the key down, not a new tap.

There is no timer. A same-digit press cycles no matter how much time has passed since the jump. Only a different digit changes the armed state.

The `#HotIf` guard limits the hotkeys to the Orca window and to presses with no Shift, Alt, or Win held. That keeps `Ctrl+Shift+N` available for direct workspace jumps and keeps other apps unaffected.
