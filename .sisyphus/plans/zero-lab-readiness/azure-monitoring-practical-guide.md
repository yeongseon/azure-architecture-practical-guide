# Azure Monitoring Practical Guide — Zero-Lab Readiness Audit

## 1. Executive Summary

`azure-monitoring-practical-guide` is **Needs scaffold** for its first Variant A troubleshooting lab.

The repo is strong on prose anchors: it already has a mature top-level troubleshooting surface, nine playbooks, service-specific KQL packs, and five service-guide families. It is weak on lab onboarding substrate: there is no `docs/troubleshooting/lab-guides/`, no `docs/design-labs/`, no `labs/`, no `infra/`, no `apps/`, no `samples/`, and no troubleshooting evidence asset tree under `docs/assets/`.

The best first lab is a **VM / Azure Monitor Agent signal-loss lab** paired to `docs/troubleshooting/playbooks/agent-not-reporting.md`, implemented as a top-level troubleshooting lab rather than a service-guide page. That choice fits the series contract's Monitoring note (“signal-quality lab” → Variant A), uses an already strong troubleshooting narrative, and avoids requiring an application sample repository before the first lab can land.

## 2. Readiness Target

- **Primary target:** first **Variant A troubleshooting lab**.
- **Recommended home:** new top-level path `docs/troubleshooting/lab-guides/`.
- **Why not `docs/service-guides/*`:** the service guides are setup/observability reference surfaces, while the repo's troubleshooting IA already owns symptom routing, playbooks, KQL evidence, and the natural reader flow for a reproducible failure lab.
- **Cross-link strategy:** keep the lab under Troubleshooting, then link to it from the paired playbook and the relevant service guide (`service-guides/vm/` for the recommended first lab).

## 3. Repository Snapshot

Pre-work verification against `~/GitHub/azure-monitoring-practical-guide/`:

- `git status --short --branch` → `## main...origin/main` (clean working tree).
- `git log --oneline -5` HEAD = `296bb3c` (`docs(reference): add cross-service diagnostic-settings matrix`).
- `git rev-parse HEAD` → `296bb3cf0150abb400d289ff3dd97e517e00c052`.
- `git diff --stat` not needed because the worktree is clean.

Verified repository state relevant to zero-lab readiness:

- `docs/troubleshooting/lab-guides/` → **absent**.
- `docs/design-labs/` → **absent**.
- `mkdocs.yml` → **present**.
- `scripts/validate_content_sources.py` → **present**.
- `scripts/validate_mslearn_urls.py` → **present**.
- `infra/` → **absent**.
- `apps/` → **absent**.
- `samples/` → **absent**.
- `scripts/` → **present** (`validate_content_sources.py`, `validate_mslearn_urls.py`, Mermaid validators).
- `docs/assets/` → **present**, but only brand/site assets were found; no troubleshooting screenshot subtree exists yet.
- `docs/service-guides/` → **present** with sub-guides for `app-service`, `container-apps`, `functions`, `aks`, and `vm`.
- `docs/tutorials/lab-guides/` → **present**, but this is a tutorial training track, not a troubleshooting-lab surface.
- `scripts/generate_validation_status.py` → **absent**, while `AGENTS.md` still references it.
- `docs/reference/validation-status.md` → **absent**.

## 4. Methodology

This audit applied the shared 8-dimension zero-lab readiness rubric against:

1. The series lab contract at `azure-architecture-practical-guide/docs/contributing/series-lab-contract.md`.
2. The target repo's IA and contributor contract (`mkdocs.yml`, `AGENTS.md`).
3. Existing troubleshooting anchors (overview, decision tree, evidence map, playbooks, KQL packs).
4. Service-guide placement fit for a monitoring-specific first lab.
5. Existing reproducibility substrate such as tutorials, scripts, assets, and any deployable scaffolding.

This is a first-lab onboarding audit only, not a general maturity review.

## 5. Readiness Scorecard

