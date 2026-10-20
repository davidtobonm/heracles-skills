---
paths:
  - "src/api/**"
  - "docs/contracts/**"
---

# Contract rules

An example path rule. /init does not copy it. To use it, copy it to `.claude/rules/contracts.md` and change the globs above to the folders where this repo's boundaries live. Claude Code loads it only when Claude touches a file that matches one of the globs.

- Read the contract for the boundary in `docs/contracts/` before editing.
- Code cites the contract file (`docs/contracts/api.md`), never a sprint.
- A contract changes only in a task whose scope names it. Otherwise stop and report what the contract lacks.
- A breaking change to a public contract (API, event, file format) is `One-way: yes` in the plan and has an ADR.
