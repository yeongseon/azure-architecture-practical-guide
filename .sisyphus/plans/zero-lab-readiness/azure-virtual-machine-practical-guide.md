# P4 Zero-Lab Readiness Audit — azure-virtual-machine-practical-guide

**Wave**: P4 — Zero-Lab Lab Onboarding Readiness  
**Date**: 2026-07-05  
**Repository**: `azure-virtual-machine-practical-guide`  
**Primary target**: First Variant A troubleshooting lab  
**Verdict**: Needs scaffold

## 1. Executive Summary

`azure-virtual-machine-practical-guide` is a real zero-lab repo for Phase 2f purposes: it has a mature troubleshooting prose surface, strong symptom-routing anchors, and existing validator infrastructure, but it does **not** yet have a dedicated troubleshooting-lab surface or any reproduction substrate directories.

The repo is therefore **not blocked**, but it is also **not first-lab-ready without scaffold**. The strongest first lab is **Extension Failures**, because it already has a crisp troubleshooting playbook, a first-10-minutes entry point, a scenario-router entry, and a tutorial lab (`docs/tutorials/lab-guides/lab-03-custom-script-extensions.md`) that can be repurposed as baseline deployment context. The second-strongest candidate is **Cannot RDP or SSH**, with strong reader demand and a related Bastion/JIT tutorial (`lab-04-azure-bastion-jit-access.md`).

The minimum path is a 4-issue chain: add the troubleshooting-lab scaffold, add minimal substrate/evidence scaffolding for the first scenario, author the first Variant A lab, then optionally land a second lab once the first proves the pattern.

## 2. Readiness Target

Target readiness is **one publishable Variant A troubleshooting lab** under `docs/troubleshooting/lab-guides/` that follows the Phase 2f lab contract:

- opens with a clear problem statement and falsifiable claim
- uses a reproducible procedure
- defines evidence artifacts explicitly
- includes post-fix validation
- declares cleanup
- cross-links to its paired troubleshooting playbook

For this repo, the preferred first target is:

- **Scenario**: VM extension failure reproduction
- **Paired playbook**: `docs/troubleshooting/playbooks/connectivity/extension-failures.md`
- **Preferred evidence shape**: richer Variant A form (`Verification Queries` + `Portal Evidence`), even if KQL remains lightweight in v1

## 3. Repository Snapshot

Observed directly at `~/GitHub/azure-virtual-machine-practical-guide/` on HEAD `9bb0fe8f8b8a6a04bc3ce32bc14a52869095469b` (`9bb0fe8`).

### Pre-work verification

- `git status --short --branch` → clean working tree on `main...origin/main`
- `git log --oneline -5` → latest commit `9bb0fe8 docs(scenario-router): add unified scenario-router.md aligning with series-wide start-here shape`
- `git rev-parse HEAD` → `9bb0fe8f8b8a6a04bc3ce32bc14a52869095469b`
- `git diff --stat` → not needed because `git status` was clean

### Verified filesystem state

- `docs/troubleshooting/` **exists** and is populated with:
  - `index.md`
  - `decision-tree.md`
  - `evidence-map.md`
  - `mental-model.md`
  - `quick-diagnosis-cards.md`
  - `first-10-minutes/*`
  - `playbooks/*`
- `docs/troubleshooting/lab-guides/` **does not exist**
- `docs/design-labs/` **does not exist**
- `docs/troubleshooting/kql/` **does not exist**
- `mkdocs.yml` **exists** and already has a substantial Troubleshooting section
- `scripts/validate_content_sources.py` **exists**
- `scripts/validate_mslearn_urls.py` **exists**
- `scripts/validate_mermaid_format.py` and `scripts/validate_mermaid_syntax.py` also exist
- `docs/tutorials/lab-guides/` **exists** with 5 hands-on tutorial labs
- `docs/assets/` exists but contains only `favicon.svg` and `logo.svg`
- root-level `infra/`, `apps/`, and `samples/` **do not exist**
- root-level `labs/` **does not exist**

### Relevant content anchors verified

