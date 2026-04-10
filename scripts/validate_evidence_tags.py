#!/usr/bin/env python3
"""
Evidence Tag Validation Script

Validates that key documentation files contain evidence-level tags.

Usage:
    python scripts/validate_evidence_tags.py [--verbose] [--strict]

Exit codes:
    0 - All required validations passed
    1 - Missing evidence tags found in required files
"""

import sys
import re
import argparse
from pathlib import Path
from typing import List, Tuple


VALID_TAGS = [
    "[Documented]",
    "[Observed]",
    "[Measured]",
    "[Validated]",
    "[Correlated]",
    "[Inferred]",
    "[Assumed]",
    "[Unknown]",
]
TAG_PATTERN = re.compile(
    r"\[(Documented|Observed|Measured|Validated|Correlated|Inferred|Assumed|Unknown)\]"
)
REQUIRED_PATTERNS = [
    "docs/design-labs/lab-*.md",
    "docs/architecture-reviews/**/*.md",
    "docs/patterns/**/*.md",
]
SHOULD_PATTERNS = [
    "docs/waf/**/*.md",
    "docs/platform/**/*.md",
]


def find_matching_files(project_path: Path, pattern: str) -> List[Path]:
    """Find files matching a glob pattern relative to the project root."""
    return sorted(project_path.glob(pattern))


def has_evidence_tag(file_path: Path) -> bool:
    """Check whether a markdown file contains any valid evidence tag."""
    try:
        content = file_path.read_text(encoding="utf-8")
    except Exception:
        return False
    return bool(TAG_PATTERN.search(content))


def validate_group(
    project_path: Path, patterns: List[str], verbose: bool = False
) -> Tuple[int, List[str]]:
    """Validate a group of file patterns and return missing files."""
    files_checked = 0
    missing_files = []

    for pattern in patterns:
        for file_path in find_matching_files(project_path, pattern):
            files_checked += 1
            rel_path = str(file_path.relative_to(project_path))
            if has_evidence_tag(file_path):
                if verbose:
                    print(f"  [OK] {rel_path}")
            else:
                missing_files.append(rel_path)

    return files_checked, missing_files


def main():
    parser = argparse.ArgumentParser(
        description="Validate evidence tags in documentation"
    )
    parser.add_argument(
        "--strict", action="store_true", help="Also fail on SHOULD directories"
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

    print(f"Validating evidence tags in: {project_path}")
    print("=" * 60)
    print(f"Valid tags: {', '.join(VALID_TAGS)}")

    required_checked, required_missing = validate_group(
        project_path, REQUIRED_PATTERNS, args.verbose
    )
    should_checked, should_missing = validate_group(
        project_path, SHOULD_PATTERNS, args.verbose
    )

    print(f"\nRequired files checked: {required_checked}")
    print(f"Required files missing tags: {len(required_missing)}")
    print(f"Should-check files checked: {should_checked}")
    print(f"Should-check files missing tags: {len(should_missing)}")

    if required_missing:
        print("\nRequired files missing evidence tags:")
        for file_path in required_missing:
            print(f"  {file_path}")

    if should_missing:
        print("\nRecommended files missing evidence tags:")
        for file_path in should_missing:
            print(f"  {file_path}")

    if required_missing or (args.strict and should_missing):
        sys.exit(1)

    if should_missing:
        print("\nWarnings found, but required checks passed.")
    else:
        print("\nAll required files contain evidence tags!")
    sys.exit(0)


if __name__ == "__main__":
    main()
