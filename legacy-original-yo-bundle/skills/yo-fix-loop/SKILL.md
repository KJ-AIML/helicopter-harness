---
name: yo-fix-loop
description: >-
  The triage→fix→verify loop for clearing a list of findings. Use whenever there are multiple discrete changes to drive to done — PR comments, bug-bash output, post-incident action items, audit findings, a backlog wave. Trigger phrases: "fix all these", "clear this list", "handle the findings", "go through the review", "ship this wave", "address the PR comments", "sort out these bugs", or any "we have N issues, sort them out." Even a casual "fix the bugs" should invoke this. Prioritizes findings, tracks one plan item per concrete change, fixes each, verifies each independently before marking it done, and never marks a task done on a "looks fixed" alone.
metadata:
  short-description: Triage, fix, and independently verify a wave of findings
---

# yo-fix-loop — Orchestrate a Fix Wave

This skill is the coordinator: read the list, sort it, turn each finding into a tracked task, fix it, verify it independently, close it out. The discipline that makes it work is **separating the fix from its verification** — even when both are done by the same agent (you), the verification pass must approach the change cold, as if someone else wrote it.

If you only have one fix to ship, you don't need this — just fix it. This skill earns its overhead once there are three or more discrete changes.

## Codex reality: sequential edits, independent verification when it matters

In Claude this loop dispatched a separate implementer subagent and a separate auditor subagent per task. In Codex, keep the active worktree edits sequential, then choose the cheapest verification shape that gives enough independence:

- **Track work with the plan tool (`update_plan`).** One plan item per concrete change. Mark in-progress when you start, completed only after the verify pass passes.
- **Fix, then verify with fresh eyes.** After a fix, *stop implementing and switch posture to auditor*: re-read the cited bug cold, re-read the diff, and **re-run the failing test / build**. Don't trust your own "looks fixed."
- **For high-stakes items, get true independence.** Start a fresh Codex session (`/new`) or a read-only MCP Codex reviewer (`mcp__codex__codex` / `mcp__codex__codex-reply`) and have it verify the diff with no memory of how you wrote it. If MCP is unavailable, fall back to shell `codex exec --skip-git-repo-check -C <repo> "Audit commit <sha> against this bug: <...>. Re-run <test>. Report PASS/FAIL with evidence."`

Use the configured `~/.codex/config.toml` defaults; pass an explicit model only when the delegation tool requires it.

## Why this loop is structured the way it is

Three primary-source-backed claims (full citations in `references/sources.md`):

1. **Author/reviewer separation is structural.** Code review at Google is defined as examination "by someone other than the author." The same context that chose an approach is the worst-positioned to review it — which is why the verify pass must come cold, in a fresh posture or a fresh session.
2. **Small batches beat big drops.** Google's CL guide: ~100 lines is reasonable, ~1000 is too large. One task = one commit.
3. **Done = verification, not a claim.** CI green is necessary but not sufficient; the verify pass is the gate.

Reading dominates the day (~58% of active programming time on comprehension — Minelli et al.), so this loop front-loads reading and treats writing as the small middle. For honest evidence-divergence notes, see `references/evidence-notes.md`.

## The loop, in order

### Phase 0 — Read before acting
Verify the premise. Cited file path? Open it. Claimed behavior? Trace it. A surprising number of reported issues evaporate once you read the code; others are real but worse than reported. Skipping this ships the wrong fix. (This is the `yo-verify-premise` posture, applied per finding.)

### Phase 1 — Triage and prioritize
Collect every finding into one list and bucket it:
- **P0 / SEV-1** — production broken or unsafe; drop everything
- **P1 / SEV-2** — bug with real user impact; ship before close-out
- **P2 / SEV-3** — narrow blast radius; ship this wave
- **P3 / SEV-4** — polish, cleanup, dead code; opportunistic
- **P4** — nice-to-have; park unless trivially adjacent

Work highest priority first. Polish before a P1 bug is a sign the loop is on autopilot. If two findings overlap or one follows from another, note the dependency.

Then tag each finding by **who owns the decision** (orthogonal to priority):
- **auto** — mechanical, low-risk; you can fix and verify it on your own judgment.
- **no-op** — informational; nothing to change.
- **ask-user** — the finding challenges the user's deliberate intent or changes product behavior. This is the user's call, not yours: surface it verbatim (finding id, file, description), ask before you fix / skip / approve, and don't auto-resolve it just because it looks easy. This is the per-finding form of the Phase 6 reversibility gate — stop at the one-way door.

For any P0/P1 or cross-cutting finding, run the `yo-engineering` senior gate before editing: risk tier, invariant, rollback/compatibility, and specialist lenses. This prevents the loop from treating a data/security/API failure like a normal local bug.

### Phase 2 — Convert findings into plan items
Put the list into the plan tool (`update_plan`). One item = one concrete change a single pass can ship in one commit. A task that touches three files in three layers is fine; a task bundling three unrelated fixes is not — split it.

The converse also holds: **a finding too big to ship as one reviewable commit is not a fix-loop item — it's a mini-feature.** Route it to `yo-feature` (issue-as-spec, vertical slices, one commit per slice) instead of forcing it through this loop as a mega-commit. The loop's "one task = one commit" discipline only works when tasks are commit-sized to begin with.

