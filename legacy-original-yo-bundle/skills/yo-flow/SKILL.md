---
name: yo-flow
description: >-
  Interactive entry-point router — when the user's intent is unclear or they want guided routing, walk them through a short "what are you trying to do?" branching menu and hand off to the right yo-* skill (yo-engineering, yo-fix-loop, yo-verify-premise, yo-audit, yo-branch, yo-gh-write, yo-feature). Triggers — explicit `/yo-flow`, ambiguous prompts like "help me decide", "what should I do next", "I'm not sure where to start", "let's plan", "what now", or broad quality prompts like "make this best engineer quality". Do NOT fire for clear, specific requests (e.g., "fix bug X in file Y" — go straight to yo-verify-premise).
metadata:
  short-description: Route an ambiguous request to the right yo-* skill
---

# yo-flow — Interactive Router

This skill replaces "type out your full intent" friction with a few one-line choices. Instead of the user writing a paragraph, ask two or three short multiple-choice questions and route to the right specialist.

It is **not** an orchestrator. It does no work itself. It is a concierge — a couple of picks and you're in the right place.

## Codex note — how to "ask"

Codex has no structured question widget. **Ask in plain text as a short numbered menu, then stop and wait for the user's pick.** Keep it to one screen. Always allow a free-form answer ("or tell me in your own words"). One question per turn — don't dump all three at once.

## Preempt: production down skips the menu

If the prompt says live users are impacted right now — "production is down", "users can't log in", error spike after a deploy — do not ask routing questions. Go straight to `yo-incident` (mitigate first). The menu is for ambiguity; an outage is not ambiguous.

## When to fire

**Fire** when the prompt is:
- Explicitly asking for routing — `/yo-flow`, "what should I do", "I'm not sure where to start", "help me pick", "let's plan this"
- Ambiguous about scope — "I want to work on X" without saying *what kind* of work
- A request to "just start" with no anchor

**Do NOT fire** when the work is already named clearly:
- "Fix bug X in file Y" → straight to `yo-verify-premise` → implement
- "Review PR #311" → straight to `yo-audit`
- "Write the PR body for this branch" → straight to `yo-gh-write`
- "Open a PR on this branch" → straight to `yo-branch` → `yo-gh-write`

If intent is clear, **skip this skill** and route directly. yo-flow is for when you'd otherwise have to ask a clarifying question anyway.

## Engineering pairing rule

`yo-engineering` is both a destination and a gate. Pair it with the target skill whenever the selected path is broad, high-risk, cross-cutting, or the user asks for senior / "best engineer" quality.

- Fix one thing -> `yo-verify-premise`, then `yo-engineering` if the confirmed fix has API, data, security, concurrency, production, UI, or maintainability risk.
- Fix a wave -> `yo-engineering` for P0/P1/cross-cutting risk classification, then `yo-fix-loop`.
- Build clear spec -> `yo-engineering` first for multi-file, high-risk, architectural, or "best engineer" work, then `yo-feature`.
- Verify -> `yo-engineering` risk lens for non-trivial diffs, then `yo-audit` for independent verification.
- Ready to PR -> `yo-engineering` if risk, rollback, compatibility, or proof needs to be explicit, then `yo-branch` -> `yo-gh-write`.

Do not force `yo-engineering` onto S0 work: typo fixes, obvious one-line local changes, and simple GH text can route directly.

## The flow

### Q1 — top-level intent (always ask first)

> What do you want to do right now?
> 1. **Fix something** — bug, finding, review comment, regression; code is broken or wrong
> 2. **Build something** — new feature, screen, or capability
> 3. **Verify something** — audit a fix, review a diff, confirm a change is safe
> 4. **Write GH text** — PR description, issue body, review comment, wrap-up
> 5. **Raise engineering quality** — architecture, risk, maintainability, security, operability, "best engineer" pass

Routing on Q1:
- Fix → ask Q2-Fix
- Build → ask Q2-Build
- Verify → `yo-engineering` for non-trivial risk lens when needed, then `yo-audit` (it scopes itself)
- Write GH text → ask Q2-Write
- Raise engineering quality → `yo-engineering` (classify risk, pick specialist lenses, route the work)

