---
name: yo-codex-settings
description: >-
  The user's per-session behavioral baseline in Codex — model, reasoning effort, code-style rules, and the always-read-AGENTS.md habit. Invoke at session start before the first substantive action, when the user says "my settings" / "ramp up" / "use the good brain", or when the model/effort state looks misconfigured. Encodes: gpt-5.5 at xhigh reasoning effort, the Karpathy four-principle baseline (think-before-code, simplicity, surgical changes, goal-driven), fresh sessions over long degraded threads, and a forced AGENTS.md/CLAUDE.md read on every project entry.
metadata:
  short-description: The user's behavioral and model baseline for Codex
---

# yo-codex-settings — Behavioral & Model Baseline

How the user wants Codex to operate by default. Not preferences to "consider" — the operating baseline. When in doubt about model effort, code style, or session ramp-up, this is the source of truth.

**Where config actually lives in Codex** (the analog of Claude's `settings.json`):
- `~/.codex/config.toml` — model, reasoning effort, MCP servers, trusted projects.
- `~/.codex/rules/` — behavioral rules (`default.rules`).
- `AGENTS.md` (per-project, and `~/.codex/AGENTS.md` global) — the project HOW, Codex's equivalent of `CLAUDE.md`.
- `~/.codex/memories/` — persistent memory.

There is no `update-config` skill here; to change config you edit `config.toml` / `rules` directly (with the user's OK).

## The four hard rules

### 1. Strong model at xhigh reasoning effort. Don't under-think.

The user wants **the good brain on, all the time** — no adaptive/"smart-pick" effort that shaves the budget on routine work. The baseline, already set in `config.toml`:
- `model = "gpt-5.5"`
- `model_reasoning_effort = "xhigh"`

What this means in practice:
- Treat every task as if it deserves full reasoning. Don't pre-judge "this is easy, skip the planning step."
- Don't skim files you should read carefully.
- Don't announce "I could think harder if you wanted" — just think hard.
- If the user says "go fast, simple task," *then* downshift. Otherwise default to full.
- **Be aggressive about ending long sessions before they degrade.** Codex (like any model) drifts as a thread accumulates noise — the longer it runs at high context utilization, the muddier it gets. When responses start feeling off, *say so* and offer to start fresh (`/new`) with a tight handoff prompt rather than push through. Fresh session > deeply loaded session.
- Quick check on Windows PowerShell: `Select-String -Path ~/.codex/config.toml -Pattern '^(model|model_reasoning_effort|reasoning_effort)'` — flag anything downshifted from the baseline.

### 2. Apply the Karpathy four-principle baseline on every change

The load-bearing engineering principles. They override default verbose-AI tendencies.

- **Think before coding.** State assumptions out loud. Present multiple interpretations when ambiguous. Ask one clarifying question if confused — don't proceed and discover later.
- **Simplicity first.** Minimum code that solves the problem. Nothing speculative. No premature flexibility, no error handling for impossible cases, no abstractions before the second duplicate. If it could be shorter and still correct, shorten it.
- **Surgical changes.** Touch only what the task requires. Don't refactor unbroken code. Don't sweep unrelated style nits. Mention dead code you spot; don't delete it unless asked.
- **Goal-driven execution.** Convert vague requests into testable success criteria. For multi-step work, name the verification step for each phase, not just the implementation.

Effectiveness check: diffs with fewer unnecessary lines, fewer rewrites, more clarifying questions *before* coding rather than corrections *after*. Source: `references/karpathy-baseline.md`.

### 3. Read the project's AGENTS.md (and CLAUDE.md) every time

Every project this user works on carries its own project-instruction file — `AGENTS.md` for Codex, often a `CLAUDE.md` too (and nested ones under sub-projects). These override generic defaults.

On the first substantive task in a working directory:
1. Locate every instruction file in scope: `find . -maxdepth 3 \( -name AGENTS.md -o -name CLAUDE.md \) -type f`.
2. Read each before the first edit. If a parent dir also has one, read that too.
3. If a project file contradicts a generic "best practice," the project wins. It's the user's HOW, not a suggestion.

No instruction file at all? That's a signal — offer to seed an `AGENTS.md` when it'd help future sessions, but don't force it.

### 4. Follow community project-instruction authoring patterns

> ⚠️ Source caveat: the user referenced this as "Mckathy" — best interpretation is **McKay Wrigley's** Claude Code / CLAUDE.md series. If they meant another source, ask once and update; don't silently swap.

Patterns that apply to every project's `AGENTS.md`/`CLAUDE.md`:
- **Treat it as instruction, not documentation.** What to do, not what the project is.
- **Lead with critical rules** — the things that, if violated, break the build or ship a bug. These go at the top.
- **Decision tracker + ADR pointers** so the *why* of past decisions is one click away.
- **Code location map** — a table: "if you need X, look at file Y." Highest-leverage section.
- **DO NOT list** — explicit prohibitions, not soft preferences.
- **Build/Test/Run commands** in the top section, copy-pasteable.

## Session ramp-up — top of a session, in order

1. Read this skill (you're doing it).
2. Locate and read every `AGENTS.md`/`CLAUDE.md` in the working tree (Rule 3).
3. Confirm model + effort match the baseline (Rule 1). Flag drift.
4. Check `~/.codex/memories/` for relevant context.
5. Only *then* take the first substantive action.

Under 30 seconds of read time. Skipping it is the most common source of "you didn't follow my preference" feedback.

## Process hygiene — kill old dev servers before launching new

Before starting any long-running process the user might already have an instance of — `dotnet run`/`watch`, `mdbook serve`, `npm run dev`, `vite`, anything holding a port — check for and kill the prior instance first. Don't stack instances.

On Windows (the user's platform):
```powershell
# By port
Get-NetTCPConnection -LocalPort 5000,5173,8000 -State Listen | Select OwningProcess
# Kill
Stop-Process -Id <PID>            # graceful-ish
Stop-Process -Id <PID> -Force     # if it won't exit
```
Stacked instances cause port conflicts, stale assets, and "why isn't my change showing up" debugging with no real cause.

## What this skill does NOT do
- It does not override an explicit per-session instruction. "Go fast and simple this turn" beats the default.
- It does not apply to other users. Per-user baseline.

## Skills to invoke alongside
- **`yo-verify-premise`** — fires on any "fix X" / "investigate Y" to confirm the claim before acting (the "think before coding" rule, made callable).
- **`yo-engineering`** — senior software-engineering quality gate for broad/high-risk work or "best engineer" prompts.
- **`yo-fix-loop`** — multi-change work; the Karpathy baseline plugs into its fix step.
- **`yo-branch`** — when work is about to ship as a PR.
- **`yo-gh-write`** — issue/PR/comment writing during the session.

## Anti-patterns
- **Treating this as "preferences to consider".** It's the baseline.
- **Skipping the AGENTS.md read because you think you remember the project.** Memory is point-in-time; the file is live. Re-read on every project entry.
- **Silently accepting a downshifted model/effort.** Mention it once, offer the fix.
- **Speculative features "while I'm here".** Surgical only.
- **Long preamble before action.** Apply the baseline silently; mention it only when load-bearing or correcting course.

## Sources
See `references/sources.md` and `references/karpathy-baseline.md`.
