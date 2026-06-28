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
- Cursor: `.helicopter-harness/adapters/cursor/`
- Pi: `.helicopter-harness/adapters/pi/`
- Generic local coding agents: `.helicopter-harness/adapters/generic/`

Planned adapters: Windsurf, Cline, Gemini, OpenCode, OpenClaw.

The adapter is not the source of truth; the harness is.

## Install

Helicopter-Harness has two install modes. The **workspace harness** is the primary mode — it installs `.helicopter-harness/` into your parent workspace and is what most users want. The **agent package** mode exposes harness skills/rules to a specific agent host (Pi, etc.) without replacing the workspace model.

### Fast path: ask your agent to install into current workspace

Paste this prompt to any coding agent:

```
Install this repo into the current folder as a parent-workspace harness:

https://github.com/KJ-AIML/helicopter-harness

Use the latest stable tag (v0.2.2). Do not install globally. Treat the current
directory as the workspace. Verify .helicopter-harness/HARNESS.md, AGENTS.md,
and CLAUDE.md exist after install.
```

### Manual workspace install — Windows

```powershell
git clone https://github.com/KJ-AIML/helicopter-harness.git
cd helicopter-harness
git checkout v0.2.2
.\install.ps1 -Parent "<current workspace path>"
```

Default parent is the current directory — omit `-Parent` to install into `.`.

### Manual workspace install — macOS/Linux

```bash
git clone https://github.com/KJ-AIML/helicopter-harness.git
cd helicopter-harness
git checkout v0.2.2
./install.sh "<current workspace path>"
```

Default parent is the current directory — omit the argument to install into `.`.

### Pi agent harness

```bash
pi install git:github.com/KJ-AIML/helicopter-harness@v0.2.2
```

This installs the Pi package, which does two things:

1. **Loads Helicopter-Harness skills** into Pi's skill system (audit, branch, debug, deps, design, engineering, feature, fix-loop, flow, gh-write, impact, incident, release, test-coverage, test-validation, verify-premise, workflow).
2. **Loads a lightweight Pi extension** (`extensions/pi-extension.js`) that announces status on session start and provides the `/helicopter-install` command.

On session start, the extension reports:

- `Helicopter-Harness loaded`
- `Workspace harness detected` — if `.helicopter-harness/HARNESS.md` exists in the current folder
- `Pi package loaded; workspace harness not installed in this folder` — if not detected

**Installing the workspace harness from Pi:**

Run `/helicopter-install` (or `/hh-install`) inside Pi to install the workspace harness into the current folder. The command asks for confirmation before modifying the workspace.

**Important:**

- `pi install ...` does **not** automatically create `.helicopter-harness/` in every folder. Use `/helicopter-install` to set up the workspace harness in a specific folder.
- Workspace install remains the source of truth for parent-workspace behavior.
- Pi packages run with full system access. Inspect source code before installing.
- **Status: supported** — verified with Pi v0.80.2 (local path install; remote `git:` install pending v0.2.2 tag).

### Codex

Current supported path:

1. Install the workspace harness (see above).
2. The installer creates `AGENTS.md` in the parent workspace root pointing to `.helicopter-harness/adapters/codex/AGENTS.md`.
3. Codex reads the adapter, which directs it to the harness source of truth.

No Codex marketplace plugin is available. The workspace adapter is the supported path.

### Claude Code

Current supported path:

1. Install the workspace harness (see above).
2. The installer creates `CLAUDE.md` in the parent workspace root pointing to `.helicopter-harness/adapters/claude/CLAUDE.md`.
3. Claude Code reads the adapter, which directs it to the harness source of truth.
4. Optional hooks require manual review and consent — see `.helicopter-harness/hooks/README.md`.

No Claude Code marketplace plugin is available. The workspace adapter is the supported path.

### Generic agents

1. Open your agent in the workspace root.
2. Give it the install prompt with the repo URL (see "Fast path" above).
3. All tasks should start by reading `.helicopter-harness/HARNESS.md`.
4. Adapter instructions: `.helicopter-harness/adapters/generic/AGENT_INSTRUCTIONS.md`.

### Safe install

Inspect scripts before running them. They copy the harness and create minimal adapter pointer files only when those files do not already exist.

They do not:

- install global agent rules by default
- delete repos
- overwrite existing `AGENTS.md`
- overwrite existing `CLAUDE.md`
- enable hooks automatically

If `AGENTS.md` or `CLAUDE.md` already exists, the installer prints the snippet to append manually.

### Post-install cleanup

If you cloned the repo only to run the workspace installer, the source checkout folder (e.g., `hh-source/`) can be deleted after successful install. The harness is now in `.helicopter-harness/` in your workspace.

**Do not delete `.helicopter-harness/`** — that is the installed harness.

## First-Run Prompt

```text
Start from this parent workspace. Read the Helicopter-Harness source of truth first, identify the target repo, read its profile if present, then inspect repo-local docs. Update the harness current-task state before non-trivial edits. Task: <describe task>.
```

