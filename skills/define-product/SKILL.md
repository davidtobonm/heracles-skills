---
name: define-product
description: Define or change what the product is. Interviews the owners and writes the product definition, the glossary, the user story map with story ids, and the ordered backlog. Use for /heracles:define-product, at the start of a project, or when a product rule, a user role or the scope of an epic changes.
argument-hint: "[topic to change, or empty for the full definition]"
disable-model-invocation: true
---

# Define the product

Every later skill cites what this one writes: stories get their ids here, rules get their reasons here, and terms get their meaning here.

Arguments can be plain language ("the worker fix", "T1", "the current sprint"). Resolve them against `docs/status.md`, the sprint folders in `docs/sprints/` and `git branch -a`. If more than one thing matches, list the matches and ask which one. If nothing matches, say so and stop.

Work on a design branch, never on `main` or `dev`. If one is not checked out already, create it from `dev` with `git switch dev && git pull --ff-only && git switch -c design/product-<topic>`.

## 1. Read what exists

Read `docs/product/product.md`, `docs/product/glossary.md`, `docs/product/stories.md` and `docs/backlog.md`. If the owners point to an earlier version of the product (another repo or folder, for example added with `claude --add-dir`), send an Explore subagent to read its product docs and README as prior art. Treat it as evidence of what was tried, not as the answer.

## 2. Interview

Call the Skill tool with "heracles:grilling" and with "heracles:domain-modeling". Walk this tree in order; skip a branch the owners already settled in the docs.

1. Users and roles: who uses the product, who pays, who approves, who only receives results.
2. The problem: what a user does today without the product, in their words, with one real example.
3. The promise: what a person can do after one hour, one week and one month.
4. Scope: what is in now, next and later. What is never in scope.
5. Rules: each product rule with its reason. Confirm or drop each rule carried from an earlier version in `product.md`.
6. Success: how the owners will know it works (a number, a user outcome).

When an answer is a decision that passes the ADR test (for example "exports never include deleted records"), call the Skill tool with "heracles:record-decision" with the owner who decided.

## 3. Write

1. `docs/product/product.md`. Replace drafts with confirmed text. Each rule has its reason in one sentence. Remove any "carried from an earlier version" status line once every rule is confirmed or dropped.
2. `docs/product/glossary.md`. Updated during the interview by domain-modeling.
3. `docs/product/stories.md`, from [STORIES-TEMPLATE.md](STORIES-TEMPLATE.md). Group stories by epic, each with a three-letter prefix the owners agree on (for example `ACC` for accounts and access). Each story has an id (`ACC-01`), a priority (`now`, `next`, `later`) and the `As a <role>, I want <capability>, so that <outcome>` sentence. Acceptance criteria are written later, by `plan-sprint`.
4. `docs/backlog.md`. Order the `now` stories into sprint-sized items, with one line of reason each.

## 4. Confirm

Show the owners the changed rules, the new stories and the backlog order as numbered lists. Iterate until they approve. Then run `python3 "${CLAUDE_PLUGIN_ROOT}/scripts/check_docs.py"`.

Commit on the `design/product-<topic>` branch as `docs(product): <what was decided>`, push it, and tell the owners to run `/heracles:ship-change design/product-<topic>`. The PR goes into `dev`. Implementers only see decisions merged there.