| Dimension | Status | Short evidence note | Follow-up needed |
|---|---|---|---|
| 1. Variant A fit | Ready | Series contract explicitly calls Monitoring a zero-lab repo that should use Variant A for a signal-quality lab. | Choose one bounded failure mode. |
| 2. Information architecture insertion fit | Needs scaffold | Troubleshooting is mature, but `docs/troubleshooting/lab-guides/` is missing from content and nav. | Add lab-guides hub + nav insertion under Troubleshooting. |
| 3. Supporting prose anchors | Ready | Strong anchors already exist: troubleshooting hub, evidence map, decision tree, playbooks, service-specific KQL, service guides. | Pair lab to one playbook and one service guide. |
| 4. Candidate scenario backlog quality | Ready | At least three credible scenarios already have strong prose: agent not reporting, missing application telemetry, AKS Container Insights issues. | Rank and bound the first scenario. |
| 5. Reproduction substrate readiness | Needs scaffold | No `labs/`, `infra/`, `apps/`, or `samples/`; tutorial labs exist but are not failure-reproduction substrate. | Create minimal first-lab companion directory and deployment scripts. |
| 6. Evidence and diagnostics substrate | Needs scaffold | Playbooks and KQL packs are strong, but there is no lab evidence folder or troubleshooting screenshot asset tree. | Add `evidence/`, verification queries, and portal asset conventions. |
| 7. Validator and policy compatibility | Ready | Content-source and MSLearn validators exist; AGENTS scopes `docs/troubleshooting/lab-guides/**` out of `content_validation`. | Reuse existing validators; do not depend on missing tutorial-validation script. |
| 8. Decomposition readiness | Ready | The work decomposes cleanly into scaffold, substrate, first lab, optional follow-on. | Open 3-4 bounded issues. |

## 6. Findings by Dimension

### 1) Variant A fit

This repo clearly fits Variant A. The series contract's per-repo applicability table says Monitoring remains zero-lab today but should use Variant A if it authors a “signal-quality lab.” The repo already frames troubleshooting as symptom → hypothesis → evidence → resolution, which aligns with the Variant A reproduction model.

### 2) Information architecture insertion fit

The natural insertion point is **top-level Troubleshooting**, not a service-guide subtree and not a new top-level section.

Evidence:

- `mkdocs.yml` already has a dedicated Troubleshooting section with overview, first-10-minutes, playbooks, and KQL queries.
- The repo AGENTS guidance explicitly shows preferred troubleshooting structure ending in `Labs`.
- `docs/service-guides/` is organized around setup/observability baselines, not symptom-based reproduction.

Recommendation: add `docs/troubleshooting/lab-guides/index.md` plus one first lab page underneath it, then cross-link from the paired playbook and relevant service guide.

### 3) Supporting prose anchors

This is a strength.

Verified strong anchors include:

- `docs/troubleshooting/index.md`
- `docs/troubleshooting/evidence-map.md`
- `docs/troubleshooting/playbooks/agent-not-reporting.md`
- `docs/troubleshooting/playbooks/missing-application-telemetry.md`
- `docs/troubleshooting/playbooks/aks-container-insights-issues.md`
- `docs/troubleshooting/kql/service-specific/vm-diagnostics.md`
- `docs/troubleshooting/kql/service-specific/aks-diagnostics.md`
- `docs/service-guides/vm/observability.md`
- `docs/service-guides/aks/observability.md`
- `docs/service-guides/functions/observability.md`
- `docs/service-guides/container-apps/observability.md`

These give the first lab enough surrounding prose to avoid becoming an orphaned artifact.

### 4) Candidate scenario backlog quality

Backlog quality is already good because multiple existing playbooks are specific, evidence-driven, and pair naturally with service-specific guides.

Best candidates are scenarios where:

- the symptom is easy to observe with one or two tables,
- the break can be introduced intentionally,
- the fix is unambiguous,
- the evidence path is already documented.

The repo already has that shape for AMA heartbeat loss, App Insights telemetry gaps, and AKS Container Insights visibility problems.

### 5) Reproduction substrate readiness

This is the largest gap.

What exists:

- tutorial lab guides under `docs/tutorials/lab-guides/`
- reusable CLI-first style across service guides and playbooks

What does not exist:

- `labs/<name>/`
- `infra/`
- deployable sample apps
- reusable troubleshooting evidence directories

