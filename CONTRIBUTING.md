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

