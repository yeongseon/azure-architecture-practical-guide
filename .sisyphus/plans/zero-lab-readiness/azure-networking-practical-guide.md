# P4 Zero-Lab Readiness Audit — azure-networking-practical-guide

**Parent:** `P4 Zero-Lab Readiness — azure-networking-practical-guide`
**Date:** 2026-07-05
**Auditor:** Sisyphus
**Primary target:** first Variant A troubleshooting lab

## 1. Executive Summary

`azure-networking-practical-guide` is **Needs scaffold** for onboarding its first Variant A troubleshooting lab.

The repo is not empty: it already has a mature troubleshooting information architecture, multiple symptom-first playbooks, an evidence map, and five tutorial-style lab guides that can be mined for reproduction steps. The strongest first-lab path is to convert an already-controlled failure pattern into a troubleshooting lab rather than inventing new substrate from scratch.

The best first candidate is **Private Endpoint DNS link break/fix** paired to `docs/troubleshooting/playbooks/connectivity/cannot-reach-private-endpoint.md`, because the repo already contains a tutorial with a deliberate break/recover step (`docs/tutorials/lab-guides/lab-02-private-endpoints.md`).

The repo is not blocked by policy or validators. The main readiness gap is structural: there is **no dedicated troubleshooting lab surface** (`docs/troubleshooting/lab-guides/` absent, no `labs/` companion tree, no troubleshooting asset/evidence subtree under `docs/assets/`).

## 2. Readiness Target

Target outcome: onboard **one first Variant A reproduction lab** that follows the Series Lab Contract v1 MUST tier and as many Variant A SHOULD items as practical, without modifying the tutorial program or launching a broader repo-wide standardization effort.

Assumed first-lab pattern:

- Troubleshooting-lab doc under `docs/troubleshooting/lab-guides/`
- Paired existing playbook
- Companion `labs/<slug>/` directory for reproducibility assets
- Evidence method that includes CLI proof and at least one richer evidence surface (KQL and/or portal capture placeholders)
- Explicit cleanup

## 3. Repository Snapshot

### Pre-work verification

- `git status --short --branch` → `## main...origin/main` (clean working tree)
- `git log --oneline -5` → HEAD `77a9210` with recent docs-only commits
- `git rev-parse HEAD` → `77a9210edffb62f504c112c2633fcbe70168a892`
- `git diff --stat` not needed because the working tree was clean

### Verified repository state at `~/GitHub/azure-networking-practical-guide/`

- Present: `mkdocs.yml`
- Present: `scripts/validate_content_sources.py`
- Present: `scripts/validate_mslearn_urls.py`
- Absent: `docs/troubleshooting/lab-guides/`
- Absent: `docs/design-labs/`
- Absent at repo root: `infra/`, `apps/`, `samples/`, `labs/`
- Present: `scripts/`
- Present: `docs/assets/` but only `favicon.svg` and `logo.svg`
- Present: `docs/tutorials/lab-guides/` with 5 existing tutorial labs
- Present: troubleshooting prose anchors including `index.md`, `evidence-map.md`, `decision-tree.md`, `first-10-minutes/`, and playbooks

### Important observed implications

1. The repo is truly zero-lab for the two contract lab surfaces (`docs/troubleshooting/lab-guides/`, `docs/design-labs/`).
2. The repo already has tutorial labs that can supply concrete Azure CLI runbooks.
3. The repo has validator baseline and MkDocs insertion points, so the first-lab problem is scaffolding and decomposition, not policy incompatibility.

## 4. Methodology

This audit was limited to first-lab onboarding readiness.

Inputs inspected:

