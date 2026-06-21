---
name: yo-codex
description: Use whenever Claude is about to delegate work to OpenAI Codex CLI. Default to the MCP session (`mcp__codex__codex` plus `mcp__codex__codex-reply`) because it keeps an interactive thread alive, edits files in place, and preserves task context. Use shell `codex exec` only for true one-shot fallback work such as read-only review or standalone questions. Encodes the routing rules so future sessions do not re-decide the delegation path.
allowed-tools: Bash, Read, Grep, Glob
---

# yo-codex - Codex Delegation

Use this when Claude needs Codex as an implementation or review partner.

## Default route: MCP session

Use `mcp__codex__codex` for the first turn, then `mcp__codex__codex-reply` with the returned `threadId` for every follow-up. The live thread keeps state, edits land in place, and follow-up failures can be sent back without rebuilding context.

Use MCP for:
- Multi-file implementation.
- Refactors or fixes that may need follow-up.
- Work where Codex should read, edit, run checks, and react to failures.
- Parallel implementation or review alongside Claude's own work.

Required shape:

```text
mcp__codex__codex({
  prompt: "<actual task, no preamble>",
  model: "gpt-5.5",
  cwd: "<absolute project path>",
  sandbox: "workspace-write",
  approval-policy: "never"
})
```

Follow-up shape:

```text
mcp__codex__codex-reply({
  threadId: "<thread id from first response>",
  prompt: "<next turn or verification failure>"
})
```

Rules:
- Always pass an absolute `cwd`.
- Use Windows paths on Windows machines.
- Save `threadId` immediately.
- Do not start a new MCP session for a normal follow-up.

## Fallback route: `codex exec`

Use shell `codex exec` only when a live MCP session is unavailable or genuinely unnecessary.

Good fallback uses:
- One-shot read-only review.
- Standalone second opinion.
- Small script or analysis where no follow-up is expected.

Avoid fallback for implementation you may need to iterate on. If verification fails, a live MCP session is the better tool.

## After Codex edits

Verify by behavior, not by rereading every edited file out of habit:

1. Run the relevant project check: tests, lint, type-check, build, or browser flow.
2. If verification passes, continue.
3. If verification fails, send the failure to `codex-reply`.
4. Read files only when you need to take the work back, cite a line, or make your own follow-up edit.

## Routing examples

| Task | Route |
|---|---|
| "Add `/api/health` and tests" | MCP |
| "Refactor auth middleware" | MCP |
| "Review this diff for authz risk" | MCP if available; `codex exec` read-only fallback if not |
| "Is this regex safe?" | `codex exec` fallback is acceptable |
| "Implement a parallel approach so we can compare" | MCP |

## Anti-patterns

- Using one-shot fallback because it feels lighter, then needing follow-up.
- Pasting Codex prose into a file edit instead of asking Codex to make the edit.
- Re-reading files only to confirm that Codex wrote what it said.
- Forgetting `cwd`.
- Losing the `threadId`.
- Letting approval prompts hang a trusted local delegation.

## Related state

- `~/.codex/` contains Codex config, rules, skills, and memories on current installs.
- MCP registration is user-scoped. Verify the active machine before assuming exact paths.
- `yo-codex-settings` defines the user's Codex-side model/effort baseline.
