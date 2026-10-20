# Glossary format

The glossary lives at `docs/product/glossary.md`.

## Structure

```md
# <Project> glossary

{One or two sentences on what the product is.}

## Language

**Customer**:
A person or company that pays for at least one subscription.
_Code_: `Customer`
_Avoid_: client, buyer

**Account**:
A login. One customer can have many accounts.
_UI_: profile · _Code_: `Account`
_Avoid_: user (it means both a customer and an account)

**Subscription**:
A customer's paid plan for a period, renewed or cancelled as a whole.
_Code_: `Subscription`
_Avoid_: membership, license
```

## Rules

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others under `_Avoid_`.
- **Keep definitions tight.** One or two sentences max. Define what it IS, not what it does.
- **Only include terms specific to this project's context.** General programming concepts (timeouts, error types, utility patterns) don't belong even if the project uses them extensively. Before adding a term, ask: is this a concept unique to this context, or a general programming concept? Only the former belongs.
- **Group terms under subheadings** when natural clusters emerge (for example Billing, Content, People and permissions).
- **Names in every layer.** `_Code_` gives the identifier when it differs from the term. `_UI_` gives the label the interface shows when it differs from the term, so the UI copy and the code name never drift apart. Leave either out when it matches the term.
