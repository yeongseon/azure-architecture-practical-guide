# Wave 2 Preparatory Artifacts

**Wave**: Wave 2 — Duplicate cleanup, baseline promotion, and navigation standardization
**Date**: 2026-07-09
**Coordinator**: Sisyphus
**Meta-tracker**: [azure-architecture-practical-guide#42](https://github.com/yeongseon/azure-architecture-practical-guide/issues/42)
**Oracle strategic calls**: Phase 3.11 (initial GO/GO/GO on all 3 artifacts) + Phase 3.12 (Artifact 01 canonical-URL correction) — SYNC session `ses_0c9fa347cffeQv11ROULLRjMNp`

## Purpose

This directory holds preparatory design artifacts for Wave 2 implementation branches. Implementation is currently blocked because 8 sibling P5 baseline conformance PRs are still open, per Oracle Phase 3.10 gating rule:

> "Do not open Wave 2 remediation PRs on sibling repos until P5 merges."

Per Oracle Phase 3.11:

> "If implementation is blocked, keep moving on approved prep/audit/design work. Stop only when the next step would create new scope, new contract, or destructive repo changes."

These 3 artifacts are approved (GO / GO / GO) design work that unblocks fast execution once P5 merges. Each artifact is a **design document, not a PR-ready implementation**. Each names:

- The exact files and line numbers affected (verified empirically 2026-07-09).
- The concrete find/replace or content-transformation steps.
- The dependencies on other artifacts or on P5 merge.
- The out-of-scope carve-outs so implementation stays focused.

## Artifacts

| # | Artifact | Scope | Blocked on | Oracle history |
|---:|---|---|---|---|
| 01 | [Duplicate-cleanup redirect maps](01-duplicate-cleanup-redirect-maps.md) | VM, Networking, Functions — file consolidation + inbound reference updates | P5 merge for those 3 repos | Phase 3.11 GO → Phase 3.12 IA + link-gravity correction applied for VM/Networking (commit `86f6d26`) |
| 02 | [Functions 2A generalization edit plan](02-functions-2a-generalization-plan.md) | Functions `cross-guide-baseline.md` — remove Functions-specific bits before Architecture promotion | P5 Functions merge, plus this artifact must land before Subwave 2B | Phase 3.11 GO → Phase 3.12 GO (Example-block strategy affirmed) |
| 03 | [Nav remediation outlines (#111, #18)](03-nav-remediation-outlines.md) | App Service and ACS — concrete implementation sketch for each of the 3 options in each issue | P5 merge for app-service and ACS | Phase 3.11 GO → Phase 3.12 GO (Option B default; Option C only if >12 children) |

## Guardrails observed

Per Oracle Phase 3.11 discipline directive:

- **No new scope.** These artifacts only concretize decisions already scoped in filed issues (vm#29, networking#27, functions#70, functions#71, app-service#111, acs#18).
- **No new contract.** Contract v1.1 is the current MUST/SHOULD baseline. These artifacts operate within it.
- **No destructive changes.** These are read-only design docs — no files in sibling repos are modified.
- **Contract compliance checked.** Each artifact verifies its plan against nav contract v1.1 MUST 3-6 and archetype SHOULD tier.

## Execution order once P5 merges

1. **Subwave 1** (in parallel across 3 repos, no ordering constraint): open one PR per repo following artifact 01 — VM, Networking, Functions duplicate consolidation.
2. **Subwave 2A**: open Functions PR following artifact 02 — generalize `cross-guide-baseline.md`.
3. **Subwave 2B**: open Architecture PR to promote the generalized baseline into `docs/contributing/` (child issue architecture#43). This MUST wait for 2A to land.
4. **Subwave 2C**: open one PR per sibling repo (9 total) adding a link to the canonical Architecture-hosted baseline. This is a second filing pass, not covered in these prep artifacts.
5. **Subwave 3** (in parallel across 2 repos, no ordering constraint): open one PR per repo following artifact 03 — app-service and ACS nav conformance.

## Files in this directory

| File | Purpose | Line count |
|---|---|---|
| `README.md` | This coordinator note (you are here) | — |
| `01-duplicate-cleanup-redirect-maps.md` | Subwave 1 execution design | see file |
| `02-functions-2a-generalization-plan.md` | Subwave 2A execution design | see file |
| `03-nav-remediation-outlines.md` | Subwave 3 execution design | see file |

## References

- Wave 2 meta: [azure-architecture-practical-guide#42](https://github.com/yeongseon/azure-architecture-practical-guide/issues/42)
- Oracle session: `ses_0c9fa347cffeQv11ROULLRjMNp` (Phase 3.11 initial approval 37s SYNC + Phase 3.12 correction review 2m 0s SYNC, both same session)
- Series Nav Contract v1.1: [`docs/contributing/series-nav-contract.md`](../../../docs/contributing/series-nav-contract.md)
- Series Lab Contract v1: [`docs/contributing/series-lab-contract.md`](../../../docs/contributing/series-lab-contract.md)
