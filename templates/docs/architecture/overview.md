# Architecture

How the parts fit together today, where each runs and where data lives. The detail of each boundary is in [../contracts/README.md](../contracts/README.md); the reasons are in [../decisions/README.md](../decisions/README.md).

Status: empty until `/heracles:design-architecture` runs. It writes:

1. A context view: the people and outside systems around the product.
2. A container view: the services, jobs and stores, and the cloud services they run on.
3. A deploy view: what deploys where, and what triggers it.
4. One sequence per key flow, for the flows the `now` stories depend on.
5. A module table per service, and where each kind of data lives.

Diagrams follow the `heracles:draw-diagram` skill.