### Q2-Fix — scope of the fix

> How big is the fix work?
> 1. **One specific thing** — single bug / comment / regression
> 2. **A wave of findings** — N PR comments, an audit list, multiple things to clear
> 3. **Not sure it's real** — want to confirm the bug exists before coding
> 4. **Real but unexplained** — it reproduces, but nobody knows why

Routing:
- One thing → `yo-verify-premise` (confirm), then `yo-engineering` if broad/high-risk, then `yo-impact` (blast radius before the edit), then implement. **Size check before implementing:** if the confirmed work turns out to be multi-file / multi-session — a "big issue" — do NOT implement it as one lump. Route to `yo-feature` with the issue as the spec: decompose into slices, one commit per slice, one PR that closes the issue.
- A wave → `yo-engineering` for risk/priority when broad/high-risk, then `yo-fix-loop` (it owns triage, dispatch, audit, wrap-up)
- Not sure → `yo-verify-premise` only — stop after the read, hand the verdict to the user before any coding
- Real but unexplained → `yo-debug` (repro → hypothesis → bisect/instrument → explain), then fix via the normal path

### Q2-Build — kind of build

> Where are you at on the build?
> 1. **Have a clear spec** — know what to build, ready to implement
> 2. **Still brainstorming** — want to talk through approaches first
> 3. **Need a branch first** — cut the right branch, then start
> 4. **Ready to open a PR** — code is done, want to ship

Routing:
- Clear spec → `yo-engineering` first for multi-file / high-risk / "best engineer" work; if it lands S2+ or architectural, `yo-design` (design doc reviewed before code) before `yo-feature`. **Exception:** a one-sentence low-risk diff — skip the loop, just implement it.
- Brainstorming → `superpowers:brainstorming` when available; otherwise free-form design chat with explicit approval before implementation
- Need a branch → `yo-branch` (cut + set base), then `yo-engineering` if high-risk, then `yo-feature`
- Ready to PR → `yo-engineering` if risk/rollback/proof must be explicit, then `yo-branch` (pre-PR readiness) → `yo-gh-write` (PR body)

### Q2-Write — kind of GH text

> What are you writing?
> 1. **PR description** — body for a new/rewritten PR
> 2. **Issue body** — bug report or chore
> 3. **Review comment** — blocker, suggestion, nitpick, question
> 4. **Wave wrap-up** — summary after closing out a batch of fixes

All four → `yo-gh-write`, pre-filling which template (PR body / issue / comment / wrap-up). yo-gh-write detects the repo profile itself.

## Optional Q3

Only when the target is genuinely ambiguous *between two skills*. Default: skip — most paths are unambiguous after Q2.

## Anti-patterns

- **Dumping all questions at once.** One at a time; wait for the pick.
- **Asking more than 3 questions.** Two is target, three is ceiling. If you'd need four, the request was clear enough to route directly.
- **Doing work inside this skill.** No reading code, no editing. yo-flow's job ends at the handoff.
- **Firing on clear requests.** "Fix bug X in file Y" is not ambiguous — route directly.
- **Treating options as exhaustive.** Always invite a free-form answer; cover the common 80% and let the rest fall through.

## What this skill is not

- Not an orchestrator (that's `yo-fix-loop`)
- Not a planner
- Not a wrapper around every specialist — direct invocation of any yo-* skill still works without going through yo-flow

## Skills this routes to

`yo-engineering` · `yo-verify-premise` · `yo-debug` · `yo-design` · `yo-feature` · `yo-fix-loop` · `yo-audit` · `yo-branch` · `yo-gh-write` · `yo-incident` (preempt) · `superpowers:brainstorming` when available

Direct-invoke skills that don't need routing: `yo-release` (cut a release), `yo-deps` (add/upgrade dependencies) — their triggers are unambiguous. `yo-impact` is an embedded discipline, not a destination — it runs inside every fix/build path right before the first edit to existing code.

## Sources

See `references/sources.md` for the structured-choice rationale: offer concrete options instead of an open prompt.
