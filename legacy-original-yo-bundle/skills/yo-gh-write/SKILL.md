---
name: yo-gh-write
description: >-
  Write GitHub issues, pull requests, and review comments in the user's voice — concise, technical, GitHub-flavored markdown. Use whenever the task involves authoring text bound for GitHub: "write a PR description", "open an issue", "draft a PR comment", "reply to this review", "post the wrap-up", "file a bug report", "comment on PR #N". Detects the repo profile (configured profiles live in `references/repo-profiles.md`; otherwise reads the repo's own PR template). Drafts in chat first for non-trivial text, does an anti-AI-slop cleanup before posting, uses `gh` HEREDOC to avoid quote-mangling. Templates and `gh` patterns live in references/ — loaded on demand.
---

# yo-gh-write — GitHub Writing in the User's Voice

This skill drafts and posts GitHub text — issues, PR bodies, review comments, inline replies, summary updates. It does not implement code. It writes the *words* that land on GitHub.

The actual templates and `gh` invocations live in `references/templates.md` and `references/gh-cli.md`. Load those when you're about to write or post, not on every invocation.

## The six things that make GH text good

1. **Why before what.** The reader can see the diff; they cannot see what made you write it. Lead with motivation — the bug, the constraint, the user-facing problem.
2. **Concrete, not categorical.** "Fixes a race in `StreamCompleted` where a late event from the previous session credits the new session" beats "Improves session handling robustness."
3. **One topic per comment.** A review comment that mixes a nit, a question, and a blocker reads as "everything is fine, also some stuff is wrong." Split them.
4. **Markdown that renders.** Fenced code blocks with language tag, tables for multi-row data, `<details>` for long logs, task-list checkboxes for test plans, file:line auto-links.
5. **Slack-tone, not changelog-tone.** Write like a colleague typing into a channel, not a press release.
6. **Risk and proof.** For broad/high-risk work, include the `yo-engineering` risk tier, rollback/compatibility note, and exact verification evidence.

## When to invoke

- "Write the PR description for this branch"
- "Open an issue for the bug we just found"
- "Draft a comment on PR #311"
- "Reply to the review on file Y" — including per-thread replies after a fix wave
- "Wrap up the wave with a comment on the issue"
- "File this as a follow-up issue"