- Start-here router: `docs/start-here/scenario-router.md`
- Start-here role paths: `docs/start-here/learning-paths.md`
- Troubleshooting hub: `docs/troubleshooting/index.md`
- Evidence anchor: `docs/troubleshooting/evidence-map.md`
- Symptom router: `docs/troubleshooting/decision-tree.md`
- First-response anchors: `docs/troubleshooting/first-10-minutes/connectivity.md`, `boot.md`
- Candidate playbooks:
  - `docs/troubleshooting/playbooks/connectivity/extension-failures.md`
  - `docs/troubleshooting/playbooks/connectivity/cannot-rdp-or-ssh.md`
  - `docs/troubleshooting/playbooks/boot-disk/backup-failures.md`
- Candidate tutorial substrate:
  - `docs/tutorials/lab-guides/lab-03-custom-script-extensions.md`
  - `docs/tutorials/lab-guides/lab-04-azure-bastion-jit-access.md`
  - `docs/tutorials/lab-guides/lab-02-disk-encryption-and-backup.md`

## 4. Methodology

This audit applied the shared 8-dimension zero-lab readiness rubric against verified repository state only.

Inputs used:

1. Phase 2f contract: `azure-architecture-practical-guide/docs/contributing/series-lab-contract.md`
2. Repository structure and navigation (`mkdocs.yml`, root inventory)
3. Troubleshooting anchors (hub, decision tree, evidence map, first-10-minutes pages)
4. Candidate playbooks and tutorial-lab surfaces
5. Validator and policy files (`AGENTS.md`, `scripts/validate_content_sources.py`, `scripts/validate_mslearn_urls.py`)

This is a **read-only** audit against the VM repo. No file in `azure-virtual-machine-practical-guide` was modified.

## 5. Readiness Scorecard

| Dimension | Status | Short evidence note | Follow-up needed |
|---|---|---|---|
| 1. Variant A fit | Ready | Repo already has symptom-driven troubleshooting structure and OS/runtime failure scenarios; contract explicitly says VM should use Variant A if it authors an OS-level lab. | Choose first scenario only. |
| 2. Information architecture insertion fit | Needs scaffold | `docs/troubleshooting/` is mature, but `docs/troubleshooting/lab-guides/` is absent and `mkdocs.yml` has no Labs child yet. | Add lab-guides hub and minimal nav insertion. |
| 3. Supporting prose anchors | Ready | Scenario Router, Troubleshooting hub, Decision Tree, Evidence Map, First 10 Minutes, and paired playbooks already exist. | Reuse anchors and cross-link both directions. |
| 4. Candidate scenario backlog quality | Ready | Extension, admin-path, backup, boot, and connectivity scenarios are already broken out as specific playbooks with hypotheses/evidence prompts. | Rank and sequence first candidates. |
| 5. Reproduction substrate readiness | Needs scaffold | No `labs/`, `infra/`, `apps/`, or `samples/`; tutorial labs are docs-only and generic. | Add minimal companion substrate for the first scenario. |
| 6. Evidence and diagnostics substrate | Needs scaffold | Evidence Map exists, but no `docs/troubleshooting/kql/`, no troubleshooting asset tree, and no evidence directories. | Add first-lab evidence pack structure. |
| 7. Validator and policy compatibility | Ready | Mermaid and MSLearn validators exist; AGENTS already treats `docs/troubleshooting/lab-guides/**` as out of `content_validation` scope. | Follow existing frontmatter/diagram rules. |
| 8. Decomposition readiness | Ready | Gaps are bounded and map cleanly to scaffold → substrate → first lab → optional follow-on. | Open 4 issues max in dependency order. |

## 6. Findings by Dimension

### 1) Variant A fit — Ready

This repo clearly fits Variant A, not Variant B:

- troubleshooting is organized around failure symptoms and diagnosis
- playbooks already frame competing hypotheses and evidence collection
- the contract's per-repo applicability table explicitly says VM should use Variant A if it authors an OS-level lab

Nothing in the repo suggests the first lab should be a design exercise instead of a reproduction lab.

### 2) Information architecture insertion fit — Needs scaffold

The prose architecture is strong, but the actual lab insertion point is missing.

Evidence:

- `docs/troubleshooting/` exists and is already the right home for Variant A labs
- `docs/troubleshooting/lab-guides/` does not exist
- `mkdocs.yml` Troubleshooting nav includes Overview, Quick Diagnosis, Decision Tree, Mental Model, Evidence Map, First 10 Minutes, and Playbooks, but no Labs node

Implication:

- the repo does not need a new top-level section
- it does need a **bounded** troubleshooting-lab surface: a hub page plus minimal nav entry
- because the Troubleshooting nav is already full, the lab hub should list labs on the page and avoid fully expanding every lab in `mkdocs.yml`

