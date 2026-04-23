#!/usr/bin/env python3
"""Add missing content_validation frontmatter to markdown files.

Scans docs/ for markdown files that already define content_sources in YAML
frontmatter but do not yet define content_validation. For each eligible file,
the script inserts a generated content_validation block immediately before the
closing frontmatter fence while leaving the rest of the document unchanged.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Any

import yaml

ROOT_DIR = Path(__file__).resolve().parent.parent
DOCS_DIR = ROOT_DIR / "docs"
DEFAULT_SOURCE_URL = "https://learn.microsoft.com/en-us/azure/architecture/"
REVIEW_DATE = "2026-04-22"
FRONTMATTER_RE = re.compile(r"\A---\s*\n(.*?)\n---\s*\n?", re.DOTALL)
LEARN_URL_RE = re.compile(r"https://learn\.microsoft\.com[^\s)\]>\"']*")
EVIDENCE_TAG_RE = re.compile(
    r"\[(?:Documented|Observed|Measured|Validated|Correlated|Inferred|Assumed|Unknown)\]\s*",
    re.IGNORECASE,
)


def extract_frontmatter(text: str) -> tuple[str, dict[str, Any], str, int] | None:
    """Return raw frontmatter, parsed data, body text, and closing fence offset."""
    match = FRONTMATTER_RE.match(text)
    if not match:
        return None

    raw_frontmatter = match.group(1)
    parsed = yaml.safe_load(raw_frontmatter) or {}
    if not isinstance(parsed, dict):
        return None

    body = text[match.end() :]
    closing_offset = text.find("\n---", match.start(1) + len(raw_frontmatter)) + 1
    return raw_frontmatter, parsed, body, closing_offset


def ordered_unique(items: list[str]) -> list[str]:
    seen: set[str] = set()
    result: list[str] = []
    for item in items:
        normalized = item.strip()
        if not normalized or normalized in seen:
            continue
        seen.add(normalized)
        result.append(normalized)
    return result


def extract_title(body: str, fallback: str) -> str:
    for line in body.splitlines():
        stripped = line.strip()
        if stripped.startswith("# "):
            return stripped[2:].strip()
    return fallback


def normalize_line(line: str) -> str:
    text = line.strip()
    text = re.sub(r"^#{1,6}\s+", "", text)
    text = re.sub(r"^[-*+]\s+", "", text)
    text = re.sub(r"^\d+\.\s+", "", text)
    text = EVIDENCE_TAG_RE.sub("", text)
    text = re.sub(r"`([^`]*)`", r"\1", text)
    text = re.sub(r"!?\[([^\]]+)\]\([^\)]+\)", r"\1", text)
    text = re.sub(r"\s+", " ", text)
    return text.strip(" :-")


def summarize_focus(text: str, title: str) -> str | None:
    cleaned = normalize_line(text)
    if not cleaned:
        return None
    if len(cleaned) < 12:
        return None
    if cleaned.startswith("<!--") or cleaned.startswith("```"):
        return None
    if cleaned.lower().startswith(("see also", "sources")):
        return None

    first_sentence = re.split(r"(?<=[.!?])\s+", cleaned, maxsplit=1)[0].rstrip(".!?")
    first_sentence = first_sentence[:140].rstrip(" ,;:-")
    if len(first_sentence) < 12:
        return None

    lowered = first_sentence.lower()
    title_lower = title.lower()
    if title_lower in lowered:
        return first_sentence
    return f"{title} includes guidance on {first_sentence[0].lower()}{first_sentence[1:]}"


def extract_candidate_claims(body: str, title: str) -> list[str]:
    lines = body.splitlines()
    headings: list[str] = []
    keyword_lines: list[str] = []
    service_pattern = re.compile(
        r"\b(Azure|architecture|landing zone|Well-Architected|App Service|AKS|Kubernetes|Functions|Cosmos DB|Service Bus|Event Grid|Virtual WAN|hub-spoke|private endpoint|identity|network|resilience|governance|observability|cost)\b",
        re.IGNORECASE,
    )

    for line in lines:
        stripped = line.strip()
        if not stripped or stripped.startswith("```"):
            continue
        if stripped.startswith("##"):
            headings.append(normalize_line(stripped))
        if service_pattern.search(stripped):
            keyword_lines.append(stripped)

    candidates: list[str] = [
        f"Document covers {title} aligned with Azure architecture guidance",
        f"Document includes Microsoft Learn-traceable guidance for {title}",
    ]

    for heading in headings[:3]:
        if heading:
            candidates.append(f"Document addresses {heading} for {title}")

    for line in keyword_lines[:5]:
        focus = summarize_focus(line, title)
        if focus:
            candidates.append(focus)

    filtered = ordered_unique(candidates)
    if len(filtered) < 2:
        filtered.append(f"Document includes architecture practices relevant to {title}")
    return filtered[:5]


def extract_learn_urls(text: str) -> list[str]:
    return ordered_unique(LEARN_URL_RE.findall(text))


def build_content_validation_block(claims: list[str], source_urls: list[str]) -> str:
    sources = source_urls or [DEFAULT_SOURCE_URL]
    core_claims = [
        {
            "claim": claim,
            "source": sources[index % len(sources)],
            "verified": False,
        }
        for index, claim in enumerate(claims)
    ]
    block = {
        "content_validation": {
            "status": "pending_review",
            "last_reviewed": REVIEW_DATE,
            "reviewer": "agent",
            "core_claims": core_claims,
        }
    }
    return yaml.safe_dump(block, sort_keys=False, allow_unicode=True).rstrip()


def update_file(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    extracted = extract_frontmatter(text)
    if extracted is None:
        return False

    raw_frontmatter, frontmatter, body, closing_index = extracted
    if "content_sources" not in frontmatter or "content_validation" in frontmatter:
        return False

    title = extract_title(body, path.stem.replace("-", " ").title())
    urls = extract_learn_urls(f"{raw_frontmatter}\n{body}")
    claims = extract_candidate_claims(body, title)
    validation_block = build_content_validation_block(claims, urls)

    if closing_index == -1:
        raise ValueError(f"Unable to locate closing frontmatter fence in {path}")

    insertion = f"{validation_block}\n"
    new_text = f"{text[:closing_index]}{insertion}{text[closing_index:]}"

    verification = extract_frontmatter(new_text)
    if verification is None:
        raise ValueError(f"Updated frontmatter could not be parsed for {path}")

    _, verified_frontmatter, _, _ = verification
    yaml.safe_load(verification[0])
    content_validation = verified_frontmatter.get("content_validation")
    if not isinstance(content_validation, dict):
        raise ValueError(f"Missing content_validation after update for {path}")

    path.write_text(new_text, encoding="utf-8")
    return True


def main() -> None:
    updated = 0
    scanned = 0
    for path in sorted(DOCS_DIR.rglob("*.md")):
        scanned += 1
        if update_file(path):
            updated += 1

    print(f"Scanned markdown files: {scanned}")
    print(f"Updated files: {updated}")


if __name__ == "__main__":
    main()
