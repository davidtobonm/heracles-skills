# Choosing the model and effort for a task

A task's weight is how much judgment it needs and what breaks if it goes wrong. The weight picks the model. Model names are Claude Code aliases (`haiku`, `sonnet`, `opus`). In other agents, read them as the small, medium and large model you have; an agent that cannot set a model per subagent ignores these fields. They follow the current model of each tier.

| The task | Model | Effort |
|---|---|---|
| Search, read and summarize, rename, update a doc, apply a change already decided | `haiku` or `sonnet` | `low` |
| Build a bounded piece with a clear contract, and its test | `sonnet` | `medium` |
| Design, review a diff, debug without a known cause, cross modules, touch privacy or money | `opus` | `high` |
| Hard to undo, or other tasks depend on it (the shape of a wave) | the orchestrator, or `opus` | `high`, or `xhigh` when it crosses many folders |

- Raise effort before you raise the model. A bounded but delicate piece (an integration with an outside API, a money figure) is `sonnet` at `high`. `opus` is for missing judgment, not for care.
- When in doubt, split the task instead of raising the model. One `opus` task usually becomes one that decides and several `sonnet` tasks that build what was decided.
- `xhigh` exists only on some models; use it only with `opus`. On Claude Code older than v2.1.292 the Agent tool takes no `effort`; set it in the agent file instead.
- Read-only searches use the `Explore` subagent.
- Keep each subagent well under about 100k tokens. If a report shows a task ran over, split the rest instead of repeating it the same way.
