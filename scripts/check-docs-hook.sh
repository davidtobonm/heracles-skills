#!/usr/bin/env bash
# Stop hook: when the working tree changed, run the docs check and hand failures back to Claude.
# It does nothing in a project without docs/sprints/ (one that never ran /heracles:init).
# It lets the stop through when Claude is already continuing because of this hook, and when
# Claude's last message ends with a question for the humans (an interview round is waiting).
here=$(cd "$(dirname "$0")" && pwd)
input=$(cat)
case "$input" in *'"stop_hook_active":true'* | *'"stop_hook_active": true'*) exit 0 ;; esac
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
[ -d docs/sprints ] || exit 0
[ -n "$(git status --porcelain 2>/dev/null)" ] || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

asking=$(printf '%s' "$input" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
except ValueError:
    sys.exit()
text = data.get("last_assistant_message") or ""
if not text and data.get("transcript_path"):
    try:
        for line in open(data["transcript_path"], encoding="utf-8"):
            entry = json.loads(line)
            if entry.get("type") == "assistant":
                parts = entry.get("message", {}).get("content", [])
                said = "".join(p.get("text", "") for p in parts if isinstance(p, dict))
                text = said or text
    except (OSError, ValueError):
        pass
print("yes" if text.rstrip().rstrip("*_`").endswith("?") else "no")
' 2>/dev/null)
[ "$asking" = "yes" ] && exit 0

if out=$(python3 "$here/check_docs.py" 2>&1); then
  exit 0
fi
{
  echo "The docs check failed (heracles scripts/check_docs.py). Fix each line before you finish:"
  printf '%s\n' "$out" | head -30
} >&2
exit 2
