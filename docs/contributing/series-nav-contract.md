# Series Navigation Contract v1

Series-wide contract defining what the top-level `mkdocs.yml` navigation MUST, SHOULD, and MAY contain across the Azure Practical Guide series, plus two structural archetypes (documentation-first and code-first) that keep archetype-appropriate depth without forcing identical navigation.

**Status**: v1 — approved via Oracle strategic review 2026-07-09 (Wave 2 Phase 3.7 of the cross-repo standardization program).
**Scope**: 10 sibling `azure-*-practical-guide` repos.
**Predecessors**:

- **Phase 2d** — unified `docs/start-here/learning-paths.md` (SHIPPED to 9 non-Functions repos).
- **Phase 2e** — unified `docs/start-here/scenario-router.md` (SHIPPED to 9 non-Functions repos).
- **Phase 2f** — `docs/contributing/series-lab-contract.md` (SHIPPED to this repo).
- **Phase P5** — baseline conformance across 10 repos (in flight at authoring time — 9 sibling PRs open, Container Apps already merged).

## 1. Purpose

Top-level `mkdocs.yml` navigation across the series is asymmetric in size and in section vocabulary:

| Repo | Top-level sections | Nav lines | Archetype |
|---|---:|---:|---|
| networking | 9 | 185 | 문서형 (documentation-first) |
| virtual-machine | ~9 | ~200 | 문서형 |
| storage | ~9 | ~200 | 문서형 |
| monitoring | ~9 | ~210 | 문서형 |
| architecture | 11 | 231 | 문서형 (workload-oriented) |
| aks | ~10 | ~230 | 문서형 |
| communication-services | ~9 | ~260 | 코드형 (code-first) |
| app-service | ~10 | ~300 | 코드형 |
| container-apps | ~11 | 534 | 코드형 |
| functions | ~12 | 447 | 코드형 (language × plan matrix) |

The 문서형 repos organize around service concepts, operations, and troubleshooting playbooks. The 코드형 repos add per-language or per-plan tutorial matrices that expand the nav by 100-350 lines. Section vocabulary drifts: some repos use `Tutorials`, others `Language Guides`, others `SDK Guides`, others `Workload Guides`. Ordering drifts too — `Contributing` sometimes precedes `Reference`, `Troubleshooting` sometimes precedes `Operations`.

**What this contract IS.** A short, testable definition of the four navigation elements every repo MUST have, plus two archetype-specific SHOULD tiers (문서형 and 코드형) that keep archetype-appropriate depth without forcing identical navigation. It bounds nav budget (6-9 top-level items, 5-8 children) and pins ordering so a reader moving between repos always knows where `Start Here`, `Reference`, and `Contributing` will be.

**What this contract IS NOT.** It is not a mandate that every repo MUST use the same section names or the same section count. Archetype variation is expected. Repo-specific sections (`Well-Architected Framework`, `Architecture Reviews`, `Design Labs`, `Language Guides`, `SDK Guides`, `Workload Guides`, `Service Guides`) remain the repo owner's choice within the archetype's SHOULD tier.

## 2. Design Principles