Implication: the first lab must either be a docs-only Variant A reproduction lab or introduce the minimal companion directory itself. For Monitoring, the stronger move is to introduce the minimal companion directory with deployment, break, fix, and verify scripts.

### 6) Evidence and diagnostics substrate

Evidence content is strong in prose but not yet scaffolded for labs.

Strengths:

- evidence-map page already maps symptoms to data sources
- playbooks include KQL and CLI evidence collection
- service-specific KQL packs already exist for VM and AKS scenarios

Gaps:

- no `labs/<name>/evidence/`
- no troubleshooting portal screenshot subtree under `docs/assets/`
- no existing lab query-pack convention under `docs/troubleshooting/lab-guides/`

This is a scaffold problem, not a content-gap problem.

### 7) Validator and policy compatibility

Compatibility is mostly good.

- `scripts/validate_content_sources.py` exists and already enforces Mermaid/content-source discipline.
- `scripts/validate_mslearn_urls.py` exists.
- `AGENTS.md` already treats `docs/troubleshooting/lab-guides/**` as out of scope for `content_validation`, which matches the series contract's lab handling.

One notable repo-specific drift exists:

- `AGENTS.md` tells contributors to run `python3 scripts/generate_validation_status.py`, but that script is absent.
- `docs/reference/validation-status.md` is also absent.

This drift matters for tutorials, not for the first troubleshooting lab. It should be noted, but it is **not** the primary outcome of this audit.

### 8) Decomposition readiness

The work breaks cleanly into:

1. add the troubleshooting lab surface,
2. add minimal first-lab substrate/evidence conventions,
3. author the first lab,
4. optionally capitalize on the scaffold with a second scenario.

That is a good fit for a 3-4 issue sequence.

## 7. Candidate First-Lab Backlog

### Recommended location for all candidates

Use `docs/troubleshooting/lab-guides/` as the publication surface. Do **not** place the first lab under `docs/service-guides/`; instead, cross-link from the service guide most relevant to the scenario.

### Strong candidate 1 — VM AMA heartbeat loss after DCR association break

- **Status:** strongest first-lab candidate
- **Paired playbook:** `docs/troubleshooting/playbooks/agent-not-reporting.md`
- **Prose anchor:** `docs/service-guides/vm/observability.md`
- **KQL anchor:** `docs/troubleshooting/kql/service-specific/vm-diagnostics.md`
- **Why it is strong:** bounded symptom, no app code required, clear before/after evidence (`Heartbeat`, possibly `Perf`/`InsightsMetrics`), and a crisp falsification step after DCR reassociation or agent repair.
- **Likely failure injection:** remove or mispoint DCR association for a test VM after onboarding AMA.

### Strong candidate 2 — Missing Application Insights telemetry after connection-string drift

- **Status:** strong follow-on or alternative first lab
- **Paired playbook:** `docs/troubleshooting/playbooks/missing-application-telemetry.md`
- **Prose anchors:** `docs/service-guides/app-service/application-insights-integration.md` and tutorial `docs/tutorials/lab-guides/lab-04-application-insights-setup.md`
- **Why it is strong:** excellent evidence model and high reader value, especially for App Service / Functions operators.
- **Constraint:** the current tutorial lab uses a placeholder telemetry workflow and the repo has no `apps/` sample, so this scenario needs a small app or more explicit traffic-generation substrate before it becomes the easiest first lab.

### Stretch candidate — AKS Container Insights partial or stale data

- **Status:** stretch candidate
- **Paired playbook:** `docs/troubleshooting/playbooks/aks-container-insights-issues.md`
- **Prose anchor:** `docs/service-guides/aks/observability.md`
- **KQL anchor:** `docs/troubleshooting/kql/service-specific/aks-diagnostics.md`
- **Why stretch:** very strong documentation anchors, but AKS cost, enablement complexity, and multi-component failure modes make it a worse first-lab substrate than the VM path.

## 8. Gap Catalog

