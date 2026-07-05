# P2-1 Audit: Series Frontmatter Provenance Schema — Current State and Canonicalization Plan

**Status**: DRAFT — Audit complete, migration plan proposed. Awaiting per-repo P3 execution.
**Scope**: 10 sibling `azure-*-practical-guide` repos. Frontmatter `content_sources` provenance/source schema only.
**Author**: Sisyphus (agent)
**Related issue**: [azure-architecture-practical-guide#36](https://github.com/yeongseon/azure-architecture-practical-guide/issues/36)
**Parent tracker**: [azure-architecture-practical-guide#34](https://github.com/yeongseon/azure-architecture-practical-guide/issues/34) (Phase 2 meta-tracker)
**Oracle decomposition**: `ses_0d03f7aaeffeUpJ4xkJ5TlTKql` (task `bg_baa2acdf`, 2m 33s)

---

## 1. Executive Summary

The audit ran a shape-classifier over every `.md` file in `docs/` across all 10 repos and grouped `content_sources` shapes into four classes: `canonical` (`content_sources.diagrams[...]`), `bare_list` (bare-string list), `dict_list` (dict-list without a `diagrams:` container), and `other` (dict-form without `diagrams:` key, e.g. `references:`-only).

**Headline result**: 8 of the 9 executable repos are already effectively 100% canonical. **ACS is the single primary migration target**, with 121 non-canonical pages across two legacy shapes. Functions (excluded per user directive) uses a third dict-form (`references:`) on 295 pages but is tracking-only.

Oracle's original P2-1 hypothesis referenced an "ACS `validate_mslearn_urls.py` crash on list-form." That hypothesis was **partially incorrect**: ACS has neither `validate_mslearn_urls.py` nor `validate_content_sources.py` at all — no validator infrastructure exists in ACS. The real gap is: **ACS never adopted the canonical schema OR the validators that enforce it.**

## 2. Methodology

Data collection ran `python3` over each repo's `docs/` tree, parsed frontmatter with PyYAML, and classified `content_sources` shape:

- `canonical`: `content_sources` is a `dict` with a `diagrams` key.
- `bare_list`: `content_sources` is a `list` whose first element is a `str`.
- `dict_list`: `content_sources` is a `list` whose first element is a `dict`.
- `other`: `content_sources` is a `dict` without a `diagrams` key (e.g., `references:` only), or an empty list, or unparseable.

Reference shape: **Variant A canonical**, as used in `azure-container-apps-practical-guide/docs/platform/index.md`:

```yaml
content_sources:
  diagrams:
    - id: <slug>
      type: flowchart | graph | sequence | ...
      source: mslearn | mslearn-adapted | self-generated
      # For mslearn/mslearn-adapted:
      mslearn_url: https://learn.microsoft.com/en-us/...
      based_on:
        - https://learn.microsoft.com/en-us/...
      # For self-generated:
      justification: "Why this diagram is authored here."
```

## 3. Per-Repo Shape Distribution

| Repo | canonical | bare_list | dict_list | other | Total | Status |
|---|---:|---:|---:|---:|---:|---|
| container-apps | 367 | 0 | 0 | 2 | 369 | ✅ Nearly clean |
| app-service | 227 | 0 | 0 | 1 | 228 | ✅ Nearly clean |
| architecture | 113 | 0 | 0 | 0 | 113 | ✅ 100% canonical |
| monitoring | 95 | 0 | 0 | 0 | 95 | ✅ 100% canonical |
| storage | 78 | 0 | 0 | 0 | 78 | ✅ 100% canonical |
| networking | 77 | 0 | 0 | 0 | 77 | ✅ 100% canonical |
| vm | 76 | 0 | 0 | 0 | 76 | ✅ 100% canonical |
| aks | 69 | 0 | 0 | 0 | 69 | ✅ 100% canonical |
| **acs** | **15 (11%)** | **87 (64%)** | **34 (25%)** | 0 | **136** | ❌ **Primary migration target** |
| functions (excluded) | 7 (2%) | 0 | 0 | 295 (98%) | 302 | ⚠️ Tracking-only |

## 4. Non-Canonical Shape Catalog

### 4.1 ACS bare-string list (87 files)

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

**Issue**: No structure — cannot distinguish source `type` from URL, no `id` to bind to a diagram, no `justification` for self-generated content. Cannot be validated by the shared validator.

### 4.2 ACS dict-list without `diagrams:` container (34 files)

Three sub-variants observed:

**Sub-variant 4.2.a — "rich"** (18 files):

```yaml
content_sources:
  - id: some-slug
    type: self-generated
    source: ...
    justification: ...
    based_on: ...
```

Just needs `diagrams:` container wrapping.

**Sub-variant 4.2.b — "url-only"** (8 files):

```yaml
content_sources:
  - type: mslearn
    url: https://...
```

Missing `id`. Uses `url:` (not `mslearn_url:`). Not diagram-scoped.

**Sub-variant 4.2.c — "source-url"** (8 files):

```yaml
content_sources:
  - source: mslearn-adapted
    mslearn_url: https://...
```

Missing `id` and `type`. Field naming closest to canonical but still page-level, not diagram-level.

### 4.3 Container Apps residual (2 files)

- `docs/operations/alerts/metric-alerts-by-incident-question.md` — uses `content_sources.references:` (same shape as Functions). Legacy vestige from before Phase 2d.
- `docs/reference/content-validation-status.md` — auto-generated dashboard. Expected non-canonical.

### 4.4 App Service residual (1 file)

- `docs/reference/content-validation-status.md` — auto-generated dashboard. Expected non-canonical.

### 4.5 Functions dict-form (excluded — 295 files)

```yaml
content_sources:
  references:
    - type: mslearn-adapted
      url: https://...
```

Functions repo's own `scripts/validate_content_sources.py` accepts this as a legacy escape hatch. Functions is tracking-only per user directive.

## 5. Semantic Issues Within Canonical Shape

Even where the container shape is canonical, three field-level inconsistencies remain across the 8 clean repos:

### 5.1 `type` vs `source` conflation (ACS-specific, propagates to canonical files)

ACS's 15 canonical files use `type: self-generated` or `type: mslearn-adapted` — treating `type` as a source designator. Canonical intent is:

- `type:` = diagram type (`flowchart`, `graph`, `sequence`, `stateDiagram`, ...)
- `source:` = provenance (`mslearn` | `mslearn-adapted` | `self-generated`)

This is a **semantic bug** even inside canonical files. Fixing it requires field renaming, not just container shape migration.

### 5.2 `based_on` cardinality drift

Observed variants:

- `based_on: Generic ACS architecture` (bare string — how-acs-works.md)
- `based_on: [https://learn.microsoft.com/..., https://...]` (URL list — container-apps standard)
- `based_on: - https://...` (single-URL list)

Canonical: **list of URLs**. Bare strings should be moved to `justification:`.

### 5.3 `mslearn_url` vs `url` vs no field

- `mslearn_url:` — container-apps + app-service + monitoring (dominant)
- `url:` — ACS sub-variant 4.2.b
- omitted with `source: mslearn` — canonical AKS + vm (informational URL is expected but not always present)

Canonical: **`mslearn_url:`** (explicit about which Learn URL scoping).

## 6. Canonical Schema (proposed for P2 series-wide)

```yaml
content_sources:
  diagrams:
    - id: <kebab-case-slug, MUST be unique per page and MUST match the diagram-id HTML comment>
      type: flowchart | graph | sequence | stateDiagram | classDiagram | erDiagram
      source: mslearn | mslearn-adapted | self-generated
      # If source is mslearn or mslearn-adapted, EXACTLY ONE of the following is required:
      mslearn_url: https://learn.microsoft.com/en-us/...
      based_on:
        - https://learn.microsoft.com/en-us/...
        - https://learn.microsoft.com/en-us/...
      # If source is self-generated, both of the following are required:
      justification: "1-2 sentence rationale for why this diagram is authored here rather than adapted from Learn."
      based_on:
        - https://learn.microsoft.com/en-us/...
      # OPTIONAL:
      description: "Optional human-readable caption; distinct from justification."
```

**MUST hold** for every canonical file:

1. Container shape is `content_sources.diagrams:` (list of dicts).
2. Every dict has `id` and `type` and `source`.
3. `source: mslearn` MUST have `mslearn_url:`.
4. `source: mslearn-adapted` MUST have EITHER `mslearn_url:` OR `based_on:` (list of URLs).
5. `source: self-generated` MUST have both `justification:` (string) AND `based_on:` (list of URLs).
6. `type:` values are diagram-type identifiers (Mermaid diagram types), not source designators.

**MAY hold** (optional):

- `description:` — human-readable caption.
- Additional dicts in the list for multi-diagram pages.

## 7. Migration Plan Per Repo

| Repo | Effort | Approach | Deliverable |
|---|---|---|---|
| container-apps | XS | Fix 1 file (`metric-alerts-by-incident-question.md`) + document dashboard skip pattern | Follow-up P3 issue |
| app-service | XS | Document dashboard skip pattern for `content-validation-status.md` | Follow-up P3 issue |
| architecture | Nil | No shape migration needed. Validate on next validator run. | No action |
| monitoring | Nil | No shape migration needed. Validate on next validator run. | No action |
| storage | Nil | No shape migration needed. Validate on next validator run. | No action |
| networking | Nil | No shape migration needed. Validate on next validator run. | No action |
| vm | Nil | No shape migration needed. Validate on next validator run. | No action |
| aks | Nil | No shape migration needed. Validate on next validator run. | No action |
| **acs** | **L** | **Full migration**: (a) port `validate_content_sources.py` + `validate_mslearn_urls.py` from container-apps or architecture as reference, (b) migrate 121 non-canonical files across 3 sub-variants, (c) fix `type:` vs `source:` field conflation across all 136 files. | Priority P3 issue |
| functions | — | Excluded per user directive. Tracker only. | No action (Functions tracker #67) |

**Total migration surface (executable repos)**: 3 pages (container-apps + app-service, 1 auto-dashboard skip) + 121 pages (ACS full migration) + 136 pages (ACS field renaming).

## 8. Sub-Sequenced Follow-up Issues (P3)

Propose splitting P2-1 execution into these P3 sub-issues after this audit is approved:

- **P3-1 [acs]**: Port `validate_content_sources.py` + `validate_mslearn_urls.py` from container-apps. Success: validators run without crash on current ACS content, produce actionable output (even if that output is "121 non-canonical files").
- **P3-2 [acs]**: Migrate 87 bare-string list files. Preserve existing URLs by moving them into `based_on:` on new `- id: <page-slug>` entries. Where source is only a tag (`azure-docs`, `communication-services-sdk`), promote to `source: mslearn-adapted` with `justification:` explaining the adaptation.
- **P3-3 [acs]**: Migrate 34 dict-list files. Wrap existing dicts under `diagrams:` container. Add missing `id` (derive from page slug). Rename `url:` → `mslearn_url:` where present.
- **P3-4 [acs]**: Field-rename pass across all 136 ACS files. `type: self-generated` → `source: self-generated` + `type: <mermaid-type>`. `type: mslearn-adapted` → `source: mslearn-adapted` + `type: <mermaid-type>`.
- **P3-5 [container-apps]**: Migrate `docs/operations/alerts/metric-alerts-by-incident-question.md` from `references:` shape to `diagrams:` shape.
- **P3-6 [series]**: Document `content-validation-status.md` as an accepted non-canonical exception (auto-generated dashboard) in each repo's validator config.

Sequencing: **P3-1 blocks P3-2/P3-3/P3-4** (validators are the acceptance test). P3-5 and P3-6 can run in parallel with P3-1 through P3-4.

## 9. Non-Goals (deferred to future phases)

1. **Non-`content_sources` frontmatter keys** — `content_validation`, `hide:`, `validation:`, `description:`, `edit_url:`, etc. remain out of P2 scope per Phase 2f §8.
2. **Content changes beyond frontmatter** — page bodies, diagrams themselves, source-URL correctness are not audited here.
3. **Functions repo migration** — Functions uses `references:` shape and its own validator accepts it as an escape. Per user directive, Functions is tracking-only through Phase B.
4. **Validator cross-repo alignment beyond ACS** — Each executable repo has its own validator today (except ACS). Whether the validators should share a common library is a separate architectural question, not a P2 concern.
5. **Migration execution** — this audit produces the plan and issue set. Actual migrations happen in the P3 sub-issues.

## 10. Risks

1. **ACS migration size**: 121 non-canonical files + 136 field-rename passes = 257 file mutations. Bulk sed/script + manual review per file. Approximate effort: 1-2 sessions of focused work.
2. **Field-rename may hit auto-generated dashboards**: ACS's `content-validation-status.md` (if it exists) must be regenerated after field rename, not manually mutated.
3. **Validator porting risk**: The container-apps validator is tuned for container-apps content-scope policy. Porting to ACS may need `scripts/lib/content_scope.py` equivalent that reflects ACS's own section layout. Budget for 2-3 hours of validator adaptation, not a copy-paste port.

## 11. Verification / Acceptance

This audit is considered **complete** when:

- [x] All 10 repos' `content_sources` shapes are classified and counted.
- [x] The canonical schema is written down.
- [x] Each executable repo has a concrete migrate-or-validate path (Nil / XS / L).
- [x] The Oracle-flagged unknowns (aks, vm, networking, storage) are resolved to `Nil`.
- [x] Non-goals are called out.
- [x] Sub-issue split is proposed.

The audit does **not** yet require agreement on the P3 sub-issue split. Approving this audit unblocks opening P3 issues; approving the P3 split is a separate decision.

---

**Next step**: Post the audit to issue #36, open P3-1 through P3-6 as follow-up issues (or a single "ACS P3 migration" umbrella issue if preferred), and update meta-tracker #34 with P2-1 as complete.
