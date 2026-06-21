---
name: yo-branch
description: >-
  The user's branch-and-merge conventions — what branches mean, which ones merge, which don't, what to base off of, and the pre-PR readiness checklist. Use when starting new work ("create a branch for X"), opening a PR ("is this ready to PR"), navigating multi-branch state ("which branch should this go on"), or whenever Codex is about to create/push/merge a branch and might pick the wrong one. Encodes: experimental/* are reference-only, feat/*-yo is the user's tracked work convention, the LLM-tester branch exception, base off develop not main, and the pre-PR sanity checklist.
---

# yo-branch — Branch & Merge Conventions

This skill makes the user's branch conventions callable. They live in memory as facts; this skill turns them into a checklist Codex consults *before* creating a branch, pushing one, or opening a PR.

If you skip this skill and push to the wrong branch, the fix is reflog-recoverable but the wasted context is not.

## The conventions

### Branch types

| Prefix | Meaning | Merges to develop? |
|---|---|---|
| `feat/*-yo` | The user's tracked feature work. Suffix `-yo` matches their GitHub handle / personal convention. | **Yes** |
| `feat/*` (no `-yo`) | Another contributor's tracked work, or shared feature work. | Yes |
| `fix/*` | Bug fix targeted at develop. | Yes |
| `experimental/*` | **Reference-only.** Spike, exploration, capture of an idea. Never merges. Real work that grows out of an experiment migrates to a `feat/*-yo` branch. | **No** |
| `experiment/automated-test-docs` | **Specific exception.** All QA-automation work (LLM tester playbook, XAML tags, scenarios) consolidates here even though the prefix is `experiment`. Treat as long-running. | No (consolidates, doesn't merge upstream) |

### Unit mapping (issue → branch → commits)

- **1 issue = 1 branch = 1 PR** (`Closes #N`). The issue is the unit of *intent*; the PR is the unit of *review*.
- **1 PR = N small commits.** The commit is the unit of *change*: each one a coherent step that builds and passes tests. ~100 changed lines per commit is reasonable; ~1000 is too large to review well (Google CL guide).
- **An issue too big for one reviewable PR gets split** — sub-issues (or a tasklist on the parent), one PR each. Keep branches short-lived: days, not weeks. A long-lived branch is a merge-conflict generator; if the work genuinely can't land in a week, use `yo-engineering`'s long-running strategy (feature flag / branch by abstraction / wire-entry-point-last) instead of letting the branch age.
- **Never 1 issue = 1 big commit.** A mega-commit can't be reviewed properly, makes `git bisect` useless, and can only be reverted whole.

### Base branch

- Cut new feature branches from **`develop`**, not `main`.
- `main` is the release line; `develop` is the integration line.
- If `develop` doesn't exist on a fork or unfamiliar repo, fall back to the repo's default branch and surface that to the user.

### When NOT to create a branch

- The user is exploring on an existing branch and wants to commit there → commit on the current branch.
- Work that explicitly belongs to a long-running consolidated branch (e.g., the LLM-tester branch above) → push to that branch.

## The pre-PR readiness checklist

Run this before invoking `yo-gh-write` to open a PR:

1. **On the right branch?** `git branch --show-current` matches a `feat/*-yo` or `fix/*` pattern, not `experimental/*` or `main`.
2. **Up to date with develop?** `git fetch origin && git log HEAD..origin/develop --oneline` — should be empty, or a planned rebase.
3. **Commits are clean?** `git log <base>..HEAD --oneline` — no `wip`, no `fixup`, no `tmp`. Each commit message describes the change in imperative mood.
4. **No Co-Authored-By tags.** `git log <base>..HEAD --grep "Co-Authored-By" --oneline` should return nothing. Hard prohibition per user memory.
5. **No assistant/vendor mentions** in commit messages or files added in this branch: no "Claude", "Codex", "AI", or "Generated". Same hard prohibition.
6. **Builds clean?** Project-appropriate build runs without new errors.
7. **Tests pass?** Project-appropriate test command — 0 failures.
8. **Diff scope sane?** `git diff <base>..HEAD --stat` — only files this work should touch.
9. **Risk gate done?** For API/data/security/concurrency/production-impact changes, `yo-engineering` has named the risk tier, rollback path, and specialist lenses before PR text is written.

If any check fails, fix before opening the PR. The PR description should describe a clean diff, not "the diff plus some cleanup we'll do in review."

## CI and branch protection

The local checklist is the precondition; the PR's required checks are the gate. Conventions:

- **Watch the push.** After pushing a PR branch, watch CI to completion (`gh pr checks <N> --watch`). "Done" is not claimable while checks are pending.
- **Red CI on your PR is your top priority.** Fix it before starting anything new — a red PR blocks reviewers and rots fast.
- **Don't retry-until-green.** A flaky pass can hide a real race. Classify the flake first (product race / test race / infra — see `yo-test-coverage`), say which it was, and only then re-run.
- **Never bypass protection.** Admin-merging past required checks or force-pushing around protection is an S3 one-way door (`yo-engineering`) — explicit user sign-off required, no exceptions.
- **Broken base ≠ broken branch.** If checks fail because `develop` itself is red, say so and rebase once upstream is fixed — don't patch unrelated failures into your PR to force green.

## Common commands

```bash
# New feature branch off develop
git fetch origin
git checkout develop && git pull origin develop
git checkout -b feat/<short-name>-yo

# Bring branch up to date before PR (preserves linear history)
git fetch origin
git rebase origin/develop

# Inspect what's actually in the branch
git log origin/develop..HEAD --oneline
git diff origin/develop..HEAD --stat

# Co-Author tag scan
git log origin/develop..HEAD --grep "Co-Authored-By"
git log origin/develop..HEAD --grep "Claude" -i
git log origin/develop..HEAD --grep "Codex" -i
git log origin/develop..HEAD --grep "AI" -i
git log origin/develop..HEAD --grep "Generated" -i
```

## What this skill does NOT do

- Open the PR — that's `yo-gh-write`'s job.
- Decide commit content / split — that's the implementer's job during the work.
- Override an explicit user instruction like "push directly to develop just this once." Surface the risk; if the user reaffirms, proceed.

## Anti-patterns

- **Branching from `main` by habit.** Default is `develop`.
- **Opening a PR from an `experimental/*` branch.** That defeats the convention — migrate the work to `feat/*-yo` first.
- **Pushing without the checklist.** The user has been clear that Co-Author tags / assistant mentions are a hard prohibition; the checklist is the cheap way to never accidentally ship one.
- **Auto-rebasing without telling the user.** Rebase is a history rewrite — surface it before doing it on a published branch.
- **Squashing aggressively.** One task = one commit is the loop discipline; preserve that on the way into the PR.
- **One issue = one big commit.** Commit per slice *as the work lands* (yo-feature step 5), not in one drop at the end. If you arrive at PR time with a single mega-commit, that's a process failure to fix upstream, not something to paper over with a good PR description.

## Skills to invoke alongside

- **`yo-codex-settings`** — applies anyway; this skill plugs into the session baseline.
- **`yo-engineering`** — runs before PR text on broad/high-risk changes to make risk and rollback explicit.
- **`yo-fix-loop`** — when a wave needs to ship as a PR, this skill runs before the wrap-up to confirm branch readiness.
- **`yo-gh-write`** — after this skill confirms branch state, gh-write composes the PR body.
- Plain `git` / `gh` commands — this skill provides the policy for the mechanics; no separate commit-command skill is required in Codex.

## Sources

See `references/sources.md`.
