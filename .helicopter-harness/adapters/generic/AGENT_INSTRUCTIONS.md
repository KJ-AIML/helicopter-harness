# Generic Agent Instructions

The agent must treat `.helicopter-harness/HARNESS.md` as the source of truth.

Before substantive work:

1. Start from the parent workspace.
2. Read `.helicopter-harness/HARNESS.md`.
3. Identify the target repo before editing.
4. Read the matching `.helicopter-harness/profiles/<repo>.md` if it exists.
5. Read repo-local agent, README, package, build, and test docs where relevant.
6. For non-trivial edits, update `.helicopter-harness/state/current-task.md`.
7. Use the relevant skill docs from `.helicopter-harness/skills/`.

Do not assume branch policy, test commands, generated-file policy, or deployment policy unless repo documentation says so.

