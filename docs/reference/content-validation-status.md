---
content_sources:
  diagrams:
    - id: content-validation-lifecycle
      type: flowchart
      source: self-generated
      justification: "Validation workflow synthesized from repository quality gates and Microsoft Learn-first documentation policy."
      based_on:
        - https://learn.microsoft.com/en-us/azure/architecture/
        - https://learn.microsoft.com/en-us/azure/well-architected/
---
# Content Validation Status

This page tracks whether major documentation areas have been reviewed for source integrity, diagram metadata, evidence quality, and internal consistency.

## Validation methodology

Each content area is checked for:

1. Microsoft Learn traceability. [Documented]
2. Mermaid diagram presence with `diagram-id` metadata. [Validated]
3. Evidence tags used where claims require strength labeling. [Validated]
4. Alignment with the repository information architecture. [Observed]

## Current status

| Section | Source coverage | Diagram metadata | Evidence tagging | Validation status |
|---|---|---|---|---|
| Home | Complete | Complete | Partial | In review |
| Design Labs | Complete for Phase 1 files | Complete | Complete | Ready for review |
| Reference | Complete for Phase 1 files | Complete | Complete | Ready for review |
| Workload Guides | Not yet populated | Not yet populated | Not yet populated | Pending |
| Architecture Reviews | Not yet populated | Not yet populated | Not yet populated | Pending |

<!-- diagram-id: content-validation-lifecycle -->
```mermaid
flowchart LR
    A[Draft content] --> B[Source check]
    B --> C[Diagram metadata check]
    C --> D[Evidence tagging review]
    D --> E[Publish or rework]
```

## Interpretation notes

- **Complete** means the criterion is present and reviewable, not that every technical claim has production proof. [Correlated]
- **Ready for review** means the page can enter a stricter architecture or editorial review loop. [Observed]
- **Pending** means content is absent or lacks enough structure to evaluate. [Unknown]

## Microsoft Learn references

- https://learn.microsoft.com/en-us/azure/architecture/
- https://learn.microsoft.com/en-us/azure/well-architected/
