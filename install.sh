#!/usr/bin/env bash
# Install, check, or remove better-orca-workspace-cycle on Linux.
#
# Safe to re-run. On Hyprland with a Lua config, each run writes one marked
# block into your user config that dofile()s THIS checkout's
# orca-tap-cycle.lua, reloads Hyprland, and confirms Ctrl+1..9 are bound.
# Re-run it after moving the folder.
#
#   ./install.sh              install / repair
#   ./install.sh --check      verify only, exit 1 on problems
#   ./install.sh --uninstall
#
# Other desktops get the portable orca-tap-cycle handler linked onto PATH and
# instructions for binding it.
set -euo pipefail

HERE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd -P)"
LUA="$HERE/orca-tap-cycle.lua"
BEGIN='-- >>> better-orca-workspace-cycle (managed by install.sh) >>>'
END='-- <<< better-orca-workspace-cycle <<<'
KEYBINDINGS="$HOME/.orca/keybindings.json"
BIN_LINK="$HOME/.local/bin/orca-tap-cycle"
# Left behind by older handlers that kept state on disk.
OLD_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/orca-tap-cycle.json"

mode="install"
case "${1:-}" in
	"") ;;
	--check) mode="check" ;;
	--uninstall) mode="uninstall" ;;
	*) echo "usage: $0 [--check|--uninstall]" >&2; exit 2 ;;
esac

say() { printf '%s\n' "$*"; }
warn() { printf '  !! %s\n' "$*"; }

# Caelestia runs ~/.config/caelestia/hypr-user.lua last and never overwrites
# it, so prefer it over the framework-owned hyprland.lua.
lua_config() {
	local f
	for f in "$HOME/.config/caelestia/hypr-user.lua" "$HOME/.config/hypr/hyprland.lua"; do
		[ -f "$f" ] && { printf '%s\n' "$f"; return 0; }
	done
	return 1
}

# hyprctl needs the instance signature, which a plain SSH or cron shell lacks.
hypr_env() {
	if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
		local runtime="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
		export XDG_RUNTIME_DIR="$runtime"
		HYPRLAND_INSTANCE_SIGNATURE="$(ls -t "$runtime/hypr" 2>/dev/null | head -n 1 || true)"
		export HYPRLAND_INSTANCE_SIGNATURE
	fi
	[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] && command -v hyprctl >/dev/null
}

# Prints the file without our block. Writes go back through `cat >` so a
# config that is a symlink into a dotfiles repo stays a symlink.
strip_block() {
	awk -v b="$BEGIN" -v e="$END" '$0==b{skip=1; next} $0==e{skip=0; next} !skip' "$1"
}

write_block() {
	local cfg="$1" tmp
	tmp="$(mktemp)"
	strip_block "$cfg" >"$tmp"
	# Drop trailing blank lines left by an earlier block before appending.
	sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$tmp"
	{
		printf '\n%s\n' "$BEGIN"
		printf 'do\n'
		printf '    local ok, err = pcall(dofile, "%s")\n' "$LUA"
		printf '    if not ok then io.stderr:write("orca-tap-cycle: ", tostring(err), "\\n") end\n'
		printf 'end\n'
		printf '%s\n' "$END"
	} >>"$tmp"
	cat "$tmp" >"$cfg"
	rm -f "$tmp"
}

# Counts plain Ctrl+1..9 binds that run Lua (modmask 4 = Ctrl only).
live_bind_count() {
	hyprctl binds -j 2>/dev/null | python3 -c '
import json, sys
try:
    binds = json.load(sys.stdin)
except ValueError:
    print(0); sys.exit()
keys = {b["key"] for b in binds if b.get("modmask") == 4 and str(b.get("key", "")) in list("123456789") and b.get("dispatcher") == "__lua"}
print(len(keys))'
}

