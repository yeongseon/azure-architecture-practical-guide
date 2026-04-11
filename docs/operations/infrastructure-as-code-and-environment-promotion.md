---
content_sources:
  diagrams:
    - id: iac-promotion-diagram-1
      type: flowchart
      source: mslearn-adapted
      mslearn_url: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview
---
# Infrastructure as Code and Environment Promotion

Infrastructure as Code (IaC) is the operational foundation for repeatable Azure architecture. It turns diagrams and standards into versioned definitions that can be reviewed, tested, and promoted consistently across environments. Environment promotion is the discipline that keeps those definitions trustworthy as they move from development to production.

## Why it matters

[Documented] Microsoft recommends using declarative provisioning such as Bicep for Azure Resource Manager deployments, and Terraform is also widely used in Azure environments. The architecture concern is not tool preference alone; it is whether topology, policy, identity, and dependency assumptions are encoded consistently.

## Core design principles

1. Use reusable modules for common platform patterns.
2. Separate environment-specific data from shared topology definitions.
3. Promote through controlled environments rather than editing production directly.
4. Keep security, policy, and networking controls versioned alongside workload changes where practical.
5. Ensure rollback or forward-fix strategies are explicit.

## Promotion model

<!-- diagram-id: iac-promotion-diagram-1 -->
```mermaid
flowchart LR
    A[Source definitions] --> B[Development environment]
    B --> C[Staging or pre-production]
    C --> D[Production]
    D --> E[Operational feedback]
    E --> A
```

## Bicep and Terraform considerations

| Concern | Bicep | Terraform | Architecture implication |
|---|---|---|---|
| Azure-native coverage | Strong alignment with ARM | Broad multi-cloud support | Choose based on platform scope |
| Policy alignment | Natural fit with Azure governance | Strong with module ecosystems | Guardrails must stay consistent |
| State model | Azure deployment history | External state management | Recovery and access patterns differ |
| Team familiarity | Best for Azure-focused teams | Useful for mixed-cloud or existing practice | Operational consistency matters most |

## Parameterization strategies

- Keep topology structure stable across environments where possible.
- Use parameters for scale, SKU, and environment-specific endpoints.
- Separate secrets from general configuration.
- Avoid parameter sprawl that hides real design differences.
- Promote immutable artifacts and reviewed parameter sets together.

## Common anti-patterns

- One code path for dev and manual exceptions in production.
- Environment-specific branching that creates drift.
- Embedding secrets or tenant-specific values in source.
- Treating IaC as deployment convenience instead of architecture truth.
- Promoting infrastructure without validating dependent app or policy changes.

## Failure modes

[Observed] Promotion problems frequently show up as:

- staging that does not represent production risk,
- policy failures discovered only at production time,
- partial rollouts that break shared dependencies,
- inconsistent network or identity assumptions between environments,
- emergency manual fixes that never return to source control.

## Ownership

- Platform teams own reusable modules, guardrail integration, and shared patterns.
- Application teams own workload-specific modules and configuration intent.
- Security and governance teams review control integration and exceptions.
- Release owners define promotion gates and release criteria.

## Validation checklist

- Environment topology and parameter strategy are defined.
- [Observed] Promotion paths are standardized and auditable.
- [Observed] Drift, failed deployments, and rollback frequency are tracked.
- [Validated] Non-production environments prove policy and dependency compatibility.
- [Correlated] Production deployment issues are traced back to template or promotion design.
- [Inferred] Module reuse reduces inconsistent implementation of core controls.

## Microsoft Learn references

- [Bicep overview](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview)
- [What is Azure Resource Manager?](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview)

## Takeaway

[Validated] Good IaC is not only declarative deployment. It is the architecture operating model encoded in source, promoted safely, and kept synchronized with real production behavior.
