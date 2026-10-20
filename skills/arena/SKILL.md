---
name: arena
description: "Spawn N parallel candidates at the same task, pick a base, graft the strongest parts of the losers into it. Called by design-architecture for one-way decisions, or when the user types /arena or says 'arena this'."
---

# Arena

Open a todolist with one entry per phase (Frame, Fan out, Cross-judge, Pick, Graft, Verify) before launching anything.

## Phase A: Frame

Every candidate gets the same prompt, so the prompt is the contract.

1. State the artifact each candidate is producing.
2. Derive the rubric, 3-6 concrete gradeable criteria for what success looks like on *this* task. It is the picker's tool in Phase D. Candidates only see the task. When the caller passes a rubric (for example `design-architecture` passes one built from its ranked quality attributes), use it.
3. Pick the runners. Default to two runners, one with `model: opus` and one with `model: sonnet`, both at `effort: high`, so the candidates differ by more than chance. Spawn more runners when the arena covers multiple design directions, and give each a different starting direction in one line. Use the same model N times when the work is generation-bound rather than judgment-sensitive.
4. Give each candidate its own output location: `.artifacts/arena-<slug>/candidate-<n>/` for documents (gitignored, inside the project), or a git worktree (`isolation: worktree`) when candidates write code. Candidates never write to the same file. Candidates use invented data only.

## Phase B: Fan out

Spawn all N subagents at once, in the background if your agent supports it, each with the task, the path to the shared grounding, its own output path, and instructions to produce the artifact and a short rationale naming the alternatives it considered and what it rejected.

If a candidate produces no output, proceed with N-1 and note the dropout.

## Phase C: Cross-judge

After all Phase B candidates complete, spawn one judge as the `reviewer` subagent (read-only, no MCP tools), `model: opus` and `effort: high`, and put the rubric in its prompt. It sees the rubric and the candidates by path label (not by model), scores each criterion, and recommends a base with rationale. It runs in parallel with your reading in Phase D. Don't spawn it while candidates are still writing.

## Phase D: Pick a base

Read every candidate end to end before picking. Score each against the rubric criterion by criterion, not on holistic feel, and compare with the cross-judge. Agreement on the base confirms the pick. Disagreement means one of you is biased or the rubric was ambiguous. Read both rationales before deciding.

Pick the base a future maintainer can extend most easily without breaking invariants. When two feel tied, prefer the cleaner boundary or the smaller API.

When the artifact is a decision the humans own (a data model, a runtime, a storage engine, a public contract), do not pick alone. Show the user the candidates side by side, your scores, the judge's scores and your recommended base, and let the user pick. Record who picked.

## Phase E: Graft

Walk each losing candidate once more for what is worth porting into the base, usually one or two things per candidate, not most of it. Fold each graft in by hand so the result stays coherent under one mental model. Don't paste mechanically.

If the candidates converge on one shape, that is strong agreement. Note it and ship the consensus shape. No graft is needed. If they wildly diverge, Phase A was under-specified. Reframe and re-run rather than averaging the divergence.

## Phase F: Verify

Verify the synthesized artifact like any other output: run it, render it, or check it against the rubric again. If verification finds a problem the arena missed, either Phase A was wrong (re-frame and re-run) or a candidate caught it and you missed the graft (go back to Phase E). Don't paper over it.

## Outputs

One synthesized artifact, with a short synthesis note alongside naming the base and why, the cross-judge's verdict, each graft with its source candidate, what was rejected and why, any convergence or dropouts, who picked the base, and the verification result.
