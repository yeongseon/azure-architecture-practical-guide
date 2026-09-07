---
content_sources:
  diagrams:
    - id: architecture-lifecycle-diagram-1
      type: flowchart
      source: mslearn-adapted
      mslearn_url: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/
---
# Architecture Lifecycle

Azure architectures are not static artifacts. They move through a lifecycle in which design assumptions become implementation choices, those choices become production constraints, and production feedback forces redesign. Teams that treat architecture as a one-time document usually accumulate drift, exceptions, and avoidable operational risk.

## Lifecycle phases

1. **Design** — define goals, constraints, options, and quality priorities.
2. **Build** — encode topology, policy, identity, and dependencies into delivery assets.
3. **Deploy** — promote changes through controlled environments and approvals.
4. **Operate** — monitor, support, optimize, and recover the workload.
5. **Evolve** — revisit assumptions as demand, regulation, and platform capabilities change.

## Lifecycle loop

<!-- diagram-id: architecture-lifecycle-diagram-1 -->
```mermaid
flowchart TD
    A[Design] --> B[Build]
    B --> C[Deploy]
    C --> D[Operate]
    D --> E[Evolve]
    E --> A
```

## What changes over time

| Phase | Main concern | Typical output |
|---|---|---|
| Design | Fit and trade-offs | ADRs, diagrams, review notes |
| Build | Reproducibility | IaC, policy, pipeline definitions |
| Deploy | Change safety | Promotion gates, approvals, rollback plans |
| Operate | Service health | SLOs, dashboards, runbooks, incident records |
| Evolve | Continued fitness | Updated ADRs, redesign backlog, deprecations |

## When to revisit architecture decisions

[Inferred] The need to revisit architecture usually follows a material change in business or technical context. Common triggers include:

- major traffic growth or tenant mix change,
- new compliance or data residency constraints,
- repeated incidents with the same dependency or failure mode,
- cost growth that outpaces business value,
- platform capability changes that make a previous trade-off obsolete,
- team topology changes that alter operational ownership.

## Anti-patterns

- Treating the first approved diagram as the final architecture.
- Releasing architecture changes incrementally without updating decision records.
- Accumulating exceptions that silently replace the intended operating model.
- Waiting for a major outage before reviewing reliability or security assumptions.
- Allowing platform changes to drift without application-team impact review.

## Ownership by phase

- Design: architects, security, platform, product, and app leaders.
- Build: platform engineers, application engineers, and governance owners.
- Deploy: release engineering, operations, and risk approvers.
- Operate: app support, platform SRE, security operations, and service owners.
- Evolve: architecture review boards, platform strategy, and workload leads.

## Validation checkpoints

- Each phase has defined outputs and exit criteria.
- [Observed] Drift and exceptions are visible rather than hidden in tickets.
- [Correlated] Deployment, incident, cost, and performance trends inform changes.
- [Validated] Revisit triggers lead to actual architecture reviews.
- [Correlated] Repeated production pain is linked back to design decisions.

## Practical review questions

- What assumptions from the original design are no longer true?
- Which operating controls exist only because the architecture is compensating for earlier constraints?
- Has the workload outgrown its original scaling, security, or team model?
- What decisions are becoming expensive to reverse?

## Takeaway

[Validated] The best architecture lifecycle is a deliberate loop: decide, encode, operate, learn, and revisit before production pressure makes redesign unavoidable.

## Prerequisites

- Defined outputs and exit criteria for each lifecycle phase (Design, Build, Deploy, Operate, Evolve).
- Decision records (ADRs) and diagrams that capture the original goals, constraints, and trade-offs.
- Named ownership per phase so architects, platform, security, release, and application teams know their responsibilities.
- Visibility into deployment, incident, cost, and performance trends so drift is observable rather than hidden.

## When to Use

Apply this lifecycle model continuously for any workload expected to live beyond its first release. Actively re-enter the loop when:

- traffic, tenant mix, or compliance constraints change materially,
- the same dependency or failure mode causes repeated incidents,
- cost growth outpaces business value, or platform changes make an earlier trade-off obsolete,
- team topology changes shift operational ownership.

## Procedure

1. **Design** — define goals, constraints, options, and quality priorities; record them as ADRs and diagrams.
2. **Build** — encode topology, policy, identity, and dependencies into versioned delivery assets.
3. **Deploy** — promote changes through controlled environments with approvals and rollback plans.
4. **Operate** — monitor SLOs, support, optimize, and recover the workload.
5. **Evolve** — feed operational, incident, and cost signals back into revisit triggers and the redesign backlog.

## Verification

- Each phase produces its defined outputs and meets exit criteria before the next phase begins.
- [Observed] Drift and exceptions are visible rather than buried in tickets.
- [Correlated] Deployment, incident, cost, and performance trends inform architecture change.
- [Validated] Revisit triggers lead to actual architecture reviews, not just backlog notes.

## Rollback / Troubleshooting

- When a phase ships without updated decision records, pause and reconcile the ADRs before the change compounds drift.
- Guard against the anti-patterns — treating the first diagram as final, accumulating silent exceptions, or waiting for a major outage to review reliability and security assumptions.
- Use the practical review questions (which assumptions no longer hold, which controls only compensate for old constraints, which decisions are becoming expensive to reverse) to decide when to roll a decision back into redesign.

## See Also

- [ADR process](adr-process.md)
- [Design labs methodology](../design-labs/methodology.md)
- [Observability and SLOs](observability-and-slos.md)

## Sources

- [Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/)
- [Adopt cloud governance at scale](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/govern/)

