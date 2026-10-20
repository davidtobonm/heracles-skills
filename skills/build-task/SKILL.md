---
name: build-task
description: Build one planned sprint task end to end on its own branch. Loads the task and its stories, isolates the work in a worktree, builds test-first (or settles a design decision with the owners), proves each acceptance criterion with evidence, runs the checks, commits and reports. Use for /build-task <sprint> <task>, or when an implementer subagent receives a task brief.
argument-hint: "<sprint id> <task id>"
---

# Build a task

One task, one branch, one report. The task's block in the sprint `plan.md` is the contract.

Arguments can be plain language ("the worker fix", "T1", "the current sprint"). Resolve them against `docs/status.md`, the sprint folders in `docs/sprints/` and `git branch -a`. If more than one thing matches, list the matches and ask which one. If nothing matches, say so and stop.

## 1. Load the task

1. Read `docs/sprints/<sprint>/spec.md` and the task's block in `docs/sprints/<sprint>/plan.md`. State the task id and title before you start.
2. If the task does not exist, is blocked by an open task, or is marked `One-way: yes` without the owners' yes in `log.md`, stop and say so.
3. Read every file in its `Read first` line, the glossary terms it uses, and the ADRs it cites.

## 2. Isolate

Never build on `main` or `dev`, even as the main session. Every task gets its own branch in its own worktree, started from `dev`. An implementer subagent is already in its worktree and skips this step.

1. Fetch `dev` and create the task worktree from it, so the plan and every merged task are in it:
   ```bash
   git fetch origin
   git worktree add .worktrees/<sprint>-<task> -b task/<sprint>-<task> origin/dev
   ```
   Work inside `.worktrees/<sprint>-<task>` from here on. If `plan.md` is not there, the plan was never pushed; stop and say so.
2. Worktrees do not isolate ports or databases. Before starting a server, run `lsof -i :<port>`. Reuse a server already running for this branch, or pick a free port.
3. Install dependencies in the worktree with the commands in `AGENTS.md`.

## 3. Build

A task with a `Decides:` line is a design task; go to 3b. Any other task is a build task; go to 3a.

### 3a. Build test-first

Follow the `tdd` skill (load it unless it is already loaded). Use the seams in the task's `Seams` line. Stay inside the task's `Scope`. If the work needs to leave the scope or change a contract, stop and report instead.

Run the typechecker and single test files as you go, and the whole suite once at the end.

### 3b. Settle a design decision

1. Use the `grilling` skill on the decision in the `Decides:` line, with the owners it names.
2. Call "record-decision" with the owner who decided. An ADR the owners have not decided stays `proposed`, and the task stays open.
3. Update the living doc the decision shapes (`docs/product/`, `docs/architecture/` or `docs/contracts/`), and call "draw-diagram" when the doc has a diagram.

## 4. Prove it

For a build task, capture evidence for each acceptance criterion it covers, as [EVIDENCE.md](EVIDENCE.md) describes. A bug fix captures the failure before the fix. Mark each criterion `passed`, `failed` or `untested`, and never leave one out silently.

For a design task, the evidence is the accepted ADR's path, the updated doc and a passing `python3 "scripts/heracles/check_docs.py"`.

## 5. Check and commit

1. Run the task's `Verify` command and the full checks from `AGENTS.md`. Fix until green, or report what stays red and why.
2. Commit with a Conventional Commits title, `type(scope): subject`, and a body that says why. Put the task id in the body.

## 6. Close out

- When a human ran `/build-task`, tick the task in `plan.md` and add one dated line to `log.md`, both inside the task worktree, and commit them with the task so the tick ships in the PR. Then tell the human to run `/ship-change task/<sprint>-<task>`, which opens a PR into `dev`.
- When you are a subagent, or `run-sprint` called you, do not edit `plan.md`, `log.md` or `docs/status.md`. The orchestrator updates them from your report, so parallel tasks never write the same file.

## 7. Report

Reply with this shape and nothing else:

```
Task <id>: <title>
Branch: <branch>   Worktree: <path>   Commits: <short shas>
Files: <paths, with line counts for new files>
Checks: <command> -> <result>, one per line
Acceptance criteria: <criterion> -> passed | failed | untested, with the evidence path
Outside scope or contract: none | <what and why>
New dependencies: none | <name and why>
Open questions: none | <question>
```
