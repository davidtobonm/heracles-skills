---
name: ship-change
description: "Take a finished branch to a merge-ready pull request: a task or design branch into dev, or dev into main as a release. Rebases, reruns the checks, runs the review loop, writes the PR from the sprint spec and evidence, opens it, and watches CI until green. The main session may merge PRs into dev when the human asked it to; a human merges every release into main. Use for /ship-change <branch> or \"open the PR\" once a task or design branch, or dev, is ready."
argument-hint: "<branch>"
disable-model-invocation: true
---

# Ship a change

The PR is a one-minute briefing for a human who has the diff. A human merges releases into `main`. You merge a PR into `dev` only when the human asked you to, for example to run a sprint unattended.

Arguments can be plain language ("the worker fix", "T1", "the current sprint"). Resolve them against `docs/status.md`, the sprint folders in `docs/sprints/` and `git branch -a`. If more than one thing matches, list the matches and ask which one. If nothing matches, say so and stop.

## 1. Find the branch

1. The branch is `$ARGUMENTS`, else the current branch. It is never `main`.
2. If the branch is checked out in a worktree (`git worktree list`), run every command below inside that worktree.
3. Pick the base. A `task/` or `design/` branch merges into `dev`. `dev` itself merges into `main`, as a release. Call it `<base>` below.
4. Check that it is ready. A task branch has its task ticked in `plan.md`. A design branch has its ADRs `accepted`. A release has every task of the sprints in it ticked or cut in `plan.md`, and its PR lists those sprints.
5. `git status` is clean. Commit or drop what is left.

## 2. Rebase and recheck

```bash
git fetch origin
git rebase origin/<base>
```

Resolve conflicts by keeping both intents. Conflicts in `plan.md` and `log.md` between parallel task branches are expected; keep every tick and every line. If you cannot tell what one side meant, stop and ask. Then run the full checks from `AGENTS.md` again.

## 3. Review

Use the `review-change` skill and the arguments `origin/<base> --fix`. Continue only with a score of 4 or 5 and no Act on items. Otherwise stop and report what is open.

## 4. Write the PR

Title in Conventional Commits form, `type(scope): subject`, no trailing period. Body with these sections, in order, dropping any with nothing to say:

- `## Why` in 1-3 sentences, the problem from the user's side.
- `## Stories` with the story ids and the acceptance criteria this PR satisfies.
- `## What changed` in 1-3 bullets.
- `## Scope` with what it covers and what it leaves out on purpose.
- `## Decisions` with links to the ADRs this PR follows or adds.
- `## Blast radius` in 1-2 sentences on who or what it touches and why that is safe.
- `## Verification` with the evidence for each criterion (`passed`, `failed`, `untested`), linking `docs/sprints/<sprint>/evidence/`. For UI criteria, include the `State | Before | After` table from the evidence file, and ask the human to drag in the images from `.artifacts/<task>/`.
- `## Review` with the score and the Consider items for the human to decide.

Use the `unslop` skill on the title and body before you post them.

## 5. Open and watch

1. Push with `git push -u origin <branch>`. After a rebase of a branch already pushed, use `git push --force-with-lease`, never `--force`.
2. `gh pr create --base <base> --title ... --body-file ...`. Open it ready for review, not as a draft.
3. `gh pr checks --watch`. When a check fails, read its log first:
   - Our bug: fix it, commit, push, watch again.
   - Infrastructure or a flaky test: retry once with `gh run rerun --failed`. A second failure is treated as our bug or reported.
   - Cannot tell: stop and report with the log excerpt.
4. Answer human review comments by fixing the code or replying with the reason. Push back when a comment drifts from the spec.

## 6. After the human merges (only if asked to follow through)

1. For a PR into `dev` that you were asked to merge: wait for green checks and a review score of 4 or 5, then `gh pr merge <number> --squash --delete-branch`. The heracles branch guard hook allows this only for PRs into `dev`.
2. For a task branch, remove its worktree and branch: `git worktree remove .worktrees/<sprint>-<task>` and `git branch -d task/<sprint>-<task>`. The next task starts from the updated `dev`.
3. For a release merged into `main`, watch the deploy workflow with `gh run watch`, then run the smoke check from `AGENTS.md` against the deployed service. Never touch real user data. Post the result as a PR comment with `gh pr comment`.
4. After a release, bring `dev` level with `main` and record it: `git switch dev && git pull --ff-only && git merge --ff-only origin/main`, update `docs/status.md`, commit it as `docs(status): release <date>`, and `git push origin dev`. Then tell the human to run `/close-sprint` for each sprint in the release.
