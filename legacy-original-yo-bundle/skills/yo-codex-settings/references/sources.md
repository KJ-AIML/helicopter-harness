# Sources - yo-codex-settings

## CLAUDE.md authoring guidance

User-flagged reference: **"Mckathy"** — best interpretation is **McKay Wrigley's** Claude Code / CLAUDE.md content (widely-circulated practitioner guide; he posts CLAUDE.md examples and breakdowns regularly on X/YouTube). If the user meant a different source, update this note rather than silently swapping.

- McKay Wrigley on X — search his pinned/recent CLAUDE.md threads
- Anthropic's official CLAUDE.md / memory guidance: https://code.claude.com/docs/en/memory (canonical; older `docs.claude.com` URLs redirect here)
- Anthropic prompting docs: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview

## Karpathy baseline

Full text in `karpathy-baseline.md`. Sourced from:

- https://github.com/forrestchang/andrej-karpathy-skills
- https://github.com/multica-ai/andrej-karpathy-skills (mirror containing the actual SKILL.md file)

## Model + reasoning effort

Anthropic's own guidance is that for complex tasks, the largest available model at fixed high reasoning produces the best results vs. adaptive budgets. Adaptive modes optimize for cost-per-token, not correctness-per-task — the user's "the brain gets stupid" intuition tracks this.

- Anthropic docs on extended thinking: https://platform.claude.com/docs/en/build-with-claude/extended-thinking
- Anthropic docs on Claude Code settings: https://code.claude.com/docs/en/settings

## Context window

The user's preference: default ~200k, bump to 400k only when a specific task needs it, avoid 1M.

Why this is right in practice (not just the user's feel):

- **"Lost in the middle" / mid-context degradation** is a documented LLM phenomenon — performance on retrieval and reasoning declines for material in the middle of a long context, even when the window technically holds it.
  Liu et al., "Lost in the Middle: How Language Models Use Long Contexts" — https://arxiv.org/abs/2307.03172
- **Anthropic's own 1M context launch notes** flag that long context is best for tasks where you actually need the breadth (large codebase scan, doc QA over a corpus) — not as a default. The cost is real both in price and in latency, and quality on focused tasks is generally best at lower utilization.
- **Compaction + fresh sessions** is the right move for long-running work. Claude Code's automatic compaction summarizes and re-loads — but a *manual* fresh session with a tight handoff prompt usually beats a deeply compacted one. The user's "1M hallucinates more when keep working on it" tracks the practical experience that the longer a thread runs at high utilization, the muddier it gets.

## Honest notes

- The "Mckathy" attribution is my best guess from a phonetic mention by the user. Update on confirmation.
- The Karpathy guidelines are a distillation by `forrestchang`, not Karpathy's own published file. They reflect his stated practice but are second-hand. Treat as a strong heuristic, not a primary source.
