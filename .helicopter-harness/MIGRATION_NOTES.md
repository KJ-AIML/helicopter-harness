# Migration Notes

## Renamed

- `yo-audit` -> `audit`
- `yo-branch` -> `branch`
- `yo-debug` -> `debug`
- `yo-deps` -> `deps`
- `yo-design` -> `design`
- `yo-engineering` -> `engineering`
- `yo-feature` -> `feature`
- `yo-fix-loop` -> `fix-loop`
- `yo-flow` -> `flow`
- `yo-gh-write` -> `gh-write`
- `yo-impact` -> `impact`
- `yo-incident` -> `incident`
- `yo-release` -> `release`
- `yo-test-coverage` -> `test-coverage`
- `yo-verify-premise` -> `verify-premise`
- `yo-workflow` -> `workflow`

## Moved

- Tool-specific Codex setup moved from `yo-codex` and `yo-codex-settings` into `adapters/codex/`.
- Tool-specific Claude setup moved from `yo-claude-settings` into `adapters/claude/`.
- The Claude baseline hook moved to `hooks/scripts/claude-session-baseline.sh` with configuration examples in `hooks/examples/`.
- Useful skill `references/` directories were preserved under the renamed skill directories.
- Legacy `agents/openai.yaml` metadata and the original yo-* source bundle were removed. Git history preserves them.

## Merged Or Separated

- `flow` is now the lightweight router.
- `workflow` is reserved for deep find -> refute -> synthesize reviews.
- `engineering` owns risk tiering and done criteria.
- `verify-premise`, `impact`, `debug`, and `fix-loop` are separate phases to avoid trigger overlap.

## Removed From Core

- Global user-level install assumptions.
- Hard-coded `develop -> main` policy from core branch/release instructions.
- Codex-only and Claude-only wording from core protocols.
- `yo-*` branding from source-of-truth docs.

## Manual Review Still Needed

- Copied legacy `references/` may still contain assumptions that need review before treating them as active policy.
- Legacy OpenAI agent metadata was removed from the repository. Git history preserves it for reference.
- The Claude SessionStart hook is preserved but should be reviewed before enabling in any user-level settings file.
- Repo profile examples are placeholders and must be filled with actual repo policy before relying on them.