Do not invoke for code edits or for plain Slack messages (those still want the same plain, anti-slop voice but don't render through GitHub markdown).

## Evidence comments are the expected endpoint

When work finishes against an existing PR or issue — an audit verdict, a post-fix verification, a feature-ship check, a bug repro — the proof belongs **on the PR/issue as a comment**, not printed to the CLI and forgotten. The verify pass already produced the evidence; surfacing it where the team reads is the default, not an extra step. `yo-audit`, `yo-fix-loop`, `yo-feature`, and `yo-verify-premise` all hand their evidence here for exactly this.

This is **not** blanket auto-post. The existing discipline still holds: draft non-trivial comments in chat first (step 3 below), and the Phase-6 reversibility posture from `yo-fix-loop` still applies — you're sending something external. The rule is about *where the finished evidence lands by default* (the PR/issue, via the "Verification evidence" template in `references/templates.md`), not about skipping the draft check. CLI-only is the fallback when there's no PR/issue to post to.

## Repo profiles

The user works across multiple repos. This skill detects the active repo and applies the right conventions.

### Configured repo profiles

Repo-specific conventions — detection signature, PR template, assignee, who to request review from, CI notes — live in `references/repo-profiles.md`. **Add or edit your repos there; don't hardcode them in this skill.** Load that file when you're about to write for a repo, and apply the first profile whose detection matches; if none match, use the generic profile below.

Two user-level rules apply to *every* profile (they're the user's preference, not the repo's):
- No `Co-Authored-By` tag.
- No assistant/vendor mentions anywhere — no "Claude", "Codex", "AI", or "Generated" — in body or commit messages.

### Generic profile (any other repo)

Detection: anything not matching a configured profile in `references/repo-profiles.md`.

Conventions:
- Read `.github/PULL_REQUEST_TEMPLATE.md` first (if it exists) and use its sections.
- If no template exists, use the **generic PR body** template in `references/templates.md` (Summary / Changes / Test plan).
- Read the most recent merged PR to infer the repo's tone and label conventions.
- Still no `Co-Authored-By`, still no assistant/vendor mentions. Those are *user* preferences, not repo preferences.

## Markdown affordances to actually use

| Affordance | Use it for |
|---|---|
| Fenced code block with lang tag (` ```csharp `) | Any code excerpt longer than inline |
| Inline code (`` ` ``) | Method names, file paths, flag names |
| Task list `- [ ]` / `- [x]` | Acceptance criteria, test plan, PR checklist |
| `<details><summary>…</summary>…</details>` | Long logs, stack traces, "click to expand" |
| Table | Comparison data (3+ rows × 2+ cols) |
| File:line auto-link (e.g., `Core/Services/ChatService.cs:42`) | Pointing at code without breaking the eye-line |
| `Closes #N` / `Fixes #N` / `Refs #N` | Wire the PR to its issue |

Skip table-for-two-rows. Skip details-for-three-lines. The affordance has to earn its visual weight.

## The drafting flow

1. **Read the underlying code.** A PR description written from the diff is fine; one written from imagination is slop. If invoked without having read the changes, read them first.
2. **Detect the repo profile** (above) so the right template applies.
3. **Draft in chat for non-trivial text.** Issues, PR bodies, review comments — show the draft to the user before posting. The user's standing feedback: anything beyond a trivial reply gets reviewed in chat first.
4. **Apply an anti-AI-slop pass** before posting. Strip AI-slop, vary rhythm, use "I" where natural, drop hedging that doesn't earn its words.
5. **Post via `gh` CLI with HEREDOC** so multiline content renders correctly. Patterns in `references/gh-cli.md`. Never inline a long body as a flag value.

## Per-thread replies after a fix wave

When `yo-fix-loop` closes a wave, it hands off to this skill for both the summary comment AND per-thread replies on the review threads being addressed. Don't post just one summary — reviewers usually want a "fixed in <SHA>" reply on the specific thread they wrote. See `references/templates.md` ("Per-thread review reply") and `references/gh-cli.md` ("Reply to a specific PR review thread").

## Anti-patterns

- **"This PR introduces several improvements that..."** — pure AI-slop opener. Lead with the bug or the constraint.
- **Bullet-listing every file changed.** The diff says that. Use bullets for *decisions*, not file enumeration.
- **Wall of text without headings or code blocks.** GH renders markdown — use it. Also don't over-structure a four-sentence comment with three H2s.
- **"Successfully" / "comprehensive" / "robust" / "leverage" / "ensure"** — flag these on every draft. Strip or replace.
- **Posting without showing the draft first** for anything beyond a one-line reply.
- **Co-Authored-By or assistant-generated tags.** Hard prohibition.
- **Mirroring the issue title in the PR title verbatim.** PR title describes *the change*, not *the problem*.
- **One summary comment when reviewers wrote N threads.** Reply per thread.

## Skills to invoke alongside

- **Anti-AI-slop pass** — built into step 4; there's no separate `humanizer` skill in Codex, so do it inline (strip slop, vary rhythm, cut hedging) as the final pass on any non-trivial draft.
- **`yo-fix-loop`** — invokes this skill for the wave wrap-up plus per-thread replies.
- **`yo-branch`** — runs before this skill on PR opens, to confirm branch readiness.
- **`yo-engineering`** — provides risk tier, rollback, specialist-lens, and verification notes for high-risk PRs/issues.
- **`yo-audit`** — when the change needs an independent verification pass, not just a description.

## Sources

See `references/sources.md`.
