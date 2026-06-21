---
name: yo-verify-premise
description: >-
  Verify the claim BEFORE acting on it. Read the cited code, trace the behavior, confirm the bug reproduces or the request is well-formed. Use whenever the task is "fix X", "investigate Y", "this is broken", "the bug is in Z", "we have a problem with W", or any framing that starts from a claim someone wants you to act on. Fires on single-issue fixes and feature requests alike — separate from yo-fix-loop, which only triggers on multi-finding waves. Catches the most expensive failure mode in agentic coding: implementing the wrong thing because the premise was wrong.
---

# yo-verify-premise — Read Before Acting

The single most expensive failure mode in agentic coding is shipping the wrong fix because the bug report was wrong. Not the *fix* was wrong — the *target* was wrong. The bug doesn't exist. The cited file doesn't behave that way. The behavior is correct and the reporter misread it. The fix would make a working thing broken.

This skill is the cheap insurance against that. It runs before substantive work begins.

## When to invoke

- "Fix the bug in <file>:<line>" — read <file>:<line> first, confirm the behavior.
- "X is broken" — reproduce it, or confirm the symptom from logs.
- "We need to handle case Y" — confirm Y can actually occur in the current code paths.
- A PR review comment claiming code does something — read the code, confirm.
- Any task that starts from someone else's claim about how the system behaves.

Do NOT invoke for:
- Greenfield work where there's no prior claim to verify.
- Pure refactors where the spec is "preserve behavior" and the behavior is whatever the tests assert.
- Tasks where the user has explicitly said "I already verified, just fix it."

## The verification, in order

### 1. Locate the claim

Pin down exactly what's being asserted. "The app crashes" → which screen, which action, which OS, which build. "Function X returns wrong value" → for which inputs, vs. what expected. "The test is flaky" → which test, what flake rate, on what runner.

Write the claim in one sentence in your head before reading anything. If you can't, ask the user to sharpen it before going further.

### 2. Read the cited code

Open every file mentioned in the claim. Read it fully — not skimmed, not searched. If the claim names `Foo.cs:42`, read Foo.cs from at least 30 lines above to 30 below line 42, plus the file's class header.

If the claim cites an effect ("the user sees X"), trace from the symptom back to the cause:
- For UI: find the view, the viewmodel binding, the command, the service call.
- For data: find the query, the model, the storage layer.
- For network: find the request site, the serializer, the deserializer, the consumer.

### 3. Reproduce or confirm

For runnable code: actually trigger the path the claim describes. Run the test, hit the endpoint, click the button. If a repro requires setup the user has, ask once for the steps.

For unrunnable claims (architectural questions, "is this safe"): trace the logic by hand. State the conditions under which the claim would be true and check whether those conditions can occur.

### 4. Decide

One of four outcomes:

- **Confirmed as stated.** Proceed to implementation — unless the symptom is confirmed but the *cause* is still unexplained, in which case route through `yo-debug` first; never fix what you can't explain. Either way, run `yo-impact` before the edit: confirming the bug is real says nothing about who else uses the code you're about to change.
- **Confirmed but worse than reported.** The bug exists AND there's a deeper or wider problem the reporter didn't see. Surface to the user before fixing — the right scope might be different.
- **Confirmed differently.** A real bug exists, but not the one described. Surface the actual bug; let the user decide whether to fix the original framing's bug or the real one.
- **Not reproducible / premise broken.** The cited file doesn't behave as claimed, the bug doesn't reproduce, the case can't occur. Surface the disconfirming evidence and ask the user how to proceed. Do NOT silently switch to fixing something else.

### 5. Report back briefly

Before implementing, write one short paragraph summarizing what you verified:

```
Premise check: <claim restated>.
Intent (build/change tasks; skip for a pure bug claim): <what the user set out to accomplish in their terms — the goal plus any tradeoff or constraint they ruled in or out. NOT a description of the diff. This is what a later reviewer (yo-audit) needs to tell a deliberate decision from a mistake; capture it from the conversation.>
Read: <files actually read>.
Repro: <yes/no/architectural-trace>.
Verdict: <confirmed / confirmed-worse / confirmed-differently / not-reproducible>.
Notes: <anything material for the implementer>.
```

This is the artifact future-you needs if the fix turns out to be wrong — so you can tell whether the implementer was misled or the premise check missed something.

When the claim is tied to an existing issue and you reproduced it (or disproved it), that repro evidence is worth posting on the issue, not just printing to the CLI — the repro steps, the command, and the actual output bound to the commit you checked against. Hand it to `yo-gh-write` ("Verification evidence" template); it posts via `--body-file` after the draft-in-chat check. A "confirmed / not-reproducible" verdict with the raw repro is exactly what the issue thread needs. CLI-only is the fallback when there's no issue to post to.

## Anti-patterns

- **Skipping the read because the token cost feels high.** The cost of fixing the wrong thing is much higher. The user has stated this explicitly as a hard rule.
- **Searching by keyword instead of reading the file.** Grep is a starting point. The behavior lives in the surrounding code, not the keyword line.
- **"It looks plausible" as a pass.** Plausibility is not verification. The bug report only gets a pass when you've seen the behavior or traced the logic to its source.
- **Reading only the cited file when the bug is upstream.** Symptoms point at the wrong file constantly. If the cited file looks innocent, follow the data backwards.
- **Silently switching scope.** If the premise is wrong, surface it. Don't redefine the task in the implementer's head and proceed.

## Relationship to other skills

- Fires *before* you start implementing. Don't ramp up on the premise while coding; confirm it here first, then implement.
- If the premise is confirmed but broad/high-risk, route through `yo-engineering` before choosing the implementation path.
- Fires *before* `yo-fix-loop` Phase 1 if the loop is dealing with a single fundamental claim. (Multi-finding waves already have Phase 0 inside the loop.)
- Used by `yo-audit` implicitly — auditors disbelieve until shown, which is the same posture as this skill, but post-implementation.

## Sources

See `references/sources.md`.
