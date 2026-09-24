// Better Workspace Cycle - Orca plugin worker.
//
// Contract (pluginApi 1). The entry module default-exports activate(ctx).
// Commands arrive through ctx.commands.register(id, handler). Host state
// comes from ctx.host.call(method, params).
//
// Press Ctrl+N on workspace N to cycle its terminal tabs. Press Ctrl+N on
// any other workspace to switch to workspace N. State decides which, never
// timing. Switching rides Orca's own `orca terminal switch`, so no code
// outside Orca ever synthesizes input.

import { execFileSync } from "node:child_process";
import { appendFileSync, mkdirSync } from "node:fs";

const PLUGIN = "better-orca-workspace-cycle";
const HOME = globalThis.process?.env?.HOME ?? "/tmp";
const LOG = `${HOME}/.local/state/better-orca-workspace-cycle.log`;
const CLI_CANDIDATES = ["orca-ide", `${HOME}/.local/bin/orca-ide`];

function log(msg) {
  console.log(`[${PLUGIN}] ${msg}`);
  try {
    mkdirSync(LOG.slice(0, LOG.lastIndexOf("/")), { recursive: true });
    appendFileSync(LOG, `[${new Date().toISOString()}] ${msg}\n`);
  } catch {
    // Logging must never break behavior.
  }
}

function orca(args) {
  let lastError;
  for (const cli of CLI_CANDIDATES) {
    try {
      const out = execFileSync(cli, args, {
        encoding: "utf8",
        timeout: 5000,
        shell: process.platform === "win32",
        stdio: ["ignore", "pipe", "pipe"],
      });
      return JSON.parse(out).result;
    } catch (e) {
      lastError = e;
    }
  }
  throw lastError;
}

let host = null;
const cursor = {};

function orderedWorktrees() {
  const list = orca(["worktree", "list", "--json"]).worktrees ?? [];
  return [...list].sort(
    (a, b) =>
      (b.isPinned ? 1 : 0) - (a.isPinned ? 1 : 0) || a.manualOrder - b.manualOrder,
  );
}

function terminalsOf(worktreeId) {
  return (orca(["terminal", "list", "--json"]).terminals ?? [])
    .filter((t) => t.worktreeId === worktreeId && !t.orphaned)
    .map((t) => t.handle);
}

function switchTo(handle) {
  orca(["terminal", "switch", "--terminal", handle, "--json"]);
}

function matchCurrent(ordered, here) {
  return ordered.findIndex(
    (w) =>
      (w.displayName === here.displayName && w.branch === here.branch) ||
      w.displayName === here.displayName ||
      w.branch === here.branch,
  );
}

async function press(n) {
  try {
    const ordered = orderedWorktrees();
    const here = await host.call("workspace.readContext");
    const current = here ? matchCurrent(ordered, here) : -1;
    const onTarget = current === n - 1;
    log(
      `press ${n}, current=${here?.displayName ?? "none"}@${current + 1} -> ${onTarget ? "cycle" : "jump"}`,
    );
    const w = ordered[n - 1];
    if (!w) return log(`press ${n}: workspace ${n} does not exist`);
    const handles = terminalsOf(w.id);
    if (!handles.length) return log(`press ${n}: ${w.displayName} has no terminals`);
    const next = onTarget ? ((cursor[w.id] ?? 0) + 1) % handles.length : 0;
    cursor[w.id] = next;
    switchTo(handles[next]);
  } catch (e) {
    log(`press ${n} FAILED: ${e}`);
  }
}

export default async function activate(ctx) {
  host = ctx.host;
  for (let n = 1; n <= 9; n++) {
    ctx.commands.register(`tap-cycle.${n}`, () => press(n));
  }
  log("activate: commands registered");
}

export async function deactivate() {
  log("deactivate");
}
