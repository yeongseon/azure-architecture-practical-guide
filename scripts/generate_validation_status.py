#!/usr/bin/env python3
"""Generate workload guide validation status dashboard from frontmatter metadata.

Scans all workload guide and design lab markdown files for validation frontmatter
and generates a dashboard page showing which guides have been reviewed, deployed,
and load-tested, when, and by whom.

Usage:
    python3 scripts/generate_validation_status.py
    python3 scripts/generate_validation_status.py --docs-dir docs --output docs/reference/validation-status.md
"""

from __future__ import annotations

import argparse
import re
from datetime import date, timedelta
from pathlib import Path
from typing import Any

import yaml

STALENESS_DAYS = 90
WORKLOAD_GUIDE_GLOB = "workload-guides/*/*.md"
DESIGN_LAB_GLOB = "design-labs/lab-*.md"

# Status icons
ICON_PASS = "✅ Pass"
ICON_FAIL = "❌ Fail"
ICON_STALE = "⚠️ Stale"
ICON_NOT_TESTED = "➖ Not Tested"
ICON_NO_DATA = "➖ No Data"

# Workload family mapping (directory name → display name)
WORKLOAD_FAMILIES = {
    "public-web-and-api": "Public Web and API",
    "internal-line-of-business": "Internal Line of Business",
    "integration-and-messaging": "Integration and Messaging",
    "serverless-processing": "Serverless Processing",
    "microservices-and-containers": "Microservices and Containers",
    "data-and-analytics": "Data and Analytics",
    "ai-and-rag": "AI and RAG",
    "design-labs": "Design Labs",
}


def parse_frontmatter(filepath: Path) -> dict[str, Any] | None:
    """Extract YAML frontmatter from a markdown file."""
    text = filepath.read_text(encoding="utf-8")
    match = re.match(r"^---\s*\n(.*?)\n---", text, re.DOTALL)
    if not match:
        return None
    try:
        return yaml.safe_load(match.group(1))
    except yaml.YAMLError:
        return None


def extract_guide_info(filepath: Path, docs_dir: Path) -> dict[str, Any]:
    """Extract guide metadata from file path and frontmatter."""
    rel = filepath.relative_to(docs_dir)
    parts = rel.parts
    # For workload guides: parts = ('workload-guides', '<family>', '<file>.md')
    # For design labs:     parts = ('design-labs', 'lab-*.md')
    if len(parts) > 1:
        family_dir = parts[0] if parts[0] == "design-labs" else parts[1]
    else:
        family_dir = "unknown"

    filename = filepath.stem

    frontmatter = parse_frontmatter(filepath)
    validation = {}
    if frontmatter and isinstance(frontmatter, dict):
        validation = frontmatter.get("validation", {}) or {}

    return {
        "filepath": filepath,
        "rel_path": str(rel),
        "family": family_dir,
        "filename": filename,
        "title": filename.replace("-", " ").title(),
        "validation": validation,
    }


def get_method_status(
    method_data: dict[str, Any] | None, today: date
) -> tuple[str, str | None]:
    """Return (status_icon, last_tested_str) for a validation method."""
    if not method_data or not isinstance(method_data, dict):
        return ICON_NO_DATA, None

    result = method_data.get("result", "not_tested")
    last_tested = method_data.get("last_tested")

    if result == "not_tested" or last_tested is None:
        return ICON_NOT_TESTED, None

    # Parse date
    if isinstance(last_tested, date):
        test_date = last_tested
    else:
        try:
            test_date = date.fromisoformat(str(last_tested))
        except (ValueError, TypeError):
            return ICON_NO_DATA, str(last_tested)

    date_str = test_date.isoformat()
    age = (today - test_date).days

    if result == "fail":
        return ICON_FAIL, date_str
    if age > STALENESS_DAYS:
        return ICON_STALE, date_str
    return ICON_PASS, date_str


