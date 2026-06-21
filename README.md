# Helicopter-Harness

Parent-workspace AI development harness for multi-repo, multi-agent engineering work.

Helicopter-Harness gives local coding agents a shared operating system: protocols, repo profiles, state tracking, optional hooks, and adapter instructions. It is designed for a parent workspace that contains many repos and may be touched by many agents.

```text
one parent workspace
many repos
many agents
one harness
```

The source of truth in this repository is `.helicopter-harness/HARNESS.md`. Tool-specific behavior lives only under `.helicopter-harness/adapters/`.

## Why Parent-Workspace Instead Of Global Rules

Global agent rules are blunt. They leak across unrelated projects, hide repo-specific policy, and make multi-repo work depend on whatever the user happened to install months ago.

A parent-workspace harness is explicit:

- Every repo in the workspace can share one operating protocol.
- Repo-specific policy lives in profiles instead of agent memory.
- Codex, Claude Code, and other agents read the same source of truth.
- Task state lives near the workspace, not in a global dotfolder.
- Hooks are optional and reviewable instead of silently imposed.

This matters when a single task crosses `api`, `frontend`, `infra`, test sandboxes, and agent tooling repos. The harness forces the agent to identify the target repo before editing and to stop guessing branch policy, test commands, generated-file policy, and deployment behavior.

## Supported Agents

Current adapters:

- Codex: `.helicopter-harness/adapters/codex/`
- Claude Code: `.helicopter-harness/adapters/claude/`
- Generic local coding agents: `.helicopter-harness/adapters/generic/`

Future adapters can be added for Cursor, Windsurf, Cline, Gemini, Pi, OpenCode, and other local agent runtimes. The adapter is not the source of truth; the harness is.

## Quick Install

Windows PowerShell:

```powershell
.\install.ps1 -Parent "D:\KJ\Axtra-Intelion"
```

macOS/Linux:

```bash
./install.sh "$HOME/work/axtra-intelion"
```

## Safe Install

Inspect scripts before running them. They copy the harness and create minimal adapter pointer files only when those files do not already exist.

They do not:

- install global agent rules by default
- delete repos
- overwrite existing `AGENTS.md`
- overwrite existing `CLAUDE.md`
- enable hooks automatically

If `AGENTS.md` or `CLAUDE.md` already exists, the installer prints the snippet to append manually.

## Windows Install

Default parent is the current directory:

```powershell
.\install.ps1
```

Explicit parent:

```powershell
.\install.ps1 -Parent "D:\KJ\Axtra-Intelion"
```

This installs to:

```text
D:\KJ\Axtra-Intelion\.helicopter-harness
```

## macOS/Linux Install

Default parent is the current directory:

```bash
./install.sh
```

Explicit parent:

```bash
./install.sh "$HOME/work/axtra-intelion"
```

This installs to:

```text
$HOME/work/axtra-intelion/.helicopter-harness
```

## First-Run Prompt

```text
Start from this parent workspace. Read the Helicopter-Harness source of truth first, identify the target repo, read its profile if present, then inspect repo-local docs. Update the harness current-task state before non-trivial edits. Task: <describe task>.
```

For a repo checkout, the source of truth is `.helicopter-harness/HARNESS.md`. For an installed Windows parent workspace using `install.ps1`, it is `<Parent>\.helicopter-harness\HARNESS.md`.

## Repo Profiles

Repo profiles live in:

```text
.helicopter-harness/profiles/
```

Profiles define what agents must not guess:

- branch and PR policy
- build and test commands
- generated-file policy
- deployment and release process
- ownership and review expectations
- known fragile areas
- S2/S3 risk surfaces

Use `.helicopter-harness/templates/repo-profile.md` when adding a profile.

## Current Task State

Active task state lives in:

```text
.helicopter-harness/state/current-task.md
```

Before non-trivial edits, the agent must record:

- target repo
- task
- mode
- risk tier
- files expected to change
- dirty files observed
- planned verification
- current status
- failed attempts count
- next smallest action

This is deliberately boring. Boring state prevents expensive mistakes.

## Hooks

Hooks are optional.

No destructive hook should run without explicit user consent. The harness currently includes an optional Claude Code SessionStart context-injection hook. It emits context only; it does not inspect or edit repos.

Read:

```text
.helicopter-harness/hooks/README.md
```

## Update

From the repo checkout:

```powershell
.\update.ps1 -Parent "D:\KJ\Axtra-Intelion"
```

```bash
./update.sh "$HOME/work/axtra-intelion"
```

By default, update preserves harness state. Use `-ResetState` or `--reset-state` only when you explicitly want to reset `.helicopter-harness/state/`.

## Uninstall

Windows:

```powershell
.\uninstall.ps1 -Parent "D:\KJ\Axtra-Intelion"
```

macOS/Linux:

```bash
./uninstall.sh "$HOME/work/axtra-intelion"
```

Uninstall removes only the installed harness directory. It does not delete repos or automatically edit `AGENTS.md` / `CLAUDE.md`.

## Contributing

Keep the core tool-neutral. Put agent-specific behavior in adapters. Keep hooks optional. Do not encode repo policy in global protocol when it belongs in a repo profile.

Read `CONTRIBUTING.md` before opening a PR.
