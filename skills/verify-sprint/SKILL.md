---
name: verify-sprint
description: Prove a built sprint does what its spec promised. A fresh verifier checks every acceptance criterion against the running app, in a seeded demo or test environment, and the code, then the owners accept each user-facing criterion one at a time. Failures become fix tasks. Use for /heracles:verify-sprint <sprint>, or when run-sprint finishes its last wave.
argument-hint: "<sprint id>"
---

# Verify a sprint

Tasks being done is not the goal. The goal is that every acceptance criterion in `spec.md` is true in the running product. A verifier that did not build the code checks it.

Arguments can be plain language ("the worker fix", "T1", "the current sprint"). Resolve them against `docs/status.md`, the sprint folders in `docs/sprints/` and `git branch -a`. If more than one thing matches, list the matches and ask which one. If nothing matches, say so and stop.

## 1. Machine check

1. Look for a project verification skill (`.claude/skills/verify-*/`). If there is none, tell the owners that `/heracles:create-verification-skill` can generate one once the app runs locally (named `verify-<app>`), and continue at code level.
2. Spawn the `heracles:verifier` subagent with the sprint id and the path of `spec.md`. It drives the app through the verification skill in a seeded demo or test environment when one exists, reads the code, and returns each criterion as `passed`, `failed` or `untested` with its evidence. At code level, criteria that need the running UI come back `untested` with that reason.
3. Read the evidence for every `passed`. A screenshot or an output that does not show the criterion is `untested`.

## 2. Owner acceptance

For each criterion of a user-facing story, walk one owner through it, one at a time:

1. Say what to do in the app and what they should see.
2. Wait for `pass`, or for what they saw instead.
3. Record the answer in `log.md`.

Skip this for criteria with no user-facing surface; the machine check covers them.

## 3. Close the gaps

For each `failed` or `untested` criterion, add a fix task to `plan.md` in a new wave, with the failure as its goal and the evidence path in `Read first`. Tell the owners to run `/heracles:run-sprint` again, or `/heracles:build-task` for each fix task. Verification passes only when every criterion is `passed` or the owners cut it from the sprint in writing.

## 4. Write the result

Write `docs/sprints/<sprint>/evidence/README.md`: one row per criterion with its result, the evidence path and the owner's answer.
