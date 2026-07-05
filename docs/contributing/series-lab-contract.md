# Series Lab Contract v1

Series-wide contract defining what a "lab" MUST provide across the Azure Practical Guide series, plus two structural variants for the two lab families that exist today (reproduction labs and design labs), plus a first-lab template appendix for repos with zero labs.

**Status**: v1 — approved via Oracle strategic review 2026-07-05 (Phase 2f of the cross-repo standardization program).
**Scope**: 10 sibling `azure-*-practical-guide` repos.
**Predecessors**:

- **Phase 2d** — unified `docs/start-here/learning-paths.md` (SHIPPED to 9 non-Functions repos).
- **Phase 2e** — unified `docs/start-here/scenario-router.md` (SHIPPED to 9 non-Functions repos).

## 1. Purpose

Lab coverage across the series is highly asymmetric:

| Repo | Labs | Lab family |
|---|---:|---|
| container-apps | 26 lab READMEs + 55 lab guides | Reproduction (Bicep + evidence + falsification) |
| architecture | 3 design labs | Design (WAF-oriented, decision-driven) |
| aks | 5 lab guides | Reproduction (mixed maturity) |
| vm | 0 | — |
| networking | 0 | — |
| storage | 0 | — |
| monitoring | 0 | — |
| app-service | 0 | — |
| acs | 0 | — |
| functions | 0 | — (tracker-only, no execution in Phase 2f) |

Container Apps' 16-methodology-concept lab (documented in `azure-container-apps-practical-guide/AGENTS.md`) is the mature reference. Architecture's design labs are structurally different (no `labs/<name>/` runbook directory, no cleanup step, no falsification-after-fix). The 7 zero-lab repos have no shape at all to reach for when they eventually add their first lab.

**What this contract IS.** A short, testable definition of "what makes a lab a lab" in this series, plus two evidence-section variants (reproduction vs design) that keep the Container Apps methodology intact for repos that adopt it, while making room for design labs and giving zero-lab repos a first-lab template to copy.

**What this contract IS NOT.** It is not a mandate that every repo MUST create a lab. Adopting the contract only standardizes *future* labs; it does not obligate a repo to author one. Repos with zero labs may stay at zero and still be contract-compliant.

## 2. Design Principles

1. **Core contract, not full transplant.** Do NOT copy Container Apps' 16 methodology concepts as a series-wide minimum. Zero-lab repos will ignore that spec, and design labs cannot satisfy it. The MUST tier is short and testable; SHOULD adds the Container Apps-style depth for repos that want it.
2. **Two variants, one contract.** Reproduction labs (Variant A) and design labs (Variant B) share the MUST tier and diverge only where the artifact model differs (falsification vs decision outcome, `labs/<name>/` vs docs-only, cleanup vs no-cleanup).
3. **MUST / SHOULD / MAY** — not P0/P1/P2. These are contract tiers, not issue priorities. MUST is enforceable in review; SHOULD is expected unless justified; MAY is optional depth.
4. **Adoption is not obligation.** Adopting this contract does not require a repo to create a lab. Adopting means: *if* the repo authors a lab, it will follow this contract.
5. **Falsification is not universal.** Reproduction labs MUST include a closing validation that proves the fix works (falsification-after-fix in the Container Apps methodology). Design labs replace this with a decision outcome and evaluation criteria. Neither is "less rigorous"; they are different verification models for different lab families.
6. **Directory layout is a Variant A convention, not a MUST.** Reproduction labs SHOULD ship with a `labs/<name>/` companion carrying Bicep/scripts/evidence. Design labs and docs-only reproduction labs MAY skip this.
7. **Container Apps AGENTS.md remains authoritative locally.** The 16 methodology concepts and evidence-section variants documented in `azure-container-apps-practical-guide/AGENTS.md` are a *superset* for Container Apps' local content. This contract is the *series* baseline.
8. **First-lab template is normative for zero-lab repos.** If a zero-lab repo decides to author its first lab, it MUST start from the appendix template, not from a Container Apps lab.

## 3. Core Contract (MUST — every lab, every variant)

