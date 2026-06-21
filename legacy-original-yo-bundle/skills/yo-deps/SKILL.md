---
name: yo-deps
description: >-
  Dependency hygiene: vet before adding, read changelogs before upgrading, one dependency change per commit. Use for "add library X", "install package Y", "upgrade Z", "update dependencies", Dependabot/Renovate PR waves, security advisories ("CVE in our deps"), and "should we use library X or write it ourselves". Treats every dependency as a long-term liability taken on deliberately: maintenance health, license, transitive weight, and an upgrade path checked BEFORE the install command runs.
metadata:
  short-description: Vet new deps, read changelogs before upgrades, one dep per commit
---

# yo-deps — Dependencies Are Liabilities You Choose

A dependency is code you now ship but don't control: its bugs are your bugs, its CVEs are your pages, its maintainer's burnout is your migration. Adding one is cheap at install time and expensive forever after — so the vetting happens *before* the install command, not after the first incident.

## When to invoke

- "Add / install library X" — including when *you* are about to reach for one mid-implementation
- "Upgrade X" / "update the dependencies" / a Dependabot or Renovate wave
- A security advisory touching the dependency tree
- "Should we use a library for this or write it?"
- "Why is the build/bundle suddenly huge?"

Do NOT invoke for restoring/locking already-declared dependencies (`npm ci`, `dotnet restore`) — that's plumbing, not a decision.

## Adding a dependency

### 1. First: do you need it at all?

If the needed slice is small and writable in ~50 lines with a test, write it (the left-pad rule). You're often using 5% of a library's surface; weigh that 5% against 100% of its maintenance, security, and upgrade surface. Also check what's already in the tree — the project may already depend on something (or a transitive dep) that covers this. Two libraries for the same job is a smell `code-simplifier` will flag later; don't create it now.

### 2. Vet it — five checks, ten minutes

- **Maintenance health.** Last release date, open-issue responsiveness, bus factor (one maintainer = one burnout from abandonment). OpenSSF Scorecard if available.
- **License.** Compatible with the project's distribution? (MIT/Apache/BSD usually fine; copyleft needs a deliberate call — surface to the user, it's their legal exposure.)
- **Transitive footprint.** What does it drag in? A utility with 80 transitive deps is 80 new suppliers. Check before install (`npm info`, deps.dev), not after.
- **Security history.** Known CVEs and, more telling, how fast they were patched.
- **API quality.** Skim the docs and an issue or two — does the design fit the project's idioms, or will every call site need an adapter?

One paragraph of verdict to the user before installing; choosing a supplier is a real decision. If the dependency is architectural (framework, ORM, runtime), it's one-way-door-shaped — record it as an ADR (`yo-design`).

### 3. Install with the lockfile committed

The lockfile (`package-lock.json`, `packages.lock.json`, `Cargo.lock`, …) IS the build reproducibility — commit it, and read its diff like code: new transitive packages are part of what you're approving. Pin per ecosystem norms. **The add is its own commit** — never buried inside a feature commit, so bisect can separate "the feature broke it" from "the new dep broke it."

## Upgrading dependencies

### The rules

1. **Read before you bump.** The changelog / release notes / migration guide for the span you're crossing — *before* upgrading, not after the build breaks. For majors, the breaking-changes list is the work estimate.
2. **One dependency per commit (or PR).** Upgrading twelve packages in one commit means `git bisect` answers "the upgrade commit" and nothing more. One bump per commit keeps the introducing change findable — the same unit-mapping rule as everywhere else in the pack.
3. **A green build does not prove a major upgrade.** It proves you didn't break compilation. Run the full suite, then exercise the flows that actually use the library. Behavior changes (defaults, ordering, timeouts) ship in majors without breaking types — `yo-audit`'s "test that passes on both sides proves nothing" applies squarely.
4. **Majors are S1/S2 work, not chores.** Plan, slice if the API churn is wide (`yo-engineering` prep-slice pattern: adapter first, swap second), verify with evidence.
5. **Don't hold majors forever.** Skipping five majors and big-bang upgrading is the dependency version of the long-lived branch — the same compounding-conflict failure mode. Take majors while the span is one release wide.

### Dependabot / Renovate waves

A wave of bot PRs is a findings list → run it through `yo-fix-loop`: triage (security patches P1, patch/minor P3, majors get their own scheduled slot), one bump merged per PR with CI green, never "approve all" — the bot read nothing; that's your job.

### Security advisories

A CVE in the tree jumps the queue (P1): confirm exposure first — is the vulnerable code path reachable from this project? (`yo-verify-premise` posture; advisory severity ≠ your severity). Patch via the smallest version move that clears it. If no patched version exists: pin + mitigate + file the follow-up, and say so honestly in the wrap-up.

## Anti-patterns

- **Install-first-think-later.** The blog post said `npm install X`; now X is a supplier you never vetted.
- **Adding a dependency for one function.** Write the 30 lines.
- **Upgrading everything in one commit.** Unbisectable by construction.
- **Ignoring the lockfile diff.** That's where supply-chain surprises (event-stream) actually appear.
- **"CI is green, the major upgrade is safe."** Green proves compilation, not behavior.
- **Holding all majors until forced.** Big-bang upgrades are long-lived branches in another costume.
- **Auto-merging bot PRs unread.** The bot automates the *bump*, not the judgment.
- **Treating advisory severity as your severity, in either direction.** Confirm reachability — then act at the confirmed level.

## Relationship to other skills

- `yo-fix-loop` — Dependabot waves and advisory lists run through its triage/fix/verify loop.
- `yo-verify-premise` — "are we actually exposed?" before emergency-patching a CVE.
- `yo-design` — framework/ORM-level choices become ADRs.
- `yo-engineering` — majors with wide churn get the prep-slice treatment; license calls and risky upgrades surface to the user.
- `yo-release` — dependency upgrades that ship get a changelog line; users debug against them.
- `yo-debug` — "it broke after we upgraded X" is a bisect with a one-bump-per-commit history (rule 2 is what makes that fast).

## Sources

See `references/sources.md`.
