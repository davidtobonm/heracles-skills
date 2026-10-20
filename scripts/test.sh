#!/usr/bin/env bash
# Checks for this repo. Run from anywhere: bash scripts/test.sh
# Needs git, python3 with PyYAML, and optionally the claude CLI and node with mermaid + jsdom
# (set MERMAID_NODE_MODULES to a node_modules folder that has them to run the diagram check).
set -uo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
fails=0
ok()   { echo "ok    $1"; }
bad()  { echo "FAIL  $1"; fails=$((fails + 1)); }
skip() { echo "skip  $1"; }

# 1. Every manifest is valid JSON.
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json .cursor-plugin/plugin.json \
         .codex-plugin/plugin.json .agents/plugins/marketplace.json gemini-extension.json package.json \
         skills/init/templates/settings.json skills/init/templates/cursor-hooks.json; do
  python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$root/$f" 2>/dev/null && ok "json $f" || bad "json $f"
done

# 2. Versions agree.
versions=$(cd "$root" && python3 -c '
import json
fs=[".claude-plugin/plugin.json",".cursor-plugin/plugin.json",".codex-plugin/plugin.json","gemini-extension.json","package.json"]
print(" ".join(sorted({json.load(open(f))["version"] for f in fs})))')
[ "$(echo "$versions" | wc -w)" -eq 1 ] && ok "one version ($versions)" || bad "versions differ: $versions"

# 3. Claude Code plugin validates.
if command -v claude >/dev/null 2>&1 && claude plugin validate --help >/dev/null 2>&1; then
  claude plugin validate "$root" >/dev/null 2>&1 && ok "claude plugin validate" || bad "claude plugin validate"
else
  skip "claude plugin validate (no claude CLI with plugin commands)"
fi

# 4. Frontmatter parses and names match folders.
python3 - "$root" <<'PY' && ok "frontmatter" || bad "frontmatter"
import sys, pathlib, yaml
root = pathlib.Path(sys.argv[1]); errors = []
for f in list(root.glob("skills/*/SKILL.md")) + list(root.glob("roles/*.md")):
    text = f.read_text(encoding="utf-8")
    try:
        meta = yaml.safe_load(text.split("---")[1])
    except Exception as e:
        errors.append(f"{f}: {e}"); continue
    if not meta.get("name") or not meta.get("description"):
        errors.append(f"{f}: needs name and description")
    if f.name == "SKILL.md" and meta.get("name") != f.parent.name:
        errors.append(f"{f}: name {meta.get('name')} differs from its folder")
for e in errors: print("   ", e)
sys.exit(1 if errors else 0)
PY

# 5. The init skill role copies match roles/.
diff -rq "$root/roles" "$root/skills/init/files/roles" >/dev/null && ok "roles in sync" || bad "roles differ: run scripts/sync.sh"

# 6. Skills stay portable: no Claude-only paths or namespaced names in skill text.
leaks=$(grep -rnE 'CLAUDE_PLUGIN_ROOT|heracles:[a-z]|Skill tool|subagent_type' "$root/skills" \
  --include='*.md' | grep -v '/skills/init/files/roles/' | grep -v '/skills/init/templates/AGENTS.md' | grep -v '/skills/init/SKILL.md' || true)
[ -z "$leaks" ] && ok "skills are agent-neutral" || { bad "agent-specific text in skills"; echo "$leaks" | sed 's/^/    /'; }

# 7. init sets up an empty repo, and the docs check passes there.
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
repo="$tmp/repo"; git init -q -b main "$repo"
( cd "$repo" && bash "$root/skills/init/init.sh" --all >/dev/null ) && ok "init --all" || bad "init --all"
for f in AGENTS.md CLAUDE.md GEMINI.md .claude/settings.json .cursor/hooks.json .opencode/agents/reviewer.md \
         .heracles/roles/implementer.md scripts/heracles/check_docs.py scripts/heracles/branch-guard.sh docs/workflow.md; do
  [ -e "$repo/$f" ] || bad "init did not add $f"
done
( cd "$repo" && python3 scripts/heracles/check_docs.py | grep -q "0 problem" ) && ok "docs check in a fresh repo" || bad "docs check in a fresh repo"
second=$(cd "$repo" && bash "$root/skills/init/init.sh" --all | grep -c '^added' || true)
[ "$second" = 0 ] && ok "init never overwrites" || bad "init added $second files on a second run"

# 8. Branch guard, Claude Code and Cursor formats.
guard="$repo/scripts/heracles/branch-guard.sh"
( cd "$repo" && git -c user.name=test -c user.email=test@example.com commit -q --allow-empty -m init )
claude_in() { printf '{"cwd":"%s"%s,"tool_input":{"command":"%s"}}' "$repo" "$2" "$1"; }
cursor_in() { printf '{"hook_event_name":"beforeShellExecution","cwd":"%s","command":"%s"}' "$repo" "$1"; }
expect() { local want=$1 label=$2; shift 2; "$@" >/dev/null 2>&1; local got=$?; [ "$got" = "$want" ] && ok "guard: $label" || bad "guard: $label (exit $got, wanted $want)"; }
run_claude() { claude_in "$1" "$2" | bash "$guard"; }
expect 0 "no dev branch: subagent commit on main allowed" run_claude "git commit -m x" ',"agent_id":"a"'
( cd "$repo" && git branch dev )
expect 2 "subagent commit on main" run_claude "git commit -m x" ',"agent_id":"a"'
expect 0 "main session commit on main (hotfix exception)" run_claude "git commit -m x" ""
( cd "$repo" && git switch -q dev )
expect 2 "subagent commit on dev" run_claude "git commit -m x" ',"agent_id":"a"'
expect 0 "main session commit on dev" run_claude "git commit -m x" ""
expect 2 "subagent gh pr merge" run_claude "gh pr merge 5 --squash" ',"agent_id":"a"'
cursor_dev=$(cursor_in "git commit -m x" | bash "$guard")
echo "$cursor_dev" | grep -q '"allow"' && ok "guard: Cursor commit on dev allowed" || bad "guard: Cursor commit on dev ($cursor_dev)"
( cd "$repo" && git switch -q main )
cursor_main=$(cursor_in "git commit -m x" | bash "$guard")
echo "$cursor_main" | grep -q '"deny"' && ok "guard: Cursor commit on main denied" || bad "guard: Cursor commit on main ($cursor_main)"

# 9. Stop hook does nothing in a repo without docs/sprints.
plain="$tmp/plain"; git init -q "$plain"; echo x > "$plain/f"
( cd "$plain" && printf '{}' | CLAUDE_PROJECT_DIR="$plain" bash "$root/skills/init/files/scripts/check-docs-hook.sh" ) \
  && ok "stop hook skips repos without heracles" || bad "stop hook ran in a plain repo"

# 10. Mermaid diagrams parse.
if [ -n "${MERMAID_NODE_MODULES:-}" ] && command -v node >/dev/null 2>&1; then
  cp "$root/skills/init/files/scripts/check-mermaid.mjs" "$MERMAID_NODE_MODULES/../heracles-check-mermaid.mjs"
  node "$MERMAID_NODE_MODULES/../heracles-check-mermaid.mjs" "$root/README.md" "$root/skills/init/templates/docs/workflow.md" "$root/skills/draw-diagram/TOOLS.md" >/dev/null 2>&1 \
    && ok "mermaid diagrams parse" || bad "mermaid diagrams"
else
  skip "mermaid diagrams (set MERMAID_NODE_MODULES)"
fi

echo
[ "$fails" -eq 0 ] && echo "all checks passed" || echo "$fails check(s) failed"
exit $((fails > 0))