For a repo checkout, the source of truth is `.helicopter-harness/HARNESS.md`. For an installed Windows parent workspace using `install.ps1`, it is `<Parent>\.helicopter-harness\HARNESS.md`.

## What next after install?

1. **Start your agent from the parent workspace** — open your coding agent (Pi, Codex, Claude Code, etc.) in the workspace root where `.helicopter-harness/` lives.
2. **Read the harness** — the agent should read `.helicopter-harness/HARNESS.md` as the source of truth.
3. **Clone or create a target repo** — the repo you want to work on should be inside the parent workspace.
4. **Create a repo profile** — copy `.helicopter-harness/templates/repo-profile.md` to `.helicopter-harness/profiles/<repo>.md` and fill in the repo-specific details (branch policy, test commands, generated-file policy, etc.).
5. **Run test-validation** — before making code edits, run the `test-validation` skill in audit-only mode to verify the profile's verification command works and is safe.

Only then should the agent start making code changes. The harness forces read-before-write: understand the repo before editing it.

## Example Session

This walkthrough shows how the harness changes agent behavior. The scenario: a user asks the agent to add a rate-limiting middleware to the `api` repo.

### 1. The workspace the agent sees

```text
D:\MyWorkspace\
├── .helicopter-harness\
│   ├── HARNESS.md
│   ├── profiles\
│   │   └── api.md
│   ├── skills\
│   ├── state\
│   │   └── current-task.md
│   └── templates\
├── api\
│   ├── src\
│   ├── tests\
│   └── README.md
└── frontend\
    └── ...
```

### 2. The user types

```text
Start from this parent workspace. Read HARNESS.md, identify the target repo,
read its profile, then inspect repo-local docs. Update state before non-trivial
edits. Task: Add rate-limiting middleware to the API. 100 requests per minute
per API key, return 429 with a Retry-After header.
```

### 3. What the agent reads (in order)

1. `.helicopter-harness/HARNESS.md` — learns the operating model, risk tiers, skill routing
2. `.helicopter-harness/profiles/api.md` — learns the api repo's branch policy, test commands, generated-file rules
3. `api/README.md` and `api/package.json` — learns the framework (Express), existing middleware stack, test runner
4. `.helicopter-harness/skills/impact/SKILL.md` — this is a shared surface edit, so impact analysis applies

### 4. The agent writes task state before editing

The agent updates `.helicopter-harness/state/current-task.md`:

```markdown
Target repo: api
Task: Add rate-limiting middleware (100 req/min per API key, 429 + Retry-After)
Mode: feature
Risk tier: S1
Files expected to change:
  - src/middleware/rateLimit.js (new)
  - src/app.js (register middleware)
  - tests/middleware/rateLimit.test.js (new)
Dirty files observed: none
Planned verification: npm test
Current status: in_progress
Failed attempts count: 0
Next smallest action: Read existing middleware pattern in src/app.js
```

### 5. The agent makes the edit

Following the api profile's conventions (CommonJS, existing middleware pattern), the agent:

- Creates `src/middleware/rateLimit.js` matching the style of `src/middleware/auth.js`
- Registers it in `src/app.js` after auth, before routes
- Writes `tests/middleware/rateLimit.test.js` covering: under limit passes, at limit returns 429, Retry-After header present, different API keys tracked independently

### 6. Verification

The agent runs the verification command from the api profile:

```text
$ npm test
  47 passing (2.1s)
  0 failing
```

The agent also checks `git status` to confirm only the three expected files changed.

### 7. State update after completion

The agent updates `current-task.md`:

```markdown
Current status: complete
Failed attempts count: 0
Next smallest action: none
```

### What the harness changed

Without the harness, the agent might have:

- Guessed the test command (`jest`? `vitest`? `mocha`?)
- Used ES modules because the agent prefers them, ignoring the repo's CommonJS convention
- Skipped task state, so a second agent picking up the work has no context
- Not checked impact on callers before adding middleware to the stack

The harness doesn't add complexity. It makes the agent read before writing.

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
.\update.ps1 -Parent "D:\MyWorkspace"
```

```bash
./update.sh "$HOME/work/my-workspace"
```

By default, update preserves harness state. Use `-ResetState` or `--reset-state` only when you explicitly want to reset `.helicopter-harness/state/`.

## Uninstall

Windows:

```powershell
.\uninstall.ps1 -Parent "D:\MyWorkspace"
```

macOS/Linux:

```bash
./uninstall.sh "$HOME/work/my-workspace"
```

Uninstall removes only the installed harness directory. It does not delete repos or automatically edit `AGENTS.md` / `CLAUDE.md`.

## Contributing

Keep the core tool-neutral. Put agent-specific behavior in adapters. Keep hooks optional. Do not encode repo policy in global protocol when it belongs in a repo profile.

Read `CONTRIBUTING.md` before opening a PR.
