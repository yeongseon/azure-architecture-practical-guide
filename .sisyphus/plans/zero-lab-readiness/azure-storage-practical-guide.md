# P4 Zero-Lab Readiness Audit — azure-storage-practical-guide

**Parent:** `P4 Zero-Lab Readiness — azure-storage-practical-guide`
**Wave:** P4 — Zero-Lab Lab Onboarding Readiness
**Date:** 2026-07-05
**Auditor:** Sisyphus
**Target lab family:** Variant A troubleshooting labs

## 1. Executive Summary

`azure-storage-practical-guide` is **Needs scaffold** for first-lab onboarding, not blocked. The repo already has a mature troubleshooting prose surface, a clean MkDocs structure, and validator coverage that is compatible with a Variant A lab. The missing pieces are the actual lab surface (`docs/troubleshooting/lab-guides/`), a companion reproduction substrate (`labs/<slug>/`), and a minimal evidence-pack convention.

The strongest first lab is **Private Endpoint and DNS Issues**. It already has the best cross-linked prose spine in the repo: a dedicated troubleshooting playbook, decision-tree route, evidence map commands, operations guidance, and a positive-path tutorial for private endpoints. That makes it the lowest-risk first Variant A lab to onboard.

## 2. Readiness Target

The readiness target is **the first Variant A troubleshooting lab**, following the Series Lab Contract v1 MUST elements plus the Variant A SHOULD elements where practical:

- Purpose/question
- Testable claim
- Procedure
- Evidence method
- Closing validation
- Cleanup
- Preferred Variant A additions: hypothesis/prediction, falsification-after-fix, paired playbook, `labs/<name>/` companion, richer evidence sections

Variant B is not recommended here. The contract explicitly lists storage as a zero-lab repo whose future lab family should default to **Variant A** if it authors a data-plane lab.

## 3. Repository Snapshot

Pre-work verification at `~/GitHub/azure-storage-practical-guide/`:

- `git status --short --branch` → `## main...origin/main`
- `git log --oneline -5` → HEAD `d2e838b` (`docs(scenario-router): add unified scenario-router.md aligning with series-wide start-here shape`)
- `git rev-parse HEAD` → `d2e838b6243096f4f2a0b6a0cda30e8416b6ed7a`
- `git diff --stat` → no output; working tree clean

Observed filesystem state relevant to first-lab onboarding:

- **Absent**: `docs/troubleshooting/lab-guides/`
- **Absent**: `docs/design-labs/`
- **Present**: `mkdocs.yml`
- **Present**: `scripts/validate_content_sources.py`
- **Present**: `scripts/validate_mslearn_urls.py`
- **Present**: `docs/troubleshooting/` with overview, decision tree, evidence map, first-10-minutes pages, and multiple playbooks
- **Present**: `docs/tutorials/lab-guides/` with five tutorial-style labs
- **Present**: `docs/assets/`
- **Present**: `scripts/`
- **Absent at repo root**: `infra/`, `apps/`, `samples/`, `labs/`

Important substrate observation:

- Tutorial lab 02 (private endpoint) is largely self-contained and reusable as a positive-path reference.
- Tutorial labs 01 and 04 reference external artifacts such as `./lab-data/...` and `lifecycle-policy.json`, but no `lab-data/` tree or `labs/` companion directory exists in the repo root today.

## 4. Methodology

This audit was read-only against `azure-storage-practical-guide` and used:

1. Series Lab Contract v1 for Variant A applicability, first-lab template intent, and validator/policy checks.
2. Repository-state verification (`git status`, `git log --oneline -5`, `git rev-parse HEAD`, `git diff --stat`).
3. Direct inspection of `mkdocs.yml`, troubleshooting hub pages, playbooks, tutorial lab guides, contributing guidance, and validator scripts.
4. The shared 8-dimension readiness rubric with only three statuses: Ready, Needs scaffold, Blocked.

## 5. Readiness Scorecard

