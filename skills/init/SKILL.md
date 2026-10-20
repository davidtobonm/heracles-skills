---
name: init
description: Set up this repo for the heracles workflow. Adds AGENTS.md, the docs skeleton, the check scripts, the subagent role files and, per agent the team uses, CLAUDE.md, Claude Code settings and hooks, Cursor hooks, GEMINI.md or OpenCode subagents, without overwriting any existing file. Use once per repo, when someone asks to set up heracles or runs /init.
disable-model-invocation: true
---

# Set up a repo

Run this from the root of a git repo, new or existing. It adds files and never overwrites one. It does not commit.

## 1. Check the repo

1. `git rev-parse --show-toplevel` must succeed and equal the current directory. If not, stop and say where the repo root is, or that `git init` comes first.
2. `git status --short`. If there are uncommitted changes, say so; the human may want to commit them before the workflow files land.

## 2. Ask which agents the team uses

Ask once, as a list to tick: Claude Code, Cursor, Codex, OpenCode, Pi, Gemini CLI, other. Map the answer to flags: Claude Code `--claude`, Cursor `--cursor`, Gemini CLI `--gemini`, OpenCode `--opencode`. Codex, Pi and the others need no flag. If the human says "all", use `--all`. If nobody uses an agent with a flag, pass `--none`.

## 3. Copy the files

Run `bash <this skill's folder>/init.sh <flags>`. In Claude Code the folder is `${CLAUDE_SKILL_DIR}`; in other agents it is the folder this `SKILL.md` was loaded from. The script prints `added` or `kept existing` for each file.

Always added:

| From | Goes to |
|---|---|
| `templates/AGENTS.md` | `AGENTS.md`: what the project is, what to read first, the workflow table, how to run it in each agent, empty Commands, the rules |
| `templates/docs/` | `docs/README.md`, `docs/product/` (product, glossary, stories), `docs/architecture/overview.md`, `docs/contracts/README.md`, `docs/decisions/README.md` (empty index), `docs/sprints/README.md`, `docs/status.md`, `docs/backlog.md`, `docs/workflow.md` |
| `files/scripts/` | `scripts/heracles/`: `check_docs.py`, `check-mermaid.mjs`, `before-after.sh`, and the two hook scripts |
| `files/roles/` | `.heracles/roles/`: the `reviewer`, `implementer`, `verifier` and `plan-checker` instructions, so agents without registered subagents can use them as prompts |
| `templates/gitignore` | lines appended to `.gitignore` when missing |

Added per flag:

| Flag | Adds |
|---|---|
| `--claude` | `CLAUDE.md` (`@AGENTS.md`), and `.claude/settings.json` with deny rules, `worktree.baseRef: head` for implementer worktrees, the branch guard before every shell command and the docs check when a session stops |
| `--cursor` | `.cursor/hooks.json`, which runs the branch guard before every shell command |
| `--gemini` | `GEMINI.md` (`@AGENTS.md`) |
| `--opencode` | `.opencode/agents/<role>.md`: the four roles as OpenCode subagents, read-only where the role is |

## 4. Merge what was kept

For each file the script kept, compare it with its template and tell the human what is missing. Edit only after the human says yes.

- `.claude/settings.json` kept: show the deny rules, `worktree.baseRef` and the `hooks` block the file lacks. `run-sprint` needs `worktree.baseRef: head` in Claude Code.
- `.cursor/hooks.json` kept: show the `beforeShellExecution` entry to add.
- `AGENTS.md` kept: show the Workflow table, the "Run it in your agent" section and the rules from the template, and offer to add them.
- `CLAUDE.md` or `GEMINI.md` kept: if it does not contain `@AGENTS.md`, offer to add that line.
- A doc kept: leave it. Check that `docs/sprints/README.md` and `docs/decisions/README.md` have the index tables the workflow writes rows into.

## 5. Check

Run `python3 scripts/heracles/check_docs.py` and fix what it reports in the files this run added.

## 6. Tell the human what comes next

Reply with these steps, in order:

1. Fill the Commands section of `AGENTS.md` (install, test, lint, typecheck, run locally, smoke check) once the stack exists. If it stays empty, the first sprint's first task fills it.
2. Commit the workflow files on `main` and push: `git add -A && git commit -m "chore: add heracles workflow" && git push`. This is the one commit on `main` made by hand.
3. Create the integration branch from it: `git switch -c dev && git push -u origin dev`. Every task and design branch starts from `dev`, and the branch guard only acts once `dev` exists.
4. Run `/define-product` to start with the product definition, or `/plan-sprint <goal>` when the product and architecture are already clear. The "Run it in your agent" section of `AGENTS.md` says how to type a skill in each agent.

Path rules are optional and Claude Code only. A file in `.claude/rules/*.md` with a `paths:` list of globs in its frontmatter loads only when Claude touches matching files. `templates/rules-example.md` in this skill's folder shows one for contract files. `run-sprint` names the matching rules in each implementer brief, because subagents in worktrees do not load them on their own.
