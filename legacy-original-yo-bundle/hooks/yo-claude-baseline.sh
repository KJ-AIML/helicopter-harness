#!/usr/bin/env bash
# Injects the user's yo-* operating baseline into every Claude Code session.
# Wired via the SessionStart hook in ~/.claude/settings.json. Emits JSON whose
# additionalContext is added to the model's context at session start.
cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"yo-* operating baseline (auto-injected at session start). Before the first substantive action, apply the user's yo-claude-settings baseline: strongest Claude model at fixed high thinking, normal context (no 1M default), and the Karpathy four principles - think before coding, simplicity first, surgical changes, goal-driven execution with concrete verification. Read any CLAUDE.md / AGENTS.md in scope before the first edit. Route work through the yo-* skills: yo-flow to triage ambiguous requests, yo-verify-premise before acting on any 'fix X' claim, yo-engineering as the risk gate for broad or high-risk work, then yo-feature / yo-fix-loop / yo-audit / yo-test-coverage / yo-branch / yo-gh-write. Invoke the relevant skill rather than working from this summary alone."}}
JSON