- Series contract: `azure-architecture-practical-guide/docs/contributing/series-lab-contract.md`
- Repo structure and nav: `mkdocs.yml`, root inventory, `docs/`, `docs/troubleshooting/`, `docs/tutorials/`, `docs/assets/`, `scripts/`
- Troubleshooting anchors: `docs/troubleshooting/index.md`, `evidence-map.md`, `playbooks/index.md`
- Candidate playbooks: private endpoint, DNS, routing/peering, hybrid, load balancer
- Candidate tutorial substrates: `lab-02-private-endpoints.md`, `lab-04-azure-firewall.md`
- Validator surface: `scripts/validate_content_sources.py`, `scripts/validate_mslearn_urls.py`

Rubric applied: the shared 8-dimension readiness rubric with only three statuses — Ready, Needs scaffold, Blocked.

## 5. Readiness Scorecard

| Dimension | Status | Short evidence note | Follow-up needed |
|---|---|---|---|
| 1. Variant A fit | Ready | Troubleshooting corpus is symptom-first and hypothesis-driven; existing tutorial labs provide reproducible Azure steps. | Select first scenario and pair it to an existing playbook. |
| 2. Information architecture insertion fit | Needs scaffold | `docs/troubleshooting/lab-guides/` is absent and Troubleshooting nav has no Labs branch. | Add first-lab doc surface and MkDocs insertion. |
| 3. Supporting prose anchors | Ready | `troubleshooting/index.md`, `decision-tree.md`, `evidence-map.md`, and playbooks already frame evidence and diagnosis. | Reuse anchors; no new framework needed. |
| 4. Candidate scenario backlog quality | Ready | Multiple playbooks already describe concrete hypotheses and evidence methods. | Prioritize low-cost, high-control first scenario. |
| 5. Reproduction substrate readiness | Needs scaffold | No `labs/`, `infra/`, `apps/`, or `samples/`; only tutorial docs exist today. | Create minimal companion substrate for the first lab. |
| 6. Evidence and diagnostics substrate | Needs scaffold | Good evidence prose exists, but no troubleshooting screenshot/evidence asset tree exists. | Add evidence placeholders and companion evidence directory. |
| 7. Validator and policy compatibility | Ready | `mkdocs.yml`, `validate_content_sources.py`, and `validate_mslearn_urls.py` are present; canonical diagram provenance already exists. | Follow existing frontmatter and diagram conventions. |
| 8. Decomposition readiness | Ready | Work cleanly splits into scaffold, substrate/evidence, and first-lab authoring. | Open 3 issues in dependency order. |

## 6. Findings by Dimension

### 1) Variant A fit — Ready

Variant A is the correct default. The repo already operates in a troubleshooting-first mode:

- `docs/troubleshooting/index.md` routes by symptom and evidence.
- `docs/troubleshooting/evidence-map.md` maps questions to concrete commands such as `az network watcher test-connectivity`, `show-next-hop`, and `test-ip-flow`.
- Playbooks already define competing hypotheses and validating signals.

This is enough to support a reproduction lab family without forcing a Variant B design-lab pivot.

### 2) Information architecture insertion fit — Needs scaffold

The repo has no contract lab insertion surface yet:

- no `docs/troubleshooting/lab-guides/`
- no `docs/design-labs/`
- no Troubleshooting nav branch for labs in `mkdocs.yml`

The good news: the Troubleshooting section is already large and structured enough that a new `Labs` child fits naturally without reworking the whole nav.

### 3) Supporting prose anchors — Ready

The repo is unusually strong here for a zero-lab target:

- `scenario-router.md` already routes operational and troubleshooting situations to exact destinations
- `troubleshooting/index.md` provides the entry contract for symptom-first diagnosis
- `evidence-map.md` already defines evidence collection primitives
- playbooks like `cannot-reach-private-endpoint.md`, `dns-resolution-failures.md`, and `peering-and-routing-issues.md` provide paired prose anchors

This means the first lab can focus on reproduction and falsification, not on explaining the whole domain from scratch.

### 4) Candidate scenario backlog quality — Ready

The repo already contains multiple lab-worthy scenarios with testable claims:

- Private Endpoint reachability failure from missing DNS link or wrong resolution
- Peering/routing break after route override or bilateral mismatch
- Forced-egress path confusion across UDR / Firewall / policy