Every lab document — reproduction or design — MUST contain the following six elements. Element names below are conceptual (heading strings may vary); the review criterion is that the element is *present* and *testable*, not that it uses a specific H2 string.

| # | Element | What it answers | Testable review criterion |
|---:|---|---|---|
| 1 | **Purpose / question** | What problem or decision does this lab investigate? | Page opens with a 1-3 sentence problem statement OR a question sentence. |
| 2 | **Testable claim** | What outcome, behavior, or design choice is being verified? | At least one falsifiable statement (`IF X THEN Y` for reproduction, `criterion C decides between A and B` for design). |
| 3 | **Procedure** | What steps does the reader run? | Numbered or headed steps that a second engineer could follow without asking questions. |
| 4 | **Evidence method** | What artifacts prove the claim? | KQL queries, portal captures, CLI output, decision matrix, or comparison table — each identified as an artifact type, not just "look at the logs". |
| 5 | **Closing validation** | How does the reader confirm the lab succeeded? | Reproduction: post-fix evidence. Design: chosen option + why other options were rejected. |
| 6 | **Cleanup (if resources created)** | How does the reader restore the account to its starting state? | `az group delete` OR equivalent teardown script OR explicit statement that no resources were created. |

Element 6 is conditional: docs-only labs (no `az` calls, no deployed resources) MUST state that no cleanup is required. Silence is a MUST violation.

## 4. Variant A — Reproduction Labs

Reproduction labs reproduce a specific failure mode with a Bicep-based runbook, capture evidence, apply a fix, and prove the fix works.

Applicable to: container-apps, aks, and any zero-lab repo that decides to author a reproduction lab.

Adds these SHOULD elements on top of the MUST tier:

| # | Element | Why |
|---:|---|---|
| A1 | **Hypothesis + prediction** | `IF X is misconfigured THEN symptom Y appears` makes the reproduction falsifiable. |
| A2 | **Falsification-after-fix** | Post-fix evidence that the symptom is gone AND the original hypothesis was correct. Not just "the fix worked" — the ORIGINAL claim is proven. |
| A3 | **Paired playbook** | The lab reproduces the failure; the playbook resolves it in production. Cross-link both directions. |
| A4 | **`labs/<name>/` companion directory** | Bicep template, verify script, and `evidence/` subdirectory with real Azure captures. |
| A5 | **Evidence-section variant** | Legacy `## Expected Evidence` (pass/fail table) OR richer `## 5) Verification Queries` + `## 6) Portal Evidence` (KQL pack + annotated screenshots). New Variant A labs SHOULD prefer the richer form. |

MAY elements for Variant A: `## Lab Metadata` (difficulty/duration/tier table), evidence tags (`[Observed]`, `[Measured]`, `[Correlated]`, `[Inferred]`), post-fix Log Analytics comparison chart.

## 5. Variant B — Design Labs

Design labs guide the reader through a decision (which service, which topology, which policy) using structured evaluation instead of runtime reproduction.

Applicable to: architecture, and any repo whose lab is fundamentally a design exercise rather than a failure reproduction.

Adds these SHOULD elements on top of the MUST tier:

| # | Element | Why |
|---:|---|---|
| B1 | **Decision context** | What business or technical constraint forces this choice? (Cost ceiling, latency budget, compliance requirement.) |
| B2 | **Options considered** | 2-5 named options with explicit trade-off dimensions. |
| B3 | **Evaluation criteria** | Weighted or unweighted comparison table; each criterion is either objective (cost/mo, RTO/RPO minutes) or a documented judgment. |
| B4 | **Decision outcome** | The chosen option with a 1-3 sentence justification cross-referencing the evaluation criteria. |
| B5 | **Rejection notes** | Why each non-chosen option was rejected. Silence is a Variant B violation because it hides the reasoning that makes the lab reusable. |

MAY elements for Variant B: reference architecture Mermaid diagram, WAF pillar alignment table, Microsoft Learn source URLs for each option.

Variant B does NOT require: `labs/<name>/` directory, Bicep templates, cleanup step, falsification, hypothesis/prediction language. Substituting these onto a design lab is a MUST violation (they misrepresent the artifact).