### 3) Supporting prose anchors — Ready

This is the repo's strongest area.

Verified anchors already available:

- `docs/start-here/scenario-router.md` routes users from troubleshooting situations to specific playbooks
- `docs/troubleshooting/index.md` frames the troubleshooting workflow
- `docs/troubleshooting/decision-tree.md` routes symptoms to scenario pages
- `docs/troubleshooting/evidence-map.md` already defines the evidence mindset and typical tools
- `docs/troubleshooting/first-10-minutes/connectivity.md` and `boot.md` provide immediate incident entry points
- candidate playbooks already exist for extension failures, RDP/SSH loss, boot issues, and backup failures

This means the first lab can land as a **paired reproducible companion**, not as an orphaned new artifact.

### 4) Candidate scenario backlog quality — Ready

The backlog is already sufficiently specific for first-lab selection.

Best current candidates are scenarios that satisfy all four conditions:

1. symptom is common and operator-relevant
2. playbook already exists
3. failure can be reproduced without building a whole application substrate
4. there is some adjacent tutorial or ops content to reuse

`Extension Failures` is the strongest because it has a tight hypothesis set and a nearby tutorial lab about Custom Script Extension. `Cannot RDP or SSH` is next because it is high-value and pairs naturally with the Bastion/JIT tutorial. `Backup Failures` is viable but introduces more service dependencies.

### 5) Reproduction substrate readiness — Needs scaffold

This is the largest concrete gap.

Observed state:

- no `labs/` directory
- no `infra/`
- no `apps/`
- no `samples/`
- tutorial labs are markdown walkthroughs only; they do not ship companion templates, scripts, or evidence folders

Consequence:

- the repo can describe scenarios, but it cannot yet reproducibly provision, misconfigure, verify, and clean up a Variant A lab with the usual series shape

Minimum acceptable first step is **not** a large shared scaffold. It is a focused first-scenario substrate, likely under `labs/<scenario>/`, with only the files needed to reproduce one scenario and collect evidence.

### 6) Evidence and diagnostics substrate — Needs scaffold

The prose evidence model exists; the artifact substrate does not.

Observed state:

- `docs/troubleshooting/evidence-map.md` is strong
- no `docs/troubleshooting/kql/`
- no `docs/assets/troubleshooting/`
- no per-lab `evidence/` directories

Implication:

- the first lab can still be Variant A, but it needs a **starter evidence pack**:
  - one or more verification queries or CLI evidence snippets
  - a portal-screenshot path reserved for later capture
  - an evidence directory under the companion lab substrate

### 7) Validator and policy compatibility — Ready

No major policy blocker was found.

Verified compatibility points:

- `scripts/validate_content_sources.py` already enforces canonical Mermaid provenance shape
- `scripts/validate_mslearn_urls.py` already validates Learn URLs in frontmatter and source sections
- `AGENTS.md` already treats `docs/troubleshooting/lab-guides/**` as out of `content_validation` scope, which matches the series contract
- the repo already uses the series conventions for Mermaid comments, Learn URLs, and troubleshooting-tail sections

The first lab should therefore fit the existing policy surface rather than needing policy redesign.

### 8) Decomposition readiness — Ready

The work breaks cleanly into a short dependency chain:

1. create the docs/nav scaffold
2. create the first-scenario substrate/evidence skeleton
3. author the first lab against that scaffold
4. optionally repeat once the pattern is proven

This is exactly the shape wanted for a P4 readiness plan.

## 7. Candidate First-Lab Backlog

| Rank | Scenario | Status | Why it is strong | Main caveat |
|---:|---|---|---|---|
| 1 | **Extension Failures** (`playbooks/connectivity/extension-failures.md`) | Strong first-lab candidate | Tight symptom boundary; clear hypotheses; existing `lab-03-custom-script-extensions.md` tutorial adjacency; reproducible via bad payload / blocked dependency / unhealthy agent path. | Needs first dedicated substrate because tutorial lab is generic and docs-only. |
| 2 | **Cannot RDP or SSH** (`playbooks/connectivity/cannot-rdp-or-ssh.md`) | Strong first-lab candidate | Very high operator value; strong cross-links from Scenario Router, Decision Tree, and First 10 Minutes; adjacent `lab-04-azure-bastion-jit-access.md` tutorial. | Failure matrix is broader; first lab must narrow to one concrete failure mode such as NSG/JIT admin-path denial. |
| 3 | **Backup Failures** (`playbooks/boot-disk/backup-failures.md`) | Stretch candidate | Existing backup tutorial adjacency (`lab-02-disk-encryption-and-backup.md`); clear evidence cues in playbook. | Heavier service surface: vault, snapshot timing, locks, and outbound requirements increase setup and cleanup cost. |

