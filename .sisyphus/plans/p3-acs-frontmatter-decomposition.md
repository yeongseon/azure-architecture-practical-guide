# P3-ACS: Canonical content_sources.diagrams Migration + Validator Enablement — Decomposition Plan

**Status**: COMPLETE (2026-07-05). All 8 waves shipped; strict CI enforcement live on ACS.
**Tracker**: [yeongseon/azure-communication-services-practical-guide#15](https://github.com/yeongseon/azure-communication-services-practical-guide/issues/15) (closed)
**Final validator state**: 0 errors across 56 mermaid-bearing pages
**Wave commits (on `yeongseon/azure-communication-services-practical-guide` main)**:

| Wave | Section | Files | Commit |
|---|---|---|---|
| 0 | Validator bootstrap | 5 (scripts + workflow) | `9825dee` |
| 1 | Platform | 9 | `2a2115b` |
| 2 | Best Practices | 8 | `ae53710` |
| 3 | Operations | 9 | `071b5c9` |
| 4 | Troubleshooting | 6 | `834e81f` |
| 5 | SDK Guides | 9 | `c18de34` |
| 6 | Leftovers | 11 | `7fd704b` |
| 7 | Strict CI flip | 1 | `2a59d1e` |

**Scope**: Single repo (ACS = azure-communication-services-practical-guide). Frontmatter `content_sources` provenance schema migration + validator bootstrap.
**Author**: Sisyphus (agent) with Oracle consultation
**Predecessor audit**: [P2-1 (#36, closed)](https://github.com/yeongseon/azure-architecture-practical-guide/issues/36) — [`p2-frontmatter-audit.md`](https://github.com/yeongseon/azure-architecture-practical-guide/blob/main/.sisyphus/plans/p2-frontmatter-audit.md)
**Oracle decomposition**: session `ses_0d01a9cdeffeJmNr5HQk99ENO2` (task `bg_8d633590`, 1m 36s)
**Parent tracker**: [P2 meta-tracker #34](https://github.com/yeongseon/azure-architecture-practical-guide/issues/34)

**Home rationale**: This decomposition plan lives in the architecture repo (meta-tracker home) rather than in ACS itself because ACS gitignores `.sisyphus/` while sibling repos do not. Storing the plan here preserves audit trail without overriding ACS's existing repo convention. The plan is referenced from the ACS meta-issue by URL.

---

## 1. Executive Summary

ACS (azure-communication-services-practical-guide) is the **single primary migration target** identified by the P2-1 series-wide audit. 121 of 136 `content_sources`-bearing markdown files (89%) use non-canonical legacy shapes. Additionally, even the 15 files that DO use the canonical `content_sources.diagrams[…]` container have a **field-conflation semantic bug** (`type: self-generated` where canonical requires `source: self-generated` + `type: <mermaid-type>`).

Total mutation surface:

- **121 files**: legacy shape → canonical container shape
- **136 files**: `type` vs `source` field-conflation cleanup (overlaps with above; net unique files touched = 136)

Oracle's recommended strategy: **incremental waves by content category, capped at ~20 files per PR, with validators ported first in permissive (non-blocking) mode, and manual per-file review using a fixed provenance rubric.**

## 2. Non-Canonical Shape Inventory (from P2-1 audit)

### 2.1 Bare-string list (87 files)

```yaml
content_sources:
  - azure-docs
  - communication-services-sdk
```

Or:

```yaml
content_sources:
  - https://learn.microsoft.com/azure/communication-services/overview
```

**Concentrated in**: `docs/visualization/*`, `docs/troubleshooting/*` (playbooks, first-10-minutes, decision-tree, evidence-map, mental-model, methodology), `docs/meta/*`.

### 2.2 Dict-list without `diagrams:` container (34 files)

Three sub-variants (per audit §4.2):

- **Sub-variant 4.2.a "rich"** (18 files): has `id`, `type`, `source`, `justification`, `based_on`. Just needs `diagrams:` container wrapping.
- **Sub-variant 4.2.b "url-only"** (8 files): has `type`, `url`. Missing `id`. Uses `url:` not `mslearn_url:`. Not diagram-scoped.
- **Sub-variant 4.2.c "source-url"** (8 files): has `source`, `mslearn_url`. Missing `id` and `type`. Page-level, not diagram-level.

### 2.3 Even "canonical" 15 files: `type` vs `source` conflation (§5.1)

ACS's 15 already-canonical-container files use `type: self-generated` or `type: mslearn-adapted` — treating `type` as a source designator. This is a semantic bug within canonical shape and must be fixed with field renaming, not just container migration.

## 3. Canonical Schema (Reference — from Container Apps)

```yaml
content_sources:
  diagrams:
    - id: <kebab-case-slug, MUST match diagram-id HTML comment>
      type: flowchart | graph | sequence | stateDiagram | classDiagram | erDiagram
      source: mslearn | mslearn-adapted | self-generated
      # If source is mslearn or mslearn-adapted:
      mslearn_url: https://learn.microsoft.com/en-us/...
      based_on:
        - https://learn.microsoft.com/en-us/...
      # If source is self-generated:
      justification: "1-2 sentence rationale."
      based_on:
        - https://learn.microsoft.com/en-us/...
```

Reference implementation: [`azure-container-apps-practical-guide/docs/platform/index.md`](https://github.com/yeongseon/azure-container-apps-practical-guide/blob/main/docs/platform/index.md).

## 4. Migration Strategy

**Recommendation (Oracle)**: Category-led waves capped at ~18-22 files per PR. NOT big-bang. NOT shape-first.

### 4.1 Why not big-bang (all 121 files at once)

- 121-file PR is too large for reliable per-diagram provenance review
- Provenance mistakes get buried
- Validator-port bugs hide behind large diff surface
- High rollback cost

### 4.2 Why not shape-first (87 bare-string, then 34 dict-list)

- Wrong unit of work — 87-file batch contains the hardest semantic ambiguity
- Mixes unrelated content categories in single PR
- Reviewer must switch semantic contexts constantly

### 4.3 Why category-led + count-capped

- Category grouping keeps reviewers in one semantic context per PR
- Provenance decisions are more consistent within a category
- Reduces chance of applying wrong `source` pattern to mixed content types
- ~20-file cap keeps each PR reviewable in <10 hours

## 5. Provenance Classification Rubric

For the 87 bare-string files where legacy encoding lost source-type information, apply this fixed rubric during migration:

- **`source: mslearn`** — the Mermaid closely mirrors a **single** Microsoft Learn diagram or structure with only trivial wording/layout changes.
- **`source: mslearn-adapted`** — the Mermaid is clearly derived from Learn content but materially reworked, simplified, relabeled, or combined.
- **`source: self-generated`** — the Mermaid is original to the repo, even if informed by Learn articles. MUST include `justification` (string) AND `based_on` (list of URLs).
- **`source: community`** — only if the page explicitly relies on a non-Microsoft source.
- **`source: unknown`** — allowed only as a temporary exception after actual review, with a follow-up issue. **Target zero. Tolerate at most a very small residue.**

**Why manual per-file review, not URL-based defaults**: a bare Learn URL does not tell you whether the local Mermaid is a direct lift, an adaptation, or a new synthesis. Rule-based defaults ("all learn.microsoft.com → mslearn") would produce a large fraction of wrong classifications.

## 6. Validator Infrastructure Strategy

**Recommendation (Oracle)**: **Interleave — port validators first, run them permissively, then switch to strict after final wave.**

### 6.1 Wave 0 (bootstrap)

- Port `scripts/validate_content_sources.py` from [azure-container-apps-practical-guide](https://github.com/yeongseon/azure-container-apps-practical-guide/blob/main/scripts/validate_content_sources.py)
- Port `scripts/validate_mslearn_urls.py` from [azure-container-apps-practical-guide](https://github.com/yeongseon/azure-container-apps-practical-guide/blob/main/scripts/validate_mslearn_urls.py)
- Port `scripts/lib/content_scope.py` (may need ACS-specific adaptation for section layout)
- Add to CI as **non-blocking / warn-only** checks
- Do NOT flip to strict yet

### 6.2 During waves 1-6

- Run ported validators locally in each wave PR
- Validators produce warnings for all non-migrated files
- Reviewers verify each wave's touched files no longer produce warnings

### 6.3 Wave 7 (strict enforcement flip)

- Confirm zero files produce validator warnings
- Flip CI job from non-blocking to **blocking** (fail build on validation error)
- Close meta-issue only when repo-wide validation is green

### 6.4 Why not "strict first"

- CI becomes noisy for months during migration
- False signal drowns out real regressions
- Discourages incremental contribution

### 6.5 Why not "migrate first, validators last"

- Weak signal during migration — no way to detect wave-level regressions
- No proof that ported validator matches ACS realities until after last wave
- Higher chance of rework

## 7. Wave Rollout Plan

**Assumption**: exact per-category counts were not preserved in the P2-1 audit. Plan below is category-led with fixed size caps. Wave membership can flex, but wave sizes should stay close to these numbers.

| Wave | Scope | Target files | Effort | Success criteria | Depends on |
|---|---|---:|---:|---|---|
| 0 | Validator/bootstrap | 0 content files | 4-6h | Ported scripts run in ACS; CI is non-blocking; migration rubric captured in issue | None |
| 1 | `docs/platform/**` | ~20 | 6-8h | All touched pages use canonical `content_sources.diagrams`; no unresolved shape errors in touched set | Wave 0 |
| 2 | `docs/best-practices/**` | ~18 | 5-7h | Same as Wave 1; provenance rubric applied consistently | Wave 1 |
| 3 | `docs/operations/**` | ~18 | 5-7h | Same as Wave 1; validator output stable | Wave 2 |
| 4 | `docs/troubleshooting/**` batch A | ~22 | 7-9h | Same as Wave 1; no unexplained `unknown` entries | Wave 3 |
| 5 | `docs/troubleshooting/**` batch B | ~22 | 7-9h | Same as Wave 1; any exceptions explicitly tracked | Wave 4 |
| 6 | `docs/troubleshooting/**` batch C + leftovers (`docs/visualization/**`, `docs/meta/**`, `docs/reference/**`, `docs/sdk-guides/**`) | ~21 | 7-9h | Repo has 0 remaining legacy shapes; all migrated pages validate | Wave 5 |
| 7 | Strict enforcement flip | 0 content files | 1-2h | CI switched to blocking; repo passes validators cleanly | Wave 6 |

**Wave ordering rationale**:

- **Platform first** because it sets the canonical provenance patterns that later sections can copy
- **Best Practices and Operations next** because they are usually structurally closer to Platform than Troubleshooting is
- **Troubleshooting last** because it tends to have the most synthesis and therefore the highest provenance ambiguity

**Total estimate**: **121 files, 6 content waves + 2 infra/governance waves, 35-48 hours**.

## 8. Field-Rename Overlap

Waves 1-6 MUST also fix the `type` vs `source` conflation described in §2.3 of this plan and §5.1 of the P2-1 audit. This is not a separate wave — it happens per-file during each migration wave. The rule per file is:

- **Before**: `type: self-generated` (semantic bug)
- **After**: `source: self-generated` + `type: <mermaid-type>` (canonical)

Where `<mermaid-type>` is derived from the actual Mermaid diagram opening line (`flowchart TD`, `graph LR`, `sequenceDiagram`, `stateDiagram-v2`, `classDiagram`, `erDiagram`).

## 9. Issue Registration Strategy

**Decision**: Register **1 meta-issue** in the ACS repo with the full wave plan embedded as a task list. Sub-issues per wave are spawned just-in-time when each wave begins, NOT upfront.

Rationale: registering all 8 wave issues at once creates high open-issue backlog pressure and Oracle's stated dependency chain (waves 1-6 sequential) means child issues would sit idle until previous waves complete. Task-list linkage inside the meta-issue provides the same visibility with less noise.

**Alternative considered and rejected**: Register meta + 8 wave-scoped child issues at once (Oracle's original recommendation). Rejected on backlog-inflation grounds; the wave plan is captured here for retrospective auditability.

## 10. Risks

1. **Source over-classification to `mslearn`**: mitigate with the rubric in §5 and require per-wave spot checks on Mermaid content, not just frontmatter.
2. **Validator drift from Container Apps reference**: port, don't redesign; keep ACS adaptations narrow and documented in the ported scripts themselves.
3. **`unknown` creeping in as a convenience escape hatch**: allow only as a documented exception with a linked follow-up, not as a default migration outcome.
4. **Wave size drift**: if a wave exceeds 25 files or ~10 review hours, split it before merge; reviewability is part of the control mechanism.
5. **`content_scope.py` port complexity**: the container-apps `content_scope.py` encodes container-apps section layout. ACS's section layout is different. Budget 2-3 hours for adaptation during Wave 0.

## 11. Escalation Triggers

- If **>10 files** end up genuinely unclear after review, pause and add a short provenance-policy addendum before continuing.
- If the ported validators need broad ACS-specific rewrites, treat that as a separate infra issue; the validator port should remain a reference adaptation, not a new implementation.
- If a wave exceeds **25 files** or **~10 review hours**, split it; reviewability is part of the control mechanism.

## 12. Definition of Done (Meta-Issue Acceptance)

- [ ] All **121** non-canonical ACS pages migrated to canonical `content_sources.diagrams[…]` shape.
- [ ] All **136** ACS pages have correct `type` (Mermaid type) vs `source` (provenance) field usage.
- [ ] Ported validators exist in `scripts/` and match Container Apps behavior as closely as ACS allows.
- [ ] CI has ported validators running in **strict/blocking** mode, and CI is green.
- [ ] No regressions introduced to the 8 already-canonical sibling repos (verified by no cross-repo file mutation).
- [ ] This plan document reflects final wave inventory (file lists per wave attached retroactively as PR merges).

## 13. Non-Goals (Explicitly Deferred)

1. **Non-`content_sources` frontmatter keys** — `content_validation`, `hide:`, `validation:`, `description:`, etc. remain out of scope per Phase 2f §8.
2. **Content changes beyond frontmatter** — page bodies, diagrams themselves, source-URL correctness are not audited or migrated here.
3. **Functions repo migration** — Functions uses `references:` shape and its own validator accepts it as an escape. Per user directive, Functions is tracking-only.
4. **Validator cross-repo alignment beyond ACS bootstrap** — Whether the validators should share a common library across all 9 executable repos is a separate architectural question, not part of this migration.
5. **Series-wide dashboard-skip pattern documentation** — `content-validation-status.md` in container-apps and app-service is a separate follow-up (P3 residual, not part of this ACS meta).

---

**Next step**: Register meta-issue in ACS referencing this plan URL, and register a separate 1-file P3 issue in azure-container-apps-practical-guide for `docs/operations/alerts/metric-alerts-by-incident-question.md`.
