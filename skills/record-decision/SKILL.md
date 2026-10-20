---
name: record-decision
description: "Write, update or supersede an Architecture Decision Record (ADR) in docs/decisions/. Use when a decision is hard to reverse, surprising without context and the result of a real trade-off: when a design, planning or build skill settles one, and also when any conversation lands on one unplanned, for example a chat about a bug that ends in choosing a storage format."
---

# Record a decision

An ADR tells a future reader, usually an agent, why the code is the way it is, so it does not "fix" something that was deliberate.

## When to write one

Write one only when all three hold:

1. Hard to reverse. Changing your mind later costs real work.
2. Surprising without context. A reader of the code would ask why.
3. A real trade-off. There were genuine alternatives.

Otherwise put a one-line reason in the sprint log and stop.

When a conversation settles such a decision while no planning or design skill is running, say so and write the ADR right then, unprompted. It stays `proposed` until a human confirms who decided.

## Who decides

The humans decide and you record. A decision about stored data, a public contract (API, event, file format), money or privacy needs a named person in `Decided by`. If nobody has decided yet, write it with `Status: proposed` and add it to "Waiting on the owners" in `docs/status.md`. Never mark your own proposal `accepted`.

## Steps

1. Search `docs/decisions/` for the same topic. If an ADR already covers it, supersede that one (step 6) instead of writing a duplicate.
2. Take the highest number in `docs/decisions/` and add one. The file is `NNNN-<slug>.md`.
3. Fill [TEMPLATE.md](TEMPLATE.md). One paragraph per section is usually enough. `Area` is one of `product`, `architecture`, `contracts`, `process` or `data`. `Options considered` is required when `Reversibility` is `one-way`.
4. Add a row to `docs/decisions/README.md` with number, title, status and area.
5. Link it where it shapes something. The product rule, architecture doc, contract or sprint spec gets one line with the ADR number. Code links it only where a reader would otherwise undo the decision, for example `# See docs/decisions/0007-soft-delete-accounts.md`.
6. To supersede, change the old ADR's status line to `superseded by NNNN` and leave the rest of it as it was. The new ADR says what changed and why.

## Done when

The file exists, its row is in the index, every place it shapes links to it, and `Decided by` names a person or the ADR is `proposed` and listed in `docs/status.md`. The heracles docs check (`python3 "scripts/heracles/check_docs.py"`) passes.