Recommendation:

- **Primary first-lab candidate**: Extension Failures
- **Alternate if extension scenario proves awkward during design**: Cannot RDP or SSH (narrowed to one admin-path failure)
- **Stretch after the first pattern lands**: Backup Failures

## 8. Gap Catalog

| Gap | Severity | Blocks first lab? | Minimal fix | Cross-repo dependency? |
|---|---|---:|---|---|
| No `docs/troubleshooting/lab-guides/` surface | Medium | Yes | Add lab-guides directory, index page, and one bounded nav entry under Troubleshooting. | No |
| No companion reproduction substrate (`labs/`, `infra/`, `samples/`) | High | Yes | Add only the first-scenario companion directory with minimal scripts/templates/evidence placeholders. | No |
| No evidence artifact surface (`docs/troubleshooting/kql/`, `docs/assets/troubleshooting/`, per-lab `evidence/`) | Medium | Yes | Create minimal first-lab evidence pack structure; do not build a full repo-wide catalog yet. | No |
| Tutorial labs are generic and not falsification-style | Medium | No | Reuse them as deployment context only; do not present them as Variant A labs. | No |
| Troubleshooting nav has no Labs insertion yet | Low | Yes | Add a single Labs hub entry and keep deep inventory on the index page. | No |

## 9. Decomposition Plan

**Parent**: `P4 Zero-Lab Readiness — azure-virtual-machine-practical-guide`

Sequence:

1. **Scaffold the troubleshooting-lab surface** so the repo has a canonical landing zone for Variant A content.
2. **Create minimal first-scenario substrate and evidence skeleton** for the chosen scenario, not a generic mega-framework.
3. **Author the first Variant A lab** against the existing paired playbook and tutorial context.
4. **Optionally add one second lab** only after the first proves the pattern and artifact model.

This should stay a 4-issue chain. Anything broader becomes a backlog expansion, not a zero-lab readiness plan.

## 10. Follow-up Issue Set

| Issue ID | Title | Depends on | Outcome | Effort |
|---|---|---|---|---|
| `P4-ZLR-vm-01` | `P4-ZLR-vm-01: Create the Variant A troubleshooting-lab scaffold` | — | Adds `docs/troubleshooting/lab-guides/` hub, minimal nav insertion, and first-lab starter shape aligned to the series contract and repo frontmatter style. | S |
| `P4-ZLR-vm-02` | `P4-ZLR-vm-02: Add minimal reproduction substrate and evidence skeleton for extension-failure labs` | `P4-ZLR-vm-01` | Creates the first companion substrate (likely `labs/<scenario>/`) plus evidence placeholders, verification-query location, and cleanup path for one scenario only. | M |
| `P4-ZLR-vm-03` | `P4-ZLR-vm-03: Author the first Variant A lab for VM extension failure reproduction` | `P4-ZLR-vm-02` | Publishes the first lab, cross-linked to `playbooks/connectivity/extension-failures.md`, with procedure, evidence method, falsification-after-fix, and cleanup. | M |
| `P4-ZLR-vm-04` | `P4-ZLR-vm-04: Add an admin-path failure lab for Cannot RDP or SSH` | `P4-ZLR-vm-03` | Optional follow-on that proves the pattern generalizes to a second high-value VM incident scenario. | M |

### `P4-ZLR-vm-01`

**QA Scenario**
- **Tool**: `test -d docs/troubleshooting/lab-guides`, `test -f docs/troubleshooting/lab-guides/index.md`, `grep -F "troubleshooting/lab-guides/index.md" mkdocs.yml`, `mkdocs build --strict`, `python3 scripts/validate_content_sources.py`, `python3 scripts/validate_mslearn_urls.py`
- **Steps**:
    1. Confirm the new troubleshooting-lab directory and hub page exist at `docs/troubleshooting/lab-guides/` and `docs/troubleshooting/lab-guides/index.md`.
    2. Verify `mkdocs.yml` contains a Troubleshooting nav entry pointing to `troubleshooting/lab-guides/index.md` and does not introduce a new top-level section.
    3. Run `python3 scripts/validate_content_sources.py`, `python3 scripts/validate_mslearn_urls.py`, and `mkdocs build --strict` from the repo root.
