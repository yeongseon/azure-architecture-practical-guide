#!/usr/bin/env python3
"""Regenerate docs/reference/content-validation-status.md from frontmatter data."""

from __future__ import annotations

import re
from pathlib import Path

import yaml

DOCS_DIR = Path("docs")
OUTPUT = DOCS_DIR / "reference" / "content-validation-status.md"

ICON = {
    "verified": "✅ Verified",
    "pending_review": "🔍 Pending Review",
    "unverified": "❓ Unverified",
}


def parse_frontmatter(path: Path) -> dict | None:
    text = path.read_text(encoding="utf-8")
    m = re.match(r"^---\s*\n(.*?)\n---", text, re.DOTALL)
    if not m:
        return None
    try:
        return yaml.safe_load(m.group(1))
    except yaml.YAMLError:
        return None


def main() -> None:
    rows: list[tuple[str, str, int, str]] = []

    for md in sorted(DOCS_DIR.rglob("*.md")):
        if md == OUTPUT:
            continue
        fm = parse_frontmatter(md)
        if not fm:
            continue
        cv = fm.get("content_validation")
        if not isinstance(cv, dict):
            continue

        rel = str(md.relative_to(DOCS_DIR))
        status = cv.get("status", "unverified")
        claims = cv.get("core_claims", [])
        n_claims = len(claims) if isinstance(claims, list) else 0
        last = cv.get("last_reviewed", "—")
        rows.append((rel, status, n_claims, str(last)))

    counts = {"verified": 0, "pending_review": 0, "unverified": 0}
    for _, s, _, _ in rows:
        counts[s] = counts.get(s, 0) + 1

    frontmatter = """\
---
content_sources:
  diagrams:
    - id: content-validation-pie
      type: pie
      source: self-generated
      justification: "Auto-generated pie chart from content_validation frontmatter across docs."
      based_on:
        - https://learn.microsoft.com/en-us/azure/architecture/
---
"""

    lines = [
        frontmatter,
        "# Content Validation Status\n",
        "Auto-generated dashboard — do not edit manually.",
        f"Run `python3 scripts/generate_content_validation_status.py` to regenerate.\n",
        "## Summary\n",
        "<!-- diagram-id: content-validation-pie -->",
        "```mermaid",
        "pie title Content Validation Status",
    ]
    for label in ("verified", "pending_review", "unverified"):
        c = counts.get(label, 0)
        if c > 0:
            lines.append(f'    "{ICON.get(label, label)}" : {c}')
    lines.append("```\n")
    lines.append("| Status | Count |")
    lines.append("|--------|-------|")
    for label in ("verified", "pending_review", "unverified"):
        lines.append(f"| {ICON.get(label, label)} | {counts.get(label, 0)} |")

    lines.append(f"\n**Total documents with content_validation**: {len(rows)}\n")
    lines.append("## Detail\n")
    lines.append("| Document | Status | Claims | Last Reviewed |")
    lines.append("|----------|--------|--------|---------------|")
    for rel, status, n_claims, last in rows:
        icon = ICON.get(status, status)
        lines.append(f"| `{rel}` | {icon} | {n_claims} | {last} |")

    lines.append("")
    lines.append("## See Also\n")
    lines.append("- [Validation Status](validation-status.md)")
    lines.append("- [Content Validation (AGENTS.md)](https://github.com/yeongseon/azure-architecture-practical-guide/blob/main/AGENTS.md)\n")
    lines.append("## Sources\n")
    lines.append("- [Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/)")
    lines.append("- [Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/well-architected/)")
    lines.append("")

    OUTPUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"Generated {OUTPUT} ({len(rows)} documents)")


if __name__ == "__main__":
    main()
