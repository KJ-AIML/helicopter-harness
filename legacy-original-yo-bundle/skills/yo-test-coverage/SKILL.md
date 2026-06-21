---
name: yo-test-coverage
description: >-
  Pair a failing test that exercises the bug WITH the fix in one commit, so the same regression cannot silently return. Use this for every bug-fix that should have a test next to it — even when the user only says "and add a test" or "regression test for this". Also covers "add tests for X", "lock this in", "pin this behavior", "characterize this before refactor", "no test for X", "needs coverage", "what's the coverage on Y". Implements Google's CL norm that tests ship in the same changelist as the fix. Three modes: regression (test would have caught the bug), characterization (pin current behavior before a refactor), coverage backfill (write the test that catches the most likely real failure mode, not the one easiest to write). Triggers on "regression test", "lock this in", "test this", "no test for", "pin the behavior".
---

# yo-test-coverage — Tests That Lock Behavior In

This skill writes tests with a specific job: prevent the same regression from coming back. Coverage-for-coverage's-sake is not the goal; tests that would have caught the bug (or that pin a load-bearing behavior before a risky change) are.

## Why pair tests with fixes

Google's reviewer norm explicitly requires tests to be added in the same CL as the production code unless the change is an emergency. The reason is mechanical: a fix without a test relies on every future change going through the same human-attention bottleneck the original fix did. A test is the durable artifact. The fix is the immediate one.

On TDD specifically: the popular "test-first or you're unprofessional" framing isn't supported by the empirical record (Hillel Wayne's review of the studies, the Fowler/Beck/DHH series). The honest position is that *test-first is taste*, but *comprehensive automated testing* — including a test paired with every bug fix — is non-negotiable. This skill picks the latter, lower-controversy practice and doesn't pretend the former is settled.

See `references/sources.md` for citations.

## When to invoke

- A bug-fix task in `yo-fix-loop` — write the regression test as part of the same commit
- "Add tests for X" — standalone coverage backfill
- "Characterize current behavior of Y before I refactor" — golden-master / characterization tests
- "This was flaky, then we fixed it — lock it in" — capture the bug as a deterministic test, not just a comment
- "No coverage on this class" — backfill with the highest-value tests first (the ones that catch the failure modes most likely to ship)

Do not invoke when the user wants a smoke test for a feature that's well-covered already. Adding overlapping tests dilutes signal.

## The approach, in order

### 1. Identify what the test is for

Before writing, name the proposition. One of:

- **Regression** — a specific bug must not recur. The test asserts the failure mode is closed.
- **Characterization** — current behavior, whatever it is, is the contract. The test pins it so refactors can't change it silently.
- **Coverage backfill** — a method or branch has no test. Write the test that would catch the most likely real failure, not the one that's easiest to write.

The name of the test should make the proposition obvious from the test list output — `LoadAsync_PopulatesMessages_AndRaisesMessagesLoadedOnce`, not `TestLoadAsync`.

Choose the smallest deterministic test that proves the proposition. Prefer small/local tests for pure logic, medium integration tests for boundaries, and large end-to-end tests only when the real behavior cannot be proven lower in the stack.

### 2. Read the existing test patterns

Before writing, find an adjacent test and match its idiom. Headless harness setup, mock/fake choices, fixture organization, naming conventions — match the project, don't impose a style. If the project uses real DI fakes (e.g., `InMemoryDbFactory`) instead of Moq, use the fake. If it uses `[AvaloniaFact]` for UI thread tests, use it.

Senior engineers fit into the existing codebase's style. New idioms have a cost the test author doesn't pay; the next person to read the suite does.

### 3. Write the test the bug would have failed

For a regression test specifically: the test should fail on the parent commit (before the fix) and pass on the fix commit. Verify this. A test that passes on both sides of the diff doesn't lock in anything — it's just a comment.

Quick verification in a worktree:

```
git worktree add /tmp/verify <parent SHA>
cd /tmp/verify
<run the new test>     # expect FAIL
git worktree remove /tmp/verify
```

If you can't be bothered to verify, at least *reason out loud* in the commit message about why the test exercises the bug — so a future reader can sanity-check.

### 4. Make the test honest

- **One proposition per test.** A test that asserts five things fails opaquely and reads as "something is broken" instead of "the third assertion broke."
- **No flakiness budgets.** Tests that pass 95% of the time are worse than no test — they train the team to ignore failures. If a test is timing-dependent, either make it deterministic (drain the dispatcher, use a fake clock) or skip it with a specific reason.
- **Classify flake root cause.** If a test flakes, record whether it is product race, test race, external dependency, data leakage, clock/time, or infrastructure. Do not hide a product race behind retries.
- **No mocks for code you don't own and don't understand.** Mocking a third-party API by guessing its behavior creates a test that asserts your guess, not reality.
- **Skip honestly, never silently.** If a path genuinely can't be tested under the harness (real OAuth callback, OS-level drag events, Modal needs OverlayLayer), `[Fact(Skip = "<specific one-line reason>")]`. The reason is part of the contract — "TODO" or "broken" is not enough.

### 5. Pin the regression at commit time

If the test pairs with a fix, both go in the same commit. The commit message names what the test pins. Example:

```
Fix StreamCompleted session-mixing race

A late StreamCompleted event from a previous session could credit cost
to the new session if the user switched sessions mid-stream. Tag the
event with the originating session ID and drop it if it doesn't match.

Test: StreamingStateViewModel_DroppedWhenSessionChanges pins the
event-drop path. Verified fails on the parent commit.
```

### 6. Report

Brief. Format:

```
Commit: <SHA>
Tests added: <N> — <one-line description each>
Failed before fix: <yes / no — verified how>
Skipped with reason: <list, or "none">
```

## Failure modes to avoid

- **Coverage theater.** A test that imports the module and asserts nothing. Catches nothing, costs review time.
- **Asserting on implementation, not behavior.** `Assert.Calls(mock.Bar, Times.Exactly(3))` breaks the next refactor and tells you nothing about correctness.
- **Tests that pass on both sides of the bug.** If the test would have passed before the fix, it doesn't pin the regression.
- **Mocking the system under test.** If you mock the thing you're testing, you're testing the mock.
- **Adding tests without reading the existing suite first.** The same scenario tested four different ways across the codebase is a maintenance cost.

## Skills to invoke alongside

- **`yo-fix-loop`** — this skill is most often invoked from inside the loop, as part of a bug-fix task
- **`yo-audit`** — the auditor's job includes verifying the new test actually fails without the fix
- The implementation side of the fix-plus-test commit is your normal editing — write the failing test here first, then implement the fix so it passes
- **`code-simplifier`** — after the test and fix pass, refine only the touched code if the diff is noisy, duplicated, or more complex than needed.

## Sources

See `references/sources.md`.
