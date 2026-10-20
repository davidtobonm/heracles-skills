#!/usr/bin/env python3
"""Check that the repo docs hold together. Standard library only.

Usage: python3 "${CLAUDE_PLUGIN_ROOT}/scripts/check_docs.py"   (run from the repo root)
The heracles Stop hook runs it from $CLAUDE_PROJECT_DIR.

Fails, with a line per problem, when:
- a relative Markdown link in AGENTS.md, docs/ or .claude/ points to a file that does not exist;
- a sprint folder in docs/sprints/ has no row in docs/sprints/README.md, or its spec.md has no status line;
- a sprint folder closed in an earlier commit has uncommitted changes;
- an ADR in docs/decisions/ has no row in docs/decisions/README.md, an unknown status,
  or is accepted with nobody in "Decided by";
- a file passes its line cap (AGENTS.md, docs/status.md, any project SKILL.md in .claude/skills/).
"""

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path.cwd()
CAPS = {"AGENTS.md": 150, "docs/status.md": 80}
SKILL_CAP = 300
LINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)\)")
SPRINT_DIR = re.compile(r"^S\d+")
SPEC_STATUS = re.compile(r"^Status: (open|closed \d{4}-\d{2}-\d{2})\s*$", re.M)
ADR_FILE = re.compile(r"^(\d{4})-[a-z0-9-]+\.md$")
ADR_STATUS = re.compile(r"^- Status: (proposed|accepted|superseded by \d{4})\s*$", re.M)
ADR_DECIDED = re.compile(r"^- Decided by: (.+)$", re.M)

problems = []


def rel(path):
    return path.relative_to(ROOT).as_posix()


def markdown_files():
    files = [ROOT / "AGENTS.md", ROOT / "CLAUDE.md"]
    for folder in ("docs", ".claude"):
        if (ROOT / folder).is_dir():
            files += [p for p in (ROOT / folder).rglob("*.md") if "worktrees" not in p.parts]
    return [f for f in files if f.is_file()]


def outside_code(text):
    kept, fenced = [], False
    for line in text.splitlines():
        if line.lstrip().startswith("```"):
            fenced = not fenced
            continue
        if not fenced:
            kept.append(re.sub(r"`[^`]*`", "", line))
    return "\n".join(kept)


def check_links():
    for md in markdown_files():
        for target in LINK.findall(outside_code(md.read_text(encoding="utf-8"))):
            if re.match(r"^[a-z]+:", target) or target.startswith("#"):
                continue
            path = target.split("#", 1)[0]
            if not (md.parent / path).exists():
                problems.append(f"{rel(md)}: broken link to {target}. Fix the path or remove the link.")


def git(*args):
    result = subprocess.run(["git", *args], cwd=ROOT, capture_output=True, text=True, check=False)
    return result.stdout if result.returncode == 0 else ""


def closed_in_head(spec):
    """True when the committed spec.md already says closed. Closing it in the working tree is allowed."""
    status = SPEC_STATUS.search(git("show", f"HEAD:{rel(spec)}"))
    return bool(status) and status.group(1).startswith("closed")


def check_sprints():
    sprints = ROOT / "docs" / "sprints"
    if not sprints.is_dir():
        return
    index_file = sprints / "README.md"
    index = index_file.read_text(encoding="utf-8") if index_file.is_file() else ""
    for folder in sorted(p for p in sprints.iterdir() if p.is_dir() and SPRINT_DIR.match(p.name)):
        if f"({folder.name}/" not in index and f"]({folder.name})" not in index:
            problems.append(f"{rel(folder)}: no row in docs/sprints/README.md. Add one.")
        spec = folder / "spec.md"
        if not spec.is_file():
            problems.append(f"{rel(folder)}: missing spec.md.")
            continue
        status = SPEC_STATUS.search(spec.read_text(encoding="utf-8"))
        if not status:
            problems.append(f"{rel(spec)}: needs a line 'Status: open' or 'Status: closed YYYY-MM-DD'.")
        elif closed_in_head(spec) and git("status", "--porcelain", "--", rel(folder)).strip():
            problems.append(f"{rel(folder)}: the sprint was closed in an earlier commit but has uncommitted changes. Revert them; put new work in the active sprint.")


def check_decisions():
    decisions = ROOT / "docs" / "decisions"
    if not decisions.is_dir():
        return
    index_file = decisions / "README.md"
    index = index_file.read_text(encoding="utf-8") if index_file.is_file() else ""
    for adr in sorted(decisions.glob("*.md")):
        if adr.name == "README.md":
            continue
        if not ADR_FILE.match(adr.name):
            problems.append(f"{rel(adr)}: name it NNNN-lowercase-slug.md.")
            continue
        text = adr.read_text(encoding="utf-8")
        if adr.name not in index:
            problems.append(f"{rel(adr)}: no row in docs/decisions/README.md. Add one.")
        status = ADR_STATUS.search(text)
        if not status:
            problems.append(f"{rel(adr)}: needs '- Status: proposed | accepted | superseded by NNNN'.")
            continue
        decided = ADR_DECIDED.search(text)
        who = decided.group(1).strip().lower() if decided else ""
        if status.group(1) == "accepted" and who in ("", "pending", "<names, or \"pending\">"):
            problems.append(f"{rel(adr)}: accepted with nobody in 'Decided by'. Name who decided, or set it back to proposed.")


def check_caps():
    for name, cap in CAPS.items():
        path = ROOT / name
        if path.is_file():
            count = len(path.read_text(encoding="utf-8").splitlines())
            if count > cap:
                problems.append(f"{name}: {count} lines, cap {cap}. Move procedures to a skill or details to docs/.")
    skills = ROOT / ".claude" / "skills"
    if skills.is_dir():
        for skill in skills.glob("*/SKILL.md"):
            count = len(skill.read_text(encoding="utf-8").splitlines())
            if count > SKILL_CAP:
                problems.append(f"{rel(skill)}: {count} lines, cap {SKILL_CAP}. Move detail to a reference file next to it.")


def main():
    check_links()
    check_sprints()
    check_decisions()
    check_caps()
    for problem in problems:
        print(problem)
    print(f"check_docs: {len(problems)} problem(s)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
