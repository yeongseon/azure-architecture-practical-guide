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

Three sibling repositories carry duplicate documentation pairs where **two pages cover the same topic** — for VM and Networking, one at a categorized subpath URL and one at a flat URL; for Functions, a modern superset alongside an older superseded file. In all three pairs both pages are wired into `mkdocs.yml`; both are reachable via search; both attract inbound cross-links from operations, platform, and troubleshooting hub pages. This creates three real problems for readers:

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
| VM | Path A (add plugin) | External Google Search indexing on the flat (loser) URL has been stable for ≥6 months; Path A preserves those external inbound links via `<meta http-equiv=refresh>`. Internal inbound refs are already 8-of-9 on the canonical subpath URL, so the internal rewrite is minimal (1 ref). |
| Networking | Path A (add plugin) | Highest external inbound-link exposure of the three pairs — long-standing Google Search indexing on the flat (loser) URL; DNS troubleshooting content is a popular external landing target. Path A preserves those external inbound links. Internal inbound refs are already 12-of-14 on the canonical subpath URL, so the internal rewrite is minimal (2 refs). |
| Functions | Path B (fallback) | Only 3 internal refs; content-validation dashboard already lists both pages so the migration is visible; low external inbound-link exposure. |

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
        # For VM: flat URL redirects to the categorized subpath URL
        'troubleshooting/playbooks/disk-performance-issues.md': 'troubleshooting/playbooks/performance/disk-performance-issues.md'
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

### Canonical-URL selection rationale (Oracle Phase 3.12 correction)

Oracle Phase 3.12 verdict: canonical-URL choice for VM must be driven by **intended information architecture + current link gravity**, NOT by file size. Applied to this pair:

- **Link gravity**: 8 of the 9 inbound refs already point at the categorized subpath URL (`performance/disk-performance-issues.md`). Keeping the subpath URL preserves 8 refs; keeping the flat URL requires rewriting 8 refs.
- **Information architecture**: The subpath URL sits inside `playbooks/performance/` — a topic-taxonomy folder that groups performance playbooks together. The flat URL sits at the top of `playbooks/` — no topical grouping. The subpath URL is IA-correct.
- **Conclusion**: Keep the **subpath URL as canonical**. Move the richer content INTO the subpath file. Delete the flat file. Redirect the flat URL → subpath URL for external inbound stability.

### Files

| Role | Path | Size | Structure |
|---|---|---:|---|
| **Canonical (keep — receives richer content)** | `docs/troubleshooting/playbooks/performance/disk-performance-issues.md` | 4,128 B (before merge) → ~12 KB (after merge) | Currently a thinner playbook variant with one mermaid diagram; will receive the full symptom → diagnosis → resolution → prevention content merged in from the flat-URL file |
| **Loser (delete after content port)** | `docs/troubleshooting/playbooks/disk-performance-issues.md` | 11,618 B | Currently the richer playbook; content ports into the canonical, then this file is deleted |

### Inbound reference audit (2026-07-09)

**8 references already point at the canonical URL** (`performance/disk-performance-issues.md`) — NO rewrite needed:

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

**1 reference points at the loser URL** (bare `disk-performance-issues.md`) — MUST rewrite to subpath URL:

| File | Line | Rewrite target |
|---|---:|---|
| `docs/troubleshooting/playbooks/index.md` | 36 | Rewrite from `disk-performance-issues.md` → `performance/disk-performance-issues.md`. Then verify against the existing line 53 entry — they may become duplicate rows on the rendered playbook index; if so, remove one. |

Total inbound-ref rewrites in this PR: **1** (previous file-size-driven approach would have required 8 rewrites).

### Content port (loser → canonical, before delete)

The loser file is 3x larger and carries the mature playbook content. Every meaningful section MUST port into the canonical:

