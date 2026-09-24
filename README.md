# Better Workspace Cycle

An Orca plugin. Press Ctrl+N on workspace N to cycle its terminal tabs.
Press Ctrl+N on any other workspace to switch to workspace N.

State decides which, never timing. There is no double tap, no key hold,
and no time window anywhere in the design.

Everything happens inside Orca. The keys are Orca keybindings, the
decision runs in an Orca plugin worker, and the switching rides Orca's own
`orca terminal switch` daemon command. No synthetic keyboard events
exist in any layer, which is also why this behaves identically on Linux,
Windows, and macOS.

## Why a plugin

Earlier revisions of this repo drove Orca through window-manager hotkeys
and synthetic key chords. Synthetic chords that re-press keys you are
already holding corrupt the compositor's key state, which produced typed
digits, stuck keys, and phantom repeats. None of that machinery exists
anymore.

## Behavior

| Situation | Press Ctrl+N |
|---|---|
| Current workspace is N | Switch to the next terminal tab in workspace N |
| Current workspace is not N | Switch to workspace N |

`Mod` in the keybindings is Ctrl on Linux and Windows, Cmd on macOS.

## How it works

The worker asks Orca which workspace has focus through the plugin host
method `workspace.readContext`, maps that workspace to its index in
Orca's own workspace order, and compares the index with the pressed
number. A match cycles the focused workspace's terminal tabs, one step
per press, wrapping around. A mismatch switches to the target workspace
through `orca terminal switch` pointed at that workspace's first
terminal tab.

Known edges. Orca's CLI has no bare "select workspace" verb, so a
workspace with zero terminals cannot be reached. The cycle cursor starts
at the workspace's first terminal tab, so if you switch tabs manually
between presses, one press may realign.

Each press writes one line to
`~/.local/state/better-orca-workspace-cycle.log` with the decision and
the workspace index map, so an ordering mismatch is visible from a
single press.

## Install

1. Open Orca settings, then Plugins.
2. Install from local folder and pick this repository's root folder,
   the one containing `orca-plugin.json`.
3. Review the permissions and enable the plugin. It requests one
   capability, `workspace:read`, which is how it reads the focused
   workspace.

The keybindings are declared in `orca-plugin.json` under
`contributes.keybindings`, so Orca's own keybinding settings can override
any of them.

For live development, add the repository folder under Settings, Plugins,
Development. Dev plugins load straight from the folder and shadow the
installed copy.

## Layout

```
orca-plugin.json   Plugin manifest, commands, keybindings, capabilities
package.json       Marks the worker as an ES module
dist/main.js       Worker, the press decision and the switching
```

Commands `tap-cycle.1` through `tap-cycle.9` are declared in the manifest
and implemented in the worker.

## Marketplace

The manifest is compatible with the Orca plugin marketplace format
(`stablyai/orca-plugins`): git source, `orca-plugin.json` at the root,
`pluginApi: 1`.
