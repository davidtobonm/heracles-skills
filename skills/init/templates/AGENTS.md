# <Project name>

<One paragraph: what the product does, for whom. /define-product writes the long version in docs/product/product.md.>

## Read before you write

| If you are going to | Read first |
|---|---|
| build a task | your brief, the sprint's `spec.md` and the task's block in `plan.md` |
| add a feature or change a product rule | `docs/product/product.md`, `docs/product/stories.md`, the glossary |
| change stored data, a schema or a migration | the ADRs with `Area: data` and `docs/architecture/overview.md` |
| change a public API, event or file format | `docs/contracts/README.md`, then the contract |
| change how the parts connect or deploy | `docs/architecture/overview.md` |
| pick up work after a pause | `docs/status.md`, or run `/whats-next` |

`docs/README.md` maps every doc. In Claude Code, area rules, if the repo has any, load on their own from `.claude/rules/` when you touch matching files. Procedures live in the heracles skills.

## Workflow

Two tracks. The design track decides; the delivery track builds what was decided. Details and the diagram are in `docs/workflow.md`.

| Track | Step | Command |
|---|---|---|
| Design | Product, stories, glossary | `/define-product` |
| Design | System architecture, data and module shape | `/design-architecture` |
| Delivery | Plan a sprint | `/plan-sprint` |
| Delivery | Build it with parallel implementers | `/run-sprint <sprint>` |
| Delivery | Or build it yourself, one task per session | `/build-task <task>`, then `/ship-change <task branch>` |
| Delivery | Prove every acceptance criterion | `/verify-sprint <sprint>` |
| Delivery | PR into `dev`, or the release PR `dev` into `main` | `/ship-change <branch>` |
| Delivery | Close the sprint after the release merges | `/close-sprint <sprint>` |
| Any | Where are we | `/whats-next` |
| Any | Which skills fit what I want to do | `/skill-guide <goal>` |

## Run it in your agent

The workflow is a set of skills (folders with a `SKILL.md`) plus this file. `/name` in this repo's docs means "run the skill `name`" in whatever way your agent does it.

| Agent | Run a skill | Subagents |
|---|---|---|
| Claude Code, heracles plugin | `/heracles:name` | Registered as `heracles:reviewer`, `heracles:implementer`, `heracles:verifier`, `heracles:plan-checker` |
| Claude Code, skills copied in | `/name` | A general subagent, given the role file below as its prompt |
| Cursor | `/name` | Registered by the plugin, or a subagent given the role file |
| Codex | `$name`, or pick it from `/skills` | A subagent given the role file, if your Codex version has them |
| OpenCode | ask for the skill by name | `@reviewer` and the others, after `init --opencode` |
| Pi | `/skill:name` | None built in: use one-session delivery |
| Gemini CLI, Copilot, others | ask for the skill by name | A subagent given the role file, if the agent has them |

- Role files. Each subagent's instructions are in `.heracles/roles/<role>.md`. When a skill says "spawn the `reviewer` subagent", use the registered one, or give a fresh subagent that file as its prompt.
- No subagents. Do the role yourself in a separate pass that starts by reading the role file, and use one-session delivery (`/build-task`, then `/ship-change`) instead of `/run-sprint`.
- Scripts. Checks live in `scripts/heracles/`: `check_docs.py`, `check-mermaid.mjs`, `before-after.sh`. Run them from the repo root.
- Hooks. In Claude Code and Cursor, `scripts/heracles/branch-guard.sh` enforces rule 11 (Claude Code also runs the docs check when a session stops). Other agents have no hook for it, so follow rule 11 yourself.

## Commands

<!-- Fill in when the stack exists: install, test, lint, typecheck, run locally, smoke check. -->

- Before you start a dev server, check whether one is running: `lsof -i :<port>`.

## Rules

1. Simple first. A function before a class, a dict before a model, one file before two. No options nobody asked for, no single-use abstractions, no impossible cases.
2. Contracts govern boundaries. `docs/contracts/` defines what crosses a boundary. Change a contract only in a task that names it. Otherwise stop and say what it lacks.
3. Stay in your scope. A task names where it may write. In shared files, add your block without rewriting anyone else's.
4. Handle every error. No `except` or `catch` that swallows an error. Every skip, drop or truncation is counted and logged with its reason.
5. Record decisions. A choice the code does not explain gets an ADR in `docs/decisions/` (skill `record-decision`). When a conversation settles such a choice without a planning or design skill running, say so and call `record-decision` right then; it stays `proposed` until a human confirms who decided. Before you change code that cites an ADR, read it; if you disagree, propose a new ADR instead of changing the code.
6. Read the code, not the comments. The code and its tests are the spec. When a comment disagrees with the code, trust the code and fix the comment.
7. Privacy. No secret or real person's data in code, tests, logs, commits, prompts or screenshots. Test data is invented. Never read or print `.env` files or secrets. `.env.example` lists every variable with dummy values, and agents read it.
8. Tests run without network and without a model. Fake at the lowest boundary (the HTTP transport, the SDK client), never inside our own code. Test what must happen and what must not.
9. No spending and no outside effects. No agent calls a paid API with real credentials, and no agent sends, shares, deletes or deploys through a connected tool (mail, drive, calendar, database, hosting). A human runs those. Add deny rules for the connected tools that can do them to your agent's permission settings (in Claude Code, `.claude/settings.json`).
10. Say it once. Code another module can use goes in a shared module in the same change. Never copy it.
11. Branches. `main` is production and `dev` is the integration branch, level with `main` after each release and holding the next one. Each task works on `task/S<NN>-<task>` in its own worktree under `.worktrees/`, and design work on `design/<topic>`, both started from `dev` and merged into it by PR. Only the main session, the one talking with a human, commits on `dev` (plans, closes, status) and merges PRs into it, and it merges only when the human asked it to, for example to run a sprint unattended. `dev` reaches `main` through a release PR that a human merges. A direct commit on `main` is an exception: only the main session makes one, only when the human asks (a hotfix), and it then merges `main` into `dev` the same day. In Claude Code and Cursor, the heracles branch guard hook blocks subagents from committing or merging on `main` or `dev`, and blocks any PR merge by an agent except the main session's into `dev`. In other agents, nothing enforces this rule but you.
