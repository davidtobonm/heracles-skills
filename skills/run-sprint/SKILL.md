---
name: run-sprint
description: Build a planned sprint as its orchestrator. Works from dev, runs each wave's tasks in parallel implementer subagents on task branches in their own worktrees, audits every task's diff and evidence, opens a PR into dev for each passing task and merges it, keeps the plan's progress, and stops for the owners on one-way tasks. Use for /run-sprint <sprint>.
argument-hint: "<sprint id>"
disable-model-invocation: true
---

# Run a sprint

You coordinate and audit; implementers build. You never write a task's code yourself.

Arguments can be plain language ("the worker fix", "T1", "the current sprint"). Resolve them against `docs/status.md`, the sprint folders in `docs/sprints/` and `git branch -a`. If more than one thing matches, list the matches and ask which one. If nothing matches, say so and stop.

Running this command is the owners asking you to merge each passing task's PR into `dev`. Merging into `main` stays a human step.

## 1. Prepare

1. Read the sprint `spec.md`, `plan.md` and `log.md`. Confirm the plan checker's `PASS` line is in `log.md`. If not, stop and point to `/plan-sprint`.
2. Check out `dev` in the main checkout and pull it. If `git status` shows uncommitted changes in `docs/`, stop and ask the owners to commit them first, because implementer worktrees only see committed files.
3. Each implementer works in its own worktree on a `task/` branch started from `dev`, so it sees the spec, the plan and every committed ADR. In Claude Code the `implementer` subagent creates it (`worktree.baseRef: head` in `.claude/settings.json`, which `/init` sets). In other agents, create it yourself before you spawn the implementer: `git worktree add .worktrees/<sprint>-<task> -b task/<sprint>-<task> dev`, and tell the implementer to work only there. Before each wave, pull `dev` again so the new tasks see the merged ones.
4. If your agent has no subagents, stop and tell the owners to use one-session delivery: `/build-task` for each task in wave order, then `/ship-change`.

## 2. Run each wave

For the lowest wave with open tasks:

1. Stop before any task with `One-way: yes`. Show the owners what it will do and what undoing it costs, and wait for a yes. Record the answer in `log.md`.
2. Spawn one `implementer` subagent per ready task, in one message, at most 3 at a time. Its instructions are in `.heracles/roles/implementer.md`; agents that do not register heracles subagents give that file as the subagent's prompt. Pass the task's `Model` and `Effort`. Fill [BRIEF-TEMPLATE.md](BRIEF-TEMPLATE.md) for each, including the path rules that match the task's scope.
3. Do other audits while they run. Never poll.

## 3. Audit each report

Apply [AUDIT.md](AUDIT.md) to every task, in its worktree: read the whole diff, run its `Verify` command and the checks yourself, and check every acceptance criterion against its evidence.

- When something fails, send the same implementer numbered, checkable findings (in Claude Code with SendMessage; elsewhere, start a new implementer with the findings and the same worktree). At most two rounds. After that, split the task or rewrite the brief; do not hand it to a bigger model unchanged.
- When it passes, copy the worktree's `.artifacts/<task>/` to the main checkout's `.artifacts/<task>/`, so screenshots survive the worktree. Then push its branch, use the `review-change` skill and `origin/dev`, open a PR into `dev` with `gh pr create --base dev` (title names the task id, body says what changed and why, with the evidence), wait for `gh pr checks --watch`, and merge it with `gh pr merge <number> --squash --delete-branch`. Run the full suite on the updated `dev`. You are the only one who merges; implementers never do.

## 4. Keep the record

After each merge, tick the task in `plan.md` and add a dated line to `log.md` (task, result, rounds, anything surprising), and commit them on `dev` and push. You are the only one who edits these two files and `docs/status.md`. If a task turns out bigger than planned, split it in `plan.md` right there and note why.

## 5. Finish

When every task is ticked:

1. Use the `verify-sprint` skill.
2. Tell the owners the result and the next commands: `/ship-change dev` for the release PR into `main` when they want to deploy, then `/close-sprint S<NN>` once it is merged. Merging into `main` stays a human step.
