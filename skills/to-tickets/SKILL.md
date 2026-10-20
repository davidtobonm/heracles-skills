---
name: to-tickets
description: Break a sprint spec into tracer-bullet tasks (vertical slices, each with its blocking edges and a verify command), quiz the humans on the breakdown, and write the approved tasks into a given plan.md. Called by plan-sprint after to-spec, or when asked to break a spec into tasks.
argument-hint: "<path to spec.md> <path to plan.md>"
---

# To Tickets

Break a spec into **tasks**: tracer-bullet vertical slices, each declaring the tasks that **block** it.

## Process

### 1. Gather context

The first argument is the spec, the second the plan file. The caller has copied the sprint's plan template into the plan file; its task block is the shape every task takes, including any extra fields it has. Read the spec in full.

### 2. Explore the codebase (optional)

If you have not already explored the code, do so. Task titles and descriptions use the vocabulary of `docs/product/glossary.md` and respect the ADRs in the area.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Draft vertical slices

Break the work into **tracer bullet** tasks.

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer it needs (storage, logic, API, UI, tests): vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window
- Any prefactoring is done first

</vertical-slice-rules>

Give each task its **blocking edges**: the other tasks that must complete before it can start. A task with no blockers can start immediately.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change (rename a column, retype a shared symbol) whose **blast radius** fans across the whole codebase, so a single edit breaks many call sites at once and no vertical slice can land green. Sequence it as **expand–contract**. First expand: add the new form beside the old so nothing breaks. Then migrate the call sites in batches sized by blast radius (per package, per directory), each batch its own task blocked by the expand, keeping CI green batch to batch. Finally contract: delete the old form once no caller remains, in a task blocked by every migrate batch.

Rules for this repo:

- If the `Commands` section of `AGENTS.md` is empty, T1 fills it, and every other build task is blocked by T1.
- If the sprint changes a contract in `docs/contracts/`, the first build task writes the contract change and every task that uses it is blocked by that task.
- A task that settles a decision has a `Decides:` line instead of `Stories:` and `Seams:`. One task decides, and the next ones build what it decided; never mix the two.
- Every task has a `Verify` command with its expected result, and `Seams` naming the public interfaces its tests go through.
- Every acceptance criterion in the spec is covered by at least one task.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each task, show:

- **Title**: short descriptive name
- **Blocked by**: which other tasks (if any) must complete first
- **What it delivers**: the end-to-end behaviour this task makes work

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct: does each task only depend on tasks that genuinely gate it?
- Should any tasks be merged or split further?

Iterate until the user approves the breakdown.

### 5. Write the tasks

Write the approved tasks into the plan file, numbered `T1`, `T2` in dependency order (blockers first), each in the template's task block. Fill every field the block has; leave a field the caller fills later (such as `Wave` or `Model`) as the template shows it.

Avoid specific file paths or code snippets except in `Read first`, `Scope` and `Verify`, where they are the point. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can, inline it and note that it came from a prototype.

Return the task ids with their blockers, one per line.