| Gap | Severity | Blocks first lab? | Minimal fix | Cross-repo dependency? |
|---|---|---|---|---|
| No `docs/troubleshooting/lab-guides/` surface | High | Yes | Add lab-guides hub, first-lab page path, and mkdocs nav insertion under Troubleshooting. | No |
| No first-lab companion substrate (`labs/`, deploy/break/fix/verify scripts, evidence dir) | High | Yes | Introduce one minimal `labs/<first-lab>/` directory for the chosen scenario. | No |
| No troubleshooting evidence asset subtree under `docs/assets/` | Medium | Yes for richer Variant A evidence | Add scenario-specific portal evidence folder and document expected captures. | No |
| Tutorial-validation instructions reference missing script/dashboard | Low | No | Record as follow-on hygiene outside the first-lab critical path. | No |

## 9. Decomposition Plan

**Parent:** `P4 Zero-Lab Readiness — azure-monitoring-practical-guide`

1. `P4-ZLR-monitoring-01: Add Troubleshooting lab-guides scaffold and nav surface`
2. `P4-ZLR-monitoring-02: Create VM AMA signal-loss lab substrate and evidence harness`
3. `P4-ZLR-monitoring-03: Author the first Variant A troubleshooting lab for AMA heartbeat loss`
4. `P4-ZLR-monitoring-04: Add missing-application-telemetry follow-on lab after the first lab scaffold proves out` *(optional)*

## 10. Follow-up Issue Set

| Issue ID | Title | Depends on | Outcome | Effort |
|---|---|---|---|---|
| P4-ZLR-monitoring-01 | Add Troubleshooting lab-guides scaffold and nav surface | None | Creates `docs/troubleshooting/lab-guides/`, index page, mkdocs placement, and first-lab starter shape aligned to the series contract. | S |
| P4-ZLR-monitoring-02 | Create VM AMA signal-loss lab substrate and evidence harness | P4-ZLR-monitoring-01 | Adds minimal `labs/<name>/` companion with deploy, break, fix, verify, cleanup, and evidence directory conventions for the VM scenario. | M |
| P4-ZLR-monitoring-03 | Author the first Variant A troubleshooting lab for AMA heartbeat loss | P4-ZLR-monitoring-02 | Publishes the first Monitoring troubleshooting lab, paired to the Agent Not Reporting playbook and VM observability guide with falsification-after-fix. | M |
| P4-ZLR-monitoring-04 | Add missing-application-telemetry follow-on lab after the first lab scaffold proves out | P4-ZLR-monitoring-03 | Reuses the new scaffold for an App Service / Application Insights telemetry-gap lab once sample/substrate details are explicit enough. | M |

### P4-ZLR-monitoring-01

**QA Scenario**
- **Tool**: `mkdocs build --strict`, `python3 scripts/validate_content_sources.py`, `grep -F "troubleshooting/lab-guides/index.md" mkdocs.yml`, `test -f docs/troubleshooting/lab-guides/index.md`
- **Steps**:
    1. Add `docs/troubleshooting/lab-guides/index.md` in `~/GitHub/azure-monitoring-practical-guide/` and insert the new Troubleshooting nav entry in `mkdocs.yml`.
    2. Run `grep -F "troubleshooting/lab-guides/index.md" mkdocs.yml` and `test -f docs/troubleshooting/lab-guides/index.md` from the repo root to confirm the nav entry and file exist.
    3. Run `python3 scripts/validate_content_sources.py` and `mkdocs build --strict` from `~/GitHub/azure-monitoring-practical-guide/`.
- **Expected Results**:
    - `grep` returns the new nav line and `test -f` exits 0 for `docs/troubleshooting/lab-guides/index.md`.
    - `python3 scripts/validate_content_sources.py` and `mkdocs build --strict` both exit 0.

### P4-ZLR-monitoring-02

