---
name: skill-guide
description: Tell the human which skills and commands fit what they want to do, in order, from the heracles plugin and the skills in this repo. Starts nothing. Use for /skill-guide <what you want to do>, or when someone asks "which skill should I use", "how do I do X here" or "what skills do we have".
argument-hint: "<what you want to do>"
---

# Skill guide

You are a map of the available skills, not a worker. You recommend; the human runs.

## 1. Read what is installed

1. List the skills this agent has, the heracles skills and the project's own (for example a `verify-<app>` skill). If you cannot list them, read the `SKILL.md` files in the skill folders your agent uses: `.agents/skills/`, `.claude/skills/`, `.cursor/skills/`, `.opencode/skills/`, `.pi/skills/`, and their user-level versions. Read each file's frontmatter: `name`, `description`, `argument-hint`, and whether it has `disable-model-invocation: true` (the human must type it) or not (the agent may call it, or the human can ask for it in plain words). The "Run it in your agent" section of `AGENTS.md` says how this agent types a skill.
2. Read the Workflow table in `AGENTS.md` and `docs/workflow.md`, if they exist.
3. Read `docs/status.md`, if it exists, so the advice fits where the project is (an open sprint, ADRs waiting on the owners).

Never recommend a skill that is not installed. If none fits, say so, and say which existing skill comes closest. If the repo has no `docs/status.md`, the first step of any path is `/init`.

## 2. Map the goal

The goal is `$ARGUMENTS`. If it is empty, list every installed skill in one table (name, typed or called, one line on when to use it), grouped as entry commands, helpers and maintenance, and stop.

Otherwise match the goal to the skills whose descriptions cover it. When the goal spans several steps (for example "add a payment provider" is plan, build, ship), give the whole path in order. When it is ambiguous between two paths (a quick fix or a planned sprint), give both with one line on when each fits, and ask one question.

## 3. Reply

At most ten lines:

```
Goal: <the goal in one line>
1. /<command> <arguments>  - <what it does for this goal>
2. <helper skill> (called by step 1, or ask for it)  - <why it matters here>
...
Watch out: <a rule from AGENTS.md or a status item that affects this goal, or "nothing">
```

Do not start any of the steps. The human picks.