These are better first-lab candidates than generic "connectivity failure" because they have narrower failure domains and clearer proof artifacts.

### 5) Reproduction substrate readiness — Needs scaffold

The repo has no first-class reproduction substrate yet:

- no `labs/`
- no repo-level IaC or sample-app surface
- no evidence directories

However, tutorial labs already provide raw runbooks. Most importantly, `lab-02-private-endpoints.md` already includes a controlled deletion/recreation of the VNet DNS link, which is nearly a troubleshooting-lab experiment skeleton already.

### 6) Evidence and diagnostics substrate — Needs scaffold

Evidence prose is present, but evidence storage/output scaffolding is not.

Observed state:

- playbooks include evidence lists and, in some cases, KQL/CLI diagnostics
- `docs/assets/` has no troubleshooting subtree
- there is no `labs/<slug>/evidence/`

The first lab needs explicit artifact homes so evidence does not remain implicit.

### 7) Validator and policy compatibility — Ready

No validator blocker was found.

- `scripts/validate_content_sources.py` enforces diagram provenance on Mermaid pages
- `scripts/validate_mslearn_urls.py` exists locally
- the repo already uses `content_sources.diagrams` frontmatter style

This is enough for a first lab. Shared-library harmonization is not needed to start.

### 8) Decomposition readiness — Ready

The work can be opened and executed as a bounded, low-risk sequence:

1. scaffold lab surface
2. create minimal reproduction/evidence companion
3. author first lab and pair it to an existing playbook

That is the right size for this repo; anything larger would drift into backlog design instead of readiness.

## 7. Candidate First-Lab Backlog

| Candidate | Recommendation | Why it is strong | Existing anchors | Substrate risk |
|---|---|---|---|---|
| Private Endpoint DNS link break/fix | **Strongest first lab** | Already has a controlled break/restore step in `lab-02-private-endpoints.md`; maps directly to DNS + private endpoint playbooks; clear falsification after relinking. | `tutorials/lab-guides/lab-02-private-endpoints.md`, `troubleshooting/playbooks/connectivity/cannot-reach-private-endpoint.md`, `troubleshooting/playbooks/dns/dns-resolution-failures.md`, `evidence-map.md` | Low |
| Hub-spoke peering route override breaks east-west reachability | Strong | Fits networking identity of repo; can reuse existing VNet/peering tutorial substrate; evidence path is mostly CLI-driven and cheap. | `tutorials/lab-guides/lab-01-hub-spoke-topology.md`, `troubleshooting/playbooks/routing/peering-and-routing-issues.md`, `troubleshooting/playbooks/routing/nsg-vs-udr-vs-firewall.md` | Medium |
| Forced-egress UDR / Azure Firewall deny-path investigation | Stretch | Good playbook and tutorial substrate exist, but higher cost and stronger evidence dependency make it less suitable as the very first lab. | `tutorials/lab-guides/lab-04-azure-firewall.md`, `troubleshooting/playbooks/routing/nsg-vs-udr-vs-firewall.md`, `troubleshooting/playbooks/connectivity/outbound-connectivity-issues.md` | Medium-High |

Recommended first lab title direction:

`Private Endpoint DNS link missing causes private resolution failure`

Why this one first:

- lowest conceptual spread
- existing deliberate fault injection already documented
- direct paired playbooks already exist
- easiest to prove with before/after DNS + connectivity evidence

## 8. Gap Catalog

| Gap | Severity | Blocks first lab? | Minimal fix | Cross-repo dependency? |
|---|---|---|---|---|
| No troubleshooting lab doc surface (`docs/troubleshooting/lab-guides/` + nav branch) | High | Yes | Add lab-guides index and first-lab insertion in `mkdocs.yml` under Troubleshooting. | No |
| No companion reproduction substrate (`labs/` absent) | High | Yes | Create `labs/<slug>/` with README/runbook helper(s) and `evidence/` placeholder. | No |
| No troubleshooting evidence asset path under `docs/assets/` | Medium | Yes | Create `docs/assets/troubleshooting/<slug>/` plus naming convention for future captures. | No |
| Existing tutorial substrates are unvalidated (`reference/validation-status.md` shows 5 not tested) | Medium | No | Reuse tutorial logic carefully; do not treat validation debt as a prerequisite for first-lab onboarding. | No |

