---
name: draw-diagram
description: Create or update a diagram in the repo docs (system architecture, data flow, domain model, storage schema) as diffable text that renders on GitHub, and check that it parses. Use when a design skill settles a structure, when a change makes a diagram stale, or when asked to draw or update a diagram.
---

# Draw a diagram

Diagrams are text in the repo, reviewed in PRs like code. A picture that cannot be diffed goes stale. A picture with a source of truth in code is generated, never drawn by hand.

## 1. Pick the tool by what the diagram shows

| Shows | Tool | Source lives in |
|---|---|---|
| System architecture (containers, cloud services, vendors, tools) | LikeC4, with an icon on every service, store and vendor | `docs/architecture/model.c4` (create it from the example in TOOLS.md if it does not exist), with exported PNGs linked from `docs/architecture/overview.md` |
| Data flow, pipelines, request sequences | Mermaid `flowchart` or `sequenceDiagram` | A fenced block in the doc that explains it |
| Domain model (entity types and their relations) | Mermaid `classDiagram`, generated | Generated from the typed models by a script in the repo once those models exist |
| Storage schema (tables, collections, files) | Mermaid `erDiagram`, generated when a schema file exists | Generated from the schema (for SQL use tbls), else hand-written in `docs/architecture/storage.md` |
| A polished one-off picture for a pitch or a talk | draw.io, exported from LikeC4 (`likec4 export drawio`) and edited by hand | `docs/pictures/`, marked as not maintained |

Details and examples for each tool are in [TOOLS.md](TOOLS.md).

## 2. Draw

1. Read the doc the diagram belongs to and the decision records it reflects. Draw only what they state. No invented services, numbers or flows.
2. One diagram answers one question. Put the answer in the doc's sentence above it ("Only the worker writes to the files bucket"), then draw the boxes that carry it.
3. Use the glossary's terms for every label.
4. Keep it under about 15 boxes. Split into two diagrams, or one per level (context, then containers), before it gets dense.
5. For a generated diagram, change the source of truth and rerun the generator. Never edit the generated block.
6. In an architecture diagram, every element that is a cloud service, a store, a vendor or a tool carries its real icon: `gcp:`, `aws:` or `azure:` for cloud services (`gcp:cloud-run`, `gcp:cloud-sql`), `tech:` for tools and vendors (`tech:react`, `tech:stripe`, `tech:github`). A vendor with no built-in icon gets its logo as an SVG in `docs/architecture/icons/`, used as `icon ./icons/<name>.svg`. Only people and abstract groupings go without an icon.

## 3. Check

Run the checks in TOOLS.md for the tool you used: the Mermaid parse check for Mermaid, `likec4 validate` for LikeC4. Fix every error. Then open the doc's rendered Markdown (or the exported PNG) once and confirm the labels fit and nothing overlaps.

## Done when

The diagram parses, sits next to the sentence it supports, uses glossary terms, and every element traces to a decision record or to code. In architecture diagrams, every service, store, vendor and tool shows its icon.
