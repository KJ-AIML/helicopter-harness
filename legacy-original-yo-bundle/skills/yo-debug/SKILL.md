---
name: yo-debug
description: >-
  Root-cause a confirmed bug whose cause is unknown. Use when the failure is real (yo-verify-premise confirmed it, or it's reproducing in front of you) but you cannot yet explain WHY it happens — "why does this fail", "can't figure out this bug", "it crashes sometimes", "it used to work", "intermittent failure", "weird behavior", debugging sessions that have gone in circles. Fires BETWEEN yo-verify-premise (is it real?) and the fix (yo-fix-loop / direct edit): deterministic repro first, one falsifiable hypothesis at a time, bisect when "it used to work", instrument instead of stare, and never fix what you can't explain.
metadata:
  short-description: Root-cause loop — repro, hypothesize, bisect, explain, then fix
---

# yo-debug — Root-Cause Before Fix

This skill covers the hard middle that the rest of the pack assumes away: the bug is confirmed, and you don't know why it happens. `yo-verify-premise` answers "is it real?"; `yo-fix-loop` ships the fix. This is the gap between them.

The core rule: **never fix what you can't explain.** A fix you can't explain is a symptom patch by definition — it may make the failure invisible while the corruption continues. Debugging is a method, not intuition; the method is the scientific one.

## When to invoke

- A confirmed bug with no known cause — repro exists, explanation doesn't
- "It used to work" — a regression with an unknown introducing change
- Intermittent / flaky failures ("crashes sometimes", "only in CI")
- A debugging session that has gone in circles — two failed fix attempts means stop fixing and start here
- Handed off from `yo-verify-premise` with verdict *confirmed* but the causal chain untraced

Do NOT invoke when the cause is already obvious from the read (a null check missing at the exact reported line) — just fix it. This skill earns its overhead when the first read does *not* explain the failure.

## The loop, in order

### 1. Get a deterministic repro first

Nothing else starts until the failure reproduces on command. A bug you can't reproduce is a bug you can't verify a fix for — any "fix" against it is a guess.

- Capture the exact failing input, environment, and steps.
- **Shrink it.** Cut the repro down until removing anything makes the failure disappear (delta-debugging posture). A minimal repro often *is* the diagnosis — the last thing you couldn't remove is the cause.
- For intermittent failures: make them deterministic before debugging — fixed seed, fake clock, forced thread interleaving, repeated runs in a loop until the flake fires under instrumentation. Classify per `yo-test-coverage`: product race / test race / infra. Do not debug a race by staring at a pass.

### 2. Read the error, actually

The failure message is evidence, not noise. Read the stack trace bottom-up to the first frame in *your* code. Read the exact message — "connection refused" and "connection reset" are different bugs. If there are logs, read the lines *before* the failure, not just the failure.

### 3. One falsifiable hypothesis at a time

State the hypothesis as a prediction before observing: *"If the cause is X, then adding a log at Y will show Z."* Then check. Whatever the result, you learned something; if you observed first and theorized after, you learned nothing — you pattern-matched.

One variable at a time. Changing three things and seeing the failure disappear tells you nothing about which one mattered — and usually means it will be back.

### 4. Bisect when "it used to work"

A regression has an introducing commit, and finding it is mechanical, not clever:

```bash
git bisect start
git bisect bad HEAD
git bisect good <last-known-good-tag-or-sha>
# with a runnable repro, automate the whole search:
git bisect run <command that exits 0 on good, non-zero on bad>
```

The introducing diff is usually small and points straight at the cause. This is also where the pack's one-slice-one-commit discipline pays off — bisect lands on a 100-line commit, not a 3000-line drop.

### 5. Instrument instead of stare

When the causal chain isn't visible by reading, make the program show its state: targeted logging, assertions on invariants, a debugger breakpoint at the boundary. **Binary-search the data flow** — instrument the midpoint between "state known good" and "state known bad", then halve again. Five probes beat fifty minutes of rereading.

Remove the probes when done — or promote the load-bearing ones to real assertions/observability (`yo-engineering`'s observability lens).

### 6. Explain, then fix

Before editing, write the causal chain in one short paragraph: *trigger → mechanism → observed failure*. It must account for ALL the symptoms — an explanation that covers the crash but not the "only on Tuesdays" part is incomplete, and the unexplained residue is usually the real bug.

Then fix, and pair the fix with the repro turned into a regression test (`yo-test-coverage` — the minimal repro from step 1 is the test, verified to fail on the parent commit). Route multi-finding outcomes through `yo-fix-loop`.

## Anti-patterns

- **Shotgun debugging.** Changing several things at once until the failure disappears. You didn't fix it; you hid it.
- **Fixing without a repro.** Unverifiable by construction.
- **"It went away."** A failure that stops without an explanation is a failure that will return at a worse time. Either explain it or file it as a known intermittent with the evidence so far.
- **Blaming the framework / compiler / library first.** It's your code until proven otherwise — select-isn't-broken posture. (When it genuinely IS the dependency, `yo-deps` owns the upgrade/pin response.)
- **Staring instead of instrumenting.** If two read-throughs didn't reveal it, the third won't. Make the program tell you.
- **Two failed fixes, third guess loading.** Stop. The framing is wrong; return to step 1 with the new evidence.
- **Deleting the repro after the fix.** The repro is the regression test. Keep it.

## Relationship to other skills

- `yo-verify-premise` — runs first; hands off here when the verdict is *confirmed* but unexplained.
- `yo-fix-loop` — receives the explained bug as a normal fix item; Phase 3's "name the root cause" is this skill's output.
- `yo-test-coverage` — the minimal repro becomes the paired regression test.
- `yo-engineering` — concurrency/silent-failure lenses for races and swallowed errors; S3 gate still applies to destructive diagnostic actions (no "let's just wipe the cache in prod" while debugging).
- `yo-incident` — if the bug is burning production right now, mitigate THERE first; this skill runs after recovery, cold.

## Sources

See `references/sources.md`.