1. **Archetype-based, not identical.** Do NOT copy Container Apps' 534-line nav or Networking's 185-line nav as a series-wide template. The 코드형 repos need the language/plan matrix; the 문서형 repos do not. Both archetypes are compliant when they satisfy the MUST tier and their archetype's SHOULD tier.
2. **MUST / SHOULD / MAY** — not P0/P1/P2. These are contract tiers, not issue priorities. MUST is enforceable in review; SHOULD is expected unless justified in the PR description; MAY is optional depth.
3. **Nav budget is enforceable.** 6-9 top-level items, 5-8 children per section, matching the recommendation documented in `azure-container-apps-practical-guide/AGENTS.md` § Navigation Budget. Repos exceeding the budget MUST document the exception in this contract's Per-Repo Applicability table (§ 7) OR in the repo's `AGENTS.md`.
4. **Deep inventory belongs on hub pages, not in `mkdocs.yml`.** Playbook catalogs, KQL query packs, lab guides, tutorial matrices, and per-language recipes SHOULD be listed on index pages inside `docs/`, not fully expanded in `mkdocs.yml`. A reader should be able to skim `mkdocs.yml` and understand the site's shape in under a minute.
5. **Ordering is pinned, section vocabulary is not.** Start Here always follows Home. Reference always precedes Contributing. Troubleshooting always follows Operations. Repo owners choose section names within these anchors (e.g., `Tutorials` vs `Language Guides` vs `SDK Guides`).
6. **Adoption is not obligation.** Adopting this contract does not require a repo to add or remove sections beyond the MUST tier. Adopting means: *if* the repo edits its `mkdocs.yml` nav, the change will follow this contract.
7. **Container Apps AGENTS.md remains authoritative locally.** The Navigation Budget section documented in `azure-container-apps-practical-guide/AGENTS.md` is a superset for Container Apps' local content. This contract is the *series* baseline.

## 3. Core Contract (MUST — every repo)

Every repo's `mkdocs.yml` nav MUST contain the following elements. Element names below are the recommended section strings; a repo MAY use synonyms (e.g., `Overview` for `Start Here` root page) as long as the anchor position is preserved.

| # | Element | Position | Testable review criterion |
|---:|---|---|---|
| 1 | **Home** | First | `- Home: index.md` (or equivalent auto-derived from `docs/index.md`). Present in every repo. |
| 2 | **Start Here** | Second (immediately after Home) | Nav entry named `Start Here` containing at minimum `overview.md`, `learning-paths.md`, `repository-map.md` per the series Start Here Rules. |
| 3 | **Reference** | Second-to-last (before Contributing, or last if no Contributing) | Nav entry named `Reference` containing at minimum a landing page (`reference/index.md`) and a validation dashboard (`reference/validation-status.md` or `reference/content-validation-status.md`). |
| 4 | **Contributing** | Last (if present) | Nav entry named `Contributing` containing at minimum `contributing/index.md`. Optional — repos MAY omit it, but if present it MUST be last. |
| 5 | **Nav budget** | — | Top-level sections between 6 and 9 items. Direct children under a top-level section between 5 and 8 items. Exceptions MUST be documented in § 7 or in the repo's `AGENTS.md`. |
| 6 | **Deep inventory on hub pages** | — | No single top-level section fully expands a collection of >8 items in `mkdocs.yml`. Playbook catalogs, lab guides, KQL packs, and tutorial matrices MUST live on index pages under `docs/`, not as inline nav children. |

Elements 1-4 are position-enforcing. Elements 5-6 are budget-enforcing. All six are MUST — a repo failing any of them fails the contract.

## 4. Archetype 문서형 — Documentation-First Repos

문서형 repos organize around service concepts, day-2 operations, and troubleshooting playbooks. There are no per-language or per-plan tutorial matrices.

Applicable to: virtual-machine, networking, storage, monitoring, architecture, aks.

Adds these SHOULD elements on top of the MUST tier:

| # | Element | Position | Why |
|---:|---|---|---|
| D1 | **Platform** | Third (after Start Here) | Service concepts and architecture. The reader's first stop for "what is this service and how does it work". |
| D2 | **Best Practices** | Fourth | Production patterns and anti-patterns. Series-wide standard section. |
| D3 | **Operations** | Fifth | Day-2 execution procedures. Series-wide standard section. |
| D4 | **Troubleshooting** | Sixth (immediately after Operations) | Symptom-based diagnosis and playbooks. Positioned adjacent to Operations because the two sections are cross-linked heavily. |

