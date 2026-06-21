---
name: yo-impact
description: >-
  Pre-edit impact analysis — BEFORE changing existing code, map who uses it, what will observe the change, why the code is the way it is, and where else the same pattern lives. Use right before implementing any fix or change to existing behavior: after yo-verify-premise confirms the bug, after yo-debug explains it, inside yo-fix-loop Phase 3, and in yo-feature's plan step when a slice touches existing code. Triggers: "before I change this", "what will this affect", "is it safe to change X", "where is this used", "what depends on this". The output is one blast-radius sentence — if you can't write it, you haven't finished the analysis.
metadata:
  short-description: Map usage, siblings, contracts, and blast radius before editing
---

# yo-impact — Know the Blast Radius Before You Edit

`yo-verify-premise` proves the bug is real. `yo-debug` explains why. This skill answers the third pre-edit question — the one juniors skip: **if I change this, what else changes?** A fix that's correct at the reported call site and wrong at the other four is a regression with good intentions.

This is not ceremony. For most edits the whole analysis is five minutes of grep and one paragraph. It runs *before* the edit because that's when it's cheap — `yo-audit` checking "hidden coupling" after the commit is the safety net, not the plan.

## When to run it

- Right before implementing any change to **existing** behavior — a fix, a refactor, a signature change, a behavior tweak
- Inside `yo-fix-loop` Phase 3, after reading the cited files and before editing
- In `yo-feature`'s plan step, for any slice that modifies (not just adds) code
- Standalone: "where is X used", "is it safe to change Y"

Skip it for purely additive changes (a new file, a new test, a new endpoint nothing references yet) — there's no existing usage surface to map. S0 typo-tier edits also skip it.

## The analysis, in order

### 1. Why is the code the way it is? (Chesterton's Fence)

Before changing a line that looks wrong, check whether it's load-bearing:

```bash
git log --oneline -5 -- <file>        # recent history of the file
git log -L <start>,<end>:<file>       # history of the exact lines
git blame <file> -L <start>,<end>     # who, when — then read the commit message / linked PR
```

If the "bug" was introduced deliberately (a commit titled "Handle provider timeout by returning empty list"), you're not fixing a bug — you're reversing a decision. That's an `ask-user`, not an edit. This single check is the difference between a fix and a regression of someone else's fix; `yo-audit` hunts exactly this ("reverted improvement") after the fact — catch it before instead.

### 2. Map the full usage surface

Find every place that observes what you're about to change — and remember the compiler only sees half of them:

- **Direct references:** callers of the function, readers of the field, implementors/overrides of the interface or virtual. LSP find-references or grep the symbol.
- **String-form references** — the ones that bite: XAML/template bindings, DI registrations by name, config keys, route/endpoint names, reflection, SQL strings, JSON property names, localization keys, CLI flags, test fixtures. Grep the *name as a string*, not just the symbol.
- **External consumers:** is this surface public — a published API, an exported type, a webhook payload another team parses? Then Hyrum's Law applies: every observable behavior is depended on by somebody, and "internal cleanup" may be a breaking change (`yo-engineering` compatibility question; majors via `yo-release`).

### 3. Classify what each usage will observe

For each usage site, one question: **does my change alter what this caller sees?** Not just types — behavior: return values for edge inputs, error shape (exception type vs null vs empty), ordering, timing/async completion, nullability, side-effect counts. A signature-compatible change that flips an edge-case return from `null` to `[]` changes every caller that checked for `null`.

### 4. Find the siblings — fix the disease, not the instance

If the bug lives here, where else does the same pattern live?

- Copy-pasted blocks (grep a distinctive line from the buggy code)
- Parallel implementations — the platform variants, the sync and async versions, the v1 and v2 handlers
- Other code paths reaching the same flawed root cause (this is `yo-debug`'s causal chain put to work)

Fix all of them, or state explicitly which ones you're leaving and why — an unstated sibling is next month's "we fixed this already" bug report. Siblings beyond this change's scope become filed follow-ups, not silence.

### 5. Check the persisted and transmitted shapes

Is the thing you're changing **stored** (DB rows, serialized files, caches, user settings) or **in flight** (API responses, queue messages)? Then old-shape data WILL hit your new code after the change ships. That's a migration/compatibility question to answer *now* — `yo-engineering` migration lens, not a production surprise.

### 6. Baseline the tests

Find the tests covering this surface and **run them before editing**. A test that was already failing before your change is not your regression — without the baseline you can't tell, and you'll either fix someone else's break for free under time pressure or get blamed by your own verify pass.

### 7. Write the blast-radius sentence

One sentence, into the plan item / SPEC slice / commit message body:

> "This changes <what> observed by <N call sites in which flows>; <siblings fixed / left with reason>; nothing else observes it because <why>."

This sentence is the gate. If you can't write it, the analysis isn't done — and it's exactly the *intent* that `yo-audit` needs later to tell a deliberate decision from an accident. Now pick the seam: make the change at the root cause, at the narrowest point that covers all affected callers — not at the symptom site where the bug happened to be reported.

## Anti-patterns

- **Editing the first grep match.** The reported site is where the bug was *seen*, not necessarily where it *lives* — and rarely the only place.
- **Trusting the compiler to find all usages.** It cannot see XAML, config, reflection, SQL, JSON names, or other repos' code. String-grep the name.
- **Fixing one of four siblings.** The other three are now harder to find — the bug report that led you here is closed.
- **Skipping the blame check.** Reversing a deliberate decision dressed up as a bug fix; the original author's fix comes back as *your* regression.
- **"It's internal" without checking.** Serialized shapes, public exports, and Hyrum's Law make a lot of "internal" code external.
- **Running tests only after the edit.** No baseline, no attribution.
- **Analysis without the sentence.** If the blast radius lives only in your head, the next session — and the auditor — start from zero.
- **Letting analysis become paralysis.** Five minutes and a paragraph for a normal fix. If the map keeps growing, that's a signal the change is S2 and needs `yo-design`, not more grep.

## Relationship to other skills

- `yo-verify-premise` — runs before this: is the claim real? Then this: what does fixing it touch?
- `yo-debug` — its causal chain feeds step 4: every path through the root cause is a sibling.
- `yo-fix-loop` — Phase 3 runs this checklist between reading the cited files and editing.
- `yo-feature` — the plan step runs this for slices that modify existing code; the sentence goes in the slice notes.
- `yo-engineering` — the senior gate's invariant/failure/compatibility questions are answered *by* this procedure; if the blast radius keeps growing, escalate the tier and consider `yo-design`.
- `yo-audit` — reads the blast-radius sentence as intent; its "hidden coupling" and "reverted improvement" checks are this skill's steps 1–2 done too late.

## Sources

See `references/sources.md`.
