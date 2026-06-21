---
name: yo-incident
description: >-
  Production-down discipline: mitigate FIRST, diagnose later. Use the moment live impact exists — "production is down", "users can't log in", "the site is broken", "sev1", "everything is erroring", a paging alert, a spike in errors after a deploy. Overrides the pack's normal read-everything-first posture: during an incident the question is "what changed?" not "what's the bug?", rollback beats fix-forward, the timeline is recorded as you go, and the blameless postmortem (with action items routed to yo-fix-loop) happens after recovery, not during the fire.
metadata:
  short-description: Mitigate first, timeline as you go, blameless postmortem after
---

# yo-incident — Mitigate First, Understand Later

Every other skill in this pack says *read first, understand fully, then act*. This skill is the explicit exception, and knowing when to flip postures is the senior skill: **while users are down, restoring service beats understanding why it broke.** Root cause is tomorrow's job; recovery is now's.

## When to invoke

- Live user impact, right now: outage, error spike, data not loading, login broken
- A paging alert or monitoring signal showing production degradation
- "Everything broke after the deploy"
- The user says any variant of "production is down" — this skill preempts `yo-flow`'s menu entirely

Do NOT invoke for a bug that *could* affect production but isn't actively burning (that's `yo-verify-premise` → `yo-debug`), or for a failing CI pipeline (that's `yo-branch`'s CI section).

## The response, in order

### 1. Classify and start the clock

One line: what's broken, for whom, since when. Severity honestly — "all users can't log in" and "one report of a slow page" get different responses. Note the wall-clock time; every action from here on gets a timestamp.

### 2. Mitigate — in this order of preference

The diagnostic question during the fire is **"what changed?"**, not "what's the bug?" — most incidents are caused by a change: a deploy, a config push, a flag flip, a dependency, a traffic shift. Find the most recent change that correlates with impact onset and undo it:

1. **Rollback the deploy** — fastest, best understood, already tested (it was production an hour ago).
2. **Flag off the feature** — if the change shipped dark behind a flag (`yo-engineering`'s long-running strategy pays off exactly here).
3. **Config revert / traffic shift** — undo the non-code change.
4. **Fix-forward** — LAST resort, only when no revert path exists. A fix written under pressure, reviewed by no one, deployed to an already-degraded system is how one incident becomes two.

**The S3 gate survives the fire.** Destructive "fixes" — dropping data, force-pushing, truncating a queue — still need explicit user sign-off, *especially* under pressure. Mitigation should be reversible; that's what makes it safe to do fast.

### 3. Timeline as you go

Append-only scratch file (`incident-<date>.md`): timestamp → what you observed / what you did / what happened. Two lines each. Memory of an incident rots within hours, and the postmortem is only as good as this record. Symptoms in user-visible terms, actions with exact commands.

### 4. Verify recovery on the user-visible signal

Recovery means the *user-visible* symptom is gone — the login works, the page loads — not that an internal metric looks better. Check the actual flow. Then keep watching for a regression window; incidents re-fire.

If the work is tracked (issue/PR), post the recovery note there via `yo-gh-write`: impact window, mitigation, current status. Silent recovery erodes trust exactly when trust is cheapest to keep.

### 5. Root-cause — after recovery, cold

Now the pack's normal discipline resumes: hand the *why* to `yo-debug` with the timeline as evidence. The mitigation (rollback) is not the fix; the bug is still in the code, waiting to ship again. Treat the re-land of the rolled-back change as S2 work minimum.

### 6. Blameless postmortem

For anything with real user impact, write it while the timeline is fresh:

```markdown
# Postmortem: <one-line title> (<date>)

Impact: who/what/how long. Numbers if you have them.
Timeline: from the incident file, cleaned up.
Root cause: the causal chain (from yo-debug), stated about SYSTEMS,
  never about people. "The deploy pipeline allowed an untested
  migration" — not "X pushed a bad migration."
What went well / what went poorly: honest, short.
Action items: each with an owner and a filed issue. No orphans.
```

Action items route into `yo-fix-loop` as a wave (the regression test that would have caught it → `yo-test-coverage`; the missing alert → observability lens; the missing flag → `yo-engineering`'s long-running strategy). A postmortem without shipped action items is a ritual, not a practice.

## Anti-patterns

- **Debugging during the fire.** Root-causing while users are down optimizes for your curiosity over their service. Mitigate, then understand.
- **Fix-forward under pressure.** The second incident is usually the hasty fix for the first.
- **"Human error" as root cause.** A system one mistake away from an outage has a system problem. Blameless isn't politeness — naming people teaches the team to hide the next incident's details.
- **Skipping the timeline because you're busy.** Two lines per action. The postmortem can't be reconstructed from memory.
- **Declaring recovery off an internal metric.** The user's flow is the signal.
- **Postmortem with no action items, or action items with no owners.** Either is a meeting, not an improvement.
- **Rolling back and never re-landing the root-cause fix.** The mitigation is not the fix; track the real fix as a P1.

## Relationship to other skills

- `yo-flow` — preempted entirely; production-down skips the menu.
- `yo-debug` — owns the post-recovery root-cause; the timeline is its evidence.
- `yo-fix-loop` — ships the postmortem action items as a wave.
- `yo-test-coverage` — the incident's repro becomes the regression test.
- `yo-engineering` — S3 gate on destructive mitigations; flags/observability lenses for the action items.
- `yo-gh-write` — recovery notes and the postmortem land on the issue/PR, in the user's voice.

## Sources

See `references/sources.md`.
