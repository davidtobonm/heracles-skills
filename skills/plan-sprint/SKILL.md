---
name: plan-sprint
description: Plan the next delivery sprint. Takes stories from the story map, interviews the owners until each has checkable acceptance criteria, has to-spec write the sprint spec and to-tickets write bounded tasks, groups them in waves (with scope, seams, verify command, model and effort per task), has a separate plan checker review it, and registers the sprint. Use for /plan-sprint or "plan the next sprint".
argument-hint: "[backlog item or story ids]"
disable-model-invocation: true
---

# Plan a sprint

A sprint is one folder, `docs/sprints/S<NN>-<slug>/`, with `spec.md` (what and why), `plan.md` (tasks in waves) and `log.md` (what happened). The spec is written before any code. Design work goes through `/define-product` or `/design-architecture`, not here.

Arguments can be plain language ("the worker fix", "T1", "the current sprint"). Resolve them against `docs/status.md`, the sprint folders in `docs/sprints/` and `git branch -a`. If more than one thing matches, list the matches and ask which one. If nothing matches, say so and stop.

## 1. Choose what

1. The goal is `$ARGUMENTS` if given, else the first item in `docs/backlog.md`.
2. Read `docs/status.md`. If a sprint is open, ask whether to close it first.
3. If the goal needs a product, architecture or data decision that has no accepted ADR, stop and say which design command to run first.

## 2. Open the sprint folder

Plan on an up-to-date `dev`, the integration branch (`git switch dev && git pull --ff-only`). Only the main session plans, so it commits on `dev` directly.

1. Create `docs/sprints/S<NN>-<slug>/`, with the next number.
2. Copy [SPEC-TEMPLATE.md](SPEC-TEMPLATE.md) to `spec.md` and fill its title, `Status: open`, the date and the type.
3. Copy [LOG-TEMPLATE.md](LOG-TEMPLATE.md) to `log.md` with today's date and the current commit.
4. Add the row `| [S<NN>](S<NN>-<slug>/spec.md) | <goal> | <type> | planning |` to `docs/sprints/README.md`.

## 3. Read the area

Read the stories in `docs/product/stories.md` that the goal covers, the glossary, the ADRs of the area and its living docs (`docs/architecture/`, `docs/contracts/`). Send Explore subagents for facts about the code.

## 4. Interview

Use the `grilling` skill until every story has acceptance criteria the owners agree with, the out-of-scope list is explicit, and contract changes are known. Call "domain-modeling" for new terms and "record-decision" for decisions that pass the ADR test.

## 5. Write the spec

Use the `to-spec` skill and the path of `spec.md`. Stories keep their ids from the story map (`ACC-03`); a new story gets an id in `stories.md` first.

## 6. Write the plan

1. Copy [PLAN-TEMPLATE.md](PLAN-TEMPLATE.md) to `plan.md`, then use the `to-tickets` skill and the paths of `spec.md` and `plan.md`. It writes vertical-slice tasks with blockers, `Seams` and `Verify`, after the owners approve the breakdown.
2. Then fill the delivery fields:
   - `Scope` names the modules or folders where the task may write. Two tasks in the same wave never share scope.
   - A task's wave is one more than the highest wave of the tasks in its `Blocked by` line. A task with no blockers is in wave 1.
   - Each task fits a fresh subagent well inside about 100k tokens; split any that does not.
   - `Model` and `Effort` follow [MODEL-CHOICE.md](MODEL-CHOICE.md).
   - `One-way: yes` marks a task whose result is hard to undo (a migration of stored data, a public contract going live). The orchestrator stops for the owners before it.

## 7. Check the plan

Spawn the `plan-checker` subagent with the paths of `spec.md` and `plan.md`. Fix what it reports and run it again, at most twice. Write its final verdict as a dated line in `log.md`, for example `- 2026-10-21. Plan checker: PASS.`; `run-sprint` looks for that line. Then show the owners the stories, the waves and the tasks as a numbered list, and iterate until they approve.

## 8. Register and commit

1. Set the sprint's row in `docs/sprints/README.md` to `open`, make it active in `docs/status.md`, fill the `Sprint` column of its stories in `stories.md`, and remove the item from `docs/backlog.md`.
2. Run `python3 "scripts/heracles/check_docs.py"`.
3. Commit on `dev` as `docs(sprint): plan S<NN>` and push it with `git push origin dev`. `run-sprint` starts every task branch from `dev`.

Then tell the owners the next command: `/run-sprint S<NN>` to build with parallel implementers, or `/build-task S<NN> T1` to build one task at a time in this session.