- **Expected Results**:
    - The lab-guides directory and index page exist, and `grep -F "troubleshooting/lab-guides/index.md" mkdocs.yml` returns a match under Troubleshooting.
    - Both validator scripts exit 0 and `mkdocs build --strict` exits 0 with no broken internal links.

### `P4-ZLR-vm-02`

**QA Scenario**
- **Tool**: `test -d labs/extension-failure`, `test -d labs/extension-failure/evidence`, `test -f labs/extension-failure/main.bicep`, `test -f labs/extension-failure/README.md`, `test -f labs/extension-failure/scripts/reproduce.sh`, `test -f labs/extension-failure/scripts/cleanup.sh`, `az bicep build --file labs/extension-failure/main.bicep`, `az deployment group create --resource-group $RG --template-file labs/extension-failure/main.bicep --parameters @labs/extension-failure/parameters.json`, `bash labs/extension-failure/scripts/reproduce.sh`, `test -f labs/extension-failure/evidence/az-vm-extension-show.json`, `test -f labs/extension-failure/evidence/activity-log.txt`, `bash labs/extension-failure/scripts/cleanup.sh`
- **Steps**:
    1. Verify the substrate exists at `labs/extension-failure/` with `main.bicep`, `README.md`, `scripts/reproduce.sh`, `scripts/cleanup.sh`, and `evidence/`.
    2. Run `az bicep build --file labs/extension-failure/main.bicep`, then deploy the substrate with `az deployment group create --resource-group $RG --template-file labs/extension-failure/main.bicep --parameters @labs/extension-failure/parameters.json`.
    3. Execute `bash labs/extension-failure/scripts/reproduce.sh`, confirm the documented failure appears, capture the expected evidence artifacts, then execute `bash labs/extension-failure/scripts/cleanup.sh`.
- **Expected Results**:
    - The substrate directory, evidence directory, Bicep template, and scripts all exist, and `az bicep build --file labs/extension-failure/main.bicep` exits 0.
    - Deployment succeeds, the reproduce script triggers the documented extension-failure symptom, the evidence directory contains at least `az-vm-extension-show.json` and `activity-log.txt`, and cleanup removes the deployed lab resources without leaving the resource group orphaned.

### `P4-ZLR-vm-03`

**QA Scenario**
- **Tool**: `test -f docs/troubleshooting/lab-guides/extension-failures.md`, `grep -F "## 5) Verification Queries" docs/troubleshooting/lab-guides/extension-failures.md`, `grep -F "## 6) Portal Evidence" docs/troubleshooting/lab-guides/extension-failures.md`, `grep -F "playbooks/connectivity/extension-failures.md" docs/troubleshooting/lab-guides/extension-failures.md`, `grep -F "troubleshooting/lab-guides/extension-failures.md" mkdocs.yml`, `mkdocs build --strict`, `python3 scripts/validate_content_sources.py`, `python3 scripts/validate_mslearn_urls.py`
- **Steps**:
    1. Confirm the new lab page exists at `docs/troubleshooting/lab-guides/extension-failures.md` and includes the richer Variant A evidence sections plus a link to `playbooks/connectivity/extension-failures.md`.
    2. Verify `mkdocs.yml` includes `troubleshooting/lab-guides/extension-failures.md` in the troubleshooting-lab surface created by `P4-ZLR-vm-01`.
    3. Run `python3 scripts/validate_content_sources.py`, `python3 scripts/validate_mslearn_urls.py`, and `mkdocs build --strict` from the repo root after adding the page and any screenshot references.
- **Expected Results**:
    - The lab page exists, contains `## 5) Verification Queries` and `## 6) Portal Evidence`, and the paired playbook link resolves in the built site.
    - `grep -F "troubleshooting/lab-guides/extension-failures.md" mkdocs.yml` returns a match, both validator scripts exit 0, and `mkdocs build --strict` exits 0 with no broken links or invalid frontmatter provenance.

### `P4-ZLR-vm-04`

