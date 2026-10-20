#!/usr/bin/env bash
# The subagent role files live in roles/. The Claude Code and Cursor manifests point there.
# (A folder named agents/ would make Gemini CLI load them in its own, stricter agent format.)
# The init skill carries a copy in skills/init/files/roles/, because tools like `npx skills add`
# copy only skill folders. Run this after editing roles/; scripts/test.sh fails if they differ.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
rm -f "$root"/skills/init/files/roles/*.md
cp "$root"/roles/*.md "$root"/skills/init/files/roles/
echo "synced $(ls "$root"/roles/*.md | wc -l | tr -d ' ') role files"
