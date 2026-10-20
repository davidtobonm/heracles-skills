---
name: skill-guide
description: Tell the human which skills and commands fit what they want to do, in order, from the heracles plugin and the skills in this repo. Starts nothing. Use for /heracles:skill-guide <what you want to do>, or when someone asks "which skill should I use", "how do I do X here" or "what skills do we have".
argument-hint: "<what you want to do>"
---

# Skill guide

You are a map of the available skills, not a worker. You recommend; the human runs.

## 1. Read what is installed

1. List `${CLAUDE_PLUGIN_ROOT}/skills/*/SKILL.md` (the heracles skills) and the project's own `.claude/skills/*/SKILL.md` (for example a `verify-<app>` skill). Read each file's frontmatter: `name`, `description`, `argument-hint`, and whether it has `disable-model-invocation: true` (the human must type it) or not (Claude calls it, or the human can ask for it in plain words). A heracles skill is typed as `/heracles:<name>`; a project skill as `/<name>`.
2. Read the Workflow table in `AGENTS.md` and `docs/workflow.md`, if they exist.
3. Read `docs/status.md`, if it exists, so the advice fits where the project is (an open sprint, ADRs waiting on the owners).

Never recommend a skill that is not installed. If none fits, say so, and say which existing skill comes closest. If the repo has no `docs/status.md`, the first step of any path is `/heracles:init`.

## 2. Map the goal

The goal is `$ARGUMENTS`. If it is empty, list every installed skill in one table (name, typed or called, one line on when to use it), grouped as entry commands, helpers and maintenance, and stop.

Otherwise match the goal to the skills whose descriptions cover it. When the goal spans several steps (for example "add a payment provider" is plan, build, ship), give the whole path in order. When it is ambiguous between two paths (a quick fix or a planned sprint), give both with one line on when each fits, and ask one question.

## 3. Reply

At most ten lines:

```
Goal: <the goal in one line>
1. /heracles:<command> <arguments>  - <what it does for this goal>
2. <helper skill> (called by step 1, or ask for it)  - <why it matters here>
...
Watch out: <a rule from AGENTS.md or a status item that affects this goal, or "nothing">
```

Do not start any of the steps. The human picks.