Each item carries (in your notes): imperative subject ("Fix RegenerateAsync race"), one-line why, file:line pointer if known, and the acceptance check the verify pass will run.

### Phase 3 — Fix
Take the top item, mark it in-progress, and implement it. Read the cited file(s) before editing. If you can reproduce the failure but can't *explain* it, switch to `yo-debug` before touching code — never fix what you can't explain. Then run the `yo-impact` pre-edit analysis: blame the lines you're about to change (deliberate decision or bug?), map who uses the surface (including string-form references), find the siblings that share the flaw, and write the one-sentence blast radius into the plan item. If the reported failure is a symptom, name the root cause even if you only patch the symptom — note whether a deeper follow-up is warranted. Build (0 errors), run the relevant tests (0 failures). Stage explicit paths only — no `git add .`/`-A`. Commit with a clean message (no Co-Authored-By, no AI mentions). Push if that's the workflow.

### Phase 4 — Verify (cold)
Switch to auditor posture (or a fresh session / MCP Codex reviewer / `codex exec` fallback per the note above). Re-read the bug, re-read the diff, **re-run the failing test/build**. Then:
- **PASS** — mark the plan item completed, move on.
- **FAIL** — read why, then choose:
  - *Minor gap* (missing test, unhandled edge): patch it. One retry, then escalate.
  - *Wrong approach*: reset and re-frame from the auditor's redline — the original framing is now poisoned. A fresh `/new` session helps here.
  - *Premise broken* (bug doesn't exist as described, or the fix needs a different decision): pause and surface to the user.
  - Always write a one-line note on what went wrong before retrying. A partial-PASS that resurfaces as a "new" finding next wave is a real failure mode.

### Phase 5 — Batch control
Work edits **sequentially**, highest priority first. Parallelize only read-only research or cold verification when it cannot mutate the shared worktree. Keep batches small and reviewable: one task → one commit → verify → next. If task B depends on task A (A renames a symbol B uses), order them and don't start B until A is verified.

### Phase 6 — Reversibility gate
Type 2 (two-way door) changes can run: file edits, feature-branch commits. Type 1 (one-way door) needs explicit user sign-off, even mid-loop: **force push, `git reset --hard`, dropping a table, sending anything externally, publishing a release, modifying CI.** Pause and ask.

### Phase 7 — Wrap-up
Post one concise summary when the wave closes:
- **What shipped** — commit SHAs + one line each
- **Surprises** — anything future-you should know (e.g., a latent race the suite doesn't cover yet)
- **Found but not fixed** — leftover items with reason (out of scope, deferred, won't-fix), each with an owner or a filed follow-up

Tone: Slack to a teammate, not a changelog. Match the project's voice, no emoji unless the user uses them, no "I successfully completed…" preamble. **Hand the actual writing to `yo-gh-write`** — it owns issue/PR/comment authoring, house style, and the anti-AI-slop pass. yo-fix-loop decides *what* the wrap-up says; yo-gh-write decides *how* it reads.

**Carry the proof into the comment, don't leave it in the CLI.** The verify pass produced real evidence — test commands, pass counts, console output. When the wave is against a PR/issue, that evidence belongs in the wrap-up (and per-thread "fixed in <SHA>" replies), not just your terminal: curated result lines in prose, raw logs in a `<details>` block bound to command + SHA. Use `yo-gh-write`'s "Verification evidence" template. The PR/issue is the expected endpoint; CLI-only is the fallback when there's nothing to post to.

## Skills to invoke alongside
- **`yo-verify-premise`** — Phase 0 posture for a finding whose premise is shaky
- **`yo-engineering`** — risk tier and specialist-review selection for P0/P1 or broad/cross-cutting findings
- **`yo-audit`** — the cold verification posture/checklist for Phase 4
- **`yo-test-coverage`** — when a task is "pair a regression test with this fix"
- **`yo-gh-write`** — the wrap-up comment and any PR text
- **`code-simplifier`** — after a fix passes, when the touched code is noisier or more complex than needed
- Domain skills — invoke when the stack matches. If none fit, proceed.

## Anti-patterns
- **Fixing without reading the cited code.** Always Phase 0.
- **Self-verification by reflex.** "I tested it" is not a PASS — re-run the failing test cold.
- **Marking tasks done before the verify pass.** Breaks the load-bearing structure.
- **Bundling unrelated fixes into one commit.** Wrecks reviewability and bisect. One task = one commit.
- **Refactoring inside a fix commit.** Behavior change and refactor are separate commits — reviewers and bisect can't untangle them. Route post-fix cleanup to `code-simplifier` as its own commit.
- **Working highest priority last.**
- **Skipping the wrap-up.** The summary is the only artifact the team sees.
- **`git add .`** — stage explicit paths.
- **Re-fixing the same finding across batches** because a prior "PASS" was partial. Write a note on what slipped.
- **Treating the loop as ceremony.** One trivial typo → just ship it. The loop is for plurality.

## Calibration sources
Full citations: `references/sources.md`. Evidence-divergence notes (TDD, seniority folklore): `references/evidence-notes.md`. Read once at setup.
