---
name: yo-release
description: >-
  Ship develop to main: version decision from the actual diff, user-facing changelog, annotated tag, release notes, post-deploy verification. Use for "cut a release", "ship to main", "bump the version", "tag this", "write release notes", "update the changelog", or any merge that turns integration work into a released artifact. Picks up where yo-branch stops (PR merged to develop) and ends when the released thing is verified working — not when the tag is pushed.
metadata:
  short-description: Version, changelog, tag, release notes, post-deploy verify
---

# yo-release — From Merged to Shipped

`yo-branch` ends at "PR merged to develop." This skill owns the rest: develop → main is where "works on my branch" has to become "shipped and verified." The discipline is the same shape as the rest of the pack — decisions from evidence (the diff, not vibes), and done means verified, not tagged.

## When to invoke

- "Cut a release" / "ship to main" / "release v X"
- Version bumps, changelog updates, tagging, GitHub releases
- After a wave or feature lands and the user wants it in users' hands
- "What's gone out since the last release?"

Do NOT invoke for merging a PR into develop — that's `yo-branch` → `yo-gh-write`. This skill starts when the integration branch becomes a release.

## The release, in order

### 1. Decide the version from the diff, not from vibes

Read what actually changed since the last tag:

```bash
git describe --tags --abbrev=0          # last release tag
git log <last-tag>..origin/develop --oneline
git diff <last-tag>..origin/develop --stat
```

Semver from the evidence: any breaking change to a public contract → **major**; new user-visible capability → **minor**; only fixes → **patch**. "Breaking" is judged against what users depend on (API shapes, config formats, file formats, CLI flags), not against internal code. If you're unsure whether something is breaking, that's an `yo-engineering` compatibility question — answer it before tagging, not in the issue tracker after.

### 2. Changelog for users, not from commit subjects

The audience is people who *use* the software; the commit log's audience is people who *maintain* it. Write what changed *for the user*, grouped Keep-a-Changelog style:

```markdown
## [X.Y.Z] - YYYY-MM-DD
### Breaking
### Added
### Changed
### Fixed
```

Walk the merged PRs since the last tag (`gh pr list --state merged --base develop --search "merged:><last-release-date>"`) — PR titles describe changes; commit subjects describe steps. One line per user-visible change; internal refactors don't appear unless they change behavior users can observe. Breaking changes additionally get a one-line migration note.

### 3. The release checklist

1. **Develop is green.** Full CI on the release candidate, not a stale run.
2. **Release commit** on develop: `CHANGELOG.md` + version files (csproj/package.json/etc.) bumped together, nothing else in the commit.
3. **Merge develop → main** per the repo's convention (merge commit vs fast-forward — read the history, match it).
4. **Annotated tag** on main: `git tag -a vX.Y.Z -m "vX.Y.Z"` and push the tag explicitly. Annotated, not lightweight — the tag is a release artifact with an author and a date.
5. **Release pipeline green.** If CI builds/publishes on tags, watch it to completion (`gh run watch`) — same rule as `yo-branch`: done isn't claimable while checks are pending.
6. **GitHub release** via `yo-gh-write`: `gh release create vX.Y.Z` with notes derived from the changelog section — not a duplicate written from scratch, and not auto-generated commit soup.

### 4. Know the rollback before you ship

One sentence, written down before the tag: how does this release get undone? (Revert to previous tag and redeploy; or "client app — users stay on the old version, pull the release.") If the release contains a migration, the rollback story is `yo-engineering` migration-lens territory and must exist *before* shipping, not after the incident.

### 5. Verify the released artifact

The tag is not the finish line. Verify the thing users get: install/run the published artifact (or the deployed environment) and smoke-check the headline flow of this release — the feature that motivated it, plus login-or-equivalent. Then watch the first regression window (error rates, first user reports). A release is done when it's *verified out there*, and if it fails out there, that's `yo-incident` — rollback path already in hand from step 4.

## Anti-patterns

- **Version from vibes.** "Feels like a minor" without reading the diff. Breaking changes shipped as patches are how users learn not to upgrade.
- **Changelog from commit subjects verbatim.** "fix race in RegenerateAsync" means nothing to a user; "Fixed: chat could credit cost to the wrong session when switching mid-stream" does.
- **Tagging an untested merge.** The release candidate is the *merged* state of main, not develop pre-merge. CI runs on what ships.
- **The Friday 6pm release.** Ship when someone will be watching the regression window. (For solo work: ship when *you* will be.)
- **Lightweight tags.** `git tag vX.Y.Z` without `-a` loses author/date/message — annotate.
- **Declaring done at tag-push.** Steps 5's verification is the actual gate, same as everywhere else in the pack.
- **Release commit smuggling in "one small fix".** The release commit is changelog + version, nothing else; the fix goes through the normal loop first.

## Relationship to other skills

- `yo-branch` — owns everything up to merged-into-develop; this skill takes over from there. Same no-bypass rule for protected main.
- `yo-gh-write` — writes the release notes and the GitHub release body in the user's voice.
- `yo-engineering` — compatibility/migration questions in step 1 and the rollback story in step 4; releases with migrations are S2 minimum.
- `yo-incident` — when post-release verification fails in production, mitigate there; the step-4 rollback note is the mitigation.
- `yo-deps` — dependency upgrades landing in a release get called out in the changelog (users debug "it broke after I upgraded" against them).

## Sources

See `references/sources.md`.
