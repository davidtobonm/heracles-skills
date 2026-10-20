# Implementer brief

Size the brief to the task. Paste what the implementer needs; it does not see this conversation.

```
Sprint <S<NN>>, task <T<n>>: <title>.

Goal: <the task's acceptance criteria, quoted from spec.md with their ids>.
Scope: <the task's Scope line>. Write only there. In shared files, add your block without rewriting others'.
Read first: <the task's Read first line>.
Rules: <every .claude/rules/*.md whose paths match the scope, by path, or "none">. Read them before editing.
Seams: <the task's Seams line>.
Verify: <the task's Verify line>, then the full checks in AGENTS.md.

Follow the preloaded build-task skill for <S<NN>> <T<n>>.

Forbidden: editing plan.md, log.md or docs/status.md; changing a contract or an ADR;
calling paid APIs with real credentials; pushing; opening a PR.
If the task needs anything outside its scope or contract, stop and say so in your report.

Reply with the report format from build-task, and nothing else.
```