## 9. Decomposition Plan

**Parent:** `P4 Zero-Lab Readiness — azure-networking-practical-guide`

1. `P4-ZLR-networking-01: Establish Variant A troubleshooting-lab scaffold`
   - Outcome: repo gains the first-class doc and nav surface for troubleshooting labs.
2. `P4-ZLR-networking-02: Create minimal companion substrate and evidence layout for the private-endpoint lab`
   - Outcome: first lab has a reproducible `labs/<slug>/` home and evidence destinations.
3. `P4-ZLR-networking-03: Author the first troubleshooting lab for Private Endpoint DNS link failure and recovery`
   - Outcome: first Variant A lab lands, paired to existing playbooks.

Stop after issue 03 unless issue 03 reveals substrate debt that truly blocks publication.

## 10. Follow-up Issue Set

| Issue ID | Title | Depends on | Outcome | Effort |
|---|---|---|---|---|
| `P4-ZLR-networking-01` | Establish Variant A troubleshooting-lab scaffold | — | Add `docs/troubleshooting/lab-guides/`, a landing page, initial nav insertion, and first-lab template aligned to the series contract. | S |
| `P4-ZLR-networking-02` | Create minimal companion substrate and evidence layout for the private-endpoint lab | `P4-ZLR-networking-01` | Add `labs/private-endpoint-dns-link-failure/` with runbook assets and `evidence/`; add `docs/assets/troubleshooting/private-endpoint-dns-link-failure/`. | S-M |
| `P4-ZLR-networking-03` | Author the first troubleshooting lab for Private Endpoint DNS link failure and recovery | `P4-ZLR-networking-02` | Publish the first Variant A lab doc and cross-link it with the private endpoint and DNS playbooks. | M |

**`P4-ZLR-networking-01`**

**QA Scenario**
- **Tool**: `mkdocs build --strict`; `grep -F "- Labs:" mkdocs.yml`; `grep -F "troubleshooting/lab-guides/index.md" mkdocs.yml`; `python3 scripts/validate_content_sources.py`; `python3 scripts/validate_mslearn_urls.py`
- **Steps**:
    1. From `~/GitHub/azure-networking-practical-guide/`, run `grep -F "- Labs:" mkdocs.yml` and `grep -F "troubleshooting/lab-guides/index.md" mkdocs.yml` to confirm the Troubleshooting nav contains the new lab-guides branch.
    2. Verify the scaffold files exist by checking `test -f docs/troubleshooting/lab-guides/index.md` and `test -f docs/troubleshooting/lab-guides/private-endpoint-dns-link-failure.md`.
    3. Run `python3 scripts/validate_content_sources.py`, `python3 scripts/validate_mslearn_urls.py`, and `mkdocs build --strict` from the repo root.
- **Expected Results**:
    - Both `grep -F` commands return matching lines from `mkdocs.yml`, and both `test -f` checks succeed.
    - Both validator scripts exit 0 and `mkdocs build --strict` exits 0 with the new lab surface included in site navigation.

**`P4-ZLR-networking-02`**