| Dimension | Status | Short evidence note | Follow-up needed |
|---|---|---|---|
| 1. Variant A fit | Ready | Storage repo already centers runtime/data-plane failure modes; contract explicitly points storage toward Variant A | No |
| 2. Information architecture insertion fit | Needs scaffold | Troubleshooting hub exists, but there is no `docs/troubleshooting/lab-guides/` subtree or nav entry | Yes |
| 3. Supporting prose anchors | Ready | Strong anchors exist in decision tree, evidence map, operations pages, and targeted playbooks | No |
| 4. Candidate scenario backlog quality | Ready | Multiple candidate incidents already have focused playbooks and adjacent tutorial material | No |
| 5. Reproduction substrate readiness | Needs scaffold | No `labs/`, `infra/`, `apps/`, or `samples/` substrate; some tutorials reference non-existent external artifacts | Yes |
| 6. Evidence and diagnostics substrate | Needs scaffold | Evidence-map commands and KQL snippets exist, but no lab evidence pack convention or artifact directory exists | Yes |
| 7. Validator and policy compatibility | Ready | MkDocs and both core validators exist; current content already uses canonical `content_sources.diagrams` shape | No |
| 8. Decomposition readiness | Ready | A bounded 4-issue path is clear and can be opened without re-auditing | No |

## 6. Findings by Dimension

### 1) Variant A fit

Ready. The repo's troubleshooting content is already symptom-driven and operational: private endpoint DNS failure, authorization failure, throttling, replication lag, lifecycle policy behavior. Those are reproduction-lab shapes, not design-lab shapes.

### 2) Information architecture insertion fit

Needs scaffold. `mkdocs.yml` has a mature Troubleshooting section but no lab subtree under Troubleshooting. The repo already uses **Tutorials → Lab Guides**, so the first Variant A insertion must avoid ambiguity by making the new surface explicitly troubleshooting-scoped, e.g. `Troubleshooting → Lab Guides` with `docs/troubleshooting/lab-guides/index.md`.

### 3) Supporting prose anchors

Ready. The repo already provides the prose support a first lab needs:

- `docs/troubleshooting/decision-tree.md`
- `docs/troubleshooting/evidence-map.md`
- `docs/operations/use-private-endpoints.md`
- `docs/operations/monitoring-and-alerting.md`
- Focused playbooks such as `playbooks/access/private-endpoint-and-dns-issues.md` and `playbooks/security/authorization-failures.md`

This is sufficient to pair a lab with an existing production-facing playbook from day one.

### 4) Candidate scenario backlog quality

Ready. The backlog is not hypothetical; it is already encoded in playbooks and routing pages. The best candidates are the ones with:

- a precise failure mode,
- deterministic before/after evidence,
- low blast radius,
- and an existing operations/tutorial anchor.

Private endpoint DNS mismatch is strongest. Authorization failure is also strong. Replication lag and throttling are materially weaker as first-lab candidates because they are harder to force deterministically.

### 5) Reproduction substrate readiness

Needs scaffold. The repo has no root-level `labs/` directory, no Bicep/scripts/evidence convention, and no shared sample or infra folders. That is the main readiness gap. The first lab can still be onboarded with a minimal `labs/private-endpoint-dns-failure/` companion, but that structure does not exist yet.

### 6) Evidence and diagnostics substrate

Needs scaffold. The content side is promising:

- Evidence Map already specifies `nslookup`, `az storage account show`, and `az network private-endpoint-connection list`
- Performance and lifecycle playbooks already include KQL examples

But there is no verified evidence-pack location, no screenshot convention inside this repo for labs, and no per-lab artifact folder. The first lab needs a lightweight convention, not a large framework.

### 7) Validator and policy compatibility

Ready. `scripts/validate_content_sources.py` enforces diagram provenance on Mermaid pages, `scripts/validate_mslearn_urls.py` validates Learn URLs, and `mkdocs.yml` is already structured enough to absorb a new Troubleshooting child section. No validator harmonization work is required before the first lab.

### 8) Decomposition readiness

Ready. The path is straightforward:

1. add troubleshooting lab scaffold,
2. add first-lab substrate/evidence directory,
3. author first lab,
4. optionally queue a second low-risk lab.

## 7. Candidate First-Lab Backlog

