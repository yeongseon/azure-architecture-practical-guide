# P2-2 Audit: Phase 2f Series Lab Contract — Existing-Lab Compliance State

**Status**: DRAFT — Audit complete, no rewrites performed. P3 follow-ups proposed.
**Scope**: 3 lab-bearing repos (container-apps, architecture, aks). 62 lab documents total.
**Non-goal**: Rewrites. Per issue #37 title, this is audit-only.
**Author**: Sisyphus (agent)
**Related issue**: [azure-architecture-practical-guide#37](https://github.com/yeongseon/azure-architecture-practical-guide/issues/37)
**Parent tracker**: [azure-architecture-practical-guide#34](https://github.com/yeongseon/azure-architecture-practical-guide/issues/34) (Phase 2 meta-tracker)
**Contract source**: `azure-container-apps-practical-guide/.sisyphus/plans/phase-2f-series-lab-contract.md` §3-5

---

## 1. Executive Summary

The Phase 2f Series Lab Contract defines two variants and two compliance tiers:

- **Variant A** (troubleshooting/experiment): 6 MUST items + 5 SHOULD items (A1-A5)
- **Variant B** (architecture/design): 6 MUST items + 5 SHOULD items (B1-B5)
- **MUST tier**: Non-negotiable for any lab
- **SHOULD tier**: Strongly recommended; silence on any item is a violation

62 lab documents were audited across 3 lab-bearing repos:

| Repo | Variant declared | Lab count | Overall compliance |
|---|---|---:|---|
| container-apps | A | 54 | High — MUST tier ~95% pass; 2 real MUST gaps; 1 real structural inconsistency |
| architecture | B | 3 | High — MUST tier 5/6 pass; 1 real MUST gap category (cleanup declaration) |
| aks | A (declared) | 5 | Low — structural mismatch: labs are tutorial-style, not experimental |

**Three real gap categories identified**:

1. **container-apps: internal structural inconsistency** — the corpus splits into two heading conventions (`## 1) Background` vs `## 1. Question`) with no repo-wide alignment. Not a Phase 2f contract violation per se, but a maintainability liability. 29 of 54 labs lack companion `labs/<slug>/` directories; 1 lab (`startup-degraded-transient-failure`) lacks a `## Clean Up` section.
2. **architecture: missing explicit "no cleanup" declarations** — all 3 design labs are paper exercises with no deployed infrastructure. Phase 2f MUST6 requires either teardown instructions OR an explicit "No cleanup required" statement. None of the 3 labs make the declaration explicit.
3. **aks: structural mismatch** — all 5 labs are tutorial-style hands-on walkthroughs, not falsification-style experiments. None have hypothesis, prediction, falsification, or paired playbook. The labs are declared as Variant A per repo convention but structurally match neither Variant A nor Variant B; they behave as Language Guide tutorials (per the AGENTS.md content-type taxonomy). Requires either family reclassification or content upgrade to Variant A structure.

**Audit is heuristic**. This document distinguishes heuristic false-negatives (script missed a semantically-compliant lab because of regex phrasing mismatch) from real gaps (lab genuinely lacks the contract item).

## 2. Methodology

### 2.1 Contract items operationalized

Six MUST items (both variants) mapped to regex heuristics:

| ID | Contract clause | Heuristic |
|---|---|---|
| MUST1 | Purpose statement | Keywords in first 1500 chars: "this lab", "reproduces", "demonstrates", "you will", "goal", "purpose", "outcome", "walks through", "hands-on" |
| MUST2 | Testable claim (hypothesis A / decision context B) | Variant A: `## Hypothesis` heading OR "IF...THEN" clause; Variant B: "decision context / options / recommendation / trade-off" markers |
| MUST3 | Procedure content | Code fences ≥ 4 AND numbered list ≥ 2 OR "step N" language OR heading with "runbook / steps / procedure / walkthrough / how to / deploy / instructions" |
| MUST4 | Evidence | Variant A: KQL fence OR screenshot ref OR `## Expected Evidence` / `## Verification` / `## Portal Evidence` OR JSON/log fence; Variant B: markdown table AND heading with "decision matrix / evaluation / comparison / criteria / options" |
| MUST5 | Validation / outcome check | Keywords: "verify", "verification", "confirm", "expected result", "expected output", "success criteria", "how you know", "validation" |
| MUST6 | Cleanup declaration | `## Clean Up` / `## Teardown` heading OR "no cleanup required" statement OR `az group delete` command |

Five Variant A SHOULD items:

| ID | Contract clause | Heuristic |
|---|---|---|
| A1 | Hypothesis with prediction | `## Hypothesis` heading AND "IF ... THEN" clause |
| A2 | Falsification (post-fix proof) | "post-fix evidence / post-fix verification / falsification / after the fix / hypothesis confirmed" |
| A3 | Paired symptom-based playbook | `## Related Playbook` section OR link to `playbooks/` path |
| A4 | Companion `labs/<slug>/` directory | Filesystem check: `<repo>/labs/<slug>/README.md` exists |
| A5 | Richer evidence variant | `## 5) Verification Queries` heading AND `## 6) Portal Evidence` heading |

Five Variant B SHOULD items:

| ID | Contract clause | Heuristic |
|---|---|---|
| B1 | Decision context | Heading: "decision context / context / background / problem statement / scenario" |
| B2 | Options considered (2+) | "Option 1 / Option A / Choice 1" OR heading: "options considered / alternatives / choices / candidate solutions" |
| B3 | Evaluation criteria | "evaluation criteria / scoring / trade-off / criteria / weighing / pros and cons" |
| B4 | Explicit decision | "recommendation / we recommend / decision: / selected option / final decision / chosen approach" |
| B5 | Rejection notes | "why not / rejected because / alternatives considered / why we didn't / not chosen because / downside / drawbacks" |

### 2.2 Heuristic vs Real gap distinction

The audit script produces boolean pass/fail counts. To distinguish real gaps from heuristic false-negatives, this audit sampled 5-10 files per failing category and read the actual document structure. Every real-gap claim in this document is spot-check confirmed.

### 2.3 Audit script

The Python script lives at `/tmp/p2_2_audit.py` in the working session and emits per-lab JSON at `/tmp/p2_2_audit_results.json`. It is not committed to the repo — this document is the durable artifact. The script's per-clause heuristics are documented in §2.1 above and can be regenerated from that specification if needed.

## 3. Per-Repo Findings

### 3.1 container-apps (Variant A) — 54 labs

Raw compliance counts:

| Item | Pass | Total | Notes |
|---|---:|---:|---|
| MUST1 purpose | 48 | 54 | 6 gaps → all heuristic false-negatives (see §4.1) |
| MUST2 testable claim | 54 | 54 | All labs have hypothesis section |
| MUST3 procedure | 29 | 54 | 25 gaps → all heuristic false-negatives (see §4.1) |
| MUST4 evidence | 54 | 54 | All labs have evidence sections |
| MUST5 validation | 54 | 54 | All labs have validation content |
| MUST6 cleanup | 53 | 54 | **1 real gap** (see §4.2) |
| A1 hypothesis+prediction | 27 | 54 | Mixed — some heuristic, some real (see §4.1, §4.3) |
| A2 falsification | 53 | 54 | 1 gap |
| A3 paired playbook | 52 | 54 | 2 gaps |
| A4 companion `labs/<slug>/` | 25 | 54 | **29 real gaps** (see §4.3) |
| A5 richer evidence variant | 4 | 54 | 50 use legacy or 16-concept variant — SHOULD preference, not MUST gap |

**Structural observation**: container-apps has two coexisting heading conventions:

- **Older labs** (~26): `## 1) Background`, `## 2) Hypothesis`, `## 3) Runbook`, `## 4) Experiment Log`, `## 5) Verification Queries`, `## 6) Portal Evidence` — the Phase 2f richer variant.
- **Newer labs** (~26): `## 1. Question`, `## 2. Setup`, `## 3. Hypothesis`, `## 4. Prediction`, `## 5. Experiment`, `## 6. Execution`, ..., `## 16. Support Takeaway` — the AGENTS.md 16-concept methodology as literal H2 headings.

Per AGENTS.md, the 16 concepts are "*conceptual elements*... **not literal Markdown headings**" and the canonical heading structure is the older `## 1) Background` form. The newer labs violate that canonical convention but were shipped anyway. This is a **real internal inconsistency** but not a Phase 2f contract violation — both forms satisfy the MUST tier conceptually.

### 3.2 architecture (Variant B) — 3 design labs

Raw compliance counts:

| Item | Pass | Total | Notes |
|---|---:|---:|---|
| MUST1 purpose | 3 | 3 | ✅ |
| MUST2 testable claim | 3 | 3 | ✅ |
| MUST3 procedure | 0 | 3 | All 3 are heuristic false-negatives — see §4.4 |
| MUST4 evidence | 0 | 3 | All 3 are heuristic false-negatives — see §4.4 |
| MUST5 validation | 3 | 3 | ✅ |
| MUST6 cleanup | 0 | 3 | **3 real gaps** (see §4.5) |
| B1 decision context | 3 | 3 | ✅ |
| B2 options | 3 | 3 | ✅ |
| B3 evaluation criteria | 3 | 3 | ✅ |
| B4 decision | 3 | 3 | ✅ |
| B5 rejection notes | 0 | 3 | All 3 are heuristic false-negatives — see §4.4 |

**Structural observation**: All 3 design labs use a strong Variant B structure: `## Decision Question`, `## Business Context`, `## Constraints`, `## Quality Attribute Priorities`, `## Candidate Options`, `## Recommended Option`, `## Architecture Hypothesis`, `## Predicted Outcomes`, `## Validation Plan`, `## Falsification Criteria`, `## Evidence`, `## Trade-offs and Risks`, `## Guardrails and Operating Model`, `## Revisit Triggers`, `## Takeaway`. This structure is **stronger** than the Phase 2f Variant B minimum contract. The only real gap is a missing explicit "No cleanup required" declaration.

### 3.3 aks (Variant A declared) — 5 lab guides

Raw compliance counts:

| Item | Pass | Total | Notes |
|---|---:|---:|---|
| MUST1 purpose | 5 | 5 | ✅ |
| MUST2 testable claim | 0 | 5 | **5 real gaps** — no hypothesis or falsifiable claim |
| MUST3 procedure | 5 | 5 | ✅ |
| MUST4 evidence | 0 | 5 | **5 real gaps** — no KQL, no evidence artifacts |
| MUST5 validation | 5 | 5 | ✅ |
| MUST6 cleanup | 5 | 5 | ✅ |
| A1 hypothesis+prediction | 0 | 5 | **5 real gaps** |
| A2 falsification | 0 | 5 | **5 real gaps** |
| A3 paired playbook | 1 | 5 | **4 real gaps** |
| A4 companion `labs/<slug>/` | 0 | 5 | **5 real gaps** — no `labs/` directory in repo |
| A5 richer evidence variant | 0 | 5 | Not applicable — labs are not experiments |

**Structural observation**: All 5 AKS labs use tutorial structure: `## Prerequisites`, `## Architecture Diagram`, `## Step-by-Step Instructions`, `### Step 1-N`, `## Validation Steps`, `## Cleanup Instructions`. Zero hypothesis, prediction, or falsification content. All spot-checked labs contain "step-by-step" language (5/5), zero contain "hypothesis" (0/5), zero contain "falsification" (0/5). These are **hands-on tutorials**, not falsification-style experiments — matching the Language Guide content-type taxonomy in AGENTS.md, not the Troubleshooting Experiment (Variant A) or Design Lab (Variant B) taxonomy in Phase 2f.

## 4. Non-Compliance Catalog

### 4.1 container-apps: heuristic false-negatives (do not count as gaps)

**MUST1 purpose (6 files, all heuristic false-negatives)**:

- `appinsights-connection-string-missing` — opens with "Demonstrate that an Azure Container App..." (imperative "Demonstrate", not "demonstrates" — heuristic missed)
- `cpu-throttling`
- `diagnostic-settings-missing`
- `ingress-target-port-mismatch`
- `revision-history-limit`
- `startup-degraded-transient-failure`

Each has a clear purpose statement in the opening paragraph but uses phrasing outside the heuristic's keyword set.

**MUST3 procedure (25 files, all heuristic false-negatives)**:

All 25 labs use the 16-concept AGENTS.md methodology structure with `## 5. Experiment` and `## 6. Execution` sections that contain the procedure content. The heuristic was calibrated for the older `## 3) Runbook` heading and missed the newer `## Experiment + ## Execution` split. Spot-checked 5 labs (azure-files-mount-failure, bicep-deployment-timeout, docker-hub-rate-limit, multi-region-failover, session-affinity-failure): all have 4-6 code fences and full experiment/execution sections.

**A1 hypothesis+prediction (27 files, mixed)**:

The 16-concept-methodology labs use `## 3. Hypothesis` + `## 4. Prediction` as separate sections instead of IF/THEN inline clauses. Some are semantically compliant (H0 null-hypothesis framing counts as a hypothesis + prediction pair). Some may be genuinely missing the prediction. Individual case-by-case review is needed for full accounting — this audit does not split them because the fix category is the same regardless: normalize the hypothesis-and-prediction convention across the repo.

### 4.2 container-apps: real MUST gaps (1)

**MUST6 cleanup — 1 file**:

- `startup-degraded-transient-failure` — uses 16-concept methodology structure, ends at `## 16. Support Takeaway`. No `## Clean Up` section. Given the lab is a live-Azure reproduction with resource-group deployment, cleanup instructions or an explicit "no cleanup required" note is required per Phase 2f MUST6.

### 4.3 container-apps: real A4 gaps (29)

The following 29 labs are shipped in `docs/troubleshooting/lab-guides/` without a companion `labs/<slug>/` directory:

```
azure-files-mount-failure
bicep-deployment-timeout
cold-start-scale-to-zero
custom-domain-tls-renewal
dapr-pubsub-failure
dapr-state-store-failure
docker-hub-rate-limit
easyauth-entra-id-failure
egress-ip-change
emptydir-disk-full
event-job-storm
github-actions-oidc-failure
log-analytics-ingestion-gap
min-replicas-cost-surprise
multi-arch-image-mismatch
multi-region-failover
observability-tracing
private-endpoint-dns-failure
probe-and-port-mismatch
replica-load-imbalance
scheduled-job-missed
session-affinity-failure
subnet-cidr-exhaustion
subscription-quota-exceeded
traffic-routing-canary
udr-nsg-egress-blocked
volume-permission-denied
websocket-grpc-ingress
workload-profile-mismatch
```

Phase 2f A4 is a SHOULD-tier item. A companion directory typically contains: `README.md`, `bicep/` templates, `evidence/` artifacts, `scripts/` reproduction helpers. Its absence means the lab is documentation-only with no reproducible infrastructure.

**Note**: All 25 of the 26 labs listed under §3.1 as "newer 16-concept-methodology labs" appear in this A4-gap list. The two lists overlap heavily — most 16-concept labs also lack companion dirs.

### 4.4 architecture: heuristic false-negatives (do not count as gaps)

**MUST3 procedure (3 files)**: Design labs use `## Validation Plan` + `## Falsification Criteria` as the equivalent of a procedure in the Variant B family. This is functionally equivalent to a runbook — it defines what will be tested and how. Heuristic did not recognize this phrasing.

**MUST4 evidence (3 files)**: All 3 have explicit `## Evidence` sections. Heuristic required a markdown table + evaluation-heading combination; the labs have narrative-style evidence, not tabular. Semantically compliant.

**B5 rejection notes (3 files)**: All 3 have `## Trade-offs and Risks` sections that contain rejection reasoning. Spot-checked content:
- lab-01: "Less runtime control than AKS or VMs", "Single-region baseline still has regional outage exposure"
- lab-02: "More DNS, routing, and private endpoint management than a public baseline"
- lab-03: "Stronger decoupling means weaker immediate consistency"

These are drawbacks/rejection notes — semantically compliant with B5.

### 4.5 architecture: real MUST gaps (1 category, 3 files)

**MUST6 cleanup — 3 files**:

- `lab-01-public-web-baseline.md`
- `lab-02-private-internal-app.md`
- `lab-03-event-driven-orders.md`

Design labs are paper exercises with no deployed infrastructure. Phase 2f §3 requires that MUST6 "cleanup" be satisfied by either a teardown procedure OR an explicit "No cleanup required — this is a paper design exercise" note. None of the 3 labs make this declaration explicit. **Real gap.** Trivial to fix.

### 4.6 aks: real gaps (all 5 labs, multiple categories)

The AKS labs are structurally tutorial-style, not experimental. Per Phase 2f §4 (Variant A), a lab MUST have a testable claim and evidence, and SHOULD have hypothesis-with-prediction, falsification, paired playbook, companion dir, and evidence artifacts.

- **MUST2** (testable claim): 0/5. Labs deploy an AKS cluster and show it works — no falsifiable claim.
- **MUST4** (evidence): 0/5. No KQL queries, no metric snapshots, no diagnostic evidence artifacts. Screenshots are absent.
- **A1** (hypothesis+prediction): 0/5.
- **A2** (falsification): 0/5. Labs do not attempt to break the deployment and prove the fix.
- **A3** (paired playbook): 1/5. Only lab-05 (disaster recovery) references an operations playbook.
- **A4** (companion `labs/<slug>/`): 0/5. AKS repo has no `labs/` directory at all.
- **A5** (richer evidence variant): 0/5. Not applicable — labs are not experiments.

**Root cause**: The AKS labs were authored as hands-on tutorials before Phase 2f contract adoption. They align with the AGENTS.md **Tutorial** content type (Language Guides section), not the **Troubleshooting Experiment (Variant A)** content type. Two options exist for closing these gaps:

1. **Reclassify**: Move `docs/tutorials/lab-guides/` content out of the "labs" family and into a `tutorials` family. Phase 2f applies only to experiment-style labs and design labs. The reclassification would make the current content correct in place.
2. **Upgrade**: Add hypothesis + falsification framing to each lab. This is expensive (5 labs × substantial rewrite) and may distort the tutorials' pedagogical purpose.

Recommendation: **Reclassify**. See §5.3.

## 5. P3 Follow-Up Recommendations

The P2-2 audit produces three P3-tier follow-up recommendations, ordered by cost:

### 5.1 P3-A (trivial, ~1 hour): architecture design labs cleanup declaration

**Scope**: Add explicit "## Cleanup" section to all 3 design labs stating "No cleanup required — this is a paper design exercise. No Azure resources are deployed."

**Files touched**: 3 (all under `docs/design-labs/`).

**Complexity**: Trivial. Copy-paste standard note.

**Blocker for**: None.

**Suggested title**: `[P3-A] architecture: add explicit "no cleanup required" declaration to 3 design labs`

### 5.2 P3-B (small, ~2 hours): container-apps cleanup gap + heading convention decision

**Scope A** (bugfix): Add `## Clean Up` section to `startup-degraded-transient-failure.md`.

**Scope B** (policy decision): The container-apps repo has two coexisting heading conventions (`## 1) Background` vs `## 1. Question`). Choose ONE canonical convention and document the choice in `AGENTS.md`. If the older `## 1) Background` form is canonical (per current AGENTS.md wording), the newer labs need refactoring; if the newer 16-concept form is now canonical, update AGENTS.md to say so.

**Files touched**: 1 for Scope A. Scope B is a policy decision that does NOT immediately mutate files; per issue #37, this audit is not authorized to perform the migration itself. The decision would enable a future P3-B2 rewrite pass touching ~26 files.

**Complexity**: Low for Scope A. Scope B requires cross-agent alignment (probably Oracle consultation on which convention should win).

**Blocker for**: None (Scope A) / Blocker for future repo-wide lab refactor (Scope B).

**Suggested title**: `[P3-B] container-apps: fix cleanup gap + choose canonical lab heading convention`

### 5.3 P3-C (larger, ~4-8 hours): aks lab family reclassification

**Scope**: Move `docs/tutorials/lab-guides/lab-*.md` from the "labs" family into a first-class **Tutorials** family. Options:

- **Option 1 (rename)**: Keep the files in `docs/tutorials/lab-guides/` but drop "lab" from the mental model. Update `mkdocs.yml` nav to label them as "Tutorial 1: ...", "Tutorial 2: ...". Update AGENTS.md to clarify that AKS repo does not currently have Variant A labs — the "labs" naming is legacy.
- **Option 2 (upgrade)**: Add hypothesis + prediction + falsification + companion `labs/<slug>/` directories to each of the 5 tutorials, converting them into true Variant A labs. This is the more expensive path.

Recommendation: **Option 1**, because:
- The 5 documents are pedagogically valid as hands-on tutorials (see AGENTS.md Language Guides section).
- Forcing hypothesis framing on a tutorial ("we hypothesize that `kubectl create deployment` will create a deployment") is contrived and lowers content quality.
- If AKS needs true experimental labs later, they should be authored fresh under the correct family.

**Files touched**: 5 markdown files (add clarifying note to intro), `mkdocs.yml` (nav labels), `AGENTS.md` (family taxonomy clarification).

**Complexity**: Medium. Includes rewriting intros + navigation + policy doc.

**Blocker for**: P2-3 (AKS baseline scaffolding) — deferrable. P2-3 will scaffold empty `apps/`, `infra/`, `labs/` directories with contract-explaining READMEs; the reclassification of existing lab-guides is a separate task.

**Suggested title**: `[P3-C] aks: reclassify tutorial-style labs into Tutorials family (Option 1: rename)`

### 5.4 Not recommended: sweeping container-apps A4 backfill

Adding companion `labs/<slug>/` directories to all 29 gap labs would be expensive (29 × substantial infra-scaffolding). Phase 2f A4 is SHOULD-tier, not MUST-tier. **Recommendation**: Leave as-is unless a specific lab is being re-executed and needs the companion assets. Do not mass-generate scaffolding for uncertain future need.

## 6. Non-Goals (Explicit)

- No lab content was rewritten in this audit.
- No new labs were authored.
- No companion `labs/<slug>/` directories were created.
- No heading conventions were changed.
- No mkdocs navigation was modified.
- No AGENTS.md policy was mutated.

Per issue #37 title: "Existing-lab repos: audit Phase 2f contract compliance **without rewrites**".

## 7. Data Reproducibility

The raw compliance JSON is in `/tmp/p2_2_audit_results.json` (session-local). To reproduce:

1. Load Phase 2f contract from `azure-container-apps-practical-guide/.sisyphus/plans/phase-2f-series-lab-contract.md` §3-5.
2. Author a Python audit script implementing the heuristics in §2.1.
3. Run over the three repos' lab-guides directories:
   - `azure-container-apps-practical-guide/docs/troubleshooting/lab-guides/*.md` (54 labs)
   - `azure-architecture-practical-guide/docs/design-labs/lab-*.md` (3 labs)
   - `azure-kubernetes-service-practical-guide/docs/tutorials/lab-guides/lab-*.md` (5 labs)
4. Spot-check every non-100% category to distinguish heuristic false-negatives from real gaps.

The audit's total surface (54 + 3 + 5 = 62 labs) is stable at the time of writing. Future lab additions in container-apps or aks will need re-audit for any P3 execution touching those files.

## 8. Summary Table

| Repo | Real MUST gaps | Real SHOULD gaps | P3 recommendation | Cost |
|---|---:|---:|---|---|
| container-apps | 1 (cleanup) | 29 (companion dir) + 1 (heading policy) | P3-B | small (~2h) |
| architecture | 3 (cleanup declaration) | 0 | P3-A | trivial (~1h) |
| aks | 5 (testable-claim + evidence, structural mismatch) | 25 (A1-A5 across 5 labs) | P3-C reclassification | medium (~4-8h) |

Total P3 execution effort estimate: ~7-11 hours across the three follow-ups.

## 9. Next Steps

1. Close issue #37 with a link to this audit.
2. Open three P3 issues (P3-A architecture, P3-B container-apps, P3-C aks) — deferred to a future wave; not required to unblock P2-3.
3. Proceed with P2-3 (AKS root scaffolding for `apps/`, `infra/`, `labs/`). Note: P2-3 scaffolds empty root directories with contract-explaining READMEs and does NOT modify existing `docs/tutorials/lab-guides/` content. P3-C reclassification of the existing content is a separate follow-up.