**QA Scenario**
- **Tool**: `test -d labs/private-endpoint-dns-link-failure/`; `test -d labs/private-endpoint-dns-link-failure/evidence/`; `test -d docs/assets/troubleshooting/private-endpoint-dns-link-failure/`; `grep -F "link-vnet-lab02" labs/private-endpoint-dns-link-failure/README.md`; `grep -F "privatelink.blob.core.windows.net" labs/private-endpoint-dns-link-failure/README.md`; `az network private-dns link vnet delete --resource-group $RG --zone-name privatelink.blob.core.windows.net --name link-vnet-lab02 --yes`; `az vm run-command invoke --resource-group $RG --name vm-client02 --command-id RunShellScript --scripts "nslookup $STORAGE_NAME.blob.core.windows.net"`; `az network private-dns link vnet create --resource-group $RG --zone-name privatelink.blob.core.windows.net --name link-vnet-lab02 --virtual-network $VNET_NAME --registration-enabled false`; `az network watcher test-connectivity --resource-group $RG --source-resource $(az vm show --resource-group $RG --name vm-client02 --query id --output tsv) --dest-address $STORAGE_NAME.blob.core.windows.net --dest-port 443`; `az group delete --name $RG --yes --no-wait`
- **Steps**:
    1. From `~/GitHub/azure-networking-practical-guide/`, run `test -d labs/private-endpoint-dns-link-failure/`, `test -d labs/private-endpoint-dns-link-failure/evidence/`, and `test -d docs/assets/troubleshooting/private-endpoint-dns-link-failure/`, then inspect the substrate instructions with `grep -F "link-vnet-lab02" labs/private-endpoint-dns-link-failure/README.md` and `grep -F "privatelink.blob.core.windows.net" labs/private-endpoint-dns-link-failure/README.md`.
    2. Deploy or reuse the tutorial substrate described by the companion README, then run `az network private-dns link vnet delete --resource-group $RG --zone-name privatelink.blob.core.windows.net --name link-vnet-lab02 --yes` followed by `az vm run-command invoke --resource-group $RG --name vm-client02 --command-id RunShellScript --scripts "nslookup $STORAGE_NAME.blob.core.windows.net"` to reproduce the fault.
    3. Restore the link with `az network private-dns link vnet create --resource-group $RG --zone-name privatelink.blob.core.windows.net --name link-vnet-lab02 --virtual-network $VNET_NAME --registration-enabled false`, validate recovery with `az network watcher test-connectivity --resource-group $RG --source-resource $(az vm show --resource-group $RG --name vm-client02 --query id --output tsv) --dest-address $STORAGE_NAME.blob.core.windows.net --dest-port 443`, save the captured outputs into `labs/private-endpoint-dns-link-failure/evidence/`, and clean up with `az group delete --name $RG --yes --no-wait`.
- **Expected Results**:
    - All three directories exist, and the companion README explicitly contains the documented DNS-link fault-injection commands and zone name.
    - After link deletion, the `nslookup` output shows the documented broken-resolution symptom; after link recreation, `az network watcher test-connectivity` succeeds and cleanup starts without orphan-preserving errors.

**`P4-ZLR-networking-03`**

**QA Scenario**
- **Tool**: `test -f docs/troubleshooting/lab-guides/private-endpoint-dns-link-failure.md`; `grep -F "## 1) Background" docs/troubleshooting/lab-guides/private-endpoint-dns-link-failure.md`; `grep -F "## 2) Hypothesis" docs/troubleshooting/lab-guides/private-endpoint-dns-link-failure.md`; `grep -F "## 3) Runbook" docs/troubleshooting/lab-guides/private-endpoint-dns-link-failure.md`; `grep -F "## 4) Experiment Log" docs/troubleshooting/lab-guides/private-endpoint-dns-link-failure.md`; `grep -F "## 5) Verification Queries" docs/troubleshooting/lab-guides/private-endpoint-dns-link-failure.md`; `grep -F "## 6) Portal Evidence" docs/troubleshooting/lab-guides/private-endpoint-dns-link-failure.md`; `grep -F "## Clean Up" docs/troubleshooting/lab-guides/private-endpoint-dns-link-failure.md`; `grep -F "## Related Playbook" docs/troubleshooting/lab-guides/private-endpoint-dns-link-failure.md`; `grep -F "../playbooks/connectivity/cannot-reach-private-endpoint.md" docs/troubleshooting/lab-guides/private-endpoint-dns-link-failure.md`; `grep -F "../playbooks/dns/dns-resolution-failures.md" docs/troubleshooting/lab-guides/private-endpoint-dns-link-failure.md`; `python3 scripts/validate_content_sources.py`; `python3 scripts/validate_mslearn_urls.py`; `mkdocs build --strict`
- **Steps**:
    1. Confirm the first lab page exists with `test -f docs/troubleshooting/lab-guides/private-endpoint-dns-link-failure.md` and verify the required section headings by running the listed `grep -F` commands against that file.
    2. Verify cross-links and paired-playbook references by running `grep -F "../playbooks/connectivity/cannot-reach-private-endpoint.md" docs/troubleshooting/lab-guides/private-endpoint-dns-link-failure.md` and `grep -F "../playbooks/dns/dns-resolution-failures.md" docs/troubleshooting/lab-guides/private-endpoint-dns-link-failure.md`, then inspect any referenced screenshots under `docs/assets/troubleshooting/private-endpoint-dns-link-failure/` for placeholder-free filenames and PII-safe captures.
    3. From the repo root, run `python3 scripts/validate_content_sources.py`, `python3 scripts/validate_mslearn_urls.py`, and `mkdocs build --strict`.