**QA Scenario**
- **Tool**: `test -f docs/troubleshooting/lab-guides/cannot-rdp-or-ssh.md`, `grep -F "playbooks/connectivity/cannot-rdp-or-ssh.md" docs/troubleshooting/lab-guides/cannot-rdp-or-ssh.md`, `grep -F "troubleshooting/lab-guides/cannot-rdp-or-ssh.md" mkdocs.yml`, `mkdocs build --strict`, `python3 scripts/validate_content_sources.py`, `python3 scripts/validate_mslearn_urls.py`, `test -f labs/cannot-rdp-or-ssh/evidence/connection-test.txt`, `test -f labs/cannot-rdp-or-ssh/evidence/effective-nsg.json`
- **Steps**:
    1. Confirm the follow-on lab page exists at `docs/troubleshooting/lab-guides/cannot-rdp-or-ssh.md`, narrows to one concrete admin-path failure mode, and links back to `playbooks/connectivity/cannot-rdp-or-ssh.md`.
    2. Verify `mkdocs.yml` includes `troubleshooting/lab-guides/cannot-rdp-or-ssh.md` and that the follow-on lab does not widen scope beyond the troubleshooting-lab surface and companion evidence artifacts.
    3. Run `python3 scripts/validate_content_sources.py`, `python3 scripts/validate_mslearn_urls.py`, and `mkdocs build --strict`, then confirm the expected evidence artifacts exist at `labs/cannot-rdp-or-ssh/evidence/connection-test.txt` and `labs/cannot-rdp-or-ssh/evidence/effective-nsg.json`.
- **Expected Results**:
    - The lab page exists, the paired playbook link is present, and `grep -F "troubleshooting/lab-guides/cannot-rdp-or-ssh.md" mkdocs.yml` returns a match.
    - The evidence artifacts exist at the documented paths, both validator scripts exit 0, and `mkdocs build --strict` exits 0 with no broken nav or internal links.

## 11. Non-goals

1. Not a content completeness audit
2. Not a shared-validator design proposal
3. Not a broken-link or MSLearn freshness sweep
4. Not a cross-repo deduplication exercise
5. Not first-lab implementation itself
6. Not a long-term backlog for all possible labs

## 12. Data Reproducibility

Audit inputs were gathered locally from the checked-out repository on 2026-07-05.

Commands run:

- `git status --short --branch`
- `git log --oneline -5`
- `git rev-parse HEAD`

Directly inspected files and directories included:

- `mkdocs.yml`
- `AGENTS.md`
- `docs/start-here/scenario-router.md`
- `docs/start-here/learning-paths.md`
- `docs/troubleshooting/index.md`
- `docs/troubleshooting/decision-tree.md`
- `docs/troubleshooting/evidence-map.md`
- `docs/troubleshooting/first-10-minutes/connectivity.md`
- `docs/troubleshooting/first-10-minutes/boot.md`
- `docs/troubleshooting/playbooks/index.md`
- `docs/troubleshooting/playbooks/connectivity/cannot-rdp-or-ssh.md`
- `docs/troubleshooting/playbooks/connectivity/extension-failures.md`
- `docs/troubleshooting/playbooks/boot-disk/vm-wont-start.md`
- `docs/troubleshooting/playbooks/boot-disk/boot-diagnostics-and-serial-console.md`
- `docs/troubleshooting/playbooks/boot-disk/backup-failures.md`
- `docs/tutorials/lab-guides/index.md`
- `docs/tutorials/lab-guides/lab-02-disk-encryption-and-backup.md` (presence verified through catalog and adjacency)
- `docs/tutorials/lab-guides/lab-03-custom-script-extensions.md`
- `docs/tutorials/lab-guides/lab-04-azure-bastion-jit-access.md`
- `scripts/validate_content_sources.py`
- `scripts/validate_mslearn_urls.py`
- `azure-architecture-practical-guide/docs/contributing/series-lab-contract.md`

No assumptions were made about missing directories; absence was verified from direct root inventory and targeted path searches.

## 13. Decision Summary

- **Verdict:** Needs scaffold
- **First recommended issue:** `P4-ZLR-vm-01: Create the Variant A troubleshooting-lab scaffold`
- **Earliest point to revisit broader harmonization:** after first lab lands or after two repos complete P4

Bottom line:

- Variant A is the correct fit.
- The repo already has enough prose structure to support a good first lab.
- The gating gap is not concept quality; it is missing lab surface and missing first-scenario substrate.
- Start with **Extension Failures**, not with the broadest or most infrastructure-heavy scenario.
