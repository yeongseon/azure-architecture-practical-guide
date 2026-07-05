# P4 Zero-Lab Readiness Audit Wave — Coordinator Synthesis

**Wave**: P4 — Zero-Lab Lab Onboarding Readiness
**Date**: 2026-07-05
**Coordinator**: Sisyphus
**Scope**: 4 true zero-lab Azure sibling repos + 1 exclusion note
**Meta-tracker**: `azure-architecture-practical-guide#34`

## Purpose

This directory holds the P4 Zero-Lab Readiness Audit wave outputs. Each per-repo
plan answers a single question: *is this repo ready to onboard its first Variant A
troubleshooting lab, and if not, what is the smallest scaffolding sequence
required?*

The audit deliberately does NOT try to score general repo maturity, harmonize
validators, or catalog all possible future labs. See the standardized non-goals
in every per-repo plan.

## Scope: 4 True Zero-Lab Repos + 1 Excluded

| Repo | In P4-ZLR? | Reason |
|---|---|---|
| `azure-virtual-machine-practical-guide` | Yes | Truly zero-lab; standard 6-section docs shape |
| `azure-networking-practical-guide` | Yes | Truly zero-lab; standard 6-section docs shape |
| `azure-storage-practical-guide` | Yes | Truly zero-lab; standard 6-section docs shape |
| `azure-monitoring-practical-guide` | Yes | Truly zero-lab; unique `docs/service-guides/` subtree |
| `azure-app-service-practical-guide` | **No** | 13 existing labs + 4 in-flight standardization plans (see exclusion note) |

## Cross-Repo Summary Matrix

Per Oracle Q3, the wave produces 5 per-repo plans plus this thin coordinator
synthesis. This matrix is the single-screen view for leadership; per-repo depth
lives in the individual plan files.

| Repo | Variant A fit | Strongest first-lab candidate | Top blocker | Verdict | First issue to open |
|---|---|---|---|---|---|
| `azure-virtual-machine-practical-guide` | Ready | Extension Failures (paired with `playbooks/connectivity/extension-failures.md`) | No `docs/troubleshooting/lab-guides/` surface + no first-scenario substrate | **Needs scaffold** | `P4-ZLR-vm-01: Create the Variant A troubleshooting-lab scaffold` |
| `azure-networking-practical-guide` | Ready | Private Endpoint DNS link break/fix (paired with `playbooks/connectivity/cannot-reach-private-endpoint.md`) | No dedicated Variant A troubleshooting-lab surface or companion substrate | **Needs scaffold** | `P4-ZLR-networking-01: Establish Variant A troubleshooting-lab scaffold` |
| `azure-storage-practical-guide` | Ready | Private endpoint DNS failure / wrong resolution path (paired with `playbooks/access/private-endpoint-and-dns-issues.md`) | Missing troubleshooting-lab surface + `labs/` substrate | **Needs scaffold** | `P4-ZLR-storage-01: Add Variant A troubleshooting lab scaffold to azure-storage-practical-guide` |
| `azure-monitoring-practical-guide` | Ready | VM AMA heartbeat loss after DCR association break (paired with `playbooks/agent-not-reporting.md`) | No `docs/troubleshooting/lab-guides/` + no first-lab companion substrate | **Needs scaffold** | `P4-ZLR-monitoring-01: Add Troubleshooting lab-guides scaffold and nav surface` |

## Cross-Repo Patterns

Three findings emerged consistently across all 4 audits:

### 1. All 4 repos share the same verdict shape: **Needs scaffold, not Blocked**

Every zero-lab repo audited has:

- mature troubleshooting prose (hubs, decision trees, evidence maps, first-10-minutes pages, playbooks)
- validator baseline compatible with lab pages (`validate_content_sources.py`, `validate_mslearn_urls.py`)
- strong candidate scenario backlog already encoded in existing playbooks

None is blocked by policy, missing conventions, or absent conceptual foundation.
All are gated by the same two structural gaps: **no `docs/troubleshooting/lab-guides/`
surface** and **no companion reproduction substrate** (`labs/`, `infra/`, evidence dirs).

### 2. Three of four converged on Private-Endpoint-adjacent first labs

Networking, storage, and monitoring all identified private-endpoint or agent-connection
failure modes as their strongest first-lab candidate. This is not a coincidence:

- private-endpoint scenarios have crisp before/after evidence (`nslookup`, connectivity checks)
- failure injection is deterministic (remove DNS zone link, break DCR association)
- recovery is symmetric and cheap (relink DNS, reassociate DCR)
- paired playbooks already exist in each repo

VM was the outlier, choosing Extension Failures because its playbook + tutorial adjacency
(`lab-03-custom-script-extensions.md`) is unusually strong.

### 3. Decomposition converges on the same 3-4 issue shape

Every plan decomposes into the same skeleton:

1. **Scaffold** the `docs/troubleshooting/lab-guides/` surface + nav insertion
2. **Substrate** — minimal first-scenario companion (`labs/<slug>/` + evidence dir)
3. **Author** the first Variant A lab, paired with an existing playbook
4. **Optional follow-on** — one second lab to prove the pattern generalizes

This is exactly the shape Oracle predicted in Q3-Q4. It also means execution can
proceed in parallel across repos once the scaffold pattern is validated in the first repo.

## Recommended Execution Order

The wave produces 4 sets of P4-ZLR-* issues to open. Recommended sequence:

1. **Open all 4 parent issues first** (`P4 Zero-Lab Readiness — <repo>`) — they document intent and unblock triage
2. **Execute the storage or networking scaffold issue first** (`P4-ZLR-storage-01` or `P4-ZLR-networking-01`) — both are smallest scope, both use private-endpoint scenarios that can then serve as reference for the others
3. **Validate the scaffold pattern** — if the first-lab publication proves the model, apply the pattern to the remaining 3 repos in parallel
4. **Defer app-service** — its own in-flight P2-B/P2-C/P3/P4 plans supersede any zero-lab work

Per Oracle Q4 revisit criterion: *"Earliest point to revisit broader harmonization:
after first lab lands or after two repos complete P4."*

## Followup Issue Inventory

All 19 P4-ZLR issues registered on 2026-07-05 at architecture commit `58e5929`:

| Repo | Slug | Parent | Children |
|---|---|---|---|
| virtual-machine | `vm` | [#22](https://github.com/yeongseon/azure-virtual-machine-practical-guide/issues/22) | [#23](https://github.com/yeongseon/azure-virtual-machine-practical-guide/issues/23), [#24](https://github.com/yeongseon/azure-virtual-machine-practical-guide/issues/24), [#25](https://github.com/yeongseon/azure-virtual-machine-practical-guide/issues/25), [#26](https://github.com/yeongseon/azure-virtual-machine-practical-guide/issues/26) |
| networking | `networking` | [#21](https://github.com/yeongseon/azure-networking-practical-guide/issues/21) | [#22](https://github.com/yeongseon/azure-networking-practical-guide/issues/22), [#23](https://github.com/yeongseon/azure-networking-practical-guide/issues/23), [#24](https://github.com/yeongseon/azure-networking-practical-guide/issues/24) |
| storage | `storage` | [#20](https://github.com/yeongseon/azure-storage-practical-guide/issues/20) | [#21](https://github.com/yeongseon/azure-storage-practical-guide/issues/21), [#22](https://github.com/yeongseon/azure-storage-practical-guide/issues/22), [#23](https://github.com/yeongseon/azure-storage-practical-guide/issues/23), [#24](https://github.com/yeongseon/azure-storage-practical-guide/issues/24) |
| monitoring | `monitoring` | [#13](https://github.com/yeongseon/azure-monitoring-practical-guide/issues/13) | [#14](https://github.com/yeongseon/azure-monitoring-practical-guide/issues/14), [#15](https://github.com/yeongseon/azure-monitoring-practical-guide/issues/15), [#16](https://github.com/yeongseon/azure-monitoring-practical-guide/issues/16), [#17](https://github.com/yeongseon/azure-monitoring-practical-guide/issues/17) |

Total: 4 parent issues + 15 child issues = 19 GitHub issues across 4 repos.

Naming convention (frozen at wave start):

- Parent: `P4 Zero-Lab Readiness — <repo-name>`
- Child: `P4-ZLR-<slug>-NN: <imperative outcome>`

## Files In This Directory

| File | Purpose | Line count |
|---|---|---|
| `README.md` | This coordinator synthesis (you are here) | — |
| `azure-virtual-machine-practical-guide.md` | VM audit plan | 378 |
| `azure-networking-practical-guide.md` | Networking audit plan | 305 |
| `azure-storage-practical-guide.md` | Storage audit plan | 270 |
| `azure-monitoring-practical-guide.md` | Monitoring audit plan | 319 |
| `azure-app-service-practical-guide.md` | Exclusion note (not zero-lab) | 66 |

## Wave Methodology

- **Framing agent**: Oracle (consultation `bg_dcbfc767`, session `ses_0cf9f7873ffeGfzvkqrVGm18eK`) — designed the 8-dimension rubric, 13-section per-repo template, and 6-section delegation prompt
- **Execution**: 4 parallel `deep` category subagents, one per zero-lab repo, each writing a per-repo plan to this directory
- **Review**: Momus review invoked on each per-repo plan
- **Coordination**: Main Sisyphus agent frozen scope, prepared exclusion note, and produced this synthesis

## References

- Oracle framing session: `ses_0cf9f7873ffeGfzvkqrVGm18eK`
- Series Lab Contract v1: `docs/contributing/series-lab-contract.md`
- Prior audit template shapes:
    - `.sisyphus/plans/p2-frontmatter-audit.md`
    - `.sisyphus/plans/p2-existing-lab-audit.md`
- Meta-tracker: `azure-architecture-practical-guide#34`
