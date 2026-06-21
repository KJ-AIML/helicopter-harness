---
name: yo-design
description: >-
  Write the design BEFORE the code for S2+ work, and record irreversible decisions as ADRs. Use when starting multi-file/architectural work ("design this", "how should we structure X", "should we use A or B"), when yo-engineering classifies work S2 or higher, when a decision is a one-way door (storage format, API shape, framework choice, protocol), or when the user asks "write a design doc" / "write an ADR" / "why did we choose X". Produces two durable artifacts in the target repo: a one-page design doc reviewed before implementation, and numbered ADRs that outlive the conversation.
metadata:
  short-description: Design doc before code; ADRs for irreversible decisions
---

# yo-design — Design Doc & ADR

The cheapest review surface in software is a one-page design, not a 1000-line diff. By PR time the approach is sunk cost — reviewers polish the chosen path instead of questioning it. This skill moves the approach-level review to where it can still change the approach.

It also fixes the pack's artifact gap: `SPEC.md` says *what*, `features.json` says *status*, but nothing durable says *why this approach over the alternatives*. That "why" is the first thing the next engineer — or the next session, or `yo-audit` — needs.

## When to invoke

- `yo-engineering` classified the work S2+ (API/data/security/concurrency/production impact)
- Multi-file or architectural feature work, before `yo-feature` starts slicing
- Any one-way-door technical decision: storage format, public API shape, framework/library choice, protocol, multi-tenancy model
- "Should we do A or B" questions where the answer will be expensive to reverse
- "Why did we choose X" — read (or write, retroactively-but-honestly-labeled) the ADR

Do NOT invoke for S0/S1 work. A design doc for a two-file fix is ceremony — the senior gate's six questions answered inline in the plan are enough. The doc earns its cost when the *approach* is genuinely contestable or expensive to reverse.

## Artifact 1 — the one-page design doc

Lives in the target repo (`docs/design/<topic>.md` or the repo's existing convention). One page is the target; three is the ceiling. Skeleton — note it is the `yo-engineering` senior gate made durable:

```markdown
# <Title>

## Context
What problem, for whom, and why now. Link the issue.

## Goals / Non-goals
Bullets. Non-goals are load-bearing — they are the scope fence.

## Proposed design
The approach in prose + the key interfaces/data shapes. Enough that a
reviewer can object; not so much that it's the implementation in markdown.

## Alternatives considered
Each REAL alternative, with the honest reason it lost. One strawman
("do nothing, obviously bad") marks the whole section as theater.

## Risks, compatibility, rollback
What could fail (silently, at scale, under concurrency), what needs
migration/staged rollout, and how this gets undone if wrong.

## Verification plan
The exact evidence that will prove it works — the end-to-end check
yo-feature's SPEC.md will end with.
```

**Review the design before code.** Show it to the user (or post it on the issue via `yo-gh-write`) and get an explicit OK on the approach. Objections at this stage cost a rewrite of a page; the same objection at PR stage costs a rewrite of the work.

Then hand off: the approved doc seeds `yo-feature`'s `SPEC.md`, and slicing proceeds as normal.

## Artifact 2 — ADRs for irreversible decisions

An Architecture Decision Record captures ONE decision, at the moment it's made, in the repo next to the code (`docs/adr/NNNN-<slug>.md`, numbered, append-only). Nygard's format:

```markdown
# NNNN. <Decision in one line, e.g. "Use SQLite for local persistence">

Status: Accepted          # Proposed | Accepted | Superseded by NNNN
Date: <YYYY-MM-DD>

## Context
The forces in play — constraints, requirements, the tradeoff being made.

## Decision
What we chose. Active voice: "We will..."

## Consequences
What gets easier, what gets harder, what we are now committed to.
Include the losing options in one line each — the next reader's first
question is "did they consider X?"
```

Rules that keep ADRs trustworthy:

- **One decision per ADR.** A record covering three decisions can't be superseded cleanly.
- **Immutable once accepted.** Reversing course = a NEW ADR that supersedes the old one. The history of changed minds is the value; editing it away destroys it.
- **Write it when the decision happens**, not in a documentation sprint later. An S3 sign-off from the user on a one-way door is exactly an ADR trigger — the sign-off rationale IS the Context section.
- **Decisions, not designs.** "We will use optimistic locking" is an ADR; the whole sync engine is a design doc.

## Anti-patterns

- **Doc after code.** A design doc written to justify an existing diff is a PR description with extra steps. (A retroactive ADR for an old undocumented decision is fine — label it as recorded after the fact.)
- **Strawman alternatives.** If every alternative is obviously terrible, the section is theater and reviewers learn to skip it.
- **The 10-page design doc.** Length is where designs go to avoid review. One page that gets read beats ten that get skimmed.
- **Editing an accepted ADR.** Supersede, never rewrite. ADRs are a ledger, not a wiki.
- **Design review as a rubber stamp.** The point is to invite "wrong approach" objections while they're cheap. If nobody could possibly object, the work was S1 and didn't need the doc.
- **Skipping the doc because the session "already knows".** The session forgets; the repo doesn't. The doc is for the next context window as much as for the team.

## Relationship to other skills

- `yo-engineering` — its senior gate's six questions ARE the design-doc skeleton; this skill makes the answers durable and reviewable. S3 sign-offs become ADRs.
- `yo-feature` — the approved design doc seeds `SPEC.md`; design decides the approach, SPEC scopes the slices.
- `yo-gh-write` — posts the design for review on the issue, in the user's voice.
- `yo-audit` — auditors read the design doc / ADR as the *intent* handoff; it's what separates a deliberate decision from a mistake.
- `yo-debug` / `yo-incident` — postmortems and root-cause findings that change architecture should land as ADRs, not just fix commits.

## Sources

See `references/sources.md`.
