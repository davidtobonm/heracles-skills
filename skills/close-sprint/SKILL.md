---
name: close-sprint
description: Close a sprint after its release is merged into main and the humans call it done. Brings the living docs (product, glossary, architecture, contracts, diagrams) back in line with the code, moves leftovers to the backlog, runs a short retro that turns repeated mistakes into checks, and freezes the sprint folder. Use for /heracles:close-sprint <sprint>.
argument-hint: "<sprint id>"
disable-model-invocation: true
---

# Close a sprint

The sprint folder is history. The living docs describe the system as it is today. Closing a sprint moves what the sprint learned from its folder into the living docs.

Arguments can be plain language ("the worker fix", "T1", "the current sprint"). Resolve them against `docs/status.md`, the sprint folders in `docs/sprints/` and `git branch -a`. If more than one thing matches, list the matches and ask which one. If nothing matches, say so and stop.

## Steps

1. Check that the sprint shipped: its tasks are in a release PR from `dev` merged into `main` (`gh pr list --base main --state merged --limit 5`). If not, stop and point to `/heracles:ship-change dev`. A design sprint with no code to deploy may close without a release.
2. Ask the human whether the sprint is done and which open tasks are cut. Do not close it on your own judgment.
3. Switch to `dev` and update it with `git pull --ff-only`. Every finished task is merged into it by now. Only the main session closes a sprint, so it commits on `dev` directly.
4. List what changed with `git diff --stat <start>..HEAD`, where the start is the `Start commit:` line of the sprint `log.md`.
5. For each changed area, compare its living doc with the code: `docs/architecture/`, `docs/contracts/`, `docs/product/product.md` and the glossary. Fix what is no longer true. Delete what the code already says. A living doc says how things are today and holds no sprint history.
6. Regenerate the generated diagrams and update the hand-written ones whose subject changed. Call the Skill tool with "heracles:draw-diagram" for each and run its checks.
7. Every decision in the sprint log that passes the ADR test gets an ADR (call the Skill tool with "heracles:record-decision"). ADRs still `proposed` go to "Waiting on the owners" in `docs/status.md`.
8. Cut and unfinished tasks go to the top of `docs/backlog.md` with one line each on why. Remove finished items from `docs/status.md`.
9. Add `## Result` and `## Retro` to the sprint `log.md`. The result names the release PR, the deploy and the smoke check outcome. The retro is three lines: what worked, what failed (in the build or in the release), and one change to how we work. For a mistake that happened twice, propose the structure that prevents it (a test, a lint rule, a hook, a line in `AGENTS.md`, a path rule, a project skill) instead of a note. Ask the human before you edit `AGENTS.md` or anything in `.claude/`.
10. Set the status line at the top of `spec.md` to `Status: closed YYYY-MM-DD` and update the sprint's row in `docs/sprints/README.md`.
11. Remove the sprint's leftover task worktrees (`git worktree list`, then `git worktree remove` for each `.worktrees/<sprint>-*`).
12. Run `python3 "${CLAUDE_PLUGIN_ROOT}/scripts/check_docs.py"` and fix what it reports.
13. Commit everything on `dev` as `docs(sprint): close <sprint>` and `git push origin dev`. After that, nothing in the sprint folder changes again. These docs reach `main` with the next release.
