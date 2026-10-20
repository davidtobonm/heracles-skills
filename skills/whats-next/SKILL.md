---
name: whats-next
description: Say where the project stands and which command to run next, from docs/status.md, the active sprint plan and the backlog. Use for /heracles:whats-next, when a session starts, after a pause, or when someone asks "what's next" or "where are we".
---

# What's next

1. Read `docs/status.md`, the active sprint's `plan.md` and the last 10 lines of its `log.md` (if a sprint is active), the first five items of `docs/backlog.md`, and the Workflow table in `AGENTS.md`.
2. Run `git fetch origin`, `git status`, `git worktree list` and `git log --oneline -5`. If `dev` is behind `origin/dev`, say so first: someone else pushed plans or merges, and `git pull --ff-only` on `dev` brings them in.
3. Reply in at most eight lines:
   - The active sprint or design work and its goal, or "nothing active".
   - Tasks done, in progress and blocked, with the blocker.
   - What waits on the owners (proposed ADRs, questions, approvals, commits to push).
   - One recommended next command, taken from the Workflow table in `AGENTS.md`, with a one-line reason.

If `docs/status.md` does not exist, the repo is not set up for this workflow; recommend `/heracles:init` and stop.

Do not start the work. The human picks.