- **Expected Results**:
    - The lab page exists, every required heading grep returns a match, and both paired playbook links are present in the document.
    - The provenance validators exit 0 and `mkdocs build --strict` exits 0, proving the authored Variant A lab publishes cleanly in the repo.

## 11. Non-goals

1. Not a content completeness audit
2. Not a shared-validator design proposal
3. Not a broken-link or MSLearn freshness sweep
4. Not a cross-repo deduplication exercise
5. Not first-lab implementation itself
6. Not a long-term backlog for all possible labs

## 12. Data Reproducibility

Observed on local repo path: `~/GitHub/azure-networking-practical-guide/`

- Audit date: 2026-07-05
- HEAD: `77a9210edffb62f504c112c2633fcbe70168a892`
- Branch state: clean `main...origin/main`

Primary files inspected:

- `mkdocs.yml`
- `scripts/validate_content_sources.py`
- `scripts/validate_mslearn_urls.py`
- `docs/troubleshooting/index.md`
- `docs/troubleshooting/evidence-map.md`
- `docs/troubleshooting/playbooks/index.md`
- `docs/troubleshooting/playbooks/connectivity/cannot-reach-private-endpoint.md`
- `docs/troubleshooting/playbooks/dns/dns-resolution-failures.md`
- `docs/troubleshooting/playbooks/routing/nsg-vs-udr-vs-firewall.md`
- `docs/troubleshooting/playbooks/routing/peering-and-routing-issues.md`
- `docs/troubleshooting/playbooks/routing/hybrid-connectivity-issues.md`
- `docs/troubleshooting/playbooks/load-balancer-health-probe-failures.md`
- `docs/tutorials/lab-guides/lab-02-private-endpoints.md`
- `docs/tutorials/lab-guides/lab-04-azure-firewall.md`
- `docs/reference/validation-status.md`
- `azure-architecture-practical-guide/docs/contributing/series-lab-contract.md`

Inventory facts in this audit are based on direct filesystem reads and targeted content inspection, not on prior summaries.

## 13. Decision Summary

- **Verdict:** Needs scaffold
- **First recommended issue:** `P4-ZLR-networking-01: Establish Variant A troubleshooting-lab scaffold`
- **Earliest point to revisit broader harmonization:** after first lab lands or after two repos complete P4

Recommended execution order:

1. `P4-ZLR-networking-01: Establish Variant A troubleshooting-lab scaffold`
2. `P4-ZLR-networking-02: Create minimal companion substrate and evidence layout for the private-endpoint lab`
3. `P4-ZLR-networking-03: Author the first troubleshooting lab for Private Endpoint DNS link failure and recovery`
4. Optional: `P4-ZLR-networking-04: Add a second troubleshooting lab for peering route override after the first lab lands`
