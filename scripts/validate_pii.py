#!/usr/bin/env python3
"""
PII Validation Script

Validates markdown files for potential PII in documentation.
Checks for:
- UUID-style subscription and tenant identifiers
- Private IPv4 addresses
- Real email addresses outside approved safe domains

Usage:
    python scripts/validate_pii.py [--verbose]

Exit codes:
    0 - All validations passed
    1 - Validation errors found
"""

import sys
import re
import argparse
from pathlib import Path
from typing import List, Optional, Tuple


UUID_PATTERN = re.compile(
    r"\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b"
)
PRIVATE_IP_PATTERN = re.compile(
    r"\b(?:10(?:\.\d{1,3}){3}|192\.168(?:\.\d{1,3}){2}|172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})\b"
)
EMAIL_PATTERN = re.compile(r"\b[A-Za-z0-9._%+-]+@([A-Za-z0-9.-]+\.[A-Za-z]{2,})\b")

SAFE_EMAIL_DOMAINS = {"example.com", "contoso.com", "microsoft.com", "outlook.com"}
TENANT_KEYWORDS = ("tenant", "tenantid", "tenant-id", "--tenant")
FENCED_CODE_PATTERN = re.compile(r"^```([A-Za-z0-9_-]+)?\s*$")


class ValidationError:
    def __init__(self, file: str, pii_type: str, line: int, value: str):
        self.file = file
        self.pii_type = pii_type
        self.line = line
        self.value = value

    def __str__(self):
        return f"{self.file}:{self.line}: {self.pii_type}: {self.value}"


def is_safe_uuid(value: str) -> bool:
    """Check whether a UUID-like value is a known placeholder or safe example."""
    normalized = value.lower()
    parts = normalized.split("-")
    compact = "".join(parts)

    if normalized in {
        "00000000-0000-0000-0000-000000000000",
        "ffffffff-ffff-ffff-ffff-ffffffffffff",
    }:
        return True

    if len(set(compact)) == 1:
        return True

    if compact in {
        "0123456789abcdef0123456789abcdef",
        "123456781234123412341234567890ab",
        "123456789abcdef0123456789abcdef0",
    }:
        return True

    return False


def should_skip_uuid(
    line: str, value: str, in_frontmatter: bool, code_language: Optional[str]
) -> bool:
    """Return True when a UUID match is a known safe example."""
    lower_line = line.lower()

    if "diagram-id:" in lower_line:
        return True

    if in_frontmatter and re.match(r"^\s*id\s*:\s*", line):
        return True

    if re.search(r"\b(x{8}-x{4}-x{4}-x{4}-x{12})\b", lower_line):
        return True

    if is_safe_uuid(value):
        return True

    if code_language and any(
        keyword in lower_line for keyword in ("example", "placeholder", "sample")
    ):
        return True

    return False


def should_skip_private_ip(
    line: str, match_start: int, match_end: int, code_language: Optional[str]
) -> bool:
    """Return True when a private IP is part of a safe CIDR example."""
    after = line[match_end:]
    if re.match(r"/\d{1,2}\b", after):
        return True

    if code_language == "mermaid" and re.search(r"/\d{1,2}\b", line):
        return True

    return False


def classify_uuid(line: str) -> str:
    """Classify UUID match using nearby tenant keywords."""
    lower_line = line.lower()
    if any(keyword in lower_line for keyword in TENANT_KEYWORDS):
        return "Potential tenant ID"
    return "Potential subscription ID"


def validate_file(
    file_path: Path, project_path: Path, verbose: bool = False
) -> List[ValidationError]:
    """Validate a single markdown file."""
    errors = []

    try:
        content = file_path.read_text(encoding="utf-8")
    except Exception as e:
        return [ValidationError(str(file_path), "Read error", 1, str(e))]

    rel_path = str(file_path.relative_to(project_path))
    lines = content.split("\n")
    in_frontmatter = False
    frontmatter_complete = False
    code_language = None

    for i, line in enumerate(lines, 1):
        if i == 1 and line.strip() == "---":
            in_frontmatter = True
            continue

        if in_frontmatter and line.strip() == "---":
            in_frontmatter = False
            frontmatter_complete = True
            continue

        fence_match = FENCED_CODE_PATTERN.match(line.strip())
        if fence_match:
            if code_language is None:
                code_language = (fence_match.group(1) or "").lower() or None
            else:
                code_language = None
            continue

        for match in UUID_PATTERN.finditer(line):
            value = match.group(0)
            if should_skip_uuid(
                line, value, in_frontmatter and not frontmatter_complete, code_language
            ):
                continue
            errors.append(ValidationError(rel_path, classify_uuid(line), i, value))

        for match in PRIVATE_IP_PATTERN.finditer(line):
            value = match.group(0)
            if should_skip_private_ip(line, match.start(), match.end(), code_language):
                continue
            errors.append(
                ValidationError(rel_path, "Potential private IP address", i, value)
            )

        for match in EMAIL_PATTERN.finditer(line):
            value = match.group(0)
            domain = match.group(1).lower()
            if domain in SAFE_EMAIL_DOMAINS:
                continue
            errors.append(
                ValidationError(rel_path, "Potential real email address", i, value)
            )

    if verbose and not errors:
        print(f"  [OK] {rel_path}")

    return errors


def validate_project(
    project_path: Path, verbose: bool = False
) -> Tuple[int, List[ValidationError]]:
    """Validate all markdown files in docs/."""
    docs_dir = project_path / "docs"
    if not docs_dir.exists():
        return 0, [
            ValidationError(
                str(project_path), "Project error", 1, "docs directory not found"
            )
        ]

    all_errors = []
    files_checked = 0

    for md_file in docs_dir.glob("**/*.md"):
        files_checked += 1
        file_errors = validate_file(md_file, project_path, verbose)
        all_errors.extend(file_errors)

    return files_checked, all_errors


def main():
    parser = argparse.ArgumentParser(
        description="Validate documentation for potential PII"
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

    print(f"Validating PII in: {project_path}")
    print("=" * 60)

    files_checked, errors = validate_project(project_path, args.verbose)

    print(f"\nFiles checked: {files_checked}")
    print(f"Potential PII matches: {len(errors)}")

    if errors:
        print("\nMatches:")
        for error in errors:
            print(f"  {error}")
        sys.exit(1)
    else:
        print("\nNo PII patterns detected!")
        sys.exit(0)


if __name__ == "__main__":
    main()
