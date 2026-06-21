# Helicopter-Harness

Helicopter-Harness is a parent-directory AI development harness for one workspace containing many repos and many coding agents.

It provides:

- shared operating protocol in `HARNESS.md`
- concise tool-neutral skills in `skills/`
- per-repo profiles in `profiles/`
- Codex, Claude Code, and generic adapter instructions in `adapters/`
- optional hooks in `hooks/`
- task state and run reporting in `state/`
- reusable templates in `templates/`

The source of truth is `.helicopter-harness/HARNESS.md`. Tool adapters point agents to that file; they do not define the harness policy themselves.