| Candidate | Strength | Why it is a good or bad first lab | Recommendation |
|---|---|---|---|
| Private endpoint DNS failure / wrong resolution path | Strong | Best prose coverage in repo; existing operations page plus tutorial lab 02 gives positive-path deployment steps; evidence is crisp (`nslookup`, PE state, DNS links, account network settings); low-risk cleanup | **Recommended first lab** |
| Authorization failure / wrong RBAC scope or auth-method mismatch | Strong | Deterministic 403-style failure, direct tie to existing auth playbook, minimal resource footprint, clear falsification-after-fix path via role/scope correction | **Recommended second candidate** |
| Lifecycle policy not working | Stretch | Existing tutorial and playbook exist, but lifecycle timing and policy evaluation windows make first-lab falsification slower and less deterministic | Stretch only |

Notes:

- Replication lag issues are real backlog material, but not a good first-lab candidate because geo-replication staleness and failover behavior are harder to reproduce safely and cheaply.
- Throttling/performance issues are also weaker first-lab material because meaningful reproduction usually needs a repeatable load generator or workload harness.

## 8. Gap Catalog

| Gap | Severity | Blocks first lab? | Minimal fix | Cross-repo dependency? |
|---|---|---|---|---|
| No `docs/troubleshooting/lab-guides/` surface or nav insertion | Medium | Yes | Add troubleshooting lab-guides index plus MkDocs nav entry | No |
| No `labs/<slug>/` companion structure | High | Yes | Create one minimal companion directory for the first lab with README, scripts/Bicep placeholders, evidence folder | No |
| No evidence-pack convention for first lab artifacts | Medium | Yes | Define per-lab `evidence/` artifact location and referenced proof set | No |
| Tutorial substrate is partially docs-only (`lab-data` references without repo artifacts) | Medium | No | Reuse tutorial lab 02 for first-lab seed; do not depend on absent shared tutorial artifacts | No |
| No troubleshooting-lab-specific authoring/template guidance in repo | Low | No | Add a first-lab starter document as part of scaffold issue | No |

## 9. Decomposition Plan

Parent: `P4 Zero-Lab Readiness — azure-storage-practical-guide`

1. `P4-ZLR-storage-01: Add Variant A troubleshooting lab scaffold to the repo`
   - Create `docs/troubleshooting/lab-guides/index.md`
   - Insert Troubleshooting nav entry in `mkdocs.yml`
   - Add first-lab starter/template aligned to the Series Lab Contract v1

2. `P4-ZLR-storage-02: Create the private-endpoint DNS lab substrate and evidence pack`
   - Create `labs/private-endpoint-dns-failure/`
   - Add minimal reproducible deployment/run/cleanup assets
   - Define the evidence artifacts the lab will capture and reference

3. `P4-ZLR-storage-03: Publish the first Variant A troubleshooting lab for private-endpoint DNS failure`
   - Author the lab guide under `docs/troubleshooting/lab-guides/`
   - Pair it bidirectionally with the existing playbook
   - Include closing validation and cleanup

4. `P4-ZLR-storage-04: Queue the next low-risk troubleshooting lab after the first lab lands`
   - Preferred follow-on: authorization failure / RBAC-scope mismatch
   - Keep lifecycle-policy timing scenarios out of the second slot unless a deterministic harness is added first

## 10. Follow-up Issue Set

| Issue ID | Title | Depends on | Outcome | Effort |
|---|---|---|---|---|
| P4-ZLR-storage-01 | Add Variant A troubleshooting lab scaffold to azure-storage-practical-guide | — | Repo gains a Troubleshooting lab surface, nav insertion, and first-lab starter | S |
| P4-ZLR-storage-02 | Create private-endpoint DNS failure lab substrate and evidence pack | P4-ZLR-storage-01 | Repo gains a minimal `labs/private-endpoint-dns-failure/` companion with reproducible assets and artifact locations | M |
| P4-ZLR-storage-03 | Publish the first Variant A troubleshooting lab for private-endpoint DNS failure | P4-ZLR-storage-02 | First real troubleshooting lab lands with paired playbook, evidence method, falsification-after-fix, and cleanup | M |
| P4-ZLR-storage-04 | Prepare the second troubleshooting lab for authorization-failure reproduction | P4-ZLR-storage-03 | Next low-risk lab is scoped without reopening readiness analysis | S |