## 6. First-Lab Template (appendix — normative for zero-lab repos)

Zero-lab repos that decide to author their first lab MUST start from a Variant A or Variant B starter template rather than copying a Container Apps lab.

The starter templates will be authored as a follow-up per-repo issue and MUST include:

- **Variant A starter** — `docs/troubleshooting/lab-guides/YYYY-MM-DD-my-first-lab.md` with placeholder blocks for MUST elements 1-6 plus Variant A SHOULD elements A1-A5.
- **Variant B starter** — `docs/design-labs/YYYY-MM-DD-my-first-decision.md` with placeholder blocks for MUST elements 1-6 plus Variant B SHOULD elements B1-B5.

Both starters MUST ship with `<!-- DELETE THIS BLOCK BEFORE PUBLISHING -->` comments on every placeholder block and a top-of-file frontmatter block matching the target repo's existing frontmatter style.

## 7. Per-Repo Applicability

| Repo | Current lab family | Contract fit | Notes |
|---|---|---|---|
| container-apps | Reproduction (26 labs, 55 guides) | Variant A + AGENTS.md superset | Container Apps' 16-concept methodology remains locally authoritative. This contract is compatible; nothing changes for Container Apps existing labs. |
| architecture | Design (3 WAF-oriented labs) | Variant B | Existing labs MAY be audited against Variant B in a follow-up; no rewrite required. |
| aks | Reproduction (5 lab guides) | Variant A | Adoption gap: audit existing labs against MUST + Variant A SHOULD; register drift as follow-up issues. |
| vm | Zero | Contract adopted, no lab required | If VM authors an OS-level lab, use Variant A + first-lab template. |
| networking | Zero | Contract adopted, no lab required | If Networking authors a connectivity lab, use Variant A. |
| storage | Zero | Contract adopted, no lab required | If Storage authors a data-plane lab, use Variant A. |
| monitoring | Zero | Contract adopted, no lab required | If Monitoring authors a signal-quality lab, use Variant A. |
| app-service | Zero | Contract adopted, no lab required | If App Service authors a deployment-slot or config lab, use Variant A. |
| acs | Zero | Contract adopted, no lab required | If ACS authors an SDK/API lab, use Variant A. |
| functions | Zero | Tracking-only (no execution per user directive) | Contract is registered on the Functions tracker for future adoption. No files are added to the Functions repo in Phase 2f. |

## 8. Non-Goals

- Not requiring every repo to author a lab.
- Not deprecating Container Apps' 16 methodology concepts or evidence-section variants documented in Container Apps' AGENTS.md.
- Not mandating a specific frontmatter schema across repos.
- Not standardizing lab metadata tables (difficulty, duration, tier). Container Apps uses these; other repos MAY.
- Not selecting a single evidence-section variant for reproduction labs. Both legacy (`## Expected Evidence`) and richer (`## 5) Verification Queries` + `## 6) Portal Evidence`) are compliant.

## 9. Governance

- **Meta-tracker location**: This repository (`azure-architecture-practical-guide`) as the neutral series governance hub.
- **Per-repo trackers**: Each of the 10 sibling repos carries a `Series Standardization Tracker` issue.
- **Amendment process**: Changes to this contract require a PR against this file. Container Apps' AGENTS.md may extend the contract locally without amendment; other repos may not.

## See Also

- [Contributing Guide](index.md) — Repository structure, document templates, PR process
- [Design Labs](../design-labs/index.md) — Existing Variant B labs in this repository

## Sources

- Oracle strategic review, session `ses_0d06ddf67ffe8eMstxxgLtovsX`, 2026-07-05.
- `azure-container-apps-practical-guide/AGENTS.md` — 16 methodology concepts + evidence-section variants (authoritative for Container Apps' local content).
- Phase 2d spec: `azure-container-apps-practical-guide/.sisyphus/plans/phase-2d-learning-paths-spec.md` (agent working directory).
- Phase 2e spec: `azure-container-apps-practical-guide/.sisyphus/plans/phase-2e-scenario-router-spec.md` (agent working directory).
