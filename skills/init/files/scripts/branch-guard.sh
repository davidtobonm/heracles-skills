#!/usr/bin/env bash
# Shell-command hook that guards the two long-lived branches.
#   main: production. A human merges the release PR from dev. No agent merges a PR into main.
#         The main session may commit on main only as an exception the human asked for (a hotfix).
#   dev:  integration. Only the main session (the one talking with a human) commits on it or
#         merges task and design PRs into it. Subagents never do.
# It does nothing in a repo with no dev branch.
#
# Two input formats:
#   Claude Code PreToolUse: {"tool_input": {"command": ...}, "cwd": ..., "agent_id": ... only for subagents}.
#     Blocking is exit 2 with the reason on stderr.
#   Cursor beforeShellExecution: {"hook_event_name": "beforeShellExecution", "command": ..., "cwd": ...}.
#     Cursor does not say whether a subagent runs the command, so in Cursor every commit or merge
#     on main is blocked (make a hotfix commit from your own terminal). The answer is JSON on stdout.
input=$(cat)
read_field() {
  printf '%s' "$input" | python3 -c '
import json, sys
d = json.load(sys.stdin)
key = sys.argv[1]
if key == "command":
    print(d.get("tool_input", {}).get("command") or d.get("command") or "")
else:
    print(d.get(key) or "")
' "$1" 2>/dev/null
}
cmd=$(read_field command)
dir=$(read_field cwd)
agent=$(read_field agent_id)
event=$(read_field hook_event_name)
[ -n "$dir" ] || dir=.
cursor=no
[ "$event" = "beforeShellExecution" ] && cursor=yes

allow() {
  [ "$cursor" = yes ] && printf '{"permission":"allow"}\n'
  exit 0
}
block() {
  if [ "$cursor" = yes ]; then
    python3 -c 'import json,sys; m="Blocked: "+sys.argv[1]; print(json.dumps({"permission":"deny","agentMessage":m,"userMessage":m}))' "$1"
    exit 0
  fi
  echo "Blocked: $1" >&2
  exit 2
}

# Only repos that use the dev and main model are guarded.
git -C "$dir" rev-parse -q --verify refs/heads/dev >/dev/null 2>&1 \
  || git -C "$dir" rev-parse -q --verify refs/remotes/origin/dev >/dev/null 2>&1 \
  || allow

# Merging a pull request.
if printf '%s' "$cmd" | grep -Eq '(^|[;&|[:space:]])gh[[:space:]]+pr[[:space:]]+merge([[:space:]]|$)'; then
  [ -z "$agent" ] || block "subagents never merge pull requests. Report to the orchestrator."
  pr=$(printf '%s' "$cmd" | sed -nE 's/.*gh[[:space:]]+pr[[:space:]]+merge[[:space:]]+([^-[:space:]][^[:space:]]*).*/\1/p')
  base=$(cd "$dir" && gh pr view $pr --json baseRefName -q .baseRefName 2>/dev/null)
  [ "$base" = "dev" ] || block "only PRs into dev may be merged by an agent (this one targets '${base:-unknown}'). A human merges the release PR into main."
  allow
fi

# Committing or merging locally.
printf '%s' "$cmd" | grep -Eq '(^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+(commit|merge)([[:space:]]|$)' || allow
lead=$(printf '%s' "$cmd" | sed -nE 's/^[[:space:]]*cd[[:space:]]+([^;&|[:space:]]+)[[:space:]]*&&.*/\1/p')
gitc=$(printf '%s' "$cmd" | sed -nE 's/.*git[[:space:]]+-C[[:space:]]+([^[:space:]]+)[[:space:]]+(commit|merge).*/\1/p')
[ -n "$lead" ] && dir=$(cd "$dir" 2>/dev/null && cd "$lead" 2>/dev/null && pwd)
[ -n "$gitc" ] && dir=$(cd "$dir" 2>/dev/null && cd "$gitc" 2>/dev/null && pwd)
branch=$(git -C "$dir" branch --show-current 2>/dev/null)

case "$branch" in
  main|master)
    [ "$cursor" = yes ] && block "agents in Cursor do not commit or merge on $branch. Work goes to dev; make a hotfix commit from your own terminal."
    [ -z "$agent" ] || block "subagents never commit or merge on $branch. Use your task branch." ;;
  dev)
    [ -z "$agent" ] || block "subagents do not commit or merge on dev. Use your task branch (task/S<NN>-<task>) in your worktree." ;;
esac
allow
