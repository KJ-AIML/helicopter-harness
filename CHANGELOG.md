# Changelog

## 0.2.2 - 2026-06-28

### Fixed

- Fixed Pi skill YAML frontmatter conflicts in `incident` and `workflow` skills (descriptions with colons caused "Nested mappings" parse errors).

### Added

- Added lightweight Pi extension (`extensions/pi-extension.js`) that:
  - Announces `Helicopter-Harness loaded` on session start
  - Detects whether workspace harness is installed in current folder
  - Provides `/helicopter-install` (alias `/hh-install`) command to install workspace harness into current folder
  - Asks for confirmation before modifying workspace
  - Verifies install after completion
- Extension is safe and non-destructive: no auto-install on startup, no global install, no file deletion.

### Changed

- Updated `package.json` `pi` manifest to include both `extensions` and `skills`.
- Updated docs to clarify Pi package install now loads skills + extension.
- Clarified that `pi install` does not auto-create `.helicopter-harness/`; use `/helicopter-install` for workspace setup.

## 0.2.1 - 2026-06-28

### Docs-only hotfix

- Clarified Pi git install status: `pi install git:github.com/KJ-AIML/helicopter-harness@v0.2.0` is verified and supported.
- Added post-install cleanup note: source checkout folder (e.g., `hh-source/`) can be deleted after workspace install; do not delete `.helicopter-harness/`.
- Added "What next after install?" section with step-by-step guidance: start agent, read HARNESS.md, clone/create target repo, create repo profile, run test-validation in audit-only mode.
- Updated Pi adapter docs with post-install cleanup note.

## 0.2.0 - 2026-06-26

### Breaking Changes

- Removed `legacy-original-yo-bundle/` directory. Git history preserves the original yo-* skills and OpenAI agent metadata.
- Renamed profile example files to generic archetypes: `alms.md.example` → `library.md.example`, `alms-langgraph-agent-skill.md.example` → `service-api.md.example`, `axga-harness-agent.md.example` → `cli-tool.md.example`, `axtra-intellion-saas-platform.md.example` → `saas-platform.md.example`.

### Added

- Added `description` and `topics` fields to both `manifest.json` files for GitHub discoverability.
- Added `_note` field to root `manifest.json` explaining the dual-manifest design (root pointer vs. inner authoritative manifest).
- Added "Done Criteria" section to `HARNESS.md` defining verification requirements and failure routing.
- Added concrete "Example Session" to `README.md` showing an agent adding rate-limiting middleware, from workspace discovery through task state to verification.
- Added real repo profile for `agent-native-backend` (documentation-only field guide) as proof-of-concept.
- Expanded `CONTRIBUTING.md` with sections on adding skills, adding adapters, and PR checklist.
- Replaced placeholder `security@example.invalid` with GitHub Security Advisory disclosure path in `SECURITY.md`.
- Added explicit parent-directory validation to `install.sh` and `install.ps1` before path operations.
- Added Cursor adapter (`.helicopter-harness/adapters/cursor/`).
- Added Ponytail-style multi-agent install matrix (`docs/INSTALL_MATRIX.md`) covering all supported, experimental, and planned install methods.
- Added Pi adapter docs (`.helicopter-harness/adapters/pi/README.md`) explaining workspace vs package install and safety notes.
- Added `package.json` with `pi` key for Pi package compatibility (`pi install git:github.com/KJ-AIML/helicopter-harness`).

### Changed

- Replaced all hardcoded internal workspace paths (`Axtra-Intelion`, `D:\KJ\`) with generic `MyWorkspace` / `my-workspace` across `README.md`, `INSTALL.md`, and `.helicopter-harness/INSTALL.md`.
- Reset `state/current-task.md` to clean empty template (removed stale "Unset" placeholder values).
- Updated `MIGRATION_NOTES.md` to reflect removal of legacy bundle (past tense).
- Updated README install section with Ponytail-style install guide: fast-path prompt, manual workspace install (Windows/macOS/Linux), Pi, Codex, Claude Code, Cursor, and generic agents.
- Clarified workspace install (primary) vs agent package install (secondary) throughout docs.
- Documented Codex, Claude Code, Generic agents, and planned adapters (Windsurf, Cline, Gemini, OpenCode, OpenClaw).
- Updated manifests to include `cursor` and `pi` adapters.
- Pi install verified (both local path and `git:github.com/KJ-AIML/helicopter-harness@v0.2.0`) with Pi v0.80.2.

## 0.1.2 - 2026-06-21

- Added `test-validation` skill for validating repo profile commands, classifying failures, and confirming safe non-mutating verification.
- Added safe/mutating/destructive command classification with flag examples and risk tiers.
- Added dependency preflight and post-run git status verification protocol.
- Added 6-category failure classification (environment, dependency, command-selection, profile, code, harness).
- Updated manifest skills list with `test-validation`.
- Updated HARNESS.md Skill Routing section.
- Fixed missing skill lookup / ENOENT for `test-validation` mode.
- Validated sandbox update preserves existing profiles and state.
- Validated against `axga-harness-agent` sandbox without modifying target repo source.

## 0.1.1 - 2026-06-21

- Fix Windows install target path to use `<Parent>\.helicopter-harness`.
- Fix parent adapter pointer file location for `AGENTS.md` and `CLAUDE.md`.
- Rewrite shell scripts as normal multiline executable scripts with validated syntax.
- Correct README and INSTALL path documentation.

## 0.1.0 - 2026-06-21

- Initial public release of Helicopter-Harness.
- Added parent-workspace harness source of truth.
- Added tool-neutral core protocols and skills.
- Added Codex, Claude Code, and generic local agent adapters.
- Added Windows and macOS/Linux install, update, and uninstall scripts.
- Added optional hook documentation.
- Added repo profile templates and current-task state tracking.