**QA Scenario**
- **Tool**: `test -d labs/ama-heartbeat-loss/`, `az bicep build --file labs/ama-heartbeat-loss/main.bicep`, `az deployment group create --resource-group "$RG" --template-file labs/ama-heartbeat-loss/main.bicep --parameters labs/ama-heartbeat-loss/main.parameters.json`, `az monitor data-collection rule association delete --name ama-heartbeat-loss --resource "$VM_RESOURCE_ID"`, `az monitor log-analytics query --workspace "$WORKSPACE_ID" --analytics-query "Heartbeat | where Computer == '$VM_NAME' | summarize LastHeartbeat=max(TimeGenerated), MinutesSinceLastHeartbeat=datetime_diff('minute', now(), max(TimeGenerated)) * -1" --timespan P1D`, `test -d labs/ama-heartbeat-loss/evidence/`, `test -f labs/ama-heartbeat-loss/evidence/heartbeat-before-fix.json`, `test -f labs/ama-heartbeat-loss/evidence/heartbeat-after-fix.json`, `az group delete --name "$RG" --yes --no-wait`
- **Steps**:
    1. Create the companion substrate at `labs/ama-heartbeat-loss/` with `main.bicep`, parameter file, deploy/break/fix/verify/cleanup scripts, and `evidence/`; verify it exists with `test -d labs/ama-heartbeat-loss/` and compile the template with `az bicep build --file labs/ama-heartbeat-loss/main.bicep`.
    2. Deploy the lab with `az deployment group create ...`, break the AMA path by deleting the DCR association with `az monitor data-collection rule association delete ...`, wait past the documented heartbeat freshness window, and run the `Heartbeat` KQL query to capture a stale result into `labs/ama-heartbeat-loss/evidence/heartbeat-before-fix.json`.
    3. Run the fix script to restore the DCR association, rerun the same `Heartbeat` query to capture fresh data into `labs/ama-heartbeat-loss/evidence/heartbeat-after-fix.json`, confirm `test -d labs/ama-heartbeat-loss/evidence/` plus both `test -f` checks succeed, then execute `az group delete --name "$RG" --yes --no-wait`.
- **Expected Results**:
    - `az bicep build` and the deployment succeed, and the broken-state `Heartbeat` query shows `MinutesSinceLastHeartbeat > 5` for the target VM before the fix.
    - After the fix, the same `Heartbeat` query shows fresh data (`MinutesSinceLastHeartbeat <= 5`), evidence files exist, and cleanup is initiated without orphaning the lab scaffold.

### P4-ZLR-monitoring-03

**QA Scenario**
- **Tool**: `test -f docs/troubleshooting/lab-guides/ama-heartbeat-loss.md`, `grep -F "troubleshooting/lab-guides/ama-heartbeat-loss.md" mkdocs.yml`, `grep -F "## Related Playbook" docs/troubleshooting/lab-guides/ama-heartbeat-loss.md`, `grep -F "docs/troubleshooting/playbooks/agent-not-reporting.md" docs/troubleshooting/lab-guides/ama-heartbeat-loss.md`, `python3 scripts/validate_content_sources.py`, `mkdocs build --strict`, `az monitor log-analytics query --workspace "$WORKSPACE_ID" --analytics-query "Heartbeat | where Computer == '$VM_NAME' | summarize LastHeartbeat=max(TimeGenerated), MinutesSinceLastHeartbeat=datetime_diff('minute', now(), max(TimeGenerated)) * -1" --timespan P1D`
- **Steps**:
    1. Author `docs/troubleshooting/lab-guides/ama-heartbeat-loss.md` using the Variant A template, include the required lab sections, add the page to `mkdocs.yml`, and verify presence with `test -f ...`, `grep -F "troubleshooting/lab-guides/ama-heartbeat-loss.md" mkdocs.yml`, and `grep -F "## Related Playbook" ...`.
    2. Confirm the lab cross-links to the paired playbook by running `grep -F "docs/troubleshooting/playbooks/agent-not-reporting.md" docs/troubleshooting/lab-guides/ama-heartbeat-loss.md`, then run `python3 scripts/validate_content_sources.py` and `mkdocs build --strict` from the repo root.
    3. Execute the acceptance signal in the lab environment with `az monitor log-analytics query --workspace "$WORKSPACE_ID" --analytics-query "Heartbeat | where Computer == '$VM_NAME' | summarize LastHeartbeat=max(TimeGenerated), MinutesSinceLastHeartbeat=datetime_diff('minute', now(), max(TimeGenerated)) * -1" --timespan P1D` once after failure injection and once after the documented fix.
