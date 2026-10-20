---
name: to-spec
description: Write a sprint spec (problem, user stories, checkable acceptance criteria, test seams, out of scope) into a given spec.md from what the conversation has already settled. No interview. Called by plan-sprint after its interview, or when asked to turn a discussion into a spec.
argument-hint: "<path to spec.md>"
---

This skill turns the current conversation and your understanding of the code into a spec. Do NOT interview the user; just synthesize what you already know. The caller has already run the interview.

## Process

1. The spec file is `$ARGUMENTS`. The caller has copied the sprint's spec template there; keep its header lines (title, `Status:`, date, type).

2. Explore the repo to understand the current state of the code, if you haven't already. Use the vocabulary of `docs/product/glossary.md` throughout, and respect the ADRs in `docs/decisions/` for the area you're touching.

3. Sketch the seams at which the feature will be tested. Prefer existing seams to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better; the ideal number is one.

   Check with the user that these seams match their expectations.

4. Fill the template's sections, following these rules.

   - The template's sections decide the shape. The goal states the problem and the solution from the user's side: what a person sees or can do, not what the code has.
   - Each story is `As a <role>, I want <capability>, so that <outcome>`, with an id. Stories keep the ids they already have in `docs/product/stories.md` when that file exists (`ACC-03`); otherwise number them `US1`, `US2`.
   - The stories cover every behaviour the sprint goal needs, and nothing outside it.
   - Each acceptance criterion is an observable truth that a test, a command or a screen can check, with an id (`ACC-03.AC1`). No "improve" and no "review".
   - A story with two actions joined by "and", two roles, or a vague capability is too big. Split it along one axis: a research spike first, happy path before edge paths, one interface at a time, smallest data scope first, or simplest rules first.
   - A design sprint (type `design`) replaces stories with "Decisions to make", each with the question, who decides, and the output (ADR, doc section, diagram).
   - Contract changes go under the template's contracts section. The decisions section lists the modules built or changed, their interfaces and schema changes, the agreed test seams, what is tested there, and the prior art for those tests.
   - Out of scope is explicit.

   Do NOT include specific file paths or code snippets. They go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype. Trim it to the decision-rich parts.

5. Return the story ids and acceptance criterion ids you wrote, one per line, so the caller can plan tasks against them.
