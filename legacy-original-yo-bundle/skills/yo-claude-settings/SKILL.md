---
name: yo-claude-settings
description: >-
  The user's per-session behavioral baseline for Claude Code: model/thinking mode, context size, code-style rules, fresh-session hygiene, and the always-read-CLAUDE.md habit. Invoke at session start before the first substantive action, when the user says "my settings" / "ramp up" / "use the good brain" / "no adaptive thinking", or when the active model, thinking, context, or project-instruction state looks misconfigured. Encodes: Claude Opus at fixed high thinking, default-sized context unless the task needs more, Karpathy four-principle engineering baseline, and a forced CLAUDE.md read on every project entry.
allowed-tools: Read, Bash, Grep, Glob
---

# yo-claude-settings - Behavioral & Model Baseline

This is the user's Claude Code baseline. Treat it as operating procedure, not a preference list.

## Hard rules

### 1. Use the good brain by default

Default to the strongest available Claude model, fixed high thinking, and a normal working context. Do not use adaptive/auto thinking as the default for serious engineering work.

Practical behavior:
- Think before coding, even when the change looks small.
- Do not skim files that define the behavior being changed.
- Prefer a fresh session with a tight handoff over pushing a degraded long thread.
- Increase context only when the task genuinely needs breadth; do not make huge context the default.
- If the active Claude Code model/thinking/context setup looks wrong, say so briefly and offer to fix it.

### 2. Apply the Karpathy baseline on every change

Use the four engineering rules from `references/karpathy-baseline.md`:
- Think before coding.
- Simplicity first.
- Surgical changes.
- Goal-driven execution with concrete verification.

This means no speculative features, no unrelated refactors, no hidden confusion, and no completion claim without evidence.

### 3. Read project instructions first

On the first substantive task in a project, locate and read project instructions before editing:

```bash
find . -maxdepth 3 \( -name CLAUDE.md -o -name AGENTS.md \) -type f 2>/dev/null | head -20
```

```powershell
Get-ChildItem -Recurse -Depth 3 -Include CLAUDE.md,AGENTS.md -File | Select-Object -First 20
```

Priority:
- `CLAUDE.md` is the Claude Code project instruction file.
- `AGENTS.md` is also relevant in repos shared with Codex.
- Nested instruction files can override broader ones for their subtree.

If project instructions contradict a generic best practice, the project instructions win unless they are unsafe or impossible.

### 4. Keep process state clean

Before starting a dev server or watcher, check whether one is already running. Do not stack processes that hold the same port or serve stale assets.

Unix-like quick checks:

```bash
pgrep -fl "dotnet run|dotnet watch|mdbook serve|vite|npm run dev" | head
lsof -i :3000 -i :5000 -i :5173 -i :8000 | grep LISTEN
```

Windows PowerShell quick checks:

```powershell
Get-Process | Where-Object { $_.ProcessName -match 'node|dotnet|vite' }
Get-NetTCPConnection -State Listen | Where-Object { $_.LocalPort -in 3000,5000,5173,8000 }
```

Kill only the process you can identify as stale or conflicting.

## Session ramp-up

1. Read this skill.
2. Read relevant `CLAUDE.md` / `AGENTS.md` files.
3. Check whether model/thinking/context look aligned with the user's baseline.
4. Use memory only when it is likely to help the repo/task.
5. Route the actual work through the right Yo skill.

## Skills to pair with

- `yo-engineering` - senior risk gate for broad, high-risk, or "best engineer" work.
- `yo-flow` - route ambiguous work through the Yo pack.
- `yo-verify-premise` - verify claims before fixing or investigating.
- `yo-feature` - build a new feature from spec to verified change.
- `yo-fix-loop` - clear multiple findings with fix/verify discipline.
- `yo-audit` - independent read-only verification before trusting a change.
- `yo-branch` - branch and PR readiness conventions.
- `yo-gh-write` - GitHub issues, PRs, and review comments in the user's voice.

## Anti-patterns

- Treating this as soft preference.
- Skipping project instructions because memory "probably knows."
- Silently accepting adaptive thinking on serious work.
- Expanding scope while claiming to be surgical.
- Starting another dev server because checking processes feels slower.

## Sources

See `references/sources.md` and `references/karpathy-baseline.md`.
