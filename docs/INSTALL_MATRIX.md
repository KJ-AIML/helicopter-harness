# Install Matrix

Helicopter-Harness install methods by host, status, and what each installs.

**Two modes:** workspace harness (primary) and agent package/adapter (secondary).

## Workspace Harness Installs

These install `.helicopter-harness/` into a parent workspace. This is the recommended default.

| Host | Command | Status | What it installs | Notes |
|------|---------|--------|------------------|-------|
| Windows PowerShell | `.\install.ps1 -Parent "<path>"` | **supported** | `.helicopter-harness/` + `AGENTS.md` + `CLAUDE.md` pointer files | Default parent is `.` if `-Parent` omitted |
| macOS/Linux bash | `./install.sh "<path>"` | **supported** | `.helicopter-harness/` + `AGENTS.md` + `CLAUDE.md` pointer files | Default parent is `.` if arg omitted |
| Any agent (prompt) | Paste fast-path prompt with repo URL | **supported** | Same as manual install, agent-driven | Agent clones repo and runs installer |

## Agent Package / Adapter Installs

These expose harness rules/skills to a specific agent host. They do not replace the workspace harness.

| Host | Command | Status | What it installs | Notes |
|------|---------|--------|------------------|-------|
| Pi | `pi install git:github.com/KJ-AIML/helicopter-harness@v0.2.0` | **experimental** | Pi package: skills from `.helicopter-harness/skills/` exposed via `package.json` `pi` key | Does not create `.helicopter-harness/` in any workspace. Local path verified with Pi v0.80.2; `git:` pending v0.2.0 tag |
| Codex | Workspace `AGENTS.md` → `.helicopter-harness/adapters/codex/AGENTS.md` | **supported** | Adapter pointer file created by workspace installer | No marketplace plugin. Requires workspace install first |
| Claude Code | Workspace `CLAUDE.md` → `.helicopter-harness/adapters/claude/CLAUDE.md` | **supported** | Adapter pointer file created by workspace installer. Optional hooks require review/consent | No marketplace plugin. Requires workspace install first |
| Cursor | Workspace `.cursor/rules/` → `.helicopter-harness/adapters/cursor/CURSOR.md` | **supported** | Adapter created by workspace installer | Requires workspace install first |
| Generic agents | `.helicopter-harness/adapters/generic/AGENT_INSTRUCTIONS.md` | **supported** | Adapter instructions for any local coding agent | Requires workspace install first |

## Planned Adapters

Not yet implemented. These are tracked for future development.

| Host | Status | Expected approach | Notes |
|------|--------|-------------------|-------|
| Windsurf | **planned** | `.windsurf/rules/` or workspace rules file | No adapter yet |
| Cline | **planned** | `.cline/rules/` or custom instructions | No adapter yet |
| Gemini | **planned** | `gemini-extension.json` or similar | No adapter yet |
| OpenCode | **planned** | `opencode.json` or plugin directory | No adapter yet |
| OpenClaw | **planned** | Skill or plugin format TBD | No adapter yet |

## What each install does NOT do

- **No global agent rules** are installed by default.
- **No repos are deleted or modified** by the installer.
- **No hooks are enabled** automatically — hooks require explicit consent.
- **No marketplace plugin** is claimed for any host unless explicitly implemented and tested.
- **No overwrite** of existing `AGENTS.md` or `CLAUDE.md` — installer prints the snippet for manual append if the file exists.

## Safety

All install scripts are inspectable before running. Review:

- `install.sh` / `install.ps1` — workspace installer
- `update.sh` / `update.ps1` — workspace updater
- `uninstall.sh` / `uninstall.ps1` — workspace remover
- `.helicopter-harness/hooks/` — optional hooks

Pi packages run with full system access. Inspect source before installing any third-party package.
