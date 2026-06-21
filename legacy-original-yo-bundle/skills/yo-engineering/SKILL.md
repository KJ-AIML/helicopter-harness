---
name: yo-engineering
description: >-
  Senior software engineering operating standard for Codex. Use when the user asks for "best engineer", "high-class engineering", "make it excellent", architecture/design judgment, broad implementation, or any software task with meaningful risk across API contracts, data, security, concurrency, observability, UX, or maintainability. Turns work into small reversible slices, chooses the right specialist reviewer skills, defines exact verification gates, and routes to yo-feature, yo-fix-loop, yo-verify-premise, yo-audit, yo-branch, yo-gh-write, plus the code-quality engineering pack.
---

# yo-engineering - Senior Software Engineering Standard

This is the quality bar skill. It is not another implementation loop. It is the decision layer that makes Codex behave like a strong senior software engineer: understand the real system, choose a small reversible path, apply the right risk lenses, verify with evidence, and leave a clean handoff.

## Core rule

Optimize for correct, maintainable, shippable software. Do not optimize for impressive-looking work.

Good work here has four properties:
- It solves the user-visible problem.
- It preserves the important invariants.
- It can be reviewed, tested, rolled back, and explained.
- It leaves the codebase easier to work in, or at least no worse.

## The senior gate

Before coding on non-trivial work, answer these six questions in your notes or plan:

1. **Behavior:** What user-visible behavior or developer workflow changes?
2. **Invariant:** What data, API, security, or domain invariant must not break?
3. **Failure:** What could fail silently, race, leak, corrupt data, or mislead users?
4. **Compatibility:** What needs migration, rollback, backwards compatibility, or staged rollout?
5. **Slice:** What is the smallest reversible slice that proves the direction?
6. **Evidence:** What exact command, test, trace, or browser flow proves the slice works?

If you cannot answer these, stop and read more. Questions 2–4 (invariant, failure, compatibility) are answered mechanically by the `yo-impact` pre-edit analysis — usage surface, siblings, persisted/transmitted shapes, blast-radius sentence — not by intuition. If the answer affects product scope or one-way-door risk, ask the user before editing.

## Risk tiers

Use the lightest process that covers the risk.

| Tier | Use when | Required gate |
|---|---|---|
| S0 Direct | Typo, tiny local cleanup, obvious one-line change | Edit, run smallest relevant check |
| S1 Normal | Local feature/fix with low blast radius | Plan, focused tests/build, self-review |
| S2 High risk | API/data/security/concurrency/production/user-flow impact | Senior gate, specialist reviewer, cold audit |
| S3 One-way door | Destructive data, force push, release, external send, auth/security policy | Pause for explicit user sign-off |

Small does not mean careless. Large does not mean heroic. Prefer small, finished slices.

## Specialist routing

Invoke the specialist lens when the touched surface matches:

- `api-contract-reviewer` - HTTP/RPC/GraphQL/SDK/CLI/webhook request or response shape changes.
- `migration-safety-reviewer` - schema, migration, backfill, data rewrite, index, retention, or destructive data work.
- `concurrency-reviewer` - async, streaming, queues, cancellation, locks, shared state, retries, ordering, backpressure.
- `type-design-analyzer` - domain models, interfaces, schemas, DTOs, invalid states, mutation/ownership boundaries.
- `silent-failure-hunter` - try/catch, fallback paths, retries, swallowed errors, vague user feedback, optional/null handling.
- `observability-reviewer` - background jobs, integrations, production debugging, logs, metrics, traces, health checks, alerts.
- `code-simplifier` - after behavior passes, when touched code is more complex, duplicated, clever, or inconsistent than needed.
- Frontend/UI skills - when the change affects user-facing UI, accessibility, motion, metadata, or visual behavior.

Do not invoke every reviewer by default. Pick only the lenses that match the actual risk.

These specialist reviewers are **optional companion skills, not part of this bundle.** If one is not installed, do not skip the risk — apply the named lens inline (trace the contract/migration/concurrency/etc. failure modes yourself) and say you did so. The lens is the requirement; the dedicated skill is just the convenience.

