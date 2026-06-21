#!/usr/bin/env bash
# Optional Claude Code SessionStart hook for Helicopter-Harness.
# Emits JSON context only. It does not inspect, edit, or execute repo code.
cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"Helicopter-Harness reminder: read .helicopter-harness/adapters/claude/CLAUDE.md first, then .helicopter-harness/HARNESS.md. Identify the target repo before editing. Read the repo profile and repo-local docs where relevant. For non-trivial edits, update .helicopter-harness/state/current-task.md. Use the smallest relevant skill from .helicopter-harness/skills/ instead of working from this reminder alone."}}
JSON
