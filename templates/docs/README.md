# Docs

What each document holds and when to read it. Living docs say how things are today and are edited in place. Sprint folders are history and are never edited after they close.

| What | Where | Read it |
|---|---|---|
| What the product is, for whom, and its rules, each with its reason | [product/product.md](product/product.md) | before a new feature |
| The words we use and their code names | [product/glossary.md](product/glossary.md) | when a term is unclear |
| Every user-facing capability, by epic, with its story id | [product/stories.md](product/stories.md) | when you plan or build a story |
| How the parts fit together, where they run and where data lives, with diagrams | [architecture/overview.md](architecture/overview.md) | before a change that crosses parts |
| What crosses a boundary (API, events, file formats, storage layout) | [contracts/README.md](contracts/README.md) | when you touch that boundary |
| Why things are the way they are | [decisions/README.md](decisions/README.md) | before changing code that cites a decision |
| What each sprint planned, decided and delivered | [sprints/README.md](sprints/README.md) | when the question is about the past |
| What is active and what waits on the owners | [status.md](status.md) | when you pick up work |
| What comes next, in order | [backlog.md](backlog.md) | when you plan a sprint |
| How we work: the two tracks and the commands | [workflow.md](workflow.md) | when you join the project |

Rules for writing docs:

- Say each thing once. What the code already says (a list, a schema, what a function does) is not repeated; name the file or symbol instead.
- A rule carries its reason in one sentence. Without the reason, nobody dares remove the rule later.
- A decision is written twice. The rule that stays goes in the living doc. The long why, with the rejected options, goes in an ADR.
- Diagrams are text (Mermaid or LikeC4) next to the sentence they support. See the `heracles:draw-diagram` skill.
- The heracles docs check (`scripts/check_docs.py` in the plugin) checks links, indexes and line caps. Its Stop hook runs it when files changed.