### P4-ZLR-storage-01

**QA Scenario**
- **Tool**: `grep -F "- Lab Guides:" /Users/yeongseonchoe/GitHub/azure-storage-practical-guide/mkdocs.yml`, `test -f /Users/yeongseonchoe/GitHub/azure-storage-practical-guide/docs/troubleshooting/lab-guides/index.md`, `python3 /Users/yeongseonchoe/GitHub/azure-storage-practical-guide/scripts/validate_content_sources.py`, `mkdocs build --strict`
- **Steps**:
    1. Run `grep -F "- Lab Guides:" /Users/yeongseonchoe/GitHub/azure-storage-practical-guide/mkdocs.yml` and confirm the Troubleshooting nav now includes a lab-guides entry.
    2. Run `test -f /Users/yeongseonchoe/GitHub/azure-storage-practical-guide/docs/troubleshooting/lab-guides/index.md` to verify the scaffold index page exists.
    3. Run `python3 /Users/yeongseonchoe/GitHub/azure-storage-practical-guide/scripts/validate_content_sources.py` from the repo root, then run `mkdocs build --strict` from `/Users/yeongseonchoe/GitHub/azure-storage-practical-guide`.
- **Expected Results**:
    - The grep command returns a matching nav line and the index file existence check succeeds.
    - `validate_content_sources.py` exits 0 and `mkdocs build --strict` exits 0 with no broken-nav or provenance errors.

### P4-ZLR-storage-02

**QA Scenario**
- **Tool**: `test -d /Users/yeongseonchoe/GitHub/azure-storage-practical-guide/labs/private-endpoint-dns-failure`, `test -d /Users/yeongseonchoe/GitHub/azure-storage-practical-guide/labs/private-endpoint-dns-failure/evidence`, `bicep build /Users/yeongseonchoe/GitHub/azure-storage-practical-guide/labs/private-endpoint-dns-failure/main.bicep`, `az deployment group create --resource-group $RG --template-file /Users/yeongseonchoe/GitHub/azure-storage-practical-guide/labs/private-endpoint-dns-failure/main.bicep --parameters @/Users/yeongseonchoe/GitHub/azure-storage-practical-guide/labs/private-endpoint-dns-failure/parameters.dev.json`, `nslookup <storage-account>.blob.core.windows.net`, `az group delete --name $RG --yes --no-wait`
- **Steps**:
    1. Run `test -d` against `/labs/private-endpoint-dns-failure` and its `/evidence` subdirectory, then run `bicep build` on `main.bicep` to verify the substrate compiles.
    2. Deploy the substrate with `az deployment group create ...`, execute the documented failure-injection step, and run `nslookup <storage-account>.blob.core.windows.net` from the lab client path to capture the reproduced symptom.
    3. Confirm the evidence directory contains the documented artifacts, then run `az group delete --name $RG --yes --no-wait` and verify the temporary resource group is scheduled for removal.
- **Expected Results**:
    - The lab substrate directories exist, `bicep build` exits 0, and the deployment succeeds.
    - The injected scenario reproduces the documented failure signal (wrong/public DNS resolution for the private-path test) and the evidence directory contains the expected artifacts before cleanup starts.

### P4-ZLR-storage-03

**QA Scenario**
- **Tool**: `test -f /Users/yeongseonchoe/GitHub/azure-storage-practical-guide/docs/troubleshooting/lab-guides/private-endpoint-dns-failure.md`, `grep -F "Private Endpoint and DNS Issues" /Users/yeongseonchoe/GitHub/azure-storage-practical-guide/docs/troubleshooting/lab-guides/private-endpoint-dns-failure.md`, `grep -F "private-endpoint-dns-failure.md" /Users/yeongseonchoe/GitHub/azure-storage-practical-guide/mkdocs.yml`, `python3 /Users/yeongseonchoe/GitHub/azure-storage-practical-guide/scripts/validate_content_sources.py`, `python3 /Users/yeongseonchoe/GitHub/azure-storage-practical-guide/scripts/validate_mslearn_urls.py`, `mkdocs build --strict`
- **Steps**:
    1. Run `test -f` on the lab page path, then confirm the page is wired into nav with `grep -F "private-endpoint-dns-failure.md" .../mkdocs.yml`.
    2. Open the lab page and verify it contains the required lab-guide sections plus a cross-link to `docs/troubleshooting/playbooks/access/private-endpoint-and-dns-issues.md`; confirm with `grep -F "Private Endpoint and DNS Issues" .../private-endpoint-dns-failure.md`.
    3. Run `python3 scripts/validate_content_sources.py`, `python3 scripts/validate_mslearn_urls.py`, and `mkdocs build --strict` from `/Users/yeongseonchoe/GitHub/azure-storage-practical-guide`.
