---
name: yo-feature
description: >-
  Use when building something NEW — a feature, capability, or screen — from an idea or spec, end to end (scope → implement → verify → ship). Triggers on "build X", "add a feature that…", "implement Y", "I want the app to do Z". Not for fixing existing bugs (that's yo-verify-premise / yo-fix-loop) or one-line diffs (just write those directly).
metadata:
  short-description: Spec-driven loop to build a feature end to end
---

# yo-feature — Spec-Driven Feature Loop

The loop for taking a feature from "here's an idea" to "shipped, verified change." It rests on three findings from agentic-coding practice: **separate planning from doing**, **give yourself a runnable pass/fail signal** (agents declare premature victory — a green check is the gate, not a feeling), and **the context window is the binding constraint** — so work one slice at a time against minimal, high-signal context.

## When this vs the neighbors

| Use | When |
|-----|------|
| **yo-feature** | Building something NEW from an idea/spec, full arc, multi-file or unfamiliar code |
| `yo-engineering` | Senior risk gate for broad/high-risk work before choosing slices or specialist reviewers |
| just implement directly | A clear single-slice change — you already know the files and the diff |
| `yo-fix-loop` | A WAVE of fixes to existing code (review comments, audit findings) — not new building |
| `yo-verify-premise` | "Fix bug X" — confirm the bug is real first; yo-feature is for building, not fixing |
| `yo-audit` | The cold-eyes verification posture the verify phase uses |

**Trivial-diff escape:** if you could describe the change in one sentence, skip all of this and just write it. The loop below is for uncertain approach / multiple files / unfamiliar code.

## Working from a GitHub issue

A big issue is a **spec input, not a unit of change**. The mapping: **1 issue = 1 branch = 1 PR (`Closes #N`); 1 PR = N slice commits** — never one mega-commit. Pull the issue body and comments into `SPEC.md`, decompose into vertical slices as usual, and commit per slice so the PR reviews incrementally and `git bisect` stays useful. If the slices won't fit one reviewable PR (~1000 changed lines is already too large per Google's CL guide), split the issue into sub-issues — or a tasklist on the parent — and ship one PR per sub-issue. If the work will span more than ~a week, don't let the branch age either: use `yo-engineering`'s long-running strategy (feature flag, branch by abstraction, or wire-the-entry-point-last) so slices merge to the integration branch continuously.

## Artifacts live in the TARGET repo, not your home dir

Two durable files, written to the project being worked on, so a fresh session (yours or a teammate's) resumes cleanly — agents have no memory across context windows:
- **`SPEC.md`** — self-contained scope. Names the files/interfaces involved, states what's out of scope, ends with an end-to-end verification step that proves the feature works.
- **`features.json`** — the tracking backbone. A JSON list of vertical slices, each `{ id, description, verify_steps, passes: false }`. JSON not Markdown (less likely to clobber it). Flip `passes` to `true` **only** after the deterministic check confirms — nothing else.

## The loop

1. **Scope → SPEC.md.** Interview the user (plain-text questions, one screen at a time — Codex has no question widget) until the feature is fully covered, then write `SPEC.md`. Decompose into small, single-objective **vertical slices** → seed `features.json`. One slice at a time beats one-shotting the whole thing.
2. **Plan.** For each slice, write the plan before any edit — which files, which interfaces, the test that defines done. When a slice *modifies* existing code (rather than only adding), run the `yo-impact` pre-edit analysis and put its blast-radius sentence in the slice notes: who uses the surface, what each caller will observe differently, which siblings share the pattern. For broad/high-risk work, run the `yo-engineering` senior gate first: risk tier, invariants, rollback, specialist reviewer lenses. Use the plan tool (`update_plan`) to track slices; write the design as text when the approach is uncertain.
3. **Implement one slice — test-first.** Write the test(s) from the slice's acceptance criteria first, then implement just enough to pass. Use agentic search (grep/read on demand) over loading whole files; carry references (paths, queries), not blobs.
4. **Verify — deterministic gate, then cold eyes.** Run the runnable check (tests / build exit code / linter / type-check) — that's the gate, not "looks done." For UI, exercise it end-to-end as a user would. Then a **cold-eyes review** that sees only the diff + the slice's criteria and flags **only** correctness/requirement gaps — not style. For real independence on a tricky slice, use a fresh `/new` session or a read-only MCP Codex reviewer; shell `codex exec` is the fallback when MCP is unavailable. Flip `passes: true` only when the check passed.
5. **Commit + reset context + repeat.** Commit the slice — **one slice = one commit**; never let slices accumulate into one big commit at the end. Update `features.json`. Start a fresh session (`/new`) between unrelated slices to fight context rot, then resume from `SPEC.md` + `features.json`. Loop to step 2 for the next slice.
6. **Ship.** When all slices pass: `yo-branch` readiness check → `yo-gh-write` for the PR body. The deterministic gate from step 4 produced real evidence (test commands, pass counts, the end-to-end check) — carry it into the PR/issue as a verification-evidence comment, not just your terminal: curated result lines in prose, raw output in a `<details>` block bound to command + SHA (`yo-gh-write`'s "Verification evidence" template). The PR/issue is the expected endpoint; CLI-only is the fallback when there's nothing to post to.

## Context discipline (the quality multiplier)

- **Keep active edits sequential.** Parallelize only read-only research or cold review when independent context is worth the overhead. Once you've traced an unfamiliar subsystem, write the 1–2k-token summary into `SPEC.md` so the next session doesn't re-trace it.
- **Don't try to build the whole feature in one pass.** Coding isn't parallelizable the way research is; one slice at a time keeps the context window high-signal.
- **JIT retrieval.** Keep lightweight identifiers (paths, queries); load on demand. Respect the repo's `AGENTS.md` / `CLAUDE.md` as always-on project policy.

## Anti-patterns

- **Trusting "done."** No `passes: true` without a runnable check that actually passed.
- **Reviewing as the author.** The verify pass must approach the diff cold — fresh posture, ideally a fresh `/new` session — not a victory-lap reread of code you just wrote.
- **One-shotting the whole feature.** Decompose into slices; one at a time. Unbounded requests cause context exhaustion and premature "done."
- **Skipping SPEC.md / features.json because "it's small."** If it's that small, it's a trivial diff → just write it. If it's not, the artifacts are what make the next session resumable.

## Relationship to other things

- `yo-flow` — the router; its "Build a feature" branch lands here.
- `yo-engineering` — risk tier and specialist-review selection for non-trivial features.
- `yo-audit` — the cold-eyes verification posture in step 4.
- `yo-test-coverage` — pairs the regression test with the slice (step 3's test-first).
- `code-simplifier` — refines touched code after the slice passes when the diff is noisier than necessary.
- `yo-branch` / `yo-gh-write` — step 6 shipping.
- `yo-workflow` — NOT the inner loop; standalone deep review only.
