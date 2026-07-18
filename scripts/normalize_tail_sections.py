#!/usr/bin/env python3
"""Normalize markdown tail sections so every doc ends with ## See Also → ## Sources.

Rules:
  1. Rename ## Microsoft Learn references / ## Microsoft Learn reference /
     ## Microsoft Learn anchors  →  ## Sources
  2. Merge duplicate ## Sources under a single heading (dedupe identical lines).
  3. Move ## Takeaway / ## Disclaimer BEFORE the tail pair.
  4. Final order: … body sections … [Takeaway] [Disclaimer] [See Also] [Sources].
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path


DOCS_ROOT = Path(__file__).resolve().parents[1] / "docs"

# Generator-owned dashboards whose tail heading the generator controls; excluded
# so the normalizer does not fight regeneration. Relative to DOCS_ROOT.
EXCLUDED_RELPATHS = {
    "reference/validation-status.md",
    "reference/content-validation-status.md",
}

# Headings that should become ## Sources
SOURCE_ALIASES = {
    "Microsoft Learn references",
    "Microsoft Learn reference",
    "Microsoft Learn anchors",
    "Microsoft Learn anchor",
    "References",
    "Related Microsoft Learn references",
    "Evidence and references",
}

# All titles that are "source-like"
SOURCE_TITLES = SOURCE_ALIASES | {"Sources"}

# Sections that must sit before the See Also / Sources tail
MOVE_BEFORE_TAIL = {"Takeaway", "Disclaimer"}

# All titles recognised as belonging to the tail region
TAIL_TITLES = SOURCE_TITLES | MOVE_BEFORE_TAIL | {"See Also"}


@dataclass(frozen=True)
class Section:
    title: str
    heading_line: str
    body: str

    def raw(self) -> str:
        return f"{self.heading_line}{self.body}"


def split_frontmatter(text: str) -> tuple[str, str]:
    if not text.startswith("---\n"):
        return "", text
    lines = text.splitlines(keepends=True)
    for index in range(1, len(lines)):
        if lines[index] in ("---\n", "---"):
            return "".join(lines[: index + 1]), "".join(lines[index + 1 :])
    return "", text


def is_fence_line(line: str) -> str | None:
    stripped = line.lstrip()
    if stripped.startswith("```"):
        return "```"
    if stripped.startswith("~~~"):
        return "~~~"
    return None


def is_h2_heading(line: str, in_fence: bool) -> bool:
    return not in_fence and line.startswith("## ") and not line.startswith("###")


def extract_title(line: str) -> str:
    return line[3:].rstrip("\n").strip()


def parse_sections(body: str) -> tuple[str, list[Section]]:
    """Split body into a prefix (before first H2) and a list of H2 Sections."""
    lines = body.splitlines(keepends=True)
    prefix: list[str] = []
    sections: list[Section] = []
    current_heading: str | None = None
    current_title: str | None = None
    current_body: list[str] = []
    in_fence = False
    fence_marker: str | None = None

    for line in lines:
        if is_h2_heading(line, in_fence):
            if current_heading is not None:
                sections.append(
                    Section(current_title or "", current_heading, "".join(current_body))
                )
            current_heading = line
            current_title = extract_title(line)
            current_body = []
            # handle fence state for heading line itself
            continue

        if current_heading is None:
            prefix.append(line)
        else:
            current_body.append(line)

        marker = is_fence_line(line)
        if marker is not None:
            if not in_fence:
                in_fence = True
                fence_marker = marker
            elif marker == fence_marker:
                in_fence = False
                fence_marker = None

    if current_heading is not None:
        sections.append(
            Section(current_title or "", current_heading, "".join(current_body))
        )

    return "".join(prefix), sections


def merge_source_bodies(sections: list[Section]) -> str:
    """Merge bodies of multiple source sections, deduplicating lines."""
    seen: set[str] = set()
    merged_lines: list[str] = []
    last_was_blank = True

    for section in sections:
        for raw_line in section.body.splitlines():
            if not raw_line.strip():
                if merged_lines and not last_was_blank:
                    merged_lines.append("")
                    last_was_blank = True
                continue
            key = raw_line.strip()
            if key in seen:
                continue
            seen.add(key)
            merged_lines.append(raw_line)
            last_was_blank = False

    while merged_lines and merged_lines[-1] == "":
        merged_lines.pop()

    if not merged_lines:
        return "\n"
    return "\n" + "\n".join(merged_lines) + "\n"


def normalize_sections(sections: list[Section]) -> list[Section] | None:
    """Reorder/rename tail sections. Returns None if no changes needed."""
    # Find ALL tail-like sections anywhere in the list (not just contiguous trailing)
    # We gather them, pull them out, and re-append in correct order.

    # Identify indices of tail sections (scanning from end, but also anywhere)
    tail_indices: list[int] = []
    non_tail_after_tail = False

    # Scan backwards to find the contiguous tail block, but also detect
    # non-tail sections interleaved (e.g. "Next steps" after "Microsoft Learn references")
    # Strategy: find ALL sections with tail titles, collect them, remove from position,
    # re-append at end in correct order.

    has_source_alias = any(s.title in SOURCE_ALIASES for s in sections)
    has_see_also = any(s.title == "See Also" for s in sections)

    # Check if any reordering is needed
    # Collect all tail-titled sections
    tail_secs = [(i, s) for i, s in enumerate(sections) if s.title in TAIL_TITLES]

    if not tail_secs:
        return None  # Nothing to do

    # Check if there's anything to fix:
    # 1. Any source alias that needs renaming
    # 2. Tail sections not at the very end in correct order
    # 3. Takeaway/Disclaimer after See Also or Sources

    needs_rename = any(s.title in SOURCE_ALIASES for _, s in tail_secs)

    # Expected final order: ... [movable sections] [See Also] [Sources]
    # Check current order
    tail_titles_in_order = [s.title for _, s in tail_secs]

    # Normalise titles for order check
    def canonical(t: str) -> str:
        if t in SOURCE_TITLES:
            return "Sources"
        return t

    canonical_order = [canonical(t) for t in tail_titles_in_order]

    # Expected: movables first, then See Also, then Sources
    expected_order: list[str] = []
    for t in canonical_order:
        if t in MOVE_BEFORE_TAIL:
            expected_order.append(t)
    if "See Also" in canonical_order:
        expected_order.append("See Also")
    if "Sources" in canonical_order:
        expected_order.append("Sources")

    # Check: are tail sections contiguous at the end?
    last_tail_idx = tail_secs[-1][0]
    first_tail_idx = tail_secs[0][0]
    all_at_end = last_tail_idx == len(sections) - 1
    # Check if non-tail sections are interleaved among tail sections
    tail_idx_set = {i for i, _ in tail_secs}
    interleaved = (
        any(i not in tail_idx_set for i in range(first_tail_idx, last_tail_idx + 1))
        if len(tail_secs) > 1
        else False
    )

    # Need multiple sources merged?
    source_count = sum(1 for t in canonical_order if t == "Sources")
    needs_merge = source_count > 1

    needs_reorder = canonical_order != expected_order
    needs_move_to_end = not all_at_end or interleaved

    if (
        not needs_rename
        and not needs_reorder
        and not needs_merge
        and not needs_move_to_end
    ):
        return None

    # Rebuild: separate non-tail from tail, reorder tail
    non_tail = [s for i, s in enumerate(sections) if i not in tail_idx_set]
    movable = [s for _, s in tail_secs if s.title in MOVE_BEFORE_TAIL]
    see_also = [s for _, s in tail_secs if s.title == "See Also"]
    sources = [s for _, s in tail_secs if s.title in SOURCE_TITLES]

    rebuilt = list(non_tail)
    rebuilt.extend(movable)
    rebuilt.extend(see_also)

    if sources:
        merged = Section("Sources", "## Sources\n", merge_source_bodies(sources))
        rebuilt.append(merged)

    return rebuilt


def normalize_file(path: Path) -> str | None:
    """Returns normalized text, or None if no changes needed."""
    original = path.read_text(encoding="utf-8")
    frontmatter, body = split_frontmatter(original)
    prefix, sections = parse_sections(body)
    result = normalize_sections(sections)
    if result is None:
        return None

    rendered_sections: list[str] = []
    for section in result:
        rendered = section.raw()
        if not rendered.endswith("\n"):
            rendered += "\n"
        if not rendered.endswith("\n\n"):
            rendered += "\n"
        rendered_sections.append(rendered)

    rebuilt_body = prefix + "".join(rendered_sections)
    rebuilt = frontmatter + rebuilt_body
    if rebuilt == original:
        return None
    return rebuilt


def collect_markdown_files() -> list[Path]:
    excluded = {DOCS_ROOT / rel for rel in EXCLUDED_RELPATHS}
    return sorted(p for p in DOCS_ROOT.rglob("*.md") if p not in excluded)


def main() -> int:
    parser = argparse.ArgumentParser(description="Normalize markdown tail sections.")
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument(
        "--check", action="store_true", help="Exit non-zero if changes needed."
    )
    mode.add_argument("--apply", action="store_true", help="Rewrite files in place.")
    args = parser.parse_args()

    changed_files: list[Path] = []
    for path in collect_markdown_files():
        result = normalize_file(path)
        if result is None:
            continue
        changed_files.append(path)
        if args.apply:
            path.write_text(result, encoding="utf-8")

    for path in changed_files:
        print(path.relative_to(DOCS_ROOT.parent))
    print(f"Changed files: {len(changed_files)}")

    if args.check and changed_files:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
