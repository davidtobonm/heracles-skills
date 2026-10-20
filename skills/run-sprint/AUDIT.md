# Audit checklist for a task

Apply every line; write the failures as numbered findings.

1. The whole diff is read, file by file. Nothing in it belongs to another task.
2. You ran the task's `Verify` command and the checks yourself. The implementer's word is not evidence.
3. Each acceptance criterion the task covers has evidence that shows it, and the evidence comes from a seeded demo or test environment, never from real user data.
4. Contract names, paths, payload shapes, status codes and environment variables match `docs/contracts/` exactly.
5. Simple: no dead code, no options nobody asked for, no class where a function does, no single-use abstraction, no new dependency without a reason, no logic copied from another module.
6. Privacy: no secret or real person's data in code, tests, logs or commits. Every route that serves user data checks access.
7. Nothing silent: every skip has a reason and a count, every list says when it was cut, no `except` or `catch` swallows an error.
8. Determinism where the spec or an ADR requires it: the same input gives the same output.
9. The rules in `AGENTS.md` hold, including any rules on languages and user-facing text.
10. Tests run without network or model, and test both what must happen and what must not (an expired session is rejected, a duplicate signup is refused).
