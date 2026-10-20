#!/usr/bin/env bash
# PreToolUse hook on Bash. Guards the two long-lived branches.
#   main: production. A human merges the release PR from dev. No PR merge into main from Claude.
#         The main session may commit on main only as an exception the human asked for (a hotfix);
#         subagents never do.
#   dev:  integration. Only the main session (the one talking with a human) commits on it or
#         merges task and design PRs into it. Subagents never do.
# The hook does nothing in a repo with no dev branch, so the plugin is safe to enable everywhere.
# Claude Code puts `agent_id` in the hook input only when a subagent makes the call.
# Exit 2 blocks the call and shows stderr to Claude.
input=$(cat)
field() { printf '%s' "$input" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command','') if '$1'=='command' else d.get('$1') or '')"; }
cmd=$(field command); dir=$(field cwd); agent=$(field agent_id)
[ -n "$dir" ] || dir=.

block() { echo "Blocked: $1" >&2; exit 2; }

# Only repos that use the dev and main model are guarded. Elsewhere the hook does nothing.
git -C "$dir" rev-parse -q --verify refs/heads/dev >/dev/null 2>&1 \
  || git -C "$dir" rev-parse -q --verify refs/remotes/origin/dev >/dev/null 2>&1 \
  || exit 0

# Merging a pull request.
if printf '%s' "$cmd" | grep -Eq '(^|[;&|[:space:]])gh[[:space:]]+pr[[:space:]]+merge([[:space:]]|$)'; then
  [ -z "$agent" ] || block "subagents never merge pull requests. Report to the orchestrator."
  pr=$(printf '%s' "$cmd" | sed -nE 's/.*gh[[:space:]]+pr[[:space:]]+merge[[:space:]]+([^-[:space:]][^[:space:]]*).*/\1/p')
  base=$(cd "$dir" && gh pr view $pr --json baseRefName -q .baseRefName 2>/dev/null)
  [ "$base" = "dev" ] || block "only PRs into dev may be merged from Claude (this one targets '${base:-unknown}'). A human merges the release PR into main."
  exit 0
fi

# Committing or merging locally.
printf '%s' "$cmd" | grep -Eq '(^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+(commit|merge)([[:space:]]|$)' || exit 0
lead=$(printf '%s' "$cmd" | sed -nE 's/^[[:space:]]*cd[[:space:]]+([^;&|[:space:]]+)[[:space:]]*&&.*/\1/p')
gitc=$(printf '%s' "$cmd" | sed -nE 's/.*git[[:space:]]+-C[[:space:]]+([^[:space:]]+)[[:space:]]+(commit|merge).*/\1/p')
[ -n "$lead" ] && dir=$(cd "$dir" 2>/dev/null && cd "$lead" 2>/dev/null && pwd)
[ -n "$gitc" ] && dir=$(cd "$dir" 2>/dev/null && cd "$gitc" 2>/dev/null && pwd)
branch=$(git -C "$dir" branch --show-current 2>/dev/null)

case "$branch" in
  main|master) [ -z "$agent" ] || block "subagents never commit or merge on $branch. Use your task branch." ;;
  dev) [ -z "$agent" ] || block "subagents do not commit or merge on dev. Use your task branch (task/S<NN>-<task>) in your worktree." ;;
esac
exit 0
