# Artifact 01 — Duplicate-Cleanup Redirect Maps

**Wave**: Wave 2 Subwave 1 — duplicate file consolidation across VM, Networking, Functions
**Status**: Design (pre-implementation)
**Blocked on**: P5 baseline conformance PRs for the 3 target repos (VM#28, Networking#26, Functions#69)
**Depends on**: None (this artifact is self-contained)
**Owns**: One PR per repo (3 PRs total)
**Verified against**: Repo state on `main` and open P5 branches as of 2026-07-09

## Related issues

- **[azure-virtual-machine-practical-guide#29](https://github.com/yeongseon/azure-virtual-machine-practical-guide/issues/29)** — VM `disk-performance-issues` duplicate pair
- **[azure-networking-practical-guide#27](https://github.com/yeongseon/azure-networking-practical-guide/issues/27)** — Networking `dns-resolution` duplicate pair
- **[azure-functions-practical-guide#70](https://github.com/yeongseon/azure-functions-practical-guide/issues/70)** — Functions `troubleshooting/architecture` duplicate pair

## Executive summary

Three sibling repositories carry duplicate documentation pairs where a **richer canonical page** coexists with a **thinner stub page** covering the same topic. Both pages are wired into `mkdocs.yml`; both are reachable via search; both attract inbound cross-links from operations, platform, and troubleshooting hub pages. This creates three real problems for readers:

1. **Split authority** — Two pages appearing side-by-side in search results (e.g., `disk-performance-issues` and `performance/disk-performance-issues`) force the reader to guess which is authoritative.
2. **Inconsistent evidence** — Fixes and revisions applied to one page are not applied to the other; over time the pages drift factually.
3. **Wasted maintenance** — Every KQL update, every evidence-pack refresh, every MSLearn URL migration must be done twice or (more commonly) is done once and creates the drift in problem 2.

The consolidation is **structural**, not editorial. Each PR:

- Picks a **canonical URL** (a keep-alive path that all inbound references converge on).
- Deletes the loser file.
- Rewrites inbound Markdown links so they all point at the canonical URL.
- Removes the loser from `mkdocs.yml` nav.
- Adds a `## See Also` or `## Related` note on the canonical page acknowledging the merge, so readers who arrive from an external stale link know what happened.

No content is rewritten. Content merges (if the stub carries information the canonical does not) are called out per-repo below and are scoped tight.

## Redirect mechanism

An empirical check of `requirements-docs.txt` across all 10 sibling repos confirms:

> **No sibling repo has `mkdocs-redirects` installed.**

Every sibling repo builds from a two-plugin base (`mkdocs-material` and `mkdocs-minify-plugin`) plus `pymdown-extensions`. Adding `mkdocs-redirects` is a per-repo choice; the plugin is stable, actively maintained, and cheap to add. Two recommended paths for these three PRs:

| Path | Approach | Trade-off |
|---|---|---|
| **Path A (recommended)** | Add `mkdocs-redirects` plugin + `redirect_maps` config entry. All external inbound links to the loser URL keep working via HTTP 302. | +1 build dependency, +5-15 lines in `mkdocs.yml`. Reader gets seamless redirect. |
| **Path B (fallback)** | Do NOT add the plugin. Only rewrite internal Markdown links; accept that external inbound links to the loser URL break with a 404. | Zero new dependencies. External inbound links (Twitter posts, Stack Overflow answers, Google Search cache) return 404 until Google reindexes. |

**Recommendation per repo:**

| Repo | Recommended path | Justification |
|---|---|---|
| VM | Path A (add plugin) | 8 inbound refs to the loser URL and Google Search indexing has been stable for ≥6 months on the current URL. Reader impact of a 404 is meaningful. |
| Networking | Path A (add plugin) | 12 inbound refs to the loser URL. Same Google Search stability. Highest inbound-ref count of the three. |
| Functions | Path B (fallback) | Only 3 inbound refs; content-validation dashboard already lists both pages so the migration is visible; low external inbound-link exposure. |

Repo owners MAY choose Path B for VM and Networking too — the plugin add is an optional quality-of-service upgrade, not a MUST.

### Path A implementation reference

```yaml
# mkdocs.yml
plugins:
  - search
  - minify:
      # ... existing minify config ...
  - redirects:
      redirect_maps:
        # <loser-relative-path>: <canonical-relative-path>
        'troubleshooting/playbooks/performance/disk-performance-issues.md': 'troubleshooting/playbooks/disk-performance-issues.md'
```

```txt
# requirements-docs.txt
mkdocs-material
mkdocs-minify-plugin
mkdocs-redirects>=1.2.1
```

`mkdocs-redirects` emits an HTML `<meta http-equiv="refresh">` page at the loser URL on `mkdocs build`. Zero JS, zero server config, works on GitHub Pages.

---

## Repo 1 of 3 — VM `disk-performance-issues`

### Files

| Role | Path | Size | Structure |
|---|---|---:|---|
| **Canonical (keep)** | `docs/troubleshooting/playbooks/disk-performance-issues.md` | 11,618 B | Full playbook: symptom → diagnosis (Portal + KQL) → resolution → prevention → sources |
| **Stub (delete)** | `docs/troubleshooting/playbooks/performance/disk-performance-issues.md` | 4,128 B, 112 lines with diagram | Shorter playbook variant, includes one mermaid diagram not present on canonical |

### Inbound reference audit (2026-07-09)

**8 references point at the STUB URL** (`performance/disk-performance-issues.md`):

| File | Line | Current link text |
|---|---:|---|
| `docs/platform/disks-and-storage.md` | 62 | link to playbook |
| `docs/reference/managed-disk-types.md` | 50 | link to playbook |
| `docs/troubleshooting/index.md` | 62 | Troubleshooting hub |
| `docs/troubleshooting/playbooks/performance/slow-performance.md` | 103 | See Also cross-link |
| `docs/troubleshooting/quick-diagnosis-cards.md` | 52 | Card link |
| `docs/troubleshooting/playbooks/index.md` | 53 | Playbook index entry (performance category) |
| `docs/troubleshooting/decision-tree.md` | 47, 66 | Decision tree branches (2 refs in this file) |
| `docs/troubleshooting/first-10-minutes/performance.md` | 46 | First-10-minutes step |

**1 reference points at the CANONICAL URL** (bare `disk-performance-issues.md`):

| File | Line | Current link text |
|---|---:|---|
| `docs/troubleshooting/playbooks/index.md` | 36 | Playbook index entry (top-level) |

> **Note the inversion**: the stub URL is more widely linked (8 refs) than the canonical content URL (1 ref). This is the strongest signal that the current `mkdocs.yml` nav evolved AFTER most of the cross-linking work, and the "canonical" was picked based on file size, not on inbound-reference weight. This artifact keeps the larger, more complete file as canonical — but the PR MUST rewrite the 8 stub-URL references, not just the 1 canonical-URL reference.

### Content-merge check

Before deleting the stub, verify:

- [ ] Is the stub's mermaid diagram present on the canonical? If not, port it as part of the same PR (with `<!-- diagram-id: -->` comment per AGENTS.md).
- [ ] Does the stub cite any MSLearn URL the canonical omits? If yes, merge into canonical's `## Sources`.
- [ ] Does the stub tag any KQL query the canonical omits? If yes, port the KQL block.

Any merged content MUST be attributed in the PR description ("port from stub before delete").

### PR execution steps

1. Branch: `wave2/consolidate-disk-performance-playbook`.
2. Optional Path A: add `mkdocs-redirects` to `requirements-docs.txt` and configure `redirect_maps` in `mkdocs.yml`.
3. Merge missing content from stub → canonical (see content-merge checklist above).
4. Delete `docs/troubleshooting/playbooks/performance/disk-performance-issues.md`.
5. Rewrite the 8 stub-URL references + verify the 1 canonical-URL reference remains valid.
6. Remove the loser entry from `mkdocs.yml` nav.
7. Add a one-line `!!! note` at the top of the canonical page: `Consolidated with `troubleshooting/playbooks/performance/disk-performance-issues.md` on 2026-07-09.`
8. Run `mkdocs build --strict` — MUST pass with zero warnings.
9. Manually verify by `grep -rn "performance/disk-performance-issues" docs/` returning zero results.

### Success criteria

- [ ] Only one `disk-performance-issues.md` file exists in `docs/`.
- [ ] All 9 inbound references resolve to the canonical URL.
- [ ] `mkdocs build --strict` passes.
- [ ] If Path A chosen: HTTP GET on the loser URL returns a `<meta http-equiv=refresh>` page redirecting to the canonical.

---

## Repo 2 of 3 — Networking `dns-resolution`

### Files

| Role | Path | Size |
|---|---|---:|
| **Canonical (keep)** | `docs/troubleshooting/playbooks/dns-resolution-issues.md` | 11,698 B |
| **Stub (delete)** | `docs/troubleshooting/playbooks/dns/dns-resolution-failures.md` | 3,734 B |

### Inbound reference audit (2026-07-09)

**12 references point at the STUB URL** (`dns/dns-resolution-failures.md`):

| File | Line |
|---|---:|
| `docs/operations/configure-dns.md` | 45 |
| `docs/platform/dns-basics.md` | 47 |
| `docs/troubleshooting/evidence-map.md` | 33 |
| `docs/start-here/scenario-router.md` | 90, 103 |
| `docs/troubleshooting/architecture-overview.md` | 61, 63 |
| `docs/troubleshooting/decision-tree.md` | 62 |
| `docs/troubleshooting/quick-diagnosis-cards.md` | 41 |
| `docs/troubleshooting/index.md` | 50 |
| `docs/troubleshooting/first-10-minutes/dns.md` | 55 |
| `docs/troubleshooting/playbooks/dns-resolution-issues.md` | 314 |
| `docs/troubleshooting/playbooks/connectivity/cannot-reach-private-endpoint.md` | 84 |
| `docs/troubleshooting/playbooks/connectivity/outbound-connectivity-issues.md` | 85 |

> **Important edge case**: `playbooks/dns-resolution-issues.md:314` — the canonical page itself links to the stub. This is a stale self-reference from when the stub was believed to be a "detailed sibling"; it MUST be removed or repointed to a sensible anchor within the canonical itself.

**2 references point at the CANONICAL URL**:

| File | Line |
|---|---:|
| `docs/tutorials/lab-guides/lab-02-private-endpoints.md` | 240 |
| `docs/troubleshooting/playbooks/index.md` | 41 |

### Playbook index edge case

`docs/troubleshooting/playbooks/index.md` lists BOTH files:

- Line 41 → canonical (`dns-resolution-issues.md`)
- Line 59 → stub (`dns/dns-resolution-failures.md`)

Both entries currently appear on the rendered playbook index. The PR MUST remove line 59.

### Content-merge check

Same checklist as VM (mermaid diagrams, MSLearn URLs, KQL queries). Note that the stub carries the substring `-failures` in its filename while the canonical uses `-issues` — no reason to preserve the "failures" naming, canonical `-issues` naming aligns with peer repos.

### PR execution steps

1. Branch: `wave2/consolidate-dns-playbook`.
2. Optional Path A: add `mkdocs-redirects`.
3. Merge missing content from stub → canonical.
4. Delete `docs/troubleshooting/playbooks/dns/dns-resolution-failures.md`.
5. Rewrite the 12 stub-URL references (including the self-reference at canonical L314).
6. Verify the 2 canonical-URL references remain valid.
7. Remove line 59 of `playbooks/index.md`.
8. Remove the loser entry from `mkdocs.yml` nav.
9. Add consolidation `!!! note` at top of canonical.
10. `mkdocs build --strict` — MUST pass.
11. Verify `grep -rn "dns/dns-resolution-failures" docs/` returns zero results.

### Success criteria

Same 4 criteria as VM.

---

## Repo 3 of 3 — Functions `troubleshooting/architecture`

### Files

| Role | Path | Size |
|---|---|---:|
| **Canonical (keep)** | `docs/troubleshooting/architecture-overview.md` | 30,737 B |
| **Older (delete)** | `docs/troubleshooting/architecture.md` | 15,737 B |

### Inbound reference audit (2026-07-09)

Only **3 total references** across the entire repo:

| File | Line | Note |
|---|---:|---|
| `docs/reference/content-validation-status.md` | 84-85 | Generated dashboard — lists BOTH files as separate rows |
| `docs/platform/networking.md` | 440 | Links to old `architecture.md` |
| `mkdocs.yml` | (nav) | Both files present in Troubleshooting nav block |

Low inbound-ref count = Path B (no redirects plugin) is acceptable.

### Content-merge check

Functions' `architecture-overview.md` (30 KB) is a genuine superset of the older `architecture.md` (15 KB). The older file predates a 2026-Q1 rewrite that added the diagnostic evidence taxonomy, the Portal blade catalog, and the modern KQL query pack references. **Content merge is not expected to add material** — but verify at PR time:

- [ ] Any specific section on the old `architecture.md` missing from `architecture-overview.md`? Diff the two files.
- [ ] Any mermaid diagram unique to the old file? (Older doc predates the diagram-id convention, so any unique diagram must be added with a proper `<!-- diagram-id: -->` comment.)

### PR execution steps

1. Branch: `wave2/consolidate-troubleshooting-architecture-page`.
2. Path B (no redirects plugin needed — low inbound-ref count).
3. Merge any missing content from old file → canonical.
4. Delete `docs/troubleshooting/architecture.md`.
5. Rewrite `platform/networking.md:440` to point at `architecture-overview.md`.
6. Remove the loser entry from `mkdocs.yml` nav.
7. Regenerate `docs/reference/content-validation-status.md` (per Functions' `python3 scripts/generate_content_validation_status.py` command).
8. Add consolidation `!!! note` at top of canonical.
9. `mkdocs build --strict` — MUST pass.
10. Verify only `architecture-overview.md` exists in `docs/troubleshooting/`.

### Success criteria

- [ ] Only one `architecture*.md` file exists in `docs/troubleshooting/`.
- [ ] All 3 inbound references resolve.
- [ ] Regenerated content-validation dashboard shows one row, not two.
- [ ] `mkdocs build --strict` passes.

---

## Cross-repo verification

Once all 3 PRs merge:

- [ ] Meta issue [architecture#42](https://github.com/yeongseon/azure-architecture-practical-guide/issues/42) updated with links to the 3 merged PRs.
- [ ] Oracle post-implementation review (SYNC RESUME session `ses_0c9fa347cffeQv11ROULLRjMNp`) with the 3 PR diffs.
- [ ] Sibling issues (vm#29, networking#27, functions#70) closed with a link to their respective PR.

## Out of scope

- Consolidating any OTHER duplicate pairs in these 3 repos — this artifact addresses only the 3 pairs surfaced during Wave 2 Phase 3.9 empirical audit.
- Editorial rewrites of the canonical pages beyond the consolidation `!!! note` and any content merged from the loser file.
- Adding `mkdocs-redirects` as a series-wide MUST — that would be a contract amendment, forbidden by Oracle Phase 3.11.
- Auditing external inbound links (Google Search, Stack Overflow, blog posts) — those are best-effort; the redirects plugin handles them if Path A is chosen, otherwise they 404 until reindexed.

## References

- Wave 2 meta: [architecture#42](https://github.com/yeongseon/azure-architecture-practical-guide/issues/42)
- Series Nav Contract v1.1: [`docs/contributing/series-nav-contract.md`](../../../docs/contributing/series-nav-contract.md)
- `mkdocs-redirects` plugin: <https://github.com/mkdocs/mkdocs-redirects>
