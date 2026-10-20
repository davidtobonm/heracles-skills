# Evidence

Evidence lets a human check a claim in one minute without trusting the agent. Pick the lightest kind that proves the criterion.

| What changed | Evidence |
|---|---|
| Pure logic | The test that covers the criterion, and its passing output |
| HTTP API, CLI or other public interface | The request or command and the response, from the running app, in a seeded demo or test environment |
| Stored data or a migration | Counts before and after, the invariant queries and their results, and the same result on a second run from the same input |
| UI | Playwright screenshots before and after, in a seeded demo or test environment, at each state the criterion names (see below) |
| Bug fix | The failing run before the fix and the passing run after it |
| Performance | One number with its unit, before and after, and how it was measured |

## Before and after screenshots

Playwright runs from the shell, so no agent needs a browser MCP tool.

1. Write or extend a Playwright spec next to the web tests that opens the app in a seeded demo or test environment, walks to each state the criterion names, and calls ``page.screenshot({ path: `${process.env.SHOT_DIR}/<state>.png` })``. Use the same state names before and after.
2. Run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/before-after.sh" <base> <spec> <task>`. The base is `origin/dev` for a task and `origin/main` for a release. It checks out the base in a temporary worktree, takes the "before" shots there, then the "after" shots in the current tree.
3. Look at every pair yourself before you mark the criterion `passed`. A blank page, an error overlay or a login screen is a failure, not evidence.
4. List the pairs in `evidence/<task>.md` as a table with columns `State | Before | After`, using the file names. `ship-change` copies that table into the PR, and a human drags the images in.

## Where it goes

- Text evidence (commands, outputs, queries) goes in `docs/sprints/<sprint>/evidence/<task>.md`, short.
- Images and videos go in `.artifacts/<task>/`, which is gitignored. Attach them to the PR through the GitHub web UI. Never upload them to a public host.

## Rules

- Only invented demo data, never real user data. No real email address, real invoice or real person's name, not even in a screenshot.
- Exercise the real path a user takes, not a test-only endpoint or an internal setter.
- Check side effects too: rows written, files created, messages queued.
- Record each criterion as `passed`, `failed` or `untested`. An untested criterion says why.
