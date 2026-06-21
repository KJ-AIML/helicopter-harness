---
name: yo-workflow
description: >-
  The deep-review pattern for work too big for one careless pass — tracing many backend flows, hunting races, auditing authz across files. Use when you want maximum-recall finding plus adversarial verification before you trust the results, structured as find → refute → synthesize. Triggers when a task spans multiple flows/files, is too deep for a single skim, or you want findings you can act on without re-vetting by hand.
metadata:
  short-description: Deep find → adversarial-verify → synthesize review
---

# yo-workflow — Deep Review (find → verify → synthesize)

In Claude this skill drove the Workflow tool to fan out a swarm of Codex agents. In Codex, prefer the simplest shape that preserves the same quality idea: in-session review by default, separate MCP Codex sessions for independent context when it matters, and shell `codex exec` only as the fallback for large read-only fan-out.

The quality idea survives intact: **recall and precision are different jobs and must not share context.** One pass to find widely; a *separate, cold* pass to try to kill each finding; then synthesis. A finder that also judges its own findings rubber-stamps them.

## Path A — sequential, in-session (default, always works)

For most reviews. Three stages, done by you, one after another:

**Stage 1 — Recall (wide net).** Go flow by flow (auth, checkout, webhook-ingest, session, upload, admin-api…). For each flow run **two lenses** so nothing slips:
- correctness / races / data-integrity / error-handling
- security / authz / input-validation / injection / secrets

Trace the *actual* code paths. Record every candidate finding to a scratch file (`review-findings.md`) — title, severity, file:line, what breaks, proposed fix. Don't filter yet; recall now, precision later.

**Stage 2 — Precision (refute each finding cold).** Go back through every high/med finding and **try to refute it** — re-trace the real code as if a colleague reported it and you're skeptical. Confirm it's genuine or kill it; tighten the fix. Default to "refuted" when you can't actually confirm it. The discipline is to switch posture from builder to skeptic; doing this in a fresh `/new` session is stronger because you re-derive from the code, not from your Stage-1 notes.

**Stage 3 — Synthesis.** Dedupe overlapping findings, group by flow, rank by severity then blast radius. Then run a **completeness critic**: given the flows and the two lenses, what flow or risk class looks under-covered? List those as follow-up review targets. Output clean markdown: `## Confirmed findings (ranked)` then `## Coverage gaps`.

## Path B — MCP Codex sessions (preferred independent path)

When the review needs independent context but not shell orchestration, start one read-only MCP Codex session per finder/refuter:

```
mcp__codex__codex({
  cwd: "<absolute repo path>",
  sandbox: "read-only",
  approval-policy: "never",
  prompt: "Review <flow> through <lens>. Trace real code paths. Output confirmed findings only."
})
```

Use `mcp__codex__codex-reply` for follow-ups in that thread. Keep the prompts read-only, pass raw repo paths and the question, and synthesize the results yourself in the main session. The refute pass still gets its own fresh session/thread.

## Path C — parallel via shell `codex exec` (fallback for large surfaces)

When the surface is too big to hold in one context and MCP sessions are unavailable or too slow, fan out with background `codex exec` processes — true parallelism using Codex's own binary instead of an agent-swarm tool.

> **Verify this works in your shell first.** Nested `codex exec` depends on your Node/`fnm` setup and trusted-dir config; it can fail to bootstrap from a bare shell. Run one throwaway `codex exec --skip-git-repo-check -C <repo> "say PONG"` before relying on it. If it doesn't run cleanly, use Path A.

Sketch (bash): one finder per flow×lens, each writing JSON to a temp file, then you read them all and synthesize:

```bash
REPO=/abs/path/to/backend; OUT=$(mktemp -d)
for flow in auth checkout webhook session upload admin; do
  for lens in "correctness, races, data integrity, error handling" \
              "authz, authentication, input validation, injection, secrets"; do
    codex exec --skip-git-repo-check -C "$REPO" \
      "Review the $flow flow end-to-end through this lens: $lens. Trace real code paths. \
       Output ONLY a JSON array of findings [{title,severity,file,detail,fix}]." \
      > "$OUT/$flow-${lens%%,*}.json" 2>/dev/null &
  done
done
wait
# then: read every $OUT/*.json, and for each high/med finding spawn a fresh
# `codex exec` that tries to REFUTE it; finally synthesize the survivors yourself.
```

- No `-m` flag needed — `model = "gpt-5.5"` is the config default.
- Background with `&`, block on `wait`, keep concurrency sane (≤ ~12 at once).
- **The refute pass must be a *separate* `codex exec`** from the finder — same separation as Path A, just across processes.
- These are read-only reviews. **Fixes are a separate step** — do them yourself, in the main session, after synthesis.

## Choosing the shape

| Situation | Shape |
|-----------|-------|
| Review a handful of flows, want an actionable report | Path A (sequential, two lenses, refute, synthesize) |
| Just a diff/PR, fast | Path A, one lens, thin the refute stage |
| Need independent context without shell orchestration | Path B MCP Codex sessions |
| Huge surface, unknown-size bug count | Path C parallel fan-out (if `codex exec` works in your shell), or Path A looped flow-by-flow |
| Going deep on ONE flow, want to steer | Not this skill — just a normal focused Codex session |

## Anti-patterns

- **Finding and judging in the same pass.** Self-verification is weak. Refute cold — fresh posture or a fresh session/process.
- **Skipping the refute stage.** A raw finder pass has good recall but ships false positives you then triage by hand. The refute pass is the point.
- **Skipping the completeness critic.** Recall isn't done until you've asked what you *didn't* look at.
- **Editing during review.** Find and verify only; route fixes to a separate step.
- **Reaching for Path B/C when Path A suffices.** Independent sessions and shell fan-out add overhead; use them when one context genuinely can't hold the surface or cold verification matters.

## Relationship to other things

- `yo-audit` — cold verification that *a specific fix* is safe. Different axis: yo-audit checks a fix; yo-workflow *finds* the issues.
- `yo-engineering` — choose review flows/lenses before a broad review, especially when API/data/security/concurrency/operability risks are mixed together.
- `yo-fix-loop` — once yo-workflow produces confirmed findings, hand the list to yo-fix-loop to triage and ship.
- `config.toml` — `model`/trust live here; that's why no per-call model flag is needed.
