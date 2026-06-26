# Contributing

Helicopter-Harness is a parent-workspace, tool-neutral AI development harness. Contributions should preserve that shape.

## Rules

- Keep core protocols tool-neutral.
- Put Codex, Claude Code, and other agent-specific behavior under `.helicopter-harness/adapters/`.
- Do not make global user-level installation the default.
- Do not add destructive hooks.
- Do not encode repo-specific branch, test, generated-file, deploy, or release policy into core files.
- Keep skill descriptions short and trigger-focused.
- Preserve `.helicopter-harness/state/runs/.gitkeep` and `.helicopter-harness/state/reports/.gitkeep`.

## Development Checks

Before opening a PR:

```powershell
Get-Content .\.helicopter-harness\manifest.json | ConvertFrom-Json | Out-Null
```

```bash
python -m json.tool .helicopter-harness/manifest.json >/dev/null
```

Check that install/update/uninstall scripts still avoid overwriting `AGENTS.md` and `CLAUDE.md`.

## Adding a Skill

1. Create `.helicopter-harness/skills/<skill-name>/SKILL.md` with a YAML frontmatter (`name`, `description`) and a short trigger-focused body.
2. Add a `references/` subdirectory only if the skill has supporting sources worth citing.
3. Register the skill in `.helicopter-harness/manifest.json` under the `skills` array.
4. Add a routing entry in `.helicopter-harness/HARNESS.md` under Skill Routing if the skill should be discoverable from the core protocol.

## Adding an Adapter

1. Create `.helicopter-harness/adapters/<tool-name>/` with an entry-point file (e.g., `CLAUDE.md`, `AGENTS.md`, `AGENT_INSTRUCTIONS.md`).
2. The entry point must reference `.helicopter-harness/HARNESS.md` as the source of truth — it must not duplicate or override core protocol.
3. Add a `README.md` in the adapter folder explaining how to connect the tool to the harness.
4. Tool-specific behavior stays in the adapter folder. Core files remain tool-neutral.

## PR Checklist

- [ ] Does the PR touch `HARNESS.md` or `manifest.json`? If yes, this changes the core protocol — flag it for extra review.
- [ ] Are new skills registered in the inner manifest and routed in HARNESS.md?
- [ ] Do install/update/uninstall scripts still avoid overwriting existing `AGENTS.md` and `CLAUDE.md`?
- [ ] Is the PR scoped to one concern? One skill, one adapter, one fix — not a mix.
