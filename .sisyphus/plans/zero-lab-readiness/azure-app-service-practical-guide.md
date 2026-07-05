# P4-ZLR Exclusion: azure-app-service-practical-guide

**Wave**: P4 — Zero-Lab Lab Onboarding Readiness
**Date**: 2026-07-05
**Verdict**: EXCLUDED from P4-ZLR wave (not zero-lab)
**Auditor**: Sisyphus (coordinator)

## Why This Repo Is Not In Scope

The P4-ZLR wave audits repositories that currently host **no lab surface** (no
`docs/troubleshooting/lab-guides/` and no `docs/design-labs/`) to determine
readiness for their first Variant A troubleshooting lab.

`azure-app-service-practical-guide` is **not** a zero-lab repo. It carries an
active lab program and multiple in-flight standardization workstreams that
make a from-zero readiness audit both duplicative and inappropriate.

## Observed State (2026-07-05)

Direct inventory at HEAD `2aa12ca`:

- **13 lab subdirectories** under `labs/`
- **4 language application subdirectories** under `apps/`
- **Extended docs sections** not present in zero-lab siblings:
  `docs/language-guides/`, `docs/meta/`, `docs/visualization/`
- **Extended validator surface**: `normalize_content_sources_schema.py`,
  `normalize_mslearn_locale.py`, `normalize_yaml_frontmatter.py`,
  `remove_out_of_scope_validation.py`, `remove_tautological_validation.py`,
  `scan_lab_pii.py`, `validate_cli_explanations.py`, `validate_doc_quality.py`
- **Additional workflow**: `.github/workflows/app-infra-ci.yml`
- **Larger contract surface**: `AGENTS.md` at 1035 lines (vs ~550 in zero-lab siblings)
- **4 uncommitted in-flight standardization plans** in `.sisyphus/plans/`:
    - `item-2-p1-p3-filename-plan.md` (588 lines) — filename normalization
    - `p2-b-design.md` (1122 lines, Round 5 REVISED) — active Oracle review
    - `p2-c-design.md` (1678 lines, Round 2r-v2 APPROVED) — ready for execution
    - `p3-design.md` (1230 lines, REVISED post-Oracle Round 1) — active
    - `p4-design.md` (595 lines, DRAFT v2) — active

## Correct Follow-Up Path

Any lab-onboarding, standardization, or scaffolding work for
`azure-app-service-practical-guide` MUST be routed through that repo's own
in-flight plans listed above, not through a P4-ZLR audit that assumes a
zero-lab baseline.

If a coordinator needs to compare app-service against the four true zero-lab
repos in the P4-ZLR wave (VM, networking, storage, monitoring), the correct
comparison surface is the app-service repo's own P2-B / P2-C / P3 / P4 plan
outputs once they land, not this file.

## Related Meta-Tracker

- Meta issue: `azure-architecture-practical-guide#34`
- Phase framework: Phase 2f Series Lab Contract v1
- Sibling audits in this wave (all TRUE zero-lab):
    - `azure-virtual-machine-practical-guide.md`
    - `azure-networking-practical-guide.md`
    - `azure-storage-practical-guide.md`
    - `azure-monitoring-practical-guide.md`

## Decision Summary

- **Verdict**: EXCLUDED — not a zero-lab repository
- **Reason**: 13 existing labs + 4 in-flight standardization plans
- **Action**: No P4-ZLR audit will be produced for this repo
- **Redirect**: Route lab work through this repo's own `.sisyphus/plans/` drafts
