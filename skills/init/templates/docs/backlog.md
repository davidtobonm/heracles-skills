# Backlog

What comes after the active work, first item first. Each item is one line with its reason. Design items run through their design command; delivery items through `/plan-sprint`, which takes the first delivery item unless the owners name another.

Proposed starting order (edit freely):

1. Product definition, with `/define-product`. Write `product/product.md`, the glossary and the story map. Every later decision cites these.
2. Architecture, with `/design-architecture`. Decide runtimes, services, data, stores and deploy, with diagrams. Depends on the product definition.
3. Walking skeleton, with `/plan-sprint`. The thinnest path from input to output through every part, deployed. Proves the architecture end to end before features pile on.
4. Verification harness, with `/plan-sprint`, then `/create-verification-skill`. Seed a demo or test environment with invented data so every later sprint can prove its stories on the running app.
