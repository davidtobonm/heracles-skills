---
name: review-change
description: Review a branch's changes against its sprint spec and this repo's rules with independent reviewer subagents, give a 1-5 merge score, and optionally fix and re-review in a bounded loop. Use for /heracles:review-change, before opening or merging a PR, when asked to "review this", or when ship-change calls it.
argument-hint: "[base ref] [--fix]"
---

# Review a change

Independent reviewers read the diff in fresh contexts, so the author never grades its own work. Findings come back sorted, with a score that says whether the change is ready to merge.

## 1. Pin the diff

1. Read `$ARGUMENTS`. The base is the first argument that does not start with `--`, else `git merge-base HEAD origin/main`. `--fix` anywhere in the arguments turns on step 5. Confirm the base with `git rev-parse --verify <base>`.
2. Use `git diff <base>`, which compares the base with the working tree, so uncommitted work is reviewed too. Note `git log <base>..HEAD --oneline`.
3. Stop here if the diff is empty.

## 2. Find the intent

Read the sprint `spec.md` and the plan tasks this branch covers (from the branch name, commit messages or `docs/status.md`). Write the intent in one paragraph: which stories and acceptance criteria this change claims to satisfy. If there is no spec, say so; the spec reviewer then only checks the commit messages' claims.

## 3. Spawn the reviewers

In one message, spawn these with the Agent tool, `subagent_type: heracles:reviewer`. Fill [REVIEWER-PROMPT.md](REVIEWER-PROMPT.md) for each.

- Spec reviewer (`model: sonnet`). Does the diff do what the stories and acceptance criteria ask? Lists what is missing or partial, what was built that nobody asked for, and what looks implemented but wrong. Quotes the spec line for each finding.
- Standards reviewer (`model: opus`). Checks the diff against `AGENTS.md`, the path rules in `.claude/rules/` that match the changed files (if the repo has any), and the lenses in [RUBRIC.md](RUBRIC.md).
- Contracts and data reviewer (`model: opus`), only when the diff touches `docs/contracts/`, a public API, event or file format, a schema, a migration or how stored data is written. Checks the contracts and data lens in RUBRIC.md and that every breaking contract or schema change has an accepted ADR.

Reviewers never edit files. An empty review is a valid result.

## 4. Judge

You are the lead reviewer, a pragmatic senior engineer, not a neutral aggregator. Merge findings that describe the same issue and note which reviewers raised it. Put every finding in one bucket:

- Act on. Wrong behavior, broken rule, security or privacy risk, missing proof. Blocks the merge.
- Consider. Real, but the cost of fixing now may outweigh it. The human decides.
- Noted. Valid but not actionable now.
- Dismissed. Wrong or missing context, with a one-line reason.

Then give the score:

| Score | Meaning |
|---|---|
| 5 | Merge as is. |
| 4 | Merge after the Consider items the human picks. No Act on items. |
| 3 | Needs fixes. At least one Act on item. |
| 2 | Significant problems in design or correctness. |
| 1 | Wrong change. Re-plan before more code. |

## 5. Fix loop (only with `--fix`)

1. Fix every Act on item. Do not change correct code to raise the score.
2. Commit, then run steps 1 to 4 again with fresh reviewers on the new diff.
3. Stop when the score is 4 or 5 with no Act on items, or after 3 rounds. After 3 rounds, stop and report to the human with what is still open.

## 6. Report

Write the result where the work is tracked: the sprint `log.md`, or the PR body under `## Review`. Include the intent, the score per round, the Act on and Consider items, and each dismissed item with its reason.