- **Expected Results**:
    - The lab page exists, is listed in `mkdocs.yml`, includes the related-playbook section, and both `python3 scripts/validate_content_sources.py` and `mkdocs build --strict` exit 0.
    - The acceptance `Heartbeat` KQL shows a failure state before the fix (`MinutesSinceLastHeartbeat > 5`) and recovery after the fix (`MinutesSinceLastHeartbeat <= 5`) for the same VM.

### P4-ZLR-monitoring-04

**QA Scenario**
- **Tool**: `test -f docs/troubleshooting/lab-guides/app-insights-telemetry-gap.md`, `grep -F "missing-application-telemetry" docs/troubleshooting/lab-guides/app-insights-telemetry-gap.md`, `grep -F "Out of scope" docs/troubleshooting/lab-guides/app-insights-telemetry-gap.md`, `python3 scripts/validate_content_sources.py`, `mkdocs build --strict`, `az monitor log-analytics query --workspace "$WORKSPACE_ID" --analytics-query "AppRequests | where AppRoleName == '$APP_ROLE_NAME' and TimeGenerated > ago(30m) | summarize LastSeen=max(TimeGenerated), RequestCount=sum(ItemCount)" --timespan PT30M`, `az webapp config appsettings set --resource-group "$RG" --name "$APP_NAME" --settings APPLICATIONINSIGHTS_CONNECTION_STRING="invalid"`
- **Steps**:
    1. Create the scoped follow-on deliverable at `docs/troubleshooting/lab-guides/app-insights-telemetry-gap.md`, explicitly include an `Out of scope` statement that excludes broader repo changes, and verify with `test -f ...`, `grep -F "missing-application-telemetry" ...`, and `grep -F "Out of scope" ...`.
    2. Run `python3 scripts/validate_content_sources.py` and `mkdocs build --strict` to confirm the scoped follow-on content integrates cleanly without broader IA regressions.
    3. In the follow-on scenario environment, set an invalid App Insights connection string with `az webapp config appsettings set ...`, run the `AppRequests` KQL query to confirm telemetry stops or becomes stale, restore the correct connection string, and rerun the same query to confirm fresh ingestion resumes.
- **Expected Results**:
    - The follow-on lab file exists, explicitly scopes out broader repo changes, and passes `python3 scripts/validate_content_sources.py` plus `mkdocs build --strict`.
    - The acceptance query shows stale or missing `AppRequests` during the broken connection-string state and fresh `LastSeen` / nonzero `RequestCount` after restoration.

## 11. Non-goals

1. Not a content completeness audit
2. Not a shared-validator design proposal
3. Not a broken-link or MSLearn freshness sweep
4. Not a cross-repo deduplication exercise
5. Not first-lab implementation itself
6. Not a long-term backlog for all possible labs

## 12. Data Reproducibility

Audit date: 2026-07-05.

Local inputs inspected directly:

- Git state commands: `git status --short --branch`, `git log --oneline -5`, `git rev-parse HEAD`
- Repository inventory: root directory, `mkdocs.yml`, `scripts/`, `docs/troubleshooting/`, `docs/service-guides/`, `docs/tutorials/lab-guides/`, `docs/assets/`
- Contract/governance source: `docs/contributing/series-lab-contract.md` in the architecture repo

All findings in this audit are based on local repository inspection only; no web lookup or cross-repo state inference was used beyond the cited series contract.

## 13. Decision Summary

- **Verdict:** Needs scaffold
- **First recommended issue:** `P4-ZLR-monitoring-01: Add Troubleshooting lab-guides scaffold and nav surface`
- **Earliest point to revisit broader harmonization:** after first lab lands or after two repos complete P4

Additional summary:

- **Recommended first lab:** VM AMA heartbeat loss after DCR association break, published under `docs/troubleshooting/lab-guides/`.
- **Why this location wins:** it matches the repo's troubleshooting IA, the AGENTS troubleshooting shape, and the service contract without overloading `docs/service-guides/` with reproduction content.
- **Why overall verdict is not Blocked:** the repo already has enough troubleshooting prose and evidence logic to support a first lab; it only lacks the lab scaffold and minimal reproduction substrate.
