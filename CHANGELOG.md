# Changelog

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
