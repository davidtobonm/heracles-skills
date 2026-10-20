#!/usr/bin/env bash
# Set up the current git repo for the heracles workflow. Run by the init skill.
# Never overwrites a file that already exists; it lists the ones it kept.
#
# Always added (every agent reads these):
#   AGENTS.md, docs/**, scripts/heracles/* (checks and hooks), .heracles/roles/* (subagent prompts),
#   lines appended to .gitignore
# Added per agent, with flags (at least one, or --all):
#   --claude    CLAUDE.md (@AGENTS.md), .claude/settings.json (deny rules, branch guard, docs check)
#   --cursor    .cursor/hooks.json (branch guard)
#   --gemini    GEMINI.md (@AGENTS.md)
#   --opencode  .opencode/agents/<role>.md (the roles as OpenCode subagents)
#   Codex, Pi and most other agents need nothing beyond AGENTS.md and the skills.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
templates="$here/templates"
files="$here/files"
target=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "Not inside a git repo. Run git init first." >&2; exit 1; }

claude=no; cursor=no; gemini=no; opencode=no
[ $# -gt 0 ] || { echo "usage: init.sh --all | [--claude] [--cursor] [--gemini] [--opencode]" >&2; exit 1; }
for arg in "$@"; do
  case "$arg" in
    --all) claude=yes; cursor=yes; gemini=yes; opencode=yes ;;
    --claude) claude=yes ;;
    --cursor) cursor=yes ;;
    --gemini) gemini=yes ;;
    --opencode) opencode=yes ;;
    --codex|--pi|--none) ;;
    *) echo "unknown option $arg" >&2; exit 1 ;;
  esac
done

copy() {
  local from=$1 dest=$2
  if [ -e "$target/$dest" ]; then
    echo "kept existing $dest"
    return
  fi
  mkdir -p "$(dirname "$target/$dest")"
  cp "$from" "$target/$dest"
  case "$dest" in *.sh) chmod +x "$target/$dest" ;; esac
  echo "added $dest"
}

copy "$templates/AGENTS.md" AGENTS.md
(cd "$templates" && find docs -type f | sort) | while IFS= read -r file; do
  copy "$templates/$file" "$file"
done
for file in "$files"/scripts/*; do copy "$file" "scripts/heracles/$(basename "$file")"; done
for file in "$files"/roles/*.md; do copy "$file" ".heracles/roles/$(basename "$file")"; done

if [ "$claude" = yes ]; then
  copy "$templates/CLAUDE.md" CLAUDE.md
  copy "$templates/settings.json" .claude/settings.json
fi
[ "$cursor" = yes ] && copy "$templates/cursor-hooks.json" .cursor/hooks.json
[ "$gemini" = yes ] && copy "$templates/GEMINI.md" GEMINI.md

if [ "$opencode" = yes ]; then
  for file in "$files"/roles/*.md; do
    name=$(basename "$file" .md)
    dest=".opencode/agents/$name.md"
    if [ -e "$target/$dest" ]; then echo "kept existing $dest"; continue; fi
    mkdir -p "$target/.opencode/agents"
    python3 - "$file" "$target/$dest" "$name" <<'PY'
import re, sys
src, dest, name = sys.argv[1:]
text = open(src, encoding="utf-8").read()
m = re.match(r"^---\n(.*?)\n---\n(.*)$", text, re.S)
head, body = (m.group(1), m.group(2)) if m else ("", text)
desc = re.search(r"^description:\s*(.+)$", head, re.M)
desc = desc.group(1).strip().strip('"') if desc else f"heracles {name}"
tools = re.search(r"^tools:\s*(.+)$", head, re.M)
edits = tools and ("Edit" in tools.group(1) or "Write" in tools.group(1))
perm = "" if edits else "permission:\n  edit: deny\n"
with open(dest, "w", encoding="utf-8") as f:
    f.write(f'---\ndescription: "{desc}"\nmode: subagent\n{perm}---\n{body}')
PY
    echo "added $dest"
  done
fi

ignore="$target/.gitignore"
touch "$ignore"
while IFS= read -r line; do
  [ -n "$line" ] || continue
  grep -qxF -- "$line" "$ignore" || { echo "$line" >> "$ignore"; echo "added .gitignore line $line"; }
done < "$templates/gitignore"
