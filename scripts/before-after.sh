#!/usr/bin/env bash
# Take Playwright screenshots of the same UI states before and after a change.
# Usage: bash "${CLAUDE_PLUGIN_ROOT}/scripts/before-after.sh" <base ref> <playwright spec> <task id>
#   Run it from inside the project checkout (or task worktree).
#   base ref: what "before" means, origin/dev for a task branch, origin/main for a release.
#   spec: a Playwright test that calls page.screenshot({ path: `${process.env.SHOT_DIR}/<state>.png` })
#         for each state an acceptance criterion names, in a seeded demo or test environment.
# Output: .artifacts/<task>/before/*.png and .artifacts/<task>/after/*.png (gitignored).
# INSTALL_CMD (default "npm ci") installs dependencies in the temporary "before" checkout.
set -euo pipefail
base=${1:?base ref}; spec=${2:?playwright spec}; task=${3:?task id}
root=$(git rev-parse --show-toplevel)
out="$root/.artifacts/$task"
# Outside the repo: a checkout inside it would put a second Playwright in the "after" run.
before="$(mktemp -d)/before-$task"
mkdir -p "$out/before" "$out/after"

git worktree add --detach "$before" "$base" >/dev/null
trap 'git worktree remove --force "$before" >/dev/null 2>&1 || true; git worktree prune' EXIT
mkdir -p "$before/$(dirname "$spec")"
cp "$root/$spec" "$before/$spec"   # the spec may be new in this change

(cd "$before" && ${INSTALL_CMD:-npm ci} >/dev/null && SHOT_DIR="$out/before" npx playwright test "$spec") \
  || echo "before: some steps failed, which is expected when the feature is new" >&2
(cd "$root" && SHOT_DIR="$out/after" npx playwright test "$spec")

echo "Screenshots in $out/before and $out/after"
