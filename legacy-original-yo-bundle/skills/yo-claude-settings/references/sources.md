# Sources - yo-claude-settings

## CLAUDE.md authoring guidance

User-flagged reference: "Mckathy" is most likely McKay Wrigley's Claude Code / CLAUDE.md guidance. If the user confirms a different source, update this note.

- Claude Code memory / CLAUDE.md guidance: https://code.claude.com/docs/en/memory
- Anthropic prompt engineering docs: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview

## Karpathy baseline

Full text in `karpathy-baseline.md`. Sourced from:

- https://github.com/forrestchang/andrej-karpathy-skills
- https://github.com/multica-ai/andrej-karpathy-skills

The Karpathy guidelines are a distillation by the repo authors, not a single canonical Karpathy file. Treat them as a strong coding heuristic.

## Model, thinking, and context

The user's preference: strongest available Claude model, fixed high thinking for serious engineering work, and normal context size unless the task needs more. Avoid huge context as a default; use fresh sessions and tight handoffs when a thread degrades.

Relevant public references:
- Anthropic extended thinking docs: https://platform.claude.com/docs/en/build-with-claude/extended-thinking
- Claude Code settings docs: https://code.claude.com/docs/en/settings
- Liu et al., "Lost in the Middle: How Language Models Use Long Contexts": https://arxiv.org/abs/2307.03172
