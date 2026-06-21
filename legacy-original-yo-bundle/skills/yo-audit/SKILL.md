---
name: yo-audit
description: >-
  Independent read-only verification of a code change. Use when the task is "audit this commit", "verify the fix", "double-check before merge", "is this safe to ship", "did the fix actually fix it", "review this PR", "sanity-check this diff", or anything where someone claims a change works and you need a second pair of eyes that wasn't involved in the implementation. Does NOT modify code. Disbelieves until shown — re-reads the cited bug, traces the diff against the failure mode, runs the relevant test filter, and reports PASS / FAIL with concrete evidence in under 200 words. Pairs with yo-fix-loop as the verification step after every implementer commit; also valid standalone when reviewing a single PR or commit. Invoke this even if the implementer said "all tests pass" — that's exactly when this skill is most valuable.
---

# yo-audit — Independent Verification

This skill is the auditor. Read-only. The job is to disbelieve until shown — the implementer's "all tests pass" is exactly when independent verification has the most value, because that's when nobody else is looking hard.

## Why this is a separate skill

Code review at Google is defined as examination by *someone other than the author*. Self-review is structurally weak: the same model that chose an approach is the worst-positioned reader of it. Empirical work on review bias also shows reviewers who saw the author's framing rate identical contributions differently — so the auditor's value comes from approaching the work cold, with no investment in the chosen approach.

CI green is necessary but not sufficient. The auditor's PASS is the gate.

For citations and evidence-divergence notes, see `references/sources.md`.

## When to invoke

- Right after any `yo-fix-loop` task's implementer commits — verify before marking the task done
- Reviewing a single commit or PR independently ("audit this commit SHA")
- Pre-merge sanity check on a non-trivial change
- "Did the fix actually fix it?" — when an earlier claim of resolution needs a second pair of eyes
- Reconcile pass — when two parties disagree on what a piece of code does

Do not use this skill to *make* changes. If the audit finds a real bug, report it — the orchestrator decides whether to dispatch a fixer.

## The audit, in order

### 1. Read the framing, then ignore the implementer's narrative

The orchestrator (or user) will hand off: commit SHA, the **intent** (what the change set out to accomplish), the cited bug or expected behavior, and the acceptance criteria. Read those.

Intent is what separates a deliberate decision from a mistake. A diff detail that contradicts the cited bug or acceptance is a defect; a detail that merely surprises *you* but matches the stated intent is not — at most it's an `ask-user` (see yo-fix-loop), not a FAIL. If no intent was handed off and the diff makes surprising choices, say so and ask for it rather than flagging them as bugs.

Then ignore any framing that biases you toward PASS. The implementer's report ("fix works, tests pass, no issues") is data, not evidence. The diff and the cited bug are the evidence.

### 2. Scope check

```
git show <SHA> --stat
```

Confirm the change touches only what it should. Stray edits in unrelated files are a yellow flag — sometimes legitimate (small adjacent cleanup) but often a tell that the implementer drifted scope or got swept by a git-index race. If you see them, name them in the report.

### 3. Read the diff against the cited bug

Open the changed file(s). Trace the bug's failure mode through the new code. Ask:

- Does this change actually close the failure mode the bug describes, or only the *symptom* the bug surfaced?
- Are there other code paths that hit the same root cause that this change misses?
- Did the change introduce a new failure mode? (Off-by-one on a guard, ordering change, exception swallowed, cleanup skipped on early return)
- Is anything in the diff trying to be cleverer than it needs to be? Cleverness without comment is a regression risk.

If the diff touches API contracts, data, security, concurrency, production jobs, or user-visible UI, apply the `yo-engineering` risk lens and name any specialist reviewer that should have been involved. A PASS can include "no extra specialist lens needed"; do not silently skip the risk call.

### 4. Re-run the relevant tests

Don't trust the implementer's "tests pass." Run them yourself:

```
<test command> --filter <relevant>
```

If the implementer claimed a test was added, find it. Read it. Confirm it would fail without the fix — a test that passes on both sides of the diff doesn't lock in anything. (You can verify this in a worktree by reverting the source change while keeping the test.)

**Capture the raw output as you go.** Save the exact command and its console output for each test run — that's the proof the report links to. When this audit is posted to a PR/issue (the usual case, not CLI-only), the curated tail goes in the report and the full log goes in a `<details>` block, each bound to its command and the commit SHA it ran against. See `yo-gh-write` ("Verification evidence" template).

### 5. Cross-check for the common silent failures

- **Symptom patched, root cause untouched.** Look for a guard wrapped around the reported failure when the underlying state still corrupts.
- **Comments lying about behavior.** Comment says "returns true on cancel" but the code returns false. Check.
- **Cleanup not on every path.** Resource acquired, but disposed only on the success branch.
- **Reverted improvement.** Did the diff undo a previous fix without referencing it? `git log -L` on the changed lines can surface this.
- **Hidden coupling.** Renamed symbol exported elsewhere; removed code referenced by string in a config or migration.
- **Test that doesn't exercise the bug.** Test name reads right but the body asserts something else entirely.

### 6. Report

Format the report tightly. **The 200-word limit is the prose verdict only** — raw test output doesn't count against it, because it lives in a collapsed `<details>` block, not the prose. Structure:

```
PASS / FAIL.

Scope: <one line — what the diff changes, and whether scope is correct>
Behavior check: <one line — does the change close the cited failure mode>
Tests: <one line — pass/fail count from your run, and whether the new test
        actually exercises the bug>
Notes: <bullets, only if you spotted something — root cause not addressed,
        latent issue not in scope, regression risk, etc.>
```

If FAIL, name the specific defect with file:line. The orchestrator's job is to decide what to do with it; yours is to make the defect impossible to dismiss.

**Where the report goes.** When the audit is against an existing PR or issue, the report is meant to land there as a comment — that's the expected endpoint, not a CLI-only print. Hand the verdict + the captured logs to `yo-gh-write` (its "Verification evidence" template), which posts via `--body-file` after the usual draft-in-chat check. CLI-only is the fallback when there's no PR/issue to post to.

## Anti-patterns

- **Rubber-stamping a "reasonable-looking" diff** without running the tests or re-reading the cited bug. The single most common silent failure of two-agent review.
- **Believing the implementer's narrative.** Their context is shaped by the framing they got; yours should be shaped by the code.
- **Treating CI green as the answer.** It's a precondition, not a verdict.
- **Going over 200 words.** A long audit report is a signal you didn't reach a clear verdict — say PASS or FAIL with the minimum evidence, escalate if you can't.
- **Modifying code while auditing.** Read-only is structural. If you write, you're an implementer, not an auditor — and you can't audit your own work.
- **Auditing only the symptom.** A senior audit checks whether the change preserves contracts, data, security, operability, and rollback expectations when those surfaces are touched.

## Audit prompt template (for callers)

When the orchestrator or user dispatches this skill, the prompt should look like:

```
Audit-only. Do NOT modify code. Verify commit <SHA> on <branch> in <repo>.

Intent: <what the change set out to accomplish — the goal, tradeoffs ruled in/out, and any deliberate-but-surprising decisions. Not a description of the diff.>

Cited bug / expected behavior: <one paragraph>

Acceptance: <what done looks like>

Verify per yo-audit:
1. git show <SHA> --stat — scope matches
2. Read the changed file(s) against the cited bug
3. Run <test filter> — confirm pass/fail count
4. Check for symptom-vs-root-cause, regressions, hidden coupling

Report under 200 words: PASS / FAIL with file:line specifics on any defect.
```

## Sources

See `references/sources.md`.