Approved 문서형 extensions (MAY sit between D2 and D3, between D3 and D4, or after D4, at the repo owner's discretion):

- `Tutorials` — hands-on labs or reproducible walkthroughs (used by networking, storage).
- `Well-Architected Framework` — WAF pillar guidance (used by architecture).
- `Architecture Patterns` — reusable design patterns (used by architecture).
- `Workload Guides` — end-to-end architecture blueprints (used by architecture).
- `Architecture Reviews` — review methodology and playbooks (used by architecture).
- `Design Labs` — WAF-oriented design exercises (used by architecture).
- `Service Guides` — cross-service integration guidance (used by monitoring, potentially aks).

문서형 repos MAY exceed the 9-item top-level budget by up to +2 sections if the extensions above are used together (as architecture does). This exception is pre-approved for architecture in § 7 and MUST be justified for any other repo in its `AGENTS.md`.

## 5. Archetype 코드형 — Code-First Repos

코드형 repos organize around per-language tutorials, per-runtime recipes, or per-plan implementation guidance in addition to concepts and operations. The tutorial matrix adds nav weight that pure 문서형 repos do not carry.

Applicable to: container-apps, functions, app-service, communication-services.

Adds these SHOULD elements on top of the MUST tier:

| # | Element | Position | Why |
|---:|---|---|---|
| C1 | **Platform** | Third (after Start Here) | Service concepts and architecture. Same anchor as 문서형 D1. |
| C2 | **Best Practices** | Fourth | Production patterns. Same anchor as 문서형 D2. |
| C3 | **Language Guides / SDK Guides** | Fifth | Per-language or per-SDK tutorials and recipes. Exact section name is repo-specific: `Language Guides` (container-apps, functions, app-service), `SDK Guides` (communication-services). |
| C4 | **Operations** | Sixth | Day-2 execution. Same anchor as 문서형 D3. |
| C5 | **Troubleshooting** | Seventh | Symptom-based diagnosis. Same anchor as 문서형 D4. |

Approved 코드형 extensions:

- Per-language sub-navigation SHOULD be a single top-level `Language Guides` entry with per-language child sections. A separate top-level entry per language is forbidden (it explodes the top-level budget).
- Per-plan sub-navigation (as functions does for Consumption / Premium / Dedicated / Container plans) SHOULD live under `Language Guides` as a second-level dimension, not as a top-level section.
- Tutorial matrices that produce more than 8 direct children under `Language Guides` MUST be listed on `docs/language-guides/index.md` as a matrix table rather than fully expanded in `mkdocs.yml`. Container Apps' 534-line nav and Functions' 447-line nav are pre-existing exceptions documented in § 7; new code-first repos MUST hit the hub-page target.

코드형 repos MAY exceed the 9-item top-level budget by up to +2 sections if the tutorial matrix requires additional grouping (as container-apps and functions do). This exception is pre-approved for those two repos in § 7 and MUST be justified for any other repo in its `AGENTS.md`.

## 6. Ordering Conventions

Ordering across the series is pinned at the anchors below. Section vocabulary between anchors is at the repo owner's discretion within their archetype's SHOULD tier.

```text
Home
Start Here
[archetype SHOULD sections in the order defined by § 4 or § 5]
[approved extensions, at owner's discretion]
Troubleshooting     ← always after Operations (문서형 D4 or 코드형 C5)
Reference           ← always second-to-last
Contributing        ← always last, if present
```

Explicit anti-patterns:

- `Reference` appearing before `Troubleshooting` — forbidden. Reference is a lookup surface, Troubleshooting is a task surface; readers move Troubleshooting → Reference, not the reverse.
- `Contributing` appearing before `Reference` — forbidden. Contributing is a repo-meta surface; it belongs at the end.
- `Troubleshooting` appearing before `Operations` — forbidden. The reader progression is "how to run it → how to diagnose it".
- A per-language top-level section (e.g., a top-level `Python` entry sibling to `Node.js`) — forbidden. Per-language content belongs under a single `Language Guides` or `SDK Guides` entry.

## 7. Per-Repo Applicability

| Repo | Archetype | Contract fit | Notes |
|---|---|---|---|
| networking | 문서형 | Fully compliant | Canonical 문서형 baseline. 9 top-level sections, 185 nav lines. No exceptions required. |
| virtual-machine | 문서형 | Fully compliant | Standard 문서형 shape. |
| storage | 문서형 | Fully compliant | Standard 문서형 shape. |
| monitoring | 문서형 | Fully compliant | Uses `Service Guides` extension (approved in § 4). |
| aks | 문서형 | Fully compliant | Standard 문서형 shape. |
| architecture | 문서형 | Compliant with pre-approved +2 exception | Uses `Well-Architected Framework`, `Architecture Patterns`, `Workload Guides`, `Architecture Reviews`, `Design Labs` extensions together. 11 top-level sections, 231 nav lines. Pre-approved. |
| communication-services | 코드형 | Fully compliant | Uses `SDK Guides` variant of C3. |
| app-service | 코드형 | Fully compliant | Standard 코드형 shape. |
| container-apps | 코드형 | Compliant with pre-approved +2 exception | 534-line nav from language × recipe expansion. Pre-approved. Container Apps' `AGENTS.md` § Navigation Budget documents the local hub-page preference. Container Apps SHOULD progressively move the language-guide recipe children onto `docs/language-guides/*/index.md` hub tables as opportunity arises. |
| functions | 코드형 | Compliant with pre-approved +2 exception | 447-line nav from 4-language × 4-plan × 7-step tutorial matrix. Pre-approved. Functions SHOULD progressively collapse the plan-dimension children onto a hub matrix table on `docs/language-guides/index.md` as opportunity arises. |

Any repo that adds a new top-level section beyond its archetype's SHOULD tier MUST update this table in the same PR.

## 8. Non-Goals

- Not requiring identical section vocabulary across the series (`Tutorials` vs `Language Guides` vs `SDK Guides` remains repo-specific within the archetype's SHOULD tier).
- Not requiring identical `Start Here` sub-navigation. The MUST criterion is only that Start Here contains `overview.md`, `learning-paths.md`, `repository-map.md`; additional pages are repo-specific per the series Start Here Rules.
- Not deprecating Container Apps' or Functions' oversized navigation. Both are pre-approved exceptions and the contract commits to progressive hub-page migration, not immediate collapse.
- Not standardizing sidebar theming, breadcrumb configuration, or Material for MkDocs plugin selection. Those are repo-specific.
- Not selecting a single spelling for section names in non-English locales. Repo owners MAY translate section names in localized README variants; the English `mkdocs.yml` nav strings remain authoritative for review purposes.

## 9. Governance

- **Meta-tracker location**: This repository (`azure-architecture-practical-guide`) as the neutral series governance hub.
- **Per-repo trackers**: Affected sibling repos may carry per-repo child issues under the current series meta tracker as needed. There is no requirement that every sibling repo maintain a standing tracker; trackers are opened by exception when a repo has active series-wide work in flight.
- **Amendment process**: Changes to this contract require a PR against this file. Container Apps' `AGENTS.md` may extend the contract locally without amendment; other repos may not.
- **Enforcement**: Nav-budget compliance is verified by human review at PR time. There is no automated `mkdocs.yml` linter in this contract's scope. If a repo owner wants automated enforcement, they SHOULD add it in a follow-up per-repo issue.

## See Also

- [Contributing Guide](index.md) — Repository structure, document templates, PR process.
- [Series Lab Contract](series-lab-contract.md) — Series-wide lab contract (Phase 2f predecessor).

## Sources

- Oracle strategic review, session `ses_0c9fa347cffeQv11ROULLRjMNp`, 2026-07-09 (Wave 2 Phase 3.6).
- `azure-container-apps-practical-guide/AGENTS.md` § Navigation Budget — local nav budget policy (6-9 top-level, 5-8 children).
- Nav baseline empirical measurement across 10 sibling repos (Wave 2 Phase 1-2, this repo's Sisyphus working directory).