- [ ] **Symptom section** — port whole section into canonical (canonical's current symptom section is a stub).
- [ ] **Diagnosis Steps** — port Portal + KQL diagnosis blocks into canonical.
- [ ] **Resolution** — port resolution steps into canonical.
- [ ] **Prevention** — port prevention section into canonical.
- [ ] **Sources** — merge loser's `## Sources` into canonical's `## Sources` (dedupe).
- [ ] **Existing canonical mermaid diagram** — PRESERVE. Do not overwrite with loser's content if loser lacks the diagram.
- [ ] **Existing canonical `## See Also`** — merge loser's `## See Also` into it (dedupe).

After port, the canonical file becomes the sole authoritative playbook. The `## See Also` and diagram-id conventions per repo AGENTS.md MUST hold in the final file.

### PR execution steps

1. Branch: `wave2/consolidate-disk-performance-playbook-onto-subpath`.
2. **Path A recommended** (VM has 6+ months of stable Google Search indexing on the flat URL): add `mkdocs-redirects` to `requirements-docs.txt`, configure `redirect_maps` in `mkdocs.yml` — flat URL `troubleshooting/playbooks/disk-performance-issues.md` → subpath URL `troubleshooting/playbooks/performance/disk-performance-issues.md`.
3. Port richer content from loser (`playbooks/disk-performance-issues.md`) into canonical (`playbooks/performance/disk-performance-issues.md`) per content-port checklist above.
4. Delete `docs/troubleshooting/playbooks/disk-performance-issues.md`.
5. Rewrite the single loser-URL reference in `playbooks/index.md:36` to the canonical subpath URL.
6. Remove the loser entry from `mkdocs.yml` nav (the flat-URL entry).
7. Add a one-line `!!! note` at the top of the canonical page: `Merged with the flat-URL variant `troubleshooting/playbooks/disk-performance-issues.md` on 2026-07-09. Content sourced from both files; the subpath URL is now the sole home for this playbook.`
8. Run `mkdocs build --strict` — MUST pass with zero warnings.
9. Manually verify with `grep -rn "playbooks/disk-performance-issues" docs/ | grep -v "performance/disk"` returning zero results.
10. Manually browse both URLs on the built site — subpath URL renders the full playbook; flat URL returns the redirect meta-refresh page.

### Success criteria

- [ ] Only one `disk-performance-issues.md` file exists in `docs/` (at the subpath location).
- [ ] All 9 inbound references resolve to the canonical subpath URL.
- [ ] Full playbook content (symptom → diagnosis → resolution → prevention) is present on the canonical.
- [ ] `mkdocs build --strict` passes.
- [ ] HTTP GET on the flat URL returns the `<meta http-equiv=refresh>` redirect to the subpath URL.

---

## Repo 2 of 3 — Networking `dns-resolution`

### Canonical-URL selection rationale (Oracle Phase 3.12 correction)

Same principle as VM: **IA + link gravity > file size.** Applied to Networking:

- **Link gravity**: 12 of the 14 inbound refs already point at the categorized subpath URL (`dns/dns-resolution-failures.md`). Keeping the subpath URL preserves 12 refs; keeping the flat URL requires rewriting 12 refs.
- **Information architecture**: The subpath URL sits inside `playbooks/dns/` — the topic-taxonomy folder for DNS playbooks. The flat URL sits at the top of `playbooks/` — no topical grouping. The subpath URL is IA-correct.
- **Filename choice**: The subpath filename is `dns-resolution-failures.md`; the flat filename is `dns-resolution-issues.md`. Oracle Phase 3.12 flagged unified filenames as "worth considering" but the correction directive weighs **link stability over filename aesthetics**. Renaming the subpath file to `-issues.md` would force 12 additional ref rewrites; keeping `-failures.md` requires 0 filename rewrites. **Recommendation: keep the existing `dns-resolution-failures.md` filename**. A future editorial pass MAY unify the filename to `-issues.md` for peer-repo consistency; that is out of scope for this consolidation PR.
- **Conclusion**: Keep the **subpath URL as canonical**. Port the richer content from the flat file INTO the subpath file. Delete the flat file. Redirect the flat URL → subpath URL.

### Files

| Role | Path | Size |
|---|---|---:|
| **Canonical (keep — receives richer content)** | `docs/troubleshooting/playbooks/dns/dns-resolution-failures.md` | 3,734 B (before merge) → ~12 KB (after merge) |
| **Loser (delete after content port)** | `docs/troubleshooting/playbooks/dns-resolution-issues.md` | 11,698 B |

### Inbound reference audit (2026-07-09)

**12 references already point at the canonical URL** (`dns/dns-resolution-failures.md`) — NO rewrite needed:

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

> **Important edge case**: `playbooks/dns-resolution-issues.md:314` — the LOSER file has a link to the canonical. This link is INSIDE the file being deleted, so the reference disappears when the file is deleted. NO separate rewrite needed. (In the previous file-size-driven design this was a "self-reference" edge case; under the corrected IA-driven design it becomes a non-issue.)

**2 references point at the loser URL** (`dns-resolution-issues.md`) — MUST rewrite to canonical subpath URL:

| File | Line | Rewrite target |
|---|---:|---|
| `docs/tutorials/lab-guides/lab-02-private-endpoints.md` | 240 | Rewrite from `../../troubleshooting/playbooks/dns-resolution-issues.md` → `../../troubleshooting/playbooks/dns/dns-resolution-failures.md` |
| `docs/troubleshooting/playbooks/index.md` | 41 | Rewrite from `dns-resolution-issues.md` → `dns/dns-resolution-failures.md`. Then verify against line 59 (existing subpath entry) — merge the two rows if they become duplicates on the rendered playbook index. |

Total inbound-ref rewrites in this PR: **2** (previous file-size-driven approach would have required 12 rewrites).

### Playbook index edge case

`docs/troubleshooting/playbooks/index.md` currently lists BOTH files:

- Line 41 → LOSER (`dns-resolution-issues.md`) — rewrite to canonical URL per audit table above, then check whether the resulting row duplicates line 59.
- Line 59 → CANONICAL (`dns/dns-resolution-failures.md`) — keep.

If the rewrite at line 41 makes it duplicate line 59, delete line 41 (keep the categorized-section placement at line 59).

### Content port (loser → canonical, before delete)

Same checklist shape as VM: port symptom, diagnosis, resolution, prevention, sources, see-also from loser into canonical. Preserve any diagram/content already in canonical.

Post-port content check:

- [ ] Canonical file title reads sensibly (may want to change H1 from `# DNS Resolution Failures` → `# DNS Resolution Issues` for peer-repo consistency; H1 change does NOT require a filename change, does NOT break inbound refs).
- [ ] No mention of the flat-URL filename remains inside the canonical text.

### PR execution steps

1. Branch: `wave2/consolidate-dns-playbook-onto-subpath`.
2. **Path A recommended** (highest inbound-ref count of the three pairs, strongest Google Search exposure): add `mkdocs-redirects` to `requirements-docs.txt`, configure `redirect_maps` — flat URL `troubleshooting/playbooks/dns-resolution-issues.md` → subpath URL `troubleshooting/playbooks/dns/dns-resolution-failures.md`.
3. Port richer content from loser into canonical per content-port checklist.
4. Optionally update canonical H1 to `# DNS Resolution Issues` for peer-repo consistency (H1 only, not filename).
5. Delete `docs/troubleshooting/playbooks/dns-resolution-issues.md`.
6. Rewrite the 2 loser-URL references per audit table above.
7. Merge/dedupe `playbooks/index.md` lines 41 and 59 as needed.
8. Remove the loser entry from `mkdocs.yml` nav.
9. Add consolidation `!!! note` at top of canonical.
10. `mkdocs build --strict` — MUST pass.
11. Verify with `grep -rn "playbooks/dns-resolution-issues" docs/ | grep -v "dns/dns-resolution-failures"` returning zero results.
12. Manually browse both URLs on built site — subpath renders full playbook; flat URL returns redirect meta-refresh.

### Success criteria

- [ ] Only one `dns-resolution*.md` playbook file exists in `docs/troubleshooting/playbooks/` (at the `dns/` subpath location).
- [ ] All 14 inbound references resolve to the canonical subpath URL.
- [ ] Full playbook content is present on canonical (symptom → diagnosis → resolution → prevention).
- [ ] `mkdocs build --strict` passes.
- [ ] HTTP GET on the flat URL returns the `<meta http-equiv=refresh>` redirect to the subpath URL.

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