- **Expected Results**:
    - The lab page exists, is present in `mkdocs.yml`, and contains the expected paired-playbook cross-link.
    - Both validators exit 0 and `mkdocs build --strict` exits 0 with no broken links or frontmatter provenance failures.

### P4-ZLR-storage-04

**QA Scenario**
- **Tool**: `test -f /Users/yeongseonchoe/GitHub/azure-storage-practical-guide/docs/troubleshooting/lab-guides/authorization-failure-scope.md`, `grep -F "Out of scope" /Users/yeongseonchoe/GitHub/azure-storage-practical-guide/docs/troubleshooting/lab-guides/authorization-failure-scope.md`, `grep -F "broader-repo changes" /Users/yeongseonchoe/GitHub/azure-storage-practical-guide/docs/troubleshooting/lab-guides/authorization-failure-scope.md`, `mkdocs build --strict`
- **Steps**:
    1. Create the scoping deliverable at `/Users/yeongseonchoe/GitHub/azure-storage-practical-guide/docs/troubleshooting/lab-guides/authorization-failure-scope.md` and run `test -f` to verify it exists.
    2. Run `grep -F "Out of scope" .../authorization-failure-scope.md` and `grep -F "broader-repo changes" .../authorization-failure-scope.md` to confirm the scope statement explicitly excludes broader repo work.
    3. Run `mkdocs build --strict` from `/Users/yeongseonchoe/GitHub/azure-storage-practical-guide` to ensure the scoping page is link-clean if it is wired into docs.
- **Expected Results**:
    - The scoping deliverable exists and explicitly states that broader-repo changes are out of scope for the second-lab planning issue.
    - `mkdocs build --strict` exits 0, confirming the planning artifact does not introduce doc-integrity regressions.

## 11. Non-goals

1. Not a content completeness audit
2. Not a shared-validator design proposal
3. Not a broken-link or MSLearn freshness sweep
4. Not a cross-repo deduplication exercise
5. Not first-lab implementation itself
6. Not a long-term backlog for all possible labs

## 12. Data Reproducibility

This audit is reproducible from repository state alone.

- Repo inspected: `~/GitHub/azure-storage-practical-guide/`
- Contract source inspected: `~/GitHub/azure-architecture-practical-guide/docs/contributing/series-lab-contract.md`
- Key files inspected: `mkdocs.yml`, `scripts/validate_content_sources.py`, `scripts/validate_mslearn_urls.py`, troubleshooting hub pages, candidate playbooks, and tutorial labs 01/02/04
- Working tree state at audit time: clean on `main`, HEAD `d2e838b6243096f4f2a0b6a0cda30e8416b6ed7a`

Another agent should not need to re-audit the repo to open the four issues above; only implementation choices remain.

## 13. Decision Summary

- **Verdict:** Needs scaffold
- **First recommended issue:** `P4-ZLR-storage-01: Add Variant A troubleshooting lab scaffold to azure-storage-practical-guide`
- **Earliest point to revisit broader harmonization:** after first lab lands or after two repos complete P4

Additional summary:

- **Strongest first-lab candidate:** Private endpoint DNS failure / wrong resolution path
- **Top blocker:** Missing troubleshooting-lab surface plus companion `labs/` substrate
- **Why not blocked:** Troubleshooting prose, validators, and scenario anchors are already strong enough to support immediate scaffold-first execution
