#!/usr/bin/env python3
"""
Azure CLI Flag Validation Script

Validates that Azure CLI examples use long flags instead of short flags.
Only checks fenced bash, shell, and azurecli code blocks for az commands.

Usage:
    python scripts/validate_cli_flags.py [--verbose]

Exit codes:
    0 - All validations passed
    1 - Validation errors found
"""

import sys
import re
import shlex
import argparse
from pathlib import Path
from typing import List, Optional, Tuple


SHORT_FLAG_MAP = {
    "-g": "--resource-group",
    "-n": "--name",
    "-l": "--location",
    "-o": "--output",
    "-s": "--subscription",
}
TARGET_LANGUAGES = {"bash", "shell", "azurecli"}
FENCED_CODE_PATTERN = re.compile(r"^```([A-Za-z0-9_-]+)?\s*$")


class ValidationError:
    def __init__(self, file: str, line: int, flag: str, replacement: str, command: str):
        self.file = file
        self.line = line
        self.flag = flag
        self.replacement = replacement
        self.command = command

    def __str__(self):
        return (
            f"{self.file}:{self.line}: Short flag '{self.flag}' should be "
            f"'{self.replacement}' in: {self.command}"
        )


def extract_flag_matches(command: str) -> List[str]:
    """Extract disallowed Azure CLI short flags from a command string."""
    try:
        tokens = shlex.split(command, comments=False, posix=True)
    except ValueError:
        tokens = command.split()

    matches = []
    for token in tokens:
        for short_flag in SHORT_FLAG_MAP:
            if token == short_flag or token.startswith(f"{short_flag}="):
                matches.append(short_flag)
    return matches


def validate_file(
    file_path: Path, project_path: Path, verbose: bool = False
) -> List[ValidationError]:
    """Validate a single markdown file."""
    errors = []

    try:
        content = file_path.read_text(encoding="utf-8")
    except Exception:
        return []

    rel_path = str(file_path.relative_to(project_path))
    lines = content.split("\n")
    code_language = None
    active_command_line: Optional[int] = None
    active_command_parts: List[str] = []

    for i, line in enumerate(lines, 1):
        fence_match = FENCED_CODE_PATTERN.match(line.strip())
        if fence_match:
            if code_language is None:
                language = (fence_match.group(1) or "").lower()
                code_language = language if language in TARGET_LANGUAGES else "other"
            else:
                code_language = None
                active_command_line = None
                active_command_parts = []
            continue

        if code_language not in TARGET_LANGUAGES:
            continue

        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            active_command_line = None
            active_command_parts = []
            continue

        if stripped.startswith("az "):
            active_command_line = i
            active_command_parts = [stripped]
        elif active_command_line is not None:
            active_command_parts.append(stripped)
        else:
            continue

        command_text = " ".join(active_command_parts)
        if command_text.endswith("\\"):
            active_command_parts[-1] = active_command_parts[-1][:-1].rstrip()
            continue

        for flag in extract_flag_matches(command_text):
            errors.append(
                ValidationError(
                    rel_path,
                    active_command_line or i,
                    flag,
                    SHORT_FLAG_MAP[flag],
                    command_text,
                )
            )

        active_command_line = None
        active_command_parts = []

    if verbose and not errors:
        print(f"  [OK] {rel_path}")

    return errors


def validate_project(
    project_path: Path, verbose: bool = False
) -> Tuple[int, List[ValidationError]]:
    """Validate all markdown files in docs/."""
    docs_dir = project_path / "docs"
    if not docs_dir.exists():
        return 0, []

    all_errors = []
    files_checked = 0

    for md_file in docs_dir.glob("**/*.md"):
        files_checked += 1
        file_errors = validate_file(md_file, project_path, verbose)
        all_errors.extend(file_errors)

    return files_checked, all_errors


def print_mapping_table():
    """Print the short-to-long flag replacement table."""
    print("\nShort flag replacement table:")
    for short_flag, long_flag in SHORT_FLAG_MAP.items():
        print(f"  {short_flag:<3} -> {long_flag}")


def main():
    parser = argparse.ArgumentParser(
        description="Validate Azure CLI examples for short flags"
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

    print(f"Validating Azure CLI flags in: {project_path}")
    print("=" * 60)

    files_checked, errors = validate_project(project_path, args.verbose)

    print(f"\nFiles checked: {files_checked}")
    print(f"Short flag issues: {len(errors)}")
    print_mapping_table()

    if errors:
        print("\nIssues:")
        for error in errors:
            print(f"  {error}")
        sys.exit(1)
    else:
        print("\nAll Azure CLI examples use long flags!")
        sys.exit(0)


if __name__ == "__main__":
    main()