def generate_dashboard(guides: list[dict[str, Any]], today: date) -> str:
    """Generate the markdown dashboard content."""
    # Compute stats
    total = len(guides)
    validated = 0
    stale = 0
    failed = 0
    not_tested = 0

    for g in guides:
        v = g["validation"]
        has_any_pass = False
        has_stale = False
        has_fail = False

        for method in ("architecture_review", "bicep_deployment", "load_test"):
            method_data = v.get(method)
            status, _ = get_method_status(method_data, today)
            if status == ICON_PASS:
                has_any_pass = True
            elif status == ICON_STALE:
                has_stale = True
            elif status == ICON_FAIL:
                has_fail = True

        if has_fail:
            failed += 1
        elif has_stale:
            stale += 1
        elif has_any_pass:
            validated += 1
        else:
            not_tested += 1

    # Group by workload family
    by_family: dict[str, list[dict[str, Any]]] = {}
    for g in guides:
        family = g["family"]
        by_family.setdefault(family, []).append(g)

    lines: list[str] = []
    lines.append("# Workload Guide Validation Status")
    lines.append("")
    lines.append(
        "This page tracks which workload guides and design labs have been validated against real Azure deployments. "
        "Each guide can be validated via **architecture review**, **Bicep deployment**, or **load test**. "
        f"Guides not validated within {STALENESS_DAYS} days are marked as stale."
    )
    lines.append("")

    # Summary section
    lines.append("## Summary")
    lines.append("")
    lines.append(f"*Generated: {today.isoformat()}*")
    lines.append("")
    lines.append("| Metric | Count |")
    lines.append("|---|---:|")
    lines.append(f"| Total guides | {total} |")
    lines.append(f"| ✅ Validated | {validated} |")
    lines.append(f"| ⚠️ Stale (>{STALENESS_DAYS} days) | {stale} |")
    lines.append(f"| ❌ Failed | {failed} |")
    lines.append(f"| ➖ Not tested | {not_tested} |")
    lines.append("")

    # Mermaid pie chart
    lines.append("```mermaid")
    lines.append("pie title Workload Guide Validation Status")
    if validated > 0:
        lines.append(f'    "Validated" : {validated}')
    if stale > 0:
        lines.append(f'    "Stale" : {stale}')
    if failed > 0:
        lines.append(f'    "Failed" : {failed}')
    if not_tested > 0:
        lines.append(f'    "Not Tested" : {not_tested}')
    lines.append("```")
    lines.append("")

    # Validation Matrix per workload family
    lines.append("## Validation Matrix")
    lines.append("")

    # Sort families: known families first (in order), then unknown
    known_order = list(WORKLOAD_FAMILIES.keys())
    sorted_families = sorted(
        by_family.keys(),
        key=lambda f: (
            known_order.index(f) if f in known_order else len(known_order),
            f,
        ),
    )

    for family in sorted_families:
        family_guides = by_family[family]
        family_display = WORKLOAD_FAMILIES.get(family, family.replace("-", " ").title())

        lines.append(f"### {family_display}")
        lines.append("")
        lines.append(
            "| Guide | Architecture Review | Bicep Deployment | Load Test | Last Validated | Status |"
        )
        lines.append("|---|---|---|---|---|---|")
        family_guides.sort(key=lambda g: g["filename"])

        for g in family_guides:
            v = g["validation"]
            review_data = v.get("architecture_review")
            bicep_data = v.get("bicep_deployment")
            load_data = v.get("load_test")

            review_status, review_date = get_method_status(review_data, today)
            bicep_status, bicep_date = get_method_status(bicep_data, today)
            load_status, load_date = get_method_status(load_data, today)

            # Last validated = most recent of the three
            dates = [d for d in [review_date, bicep_date, load_date] if d]
            last_validated = max(dates) if dates else "—"

            # Overall status
            statuses = [review_status, bicep_status, load_status]
            if ICON_FAIL in statuses:
                overall = ICON_FAIL
            elif ICON_STALE in statuses:
                overall = ICON_STALE
            elif ICON_PASS in statuses:
                overall = ICON_PASS
            else:
                overall = ICON_NOT_TESTED

            # Guide link
            guide_link = f"[{g['title']}](../{g['rel_path']})"

            lines.append(
                f"| {guide_link} | {review_status} | {bicep_status} | {load_status} | {last_validated} | {overall} |"
            )

        lines.append("")

    # How to Update section
    lines.append("## How to Update")
    lines.append("")
    lines.append(
        "To mark a guide as validated, add a `validation` block to its YAML frontmatter:"
    )
    lines.append("")
    lines.append("```yaml")
    lines.append("---")
    lines.append("hide:")
    lines.append("  - toc")
    lines.append("validation:")
    lines.append("  architecture_review:")
    lines.append("    last_tested: 2026-04-10")
    lines.append('    reviewer: "team-lead"')
    lines.append("    result: pass")
    lines.append("  bicep_deployment:")
    lines.append("    last_tested: null")
    lines.append("    result: not_tested")
    lines.append("  load_test:")
    lines.append("    last_tested: null")
    lines.append("    result: not_tested")
    lines.append("---")
    lines.append("```")
    lines.append("")
    lines.append("Then regenerate this page:")
    lines.append("")
    lines.append("```bash")
    lines.append("python3 scripts/generate_validation_status.py")
    lines.append("```")
    lines.append("")
    lines.append('!!! info "Validation fields"')
    lines.append("    - `result`: `pass`, `fail`, or `not_tested`")
    lines.append("    - `last_tested`: ISO date (YYYY-MM-DD) or `null`")
    lines.append(
        "    - `reviewer`: Name or alias of the reviewer (for `architecture_review`)"
    )
    lines.append(
        f"    - Guides older than {STALENESS_DAYS} days are flagged as **stale**"
    )
    lines.append("")

    # See Also
    lines.append("## See Also")
    lines.append("")
    lines.append("- [Workload Guides](../workload-guides/index.md)")
    lines.append("- [Design Labs](../design-labs/index.md)")
    lines.append("- [Architecture Decision Matrix](architecture-decision-matrix.md)")
    lines.append("")

    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate workload guide validation status dashboard"
    )
    parser.add_argument(
        "--docs-dir",
        type=Path,
        default=Path("docs"),
        help="Path to docs directory (default: docs)",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("docs/reference/validation-status.md"),
        help="Output file path (default: docs/reference/validation-status.md)",
    )
    args = parser.parse_args()

    # Resolve relative to project root
    project_root = Path(__file__).resolve().parent.parent
    docs_dir = project_root / args.docs_dir
    output_path = project_root / args.output

    if not docs_dir.exists():
        print(f"Error: docs directory not found: {docs_dir}")
        raise SystemExit(1)

    # Scan workload guides and design labs
    guide_files: list[Path] = []
    guide_files.extend(sorted(docs_dir.glob(WORKLOAD_GUIDE_GLOB)))
    guide_files.extend(sorted(docs_dir.glob(DESIGN_LAB_GLOB)))

    # Filter out index.md files
    guide_files = [f for f in guide_files if f.name != "index.md"]

    guides = [extract_guide_info(f, docs_dir) for f in guide_files]

    today = date.today()
    dashboard = generate_dashboard(guides, today)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(dashboard, encoding="utf-8")

    # Stats
    validated = sum(
        1
        for g in guides
        if any(
            get_method_status(g["validation"].get(m), today)[0] == ICON_PASS
            for m in ("architecture_review", "bicep_deployment", "load_test")
        )
    )
    print(
        f"Scanned {len(guides)} guides, {validated} validated, generated {output_path}"
    )


if __name__ == "__main__":
    main()
