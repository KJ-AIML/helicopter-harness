# Pi Adapter

Helicopter-Harness can be used with [Pi](https://pi.dev) in two ways. They are not mutually exclusive.

## Two install modes

### 1. Pi package install (agent-facing)

```bash
pi install git:github.com/KJ-AIML/helicopter-harness@v0.2.0
```

This installs the Pi package. Pi discovers harness skills via the `pi` key in `package.json`, which points to `.helicopter-harness/skills/`.

**What this does:**

- Exposes harness skills (audit, branch, debug, deps, design, engineering, feature, fix-loop, flow, gh-write, impact, incident, release, test-coverage, test-validation, verify-premise, workflow) to Pi's skill system.
- Does **not** create `.helicopter-harness/` in any workspace.
- Does **not** set up parent-workspace harness state, profiles, or adapter pointer files.

**Status: supported.** Verified with `pi install git:github.com/KJ-AIML/helicopter-harness@v0.2.0` (Pi v0.80.2). Pi resolved the GitHub tag, cloned to `~/.pi/agent/git/`, parsed `package.json` `pi` key, registered the package, and exposed the skills path.

### 2. Workspace harness install (recommended)

To get the full harness — state tracking, repo profiles, task protocol, adapter pointers — install the workspace harness. Ask Pi:

```
Install this repo into the current folder as a parent-workspace harness:

https://github.com/KJ-AIML/helicopter-harness

Use the latest stable tag. Do not install globally. Treat the current
directory as the workspace. Verify .helicopter-harness/HARNESS.md, AGENTS.md,
and CLAUDE.md exist after install.
```

Or run the installer manually:

```bash
# macOS/Linux
git clone https://github.com/KJ-AIML/helicopter-harness.git
cd helicopter-harness
git checkout v0.2.0
./install.sh "<workspace path>"
```

```powershell
# Windows
git clone https://github.com/KJ-AIML/helicopter-harness.git
cd helicopter-harness
git checkout v0.2.0
.\install.ps1 -Parent "<workspace path>"
```

## How Pi should use Helicopter-Harness

When the workspace harness is installed:

1. Read `.helicopter-harness/HARNESS.md` as the source of truth.
2. Identify the target repo before editing.
3. Read `.helicopter-harness/profiles/<repo>.md` if it exists.
4. Read repo-local docs (`AGENTS.md`, `CLAUDE.md`, `README*`, build/test files).
5. For non-trivial edits, update `.helicopter-harness/state/current-task.md`.
6. Load only the relevant skill docs from `.helicopter-harness/skills/`.

When only the Pi package is installed (no workspace harness), the skills are available via Pi's skill system but the workspace protocol (state tracking, repo profiles) is not active.

## Safety note

Pi packages run with full system access. Extensions execute arbitrary code, and skills can instruct the model to perform any action including running executables.

**Before installing:**

- Inspect `install.sh` / `install.ps1` before running them.
- Review `.helicopter-harness/hooks/` — hooks are optional and require explicit consent.
- Review any skill `SKILL.md` before invoking it on sensitive repos.

The installers do not:

- Install global agent rules by default.
- Overwrite existing `AGENTS.md` or `CLAUDE.md`.
- Enable hooks automatically.
- Delete repos or workspace content.