keybinding_problems() {
	[ -f "$KEYBINDINGS" ] || { echo "no $KEYBINDINGS yet (open Orca once, then re-run)"; return; }
	python3 - "$KEYBINDINGS" <<'PY'
import json, sys
try:
    data = json.load(open(sys.argv[1], encoding="utf-8"))
except (OSError, ValueError) as error:
    print(f"unreadable keybindings: {error}"); sys.exit()
block = (data.get("platforms") or {}).get("linux") or {}
if "Mod+Shift+1" not in (block.get("workspace.selectByIndex") or []):
    print('linux "workspace.selectByIndex" must include "Mod+Shift+1" (the jump chord)')
# Ctrl+PageDown is Orca's default, so only an override that drops it breaks the cycle.
if "tab.nextTerminal" in block and "Ctrl+PageDown" not in (block["tab.nextTerminal"] or []):
    print('linux "tab.nextTerminal" is overridden without "Ctrl+PageDown" (the cycle chord)')
PY
}

problems=()
check_keybindings() {
	local line
	while IFS= read -r line; do
		[ -n "$line" ] && problems+=("$line")
	done < <(keybinding_problems)
}

cfg="$(lua_config || true)"

if [ "$mode" = "uninstall" ]; then
	if [ -n "$cfg" ] && grep -qxF -e "$BEGIN" "$cfg"; then
		tmp="$(mktemp)"; strip_block "$cfg" >"$tmp"; cat "$tmp" >"$cfg"; rm -f "$tmp"
		hypr_env && hyprctl reload >/dev/null || true
		say "removed tap-cycle block from $cfg"
	fi
	[ -L "$BIN_LINK" ] && rm -f "$BIN_LINK" && say "removed $BIN_LINK"
	exit 0
fi

if [ -z "$cfg" ]; then
	# No Hyprland Lua config: fall back to the portable handler.
	if [ "$mode" = "check" ]; then
		[ "$(readlink -f "$BIN_LINK" 2>/dev/null)" = "$HERE/orca-tap-cycle" ] || problems+=("$BIN_LINK is not linked to $HERE/orca-tap-cycle")
		check_keybindings
	else
		mkdir -p "$(dirname "$BIN_LINK")"
		ln -sfn "$HERE/orca-tap-cycle" "$BIN_LINK"
		say "linked $BIN_LINK -> $HERE/orca-tap-cycle"
		say "No Hyprland Lua config found. Bind Ctrl+1..Ctrl+9 to 'orca-tap-cycle 1'..'orca-tap-cycle 9'"
		say "in your desktop's shortcut settings; the README lists sway, i3, sxhkd, GNOME and KDE."
		check_keybindings
	fi
else
	if [ "$mode" = "check" ]; then
		grep -qxF -e "$BEGIN" "$cfg" || problems+=("no tap-cycle block in $cfg")
		grep -qF -e "pcall(dofile, \"$LUA\")" "$cfg" || problems+=("$cfg does not load $LUA (moved checkout? re-run install.sh)")
	else
		write_block "$cfg"
		rm -f "$OLD_STATE"
		say "wrote tap-cycle block to $cfg"
	fi
	if hypr_env; then
		[ "$mode" = "install" ] && hyprctl reload >/dev/null && sleep 1
		count="$(live_bind_count)"
		[ "$count" = "9" ] || problems+=("Hyprland has $count of 9 Ctrl+digit tap-cycle binds live (hyprctl reload, then check the log for orca-tap-cycle errors)")
	else
		say "  (Hyprland not reachable from this shell; binds load on the next login or reload)"
	fi
	check_keybindings
fi

if [ "${#problems[@]}" -gt 0 ]; then
	say "tap-cycle ${mode} found problems:"
	for p in "${problems[@]}"; do warn "$p"; done
	exit 1
fi
if [ -n "$cfg" ]; then
	say "tap-cycle OK: Ctrl+1..9 bound in Hyprland from $LUA, keybindings match."
else
	say "tap-cycle OK: portable handler linked, keybindings match."
fi