## Operating flow

1. **Orient.** Read project instructions (`AGENTS.md` / `CLAUDE.md`), current wiring, relevant tests, and memory if useful.
2. **Classify.** Choose S0/S1/S2/S3 and the matching specialist lenses.
3. **Route.**
   - New feature or capability -> `yo-feature`, with this skill's risk tier attached. S2+ or architectural -> `yo-design` first (design doc reviewed before code; one-way doors recorded as ADRs).
   - Multiple findings -> `yo-fix-loop`, with this skill's priority/risk classification.
   - Claimed bug or broken behavior -> `yo-verify-premise` before implementation; confirmed but cause unknown -> `yo-debug` before any fix.
   - Production actively down -> `yo-incident` (mitigate first; this skill's read-first posture resumes after recovery).
   - Completed non-trivial change -> `yo-audit` before claiming safe.
   - Branch/PR/shipping -> `yo-branch` then `yo-gh-write`; develop -> main release -> `yo-release`.
   - Adding or upgrading dependencies -> `yo-deps`.
4. **Slice.** Keep each change self-contained and buildable. If a slice cannot stay small, create a prep slice first: tests, interface extraction, branch-by-abstraction, or documentation of the existing behavior.
5. **Verify.** Run the exact gate that proves the behavior. For UI, use the app/browser flow. For tests, prefer the smallest deterministic test that catches the failure.
6. **Close the loop.** Summarize what changed, what evidence ran, and any leftover risk or follow-up.

## Long-running work: keep the branch short, not the feature small

A multi-week issue does not justify a multi-week branch. Long-lived branches age badly — conflicts compound, review arrives as a big bang, and integration risk is deferred to the worst moment. The senior move is to merge small slices to the integration branch continuously while keeping the incomplete feature invisible:

- **Feature flag.** Ship slices dark behind a flag; flip it when the feature is complete. A flag is debt with a lifecycle — file the removal issue the moment you create the flag.
- **Branch by abstraction.** Introduce a seam over the old implementation, build the new one behind it directly on the integration branch, switch over, delete the old path. No long-lived branch at any point.
- **Wire the entry point last.** Order slices so the user-visible wiring (menu item, route, button) is the final slice — everything before it merges safely because nothing reaches it yet.

Decision rule: if the branch would live more than ~a week, or slices must land before the feature is usable, pick one of these instead of letting the branch age. This is the answer to "the issue is too big" — not a bigger branch, and never a bigger commit.

## Quality bar

- Prefer existing project patterns over new abstractions.
- Preserve compatibility unless the user explicitly accepts a breaking change.
- Make invalid states impossible where the local type/model system allows it.
- Fail loudly and diagnosably on real errors; do not hide problems behind cheerful fallbacks.
- Add observability at production boundaries, not noise inside pure code.
- Keep tests meaningful: they should fail for the bug or contract they claim to protect.
- Never mix refactoring and behavior change in one commit. Refactor in its own commit, where existing tests prove behavior unchanged — reviewers and `git bisect` must be able to tell intent from accident.
- No performance work without a measurement. Profile or benchmark before optimizing, re-measure after, and report both numbers. An optimization without numbers is a refactor with extra risk.
- Keep docs close to the code and update them when they explain maintenance-critical behavior.

## Anti-patterns

- **Ceremony without risk.** A one-line local fix does not need an architecture review.
- **Hero diff.** Large changes are not senior; decomposed, reversible changes are senior.
- **Review theater.** A reviewer lens that does not match the surface wastes context.
- **Green without evidence.** No completion claim without a fresh verification command or equivalent trace.
- **Silent scope expansion.** If the real fix is bigger than the prompt, surface that before absorbing it into the diff.
- **Optimizing only for speed.** DORA-style speed matters only with stability; throughput plus low failure/rework is the target.

## Sources

See `references/research.md` for the research basis behind these gates.
