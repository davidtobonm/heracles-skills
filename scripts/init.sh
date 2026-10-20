#!/usr/bin/env bash
# Copy the heracles templates into the current git repo. Run by the /heracles:init skill.
# Never overwrites a file that already exists; it lists the ones it kept.
#   templates/AGENTS.md, CLAUDE.md -> repo root
#   templates/docs/**              -> docs/
#   templates/settings.json        -> .claude/settings.json
#   templates/gitignore            -> lines appended to .gitignore when missing
# templates/rules-example.md is not copied; it is an example to adapt by hand.
set -euo pipefail
here=$(cd "$(dirname "$0")/.." && pwd)
templates="$here/templates"
target=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "Not inside a git repo. Run git init first." >&2; exit 1; }

copy() {
  local from=$1 dest=$2
  if [ -e "$target/$dest" ]; then
    echo "kept existing $dest"
    return
  fi
  mkdir -p "$(dirname "$target/$dest")"
  cp "$from" "$target/$dest"
  echo "added $dest"
}

copy "$templates/AGENTS.md" AGENTS.md
copy "$templates/CLAUDE.md" CLAUDE.md
copy "$templates/settings.json" .claude/settings.json
(cd "$templates" && find docs -type f | sort) | while IFS= read -r file; do
  copy "$templates/$file" "$file"
done

ignore="$target/.gitignore"
touch "$ignore"
while IFS= read -r line; do
  [ -n "$line" ] || continue
  grep -qxF -- "$line" "$ignore" || { echo "$line" >> "$ignore"; echo "added .gitignore line $line"; }
done < "$templates/gitignore"
