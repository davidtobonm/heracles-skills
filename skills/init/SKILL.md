---
name: init
description: Set up this repo for the heracles workflow. Copies AGENTS.md, CLAUDE.md, the docs skeleton, a .claude/settings.json with deny rules and the .gitignore lines from the plugin's templates without overwriting any existing file, then tells the human how to commit and create the dev branch. Use for /heracles:init, once per repo.
disable-model-invocation: true
---

# Set up a repo

Run this from the root of a git repo, new or existing. It adds files and never overwrites one. It does not commit.

## 1. Check the repo

1. `git rev-parse --show-toplevel` must succeed and equal the current directory. If not, stop and say where the repo root is, or that `git init` comes first.
2. `git status --short`. If there are uncommitted changes, say so; the human may want to commit them before the workflow files land.

## 2. Copy the templates

Run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/init.sh"`. It copies from `${CLAUDE_PLUGIN_ROOT}/templates/`:

| Template | Goes to |
|---|---|
| `AGENTS.md` | `AGENTS.md`: what the project is, what to read first, the workflow table, empty Commands, the rules |
| `CLAUDE.md` | `CLAUDE.md`, one line: `@AGENTS.md` |
| `docs/` | `docs/README.md`, `docs/product/` (product, glossary, stories), `docs/architecture/overview.md`, `docs/contracts/README.md`, `docs/decisions/README.md` (empty index), `docs/sprints/README.md`, `docs/status.md`, `docs/backlog.md`, `docs/workflow.md` |
| `settings.json` | `.claude/settings.json`: deny rules for `.env` reads (except `.env.example`), force pushes, pushes to `main` and bare `git push`, and `worktree.baseRef: head` so implementer worktrees start from the checked-out `dev` |
| `gitignore` | lines appended to `.gitignore` when missing: `.worktrees/`, `.claude/worktrees/`, `.artifacts/`, `node_modules/`, `.env`, `.env.*`, `!.env.example` |

The script prints `added` or `kept existing` for each file.

## 3. Merge what was kept

For each file the script kept, compare it with its template and tell the human what is missing. Edit only after the human says yes.

- `.claude/settings.json` kept: show the deny rules and `worktree.baseRef` from the template that the file lacks. `run-sprint` needs `worktree.baseRef: head`.
- `AGENTS.md` kept: show the Workflow table, the "Read before you write" table and the rules from the template, and offer to add them.
- `CLAUDE.md` kept: if it does not contain `@AGENTS.md`, offer to add that line.
- A doc kept: leave it. Check that `docs/sprints/README.md` and `docs/decisions/README.md` have the index tables the workflow writes rows into.

## 4. Check

Run `python3 "${CLAUDE_PLUGIN_ROOT}/scripts/check_docs.py"` and fix what it reports in the files this run added.

## 5. Tell the human what comes next

Reply with these steps, in order:

1. Fill the Commands section of `AGENTS.md` (install, test, lint, typecheck, run locally, smoke check) once the stack exists. If it stays empty, the first sprint's first task fills it.
2. Commit the workflow files on `main` and push: `git add -A && git commit -m "chore: add heracles workflow" && git push`. This is the one commit on `main` made by hand.
3. Create the integration branch from it: `git switch -c dev && git push -u origin dev`. Every task and design branch starts from `dev`.
4. Run `/heracles:define-product` to start with the product definition, or `/heracles:plan-sprint <goal>` when the product and architecture are already clear.

Path rules are optional. A file in `.claude/rules/*.md` with a `paths:` list of globs in its frontmatter loads only when Claude touches matching files, which keeps area rules out of `AGENTS.md`. The plugin does not install any. `${CLAUDE_PLUGIN_ROOT}/templates/rules-example.md` shows one for contract files; copy it to `.claude/rules/contracts.md` and change the globs to fit the code layout. `run-sprint` names the matching rules in each implementer brief, because subagents in worktrees do not load them on their own.
