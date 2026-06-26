# Cursor Adapter

Cursor must treat `.helicopter-harness/HARNESS.md` as the source of truth.

Before substantive work:

1. Start from the parent workspace.
2. Read `.helicopter-harness/HARNESS.md`.
3. Identify the target repo before editing.
4. Read the matching `.helicopter-harness/profiles/<repo>.md` if it exists.
5. Read repo-local `CURSOR.md`, `.cursorrules`, `AGENTS.md`, `CLAUDE.md`, `README*`, package/build/test files, and other relevant docs.
6. For non-trivial edits, update `.helicopter-harness/state/current-task.md`.
7. Load only the relevant skill docs from `.helicopter-harness/skills/`.

Cursor-specific behavior belongs here. Core harness files must remain tool-neutral.
