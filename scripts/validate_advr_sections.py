#!/usr/bin/env python3
"""
ADVR Section Validation Script

Validates that design lab markdown files include all required ADVR sections.

Usage:
    python scripts/validate_advr_sections.py [--verbose]

Exit codes:
    0 - All validations passed
    1 - Validation errors found
"""

import sys
import re
import argparse
from pathlib import Path
from typing import List, Tuple


REQUIRED_SECTIONS = [
    "Decision Question",
    "Business Context",
    "Scope and Non-Goals",
    "Constraints",
    "Quality Attribute Priorities",
    "Candidate Options",
    "Recommended Option",
    "Architecture Hypothesis",
    "Predicted Outcomes",
    "Validation Plan",
    "Falsification Criteria",
    "Evidence",
    "Trade-offs and Risks",
    "Guardrails and Operating Model",
    "Revisit Triggers",
    "Takeaway",
]
H2_PATTERN = re.compile(r"^##\s+(.+?)\s*$", re.MULTILINE)


class ValidationError:
    def __init__(self, file: str, missing_sections: List[str]):
        self.file = file
        self.missing_sections = missing_sections

    def __str__(self):
        sections = ", ".join(self.missing_sections)
        return f"{self.file}: Missing required sections: {sections}"


def validate_file(
    file_path: Path, project_path: Path, verbose: bool = False
) -> List[ValidationError]:
    """Validate a single design lab file."""
    try:
        content = file_path.read_text(encoding="utf-8")
    except Exception as e:
        return [
            ValidationError(
                str(file_path.relative_to(project_path)), [f"Read error: {e}"]
            )
        ]

    rel_path = str(file_path.relative_to(project_path))
    sections = {match.group(1).strip() for match in H2_PATTERN.finditer(content)}
    missing_sections = [
        section for section in REQUIRED_SECTIONS if section not in sections
    ]

    if verbose and not missing_sections:
        print(f"  [OK] {rel_path}")

    if missing_sections:
        return [ValidationError(rel_path, missing_sections)]
    return []


def validate_project(
    project_path: Path, verbose: bool = False
) -> Tuple[int, List[ValidationError]]:
    """Validate all design lab files in docs/design-labs/."""
    all_errors = []
    files_checked = 0

    for md_file in sorted((project_path / "docs" / "design-labs").glob("lab-*.md")):
        files_checked += 1
        file_errors = validate_file(md_file, project_path, verbose)
        all_errors.extend(file_errors)

    return files_checked, all_errors


def main():
    parser = argparse.ArgumentParser(
        description="Validate ADVR sections in design labs"
    )
    parser.add_argument(
        "--verbose", "-v", action="store_true", help="Show detailed output"
    )
    parser.add_argument("--project", "-p", type=str, help="Specific project path")
    args = parser.parse_args()

    if args.project:
        project_path = Path(args.project)
    else:
        project_path = Path(__file__).parent.parent

    print(f"Validating ADVR sections in: {project_path}")
    print("=" * 60)

    files_checked, errors = validate_project(project_path, args.verbose)

    print(f"\nDesign lab files checked: {files_checked}")
    print(f"Files with missing sections: {len(errors)}")

    if errors:
        print("\nErrors:")
        for error in errors:
            print(f"  {error}")
        sys.exit(1)
    else:
        print("\nAll design lab files include the required ADVR sections!")
        sys.exit(0)


if __name__ == "__main__":
    main()
