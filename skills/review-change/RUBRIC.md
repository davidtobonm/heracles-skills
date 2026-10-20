# Review rubric

Use the lenses that apply. Not every lens fits every change. A finding names the file and hunk, and for a bug it traces the call path that triggers it.

## Correctness

- Edge cases: empty input, missing fields, boundary values, duplicates, time zones, currency.
- Errors: caught and handled, or propagated. No `except` or `catch` that swallows an error.
- Every skip, drop or truncation is counted and logged with its reason.
- Idempotency: what happens if this runs twice, or if a previous run crashed halfway?
- Concurrency: if two runs can touch the same state, is access serialized by structure (one job per resource, locks, ownership), not by convention?

## Root cause

- Does the change fix the problem or hide a symptom (a guard that masks a broken invariant, a retry that hides a broken contract, a cast that silences a type error)?
- Would a type, a lint rule, a test or a runtime check make the wrong thing impossible instead of a comment asking people not to do it?

## Structure

- Validation happens once at the boundary where data enters, then the inside trusts it.
- Simple first. A function before a class, a dict before a model, one file before two. No options nobody asked for, no single-use abstraction.
- Code another module needs is shared, not copied.
- If the requirement had been known from the start, would the code look like this?
- A new API that keeps the old one alive with no outside callers is a finding. Migrate the callers and delete the old path.

## Proof

- Tests check behavior through public interfaces, both what must happen and what must not (an expired session is rejected).
- Tests run without network and without a model. Fakes sit at the HTTP transport or SDK client, never inside our own code.
- Every acceptance criterion the change claims has evidence: a test, a command output, or a screenshot from a seeded demo or test environment.

## Privacy and spending

- No secret, token or real person's data in code, tests, fixtures, logs, commits, prompts or screenshots.
- No call to a paid API with real credentials from code that runs in tests or from an agent.

## Contracts and data (contracts and data reviewer)

- Code cites the contract file in `docs/contracts/`, never a sprint. Names, paths, payload shapes, status codes and error formats match it exactly.
- A change that breaks callers of a public contract (API, event, file format, CLI flags) cites an accepted ADR, updates the contract file, and is marked `One-way: yes` in the plan.
- A schema change comes with a migration, and a test that data written before it still loads. A migration that cannot be undone is marked `One-way: yes`.
- Writes to stored data are validated at the boundary, and nothing is dropped without a count and a reason.
- One user's or tenant's data is never returned to another. Every route that reads stored data checks access.
- Where an ADR requires determinism, the same input gives the same stored result.

## Smell baseline (judgment calls, never hard violations)

Mysterious name, duplicated code, feature envy, data clumps, primitive obsession (a string standing in for a domain concept), repeated switches on the same type, shotgun surgery, speculative generality, middle man. A documented repo rule always overrides the baseline.

Credits: the lenses follow pstack's interrogate rubric (Lauren Tan, MIT) and the smell baseline follows mattpocock/skills code-review (Matt Pocock, MIT), both rewritten for this plugin.
