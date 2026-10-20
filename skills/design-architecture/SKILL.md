---
name: design-architecture
description: Design or change the system architecture (runtimes, services, jobs, stores, data model, cloud services, deploy) and the module shape inside each service. Settles each choice with the owners, runs competing candidates for one-way choices, records decisions, and writes the architecture overview, the LikeC4 model with cloud and vendor icons and the contracts index. Use for /heracles:design-architecture, or before adding a service, a store, a cloud dependency or a new runtime.
argument-hint: "[area to revisit, or empty for the full design]"
disable-model-invocation: true
---

# Design the architecture

The architecture serves the product, so it comes after the product definition. Design the shape the current team can run and change, not the shape a much bigger team would draw.

Arguments can be plain language ("the worker fix", "T1", "the current sprint"). Resolve them against `docs/status.md`, the sprint folders in `docs/sprints/` and `git branch -a`. If more than one thing matches, list the matches and ask which one. If nothing matches, say so and stop.

Work on a design branch, never on `main` or `dev`. If one is not checked out already, create it from `dev` with `git switch dev && git pull --ff-only && git switch -c design/architecture-<topic>`.

## 1. Ground

1. Read `docs/product/product.md`, the glossary, `docs/architecture/`, `docs/contracts/README.md` and the ADRs with `Area: architecture` or `Area: data`.
2. If the owners point to an earlier version of the system (another repo, for example added with `claude --add-dir`), send an Explore subagent to its architecture docs, deploy workflows and infrastructure code for prior art: what ran where, what it cost to operate, what broke.
3. Write down the quality attributes that decide trade-offs, ranked with the owners. Typical ones: monthly cost, operations effort for the team, latency of the key requests, duration of the longest job, isolation between users or tenants, vendor lock-in.

## 2. Settle the system shape

Call the Skill tool with "heracles:grilling" and walk this frontier with the owners, one round at a time:

1. Languages and runtimes for each part (backend, web app, workers, CLI).
2. Services and jobs: what is a request, what is a long job, what is scheduled, and where each runs.
3. Data: the main entities from the glossary, which part owns each, how it is stored, and how its schema changes (migrations).
4. Stores, mapped from the data decisions to concrete services.
5. Identity and access: sign-in, sessions, roles, API keys.
6. Outside systems: payment, email, model providers, third-party APIs.
7. Build, test, deploy and environments, including the seeded demo or test environment that verification will drive.

For each one-way choice (a runtime, a store, a cloud provider, a public protocol, a data model), call the Skill tool with "heracles:arena" with two whole-system candidates and a rubric built from the ranked quality attributes. The owners pick. Then call "heracles:record-decision" with `Area: architecture` (or `data`) and who decided.

## 3. Shape each service

For each service or job, call the Skill tool with "heracles:codebase-design" to sketch its modules: the public interface first (what a caller writes), then types and signatures, with deep modules that hide complexity behind small interfaces. Put the module map in `docs/architecture/overview.md`, one short table per service. Leave function bodies to the sprints.

## 4. Write

1. `docs/architecture/model.c4`: the LikeC4 model with a context view, a container view and a deploy view, with cloud and vendor icons. Call the Skill tool with "heracles:draw-diagram" and run `npx likec4 validate docs/architecture`.
2. `docs/architecture/overview.md`: one paragraph per view with its exported PNG, one Mermaid sequence per key flow (the few flows the `now` stories depend on), the module tables, and where each kind of data lives.
3. `docs/contracts/README.md`: one row per boundary the design creates. Each contract file is written by the first sprint that builds that boundary.
4. `AGENTS.md` Commands: fill in install, test, lint, typecheck, local run and smoke check once they exist. Ask the owners before editing `AGENTS.md`.

## 5. Close the loop

Show the owners the views and the ADRs, iterate until they approve, then add the build work to `docs/backlog.md` (usually a walking skeleton first: the thinnest path from input to output through every part, deployed).

Run `python3 "${CLAUDE_PLUGIN_ROOT}/scripts/check_docs.py"`. Commit on the `design/architecture-<topic>` branch as `docs(architecture): <what was decided>`, push it, and tell the owners to run `/heracles:ship-change design/architecture-<topic>`. The PR goes into `dev`. Implementers only see decisions merged there.
