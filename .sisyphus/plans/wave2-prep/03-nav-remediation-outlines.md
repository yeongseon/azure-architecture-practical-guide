# Artifact 03 — Nav Remediation Outlines (#111, #18)

**Wave**: Wave 2 Subwave 3 — nav conformance for App Service and Communication Services
**Status**: Design (pre-implementation)
**Blocked on**: P5 baseline conformance PRs for both repos (app-service#110, acs#17)
**Owns**: One PR per repo (2 PRs total, may run in parallel)

## Related issues

- **[azure-app-service-practical-guide#111](https://github.com/yeongseon/azure-app-service-practical-guide/issues/111)** — nav conformance to series contract
- **[azure-communication-services-practical-guide#18](https://github.com/yeongseon/azure-communication-services-practical-guide/issues/18)** — nav conformance to series contract

## Executive summary

App Service (app-service#111) and Communication Services (acs#18) both fail Series Nav Contract v1.1 MUST 3 (Reference position) and MUST 5 (top-level count) with the **same delta pattern**:

- Reference at position 8 out of 11 top-level entries.
- `Visualization` and `Meta` sit between Reference and Contributing at positions 9 and 10.
- Top-level count is 11 — exceeds the 6-9 MUST budget with no pre-approved +2 exception (only container-apps, functions, architecture are pre-approved in § 7).

Because the delta pattern is identical, one design decision drives both PRs. The 3 options originally scoped in each issue are:

- **Option A** — reorder to Ops → TS → Visualization → Meta → Reference → Contributing, AND amend the series contract to whitelist Visualization/Meta as approved 코드형 extensions, AND amend § 7 to grant these two repos +2 exceptions.
- **Option B** — fold Visualization + Meta under Reference as sub-navigation. Top-level count returns to 9. No contract amendment.
- **Option C** — relocate Visualization + Meta content to hub pages only (`docs/visualization/index.md`, `docs/meta/index.md`). Remove top-level nav entries. Top-level count returns to 9. No contract amendment.

**Recommendation: Option B for both repos** (rationale below). Option C is a defensible alternative that requires more editorial work. Option A is discouraged because it doubles the contract-amendment surface Wave 2 just closed with PR #47.

## Contract gap analysis

The nav contract v1.1 § 4 (문서형 approved extensions) and § 5 (코드형 approved extensions) do NOT list `Visualization` or `Meta`. Reading them literally, these sections are non-approved extensions in every archetype.

However, container-apps `AGENTS.md` "Series-Wide Documentation Contract" → "Approved Extension Sections" table DOES list both:

> `Visualization` — Visual maps are a deliberate learning surface, not generated leftovers
> `Meta` — Repository taxonomy, content model, or generated metadata

This is a **contract-vs-AGENTS.md drift**. The AGENTS.md list is the older document and predates the series-nav-contract; the nav contract § 4/§ 5 lists are the newer canonical source and should win.

Implications:

- Option A requires reconciling this drift by amending § 5. Doable but heavy — Wave 2 Phase 3.11 explicitly limited contract amendments to MUST 6, and Oracle's discipline directive is to not open new contract amendments in this wave.
- Options B and C sidestep the drift entirely. `Visualization` and `Meta` disappear from the top-level nav; whether the contract § 5 whitelists them becomes irrelevant.

## Verified nav state (as of 2026-07-09)

Both repos have completed their P5 baseline conformance branches (`feat/p5-baseline-conformance` at app-service@1326a1d, acs@b73422f). Both branches show identical nav shapes:

**App Service `feat/p5-baseline-conformance/mkdocs.yml`** (11 top-level entries):

| Pos | Entry | Line |
|---:|---|---:|
| 1 | Home | 98 |
| 2 | Start Here | 99 |
| 3 | Platform | 105 |
| 4 | Best Practices | 124 |
| 5 | Language Guides | 134 |
| 6 | Operations | 243 |
| 7 | Troubleshooting | 260 |
| 8 | Reference | 347 |
| 9 | Visualization | 356 |
| 10 | Meta | 361 |
| 11 | Contributing | 363 |

**Communication Services `feat/p5-baseline-conformance/mkdocs.yml`** (11 top-level entries):

| Pos | Entry | Line |
|---:|---|---:|
| 1 | Home | 96 |
| 2 | Start Here | 97 |
| 3 | Platform | 103 |
| 4 | Best Practices | 113 |
| 5 | SDK Guides | 122 |
| 6 | Operations | 202 |
| 7 | Troubleshooting | 214 |
| 8 | Reference | 263 |
| 9 | Visualization | 273 |
| 10 | Meta | 278 |
| 11 | Contributing | 280 |

Line numbers are stable from P5 merge to Subwave 3 PR start, unless another PR touches `mkdocs.yml` in between.

---

## Option A — reorder + contract amendment (NOT RECOMMENDED)

### Nav diff (both repos, structurally identical)

```yaml
# Before (positions 8-11):
- Reference:      # pos 8
- Visualization:  # pos 9
- Meta:           # pos 10
- Contributing:   # pos 11

# After:
- Visualization:  # pos 8
- Meta:           # pos 9
- Reference:      # pos 10
- Contributing:   # pos 11
```

Reference moves to position 10 (second-to-last, per MUST 3 ✅). Visualization and Meta stay top-level.

### Required contract amendments (Architecture repo)

- Amend `series-nav-contract.md` § 5 to add `Visualization` and `Meta` to the 코드형 approved extensions list.
- Amend § 7 to grant app-service and communication-services a +2 exception (matching container-apps, functions, architecture).

### Why NOT recommended

1. **Contradicts Oracle Phase 3.11**: contract amendments are limited to the MUST 6 amendment shipped in PR #47. Adding two more amendments in the same wave opens the contract to gradual weakening.
2. **Doubles review surface**: 2 sibling PRs + 1 contract-amendment PR = 3 reviews, cross-repo dependency.
3. **Precedent risk**: If Visualization/Meta earn a +2 exception here, storage/monitoring/networking will ask for one next. The contract's exception budget becomes a routine ask.
4. **Only defensible if**: The repo owner has strong editorial reasons to keep Visualization and Meta as top-level nav entries. On review of the actual pages, this is not the case — see Option B / C rationale.

---

## Option B — fold Visualization + Meta under Reference (RECOMMENDED)

### Nav diff (App Service)

```yaml
# Before (lines 347-364):
  - Reference:
      - Overview: reference/index.md
      - Content Validation Status: reference/content-validation-status.md
      # ... existing Reference children ...
  - Visualization:
      - Overview: visualization/index.md
      - Site Graph: visualization/site-graph.md
      # ... existing Visualization children ...
  - Meta:
      - Overview: meta/index.md
      - Taxonomy: meta/taxonomy.md
      # ... existing Meta children ...
  - Contributing:
      - contributing/index.md

# After (structurally):
  - Reference:
      - Overview: reference/index.md
      - Content Validation Status: reference/content-validation-status.md
      # ... existing Reference children ...
      - Visualization:                          # NEW sub-section
          - visualization/index.md
          - visualization/site-graph.md
          # ... moved from top-level ...
      - Meta:                                    # NEW sub-section
          - meta/index.md
          - meta/taxonomy.md
          # ... moved from top-level ...
  - Contributing:
      - contributing/index.md
```

Top-level count: 11 → 9. Reference position: 8 → 8 (second-to-last, MUST 3 ✅). Reference direct children go up by 2 (one for the Visualization sub-heading, one for the Meta sub-heading), which SHOULD land Reference within the 5-8 SHOULD range or 9-12 tolerance range depending on current count — verify at PR time.

### Nav diff (Communication Services)

Structurally identical. Line refs different (Visualization at 273, Meta at 278; Reference at 263).

### File-move impact

**Zero file moves.** The Markdown files stay at their current paths (`docs/visualization/*.md`, `docs/meta/*.md`). Only `mkdocs.yml` changes. All internal cross-links keep working; no `mkdocs-redirects` plugin needed.

### Considerations

- Reference direct children may briefly exceed 8 after the fold. If the count lands at 10-12, the SHOULD tier explicitly permits 9-12 without justification. If the count exceeds 12, the MUST 6 outlier guardrail triggers and the PR MUST document justification in `AGENTS.md`.
- Semantic fit: Reference is a lookup surface; Visualization (site graphs, document maps) and Meta (taxonomy, content model) ARE lookup surfaces for site structure. The fold is not a stretch.
- The visible section name change ("Visualization" moves from top-level to `Reference > Visualization`) is a small UX shift. Readers who bookmarked the top-level Visualization entry get a broken menu path but the pages themselves keep loading.

### PR execution steps (per repo, same for both)

1. Branch: `wave2/nav-fold-visualization-meta-under-reference`.
2. Move Visualization block from top-level to under Reference in `mkdocs.yml`. Preserve internal ordering of visualization children.
3. Move Meta block similarly.
4. Verify Reference direct-child count post-fold. If ≥13, document justification in `AGENTS.md` per MUST 6 outlier rule.
5. Update any internal cross-link that used the top-level path (unlikely, since `mkdocs.yml` nav paths don't affect Markdown link URLs — but grep for `../../visualization/` and `../../meta/` patterns just to be safe).
6. `mkdocs build --strict` — MUST pass.
7. Manually browse `/reference/visualization/` and `/reference/meta/` in the built site — MUST render correctly.

### Success criteria

- [ ] Top-level count is 9.
- [ ] Reference is at position 8 (second-to-last).
- [ ] All Visualization and Meta pages are still reachable via nav.
- [ ] Contract § 3 MUST 3, MUST 5, MUST 6 all pass.
- [ ] `mkdocs build --strict` passes.

---

## Option C — hub-page only, remove top-level nav entries

### Nav diff (both repos)

```yaml
# Before (positions 8-11):
- Reference:      # pos 8
- Visualization:  # pos 9  ← DELETE from nav
- Meta:           # pos 10 ← DELETE from nav
- Contributing:   # pos 11

# After (positions 8-9):
- Reference:      # pos 8 (second-to-last)
- Contributing:   # pos 9
```

Top-level count: 11 → 9. Reference is second-to-last per MUST 3 ✅.

### File-move impact

Visualization and Meta content pages stay in `docs/visualization/` and `docs/meta/`. Only `mkdocs.yml` changes. Contract § 3 MUST 6 explicitly allows "deep inventory on hub pages, not in `mkdocs.yml`" — this is that pattern.

### Trade-off vs Option B

| Dimension | Option B (fold) | Option C (hub-only) |
|---|---|---|
| Discoverability from top-level nav | Yes — nested under Reference | No — only via hub page or search |
| Editorial complexity | Zero — pure nav shuffle | Zero — pure nav delete + verify hub |
| Hub-page requirement | None | `visualization/index.md` and `meta/index.md` MUST be complete hub pages listing all children with links |
| Reader intuition | Reference IS the surface for lookup, so Visualization+Meta belong there | Visualization+Meta are meta-content, best consumed via search/hub not top-level nav |
| Contract § 3 MUST 6 alignment | Neutral | Strong — this is the pattern MUST 6 explicitly encourages |

**Option C is the "pure MUST 6" choice.** It requires that the hub pages (`docs/visualization/index.md`, `docs/meta/index.md`) actually list all children with links — verify this BEFORE removing the top-level nav entry. If the hub pages are stubs, Option C requires editorial work to complete them first.

### Prerequisite check (per repo, before choosing Option C)

- [ ] `docs/visualization/index.md` exists and lists all `docs/visualization/*.md` pages with descriptive links.
- [ ] `docs/meta/index.md` exists and lists all `docs/meta/*.md` pages with descriptive links.

If either check fails, Option C requires an editorial completion pass on the hub page as part of the same PR.

### PR execution steps (per repo)

1. Branch: `wave2/nav-remove-visualization-meta-top-level`.
2. Run prerequisite hub-page completeness check.
3. Complete hub pages if they are stubs.
4. Delete Visualization and Meta blocks from top-level `mkdocs.yml`.
5. Verify neither entry appears in the built site's main nav.
6. Add a `!!! note` at the top of each hub page: `This section is not in the top-level navigation. Access via search or the Reference index.`
7. `mkdocs build --strict` — MUST pass.

### Success criteria

- [ ] Top-level count is 9.
- [ ] Reference is at position 8 (second-to-last).
- [ ] Visualization and Meta hub pages list all children.
- [ ] `mkdocs build --strict` passes.

---

## Recommendation matrix

| Criterion | Option A | Option B | Option C |
|---|---|---|---|
| Requires contract amendment | Yes (§ 5, § 7) | No | No |
| Requires editorial completion of hub pages | No | No | Maybe (verify first) |
| Reader can find Visualization/Meta via top-nav | Yes (top-level) | Yes (under Reference) | No (search or hub) |
| Contract § 3 MUST 3 pass | Yes | Yes | Yes |
| Contract § 3 MUST 5 pass | Yes (with amendment) | Yes | Yes |
| Contract § 3 MUST 6 pass | Neutral | Yes (fold, no >12) | Strong yes |
| Cross-repo review scope | 2 sibling PRs + 1 contract PR = 3 reviews | 2 sibling PRs = 2 reviews | 2 sibling PRs = 2 reviews |
| Risk of setting precedent | High (routine +2 exception ask) | Low | Low |

**Final recommendation: Option B for both repos.** Same PR shape, same review criteria, deployable in parallel. Consult Oracle Phase 3.12 for final confirmation before opening the PRs.

If Option B fold pushes Reference direct-children over 12 in either repo, escalate to Option C for that repo only (mixed strategy is acceptable).

## Out of scope

- Amending the series nav contract § 5 to whitelist Visualization/Meta as approved 코드형 extensions (Option A only, and Option A is not recommended).
- Editing the CONTENT of Visualization or Meta pages beyond a hub-page completeness pass (Option C prerequisite).
- Other nav reorganizations in these repos beyond the Reference/Visualization/Meta positions.
- Any nav changes to storage, networking, monitoring, VM, aks — those repos are already compliant per contract § 7 table.

## Cross-repo verification

Once both PRs merge:

- [ ] Meta issue [architecture#42](https://github.com/yeongseon/azure-architecture-practical-guide/issues/42) updated with links to the 2 merged PRs.
- [ ] Oracle post-implementation review (SYNC RESUME session `ses_0c9fa347cffeQv11ROULLRjMNp`) with the 2 PR diffs.
- [ ] Sibling issues (app-service#111, acs#18) closed with a link to their respective PR.

## References

- Wave 2 meta: [architecture#42](https://github.com/yeongseon/azure-architecture-practical-guide/issues/42)
- Series Nav Contract v1.1: [`docs/contributing/series-nav-contract.md`](../../../docs/contributing/series-nav-contract.md)
- MUST 6 amendment (Phase 3.11): [architecture#47](https://github.com/yeongseon/azure-architecture-practical-guide/pull/47) (MERGED)
- App Service P5 branch: `feat/p5-baseline-conformance` @ 1326a1d
- ACS P5 branch: `feat/p5-baseline-conformance` @ b73422f
