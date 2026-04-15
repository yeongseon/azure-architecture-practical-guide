# AGENTS.md

Guidance for AI agents working in this repository.

## Project Overview

**Azure Architecture Practical Guide** — a comprehensive, hands-on guide for designing, reviewing, and operating Azure architectures, covering foundational platform decisions, workload blueprints, and evidence-based architecture reviews.

- **Live site**: <https://yeongseon.github.io/azure-architecture-practical-guide/>
- **Repository**: <https://github.com/yeongseon/azure-architecture-practical-guide>

## Repository Structure

```text
.
├── .github/
│   └── workflows/              # GitHub Pages deployment
├── docs/
│   ├── architecture-reviews/   # Review methodology, decision trees, anti-patterns
│   │   ├── playbooks/          # Review guides for common workload archetypes
│   │   ├── anti-patterns/      # Architecture failure modes and corrective patterns
│   │   └── migration-playbooks/ # Stepwise modernization and transition guides
│   ├── assets/                 # Images, icons
│   ├── design-labs/            # Guided design exercises
│   ├── operations/             # ADRs, IaC, governance, observability, FinOps
│   ├── patterns/               # Architecture patterns
│   ├── platform/               # Azure architecture foundations
│   ├── reference/              # Decision matrices, cheatsheets, glossary
│   ├── start-here/             # Entry points
│   ├── waf/                    # Well-Architected Framework guidance
│   └── workload-guides/        # Practical blueprints
├── infra/
│   └── bicep/                  # Bicep templates for architecture baselines
├── labs/                       # Architecture validation exercises
├── scripts/                    # Validation and quality scripts
└── mkdocs.yml                  # MkDocs Material configuration
```

## Content Categories

The documentation is organized by intent and lifecycle stage:

| Section | Purpose |
|---|---|
| **Start Here** | Entry points, learning paths, repository map |
| **Platform** | Azure architecture foundations — landing zones, identity, networking, compute, data, resilience |
| **Well-Architected Framework** | Reliability, Security, Cost Optimization, Operational Excellence, and Performance Efficiency guidance |
| **Architecture Patterns** | Proven decomposition, integration, data, resilience, networking, security, and deployment patterns |
| **Workload Guides** | Practical blueprints for public web, internal apps, integration, serverless, microservices, data, and AI workloads |
| **Operations** | ADRs, IaC, governance guardrails, observability, FinOps, and continuity practices |
| **Architecture Reviews** | Decision tree, evidence map, first-60-minutes reviews, anti-patterns, and migration playbooks |
| **Design Labs** | Guided design exercises for common Azure workload scenarios |
| **Reference** | Decision matrices, service selection cheatsheets, mappings, glossary, and validation status |

## Content Types & Methodology

### Architecture Decisions, Reviews, and Validation Records (ADVR)

All architecture labs, review playbooks, and design decision content must follow this 16-section structure where applicable:

1. **Decision Question**: The architecture decision or review question being addressed.
2. **Business Context**: The business driver, stakeholders, and expected outcomes.
3. **Scope and Non-Goals**: What is and is not covered by the decision.
4. **Constraints**: Regulatory, organizational, budgetary, technical, or operational constraints.
5. **Quality Attribute Priorities**: Ranked priorities such as security, reliability, cost, performance, and operability.
6. **Candidate Options**: Feasible architecture options under consideration.
7. **Recommended Option**: The selected option and why it was chosen.
8. **Architecture Hypothesis**: The belief about how and why the recommendation will work.
9. **Predicted Outcomes**: Expected consequences, benefits, and limits.
10. **Validation Plan**: How the architecture decision will be tested or reviewed.
11. **Falsification Criteria**: What evidence would prove the decision is wrong or insufficient.
12. **Evidence**: Documents, measurements, diagrams, benchmarks, or observations supporting the decision.
13. **Trade-offs and Risks**: Known compromises, failure modes, and open concerns.
14. **Guardrails and Operating Model**: Required policies, ownership boundaries, and runtime controls.
15. **Revisit Triggers**: Conditions that should trigger re-evaluation of the decision.
16. **Takeaway**: The practical conclusion for architects and operators.

### Evidence Levels

When documenting architecture decisions or reviews, use these tags to specify the strength of the evidence:

- `[Documented]`: Explicitly stated in official documentation, standards, or approved design records.
- `[Observed]`: Directly seen in logs, metrics, deployment behavior, or product behavior.
- `[Measured]`: Quantified data such as latency, cost, throughput, or recovery times.
- `[Validated]`: Confirmed through testing, drills, proofs of concept, or production verification.
- `[Correlated]`: Multiple signals align but do not fully prove causation.
- `[Inferred]`: Conclusion based on logic and multiple pieces of evidence.
- `[Assumed]`: Working assumption pending validation.
- `[Unknown]`: Missing data or unresolved ambiguity.

## Documentation Conventions

### File Naming

- Tutorial: `XX-topic-name.md` (numbered for sequence)
- All others: `topic-name.md` (kebab-case)
- Index files: `index.md` in each directory

### CLI Command Style

```bash
# ALWAYS use long flags for readability
az group create --name $RG --location $LOCATION

# NEVER use short flags in documentation
az group create -n $RG -l $LOCATION  # ❌ Don't do this
```

### Variable Naming Convention

| Variable | Description | Example |
|----------|-------------|---------|
| `$RG` | Resource group name | `rg-architecture-demo` |
| `$LOCATION` | Azure region | `koreacentral` |
| `$SUBSCRIPTION_ID` | Subscription identifier placeholder | `<subscription-id>` |

### PII Removal (Quality Gate)

**CRITICAL**: All CLI output examples MUST have PII removed.

**Must mask (real Azure identifiers):**

- Subscription IDs: `<subscription-id>`
- Tenant IDs: `<tenant-id>`
- Object IDs: `<object-id>`
- Resource IDs containing real subscription/tenant
- Emails: Remove or mask as `user@example.com`
- Secrets/Tokens: NEVER include

**OK to keep (synthetic example values):**

- Demo correlation IDs: `a1b2c3d4-e5f6-7890-abcd-ef1234567890`
- Example request IDs in logs
- Placeholder domains: `example.com`, `contoso.com`
- Sample resource names used consistently in docs

The goal is to prevent leaking **real Azure account information**, not to mask obviously-fake example values that aid readability.

### Admonition Indentation Rule

For MkDocs admonitions (`!!!` / `???`), every line in the body must be indented by **4 spaces**.

```markdown
!!! warning "Important"
    This line is correctly indented.

    - List item also inside
```

### Mermaid Diagrams

All architectural diagrams use Mermaid. Every documentation page should include at least one diagram. Test with `mkdocs build --strict`.

#### Diagram Orientation Rule

- **Sequential flows with 5+ nodes**: Use `flowchart TD` (top-down) to prevent horizontal overflow.
- **Short diagrams with fewer than 5 nodes**: `flowchart LR` (left-right) is acceptable.
- **Layered architecture diagrams** (e.g., network layers, stack diagrams): Always use `flowchart TD`.

```mermaid
%% CORRECT — 5+ node sequential flow uses TD
flowchart TD
    A[Commit] --> B[Build and test]
    B --> C[Package artifact]
    C --> D[Deploy to staging]
    D --> E[Validation]
    E --> F[Swap to production]

%% WRONG — long horizontal overflow
flowchart LR
    A[Commit] --> B[Build and test] --> C[Package] --> D[Deploy] --> E[Validate] --> F[Swap]
```

### Nested List Indentation

All nested list items MUST use **4-space indent** (Python-Markdown standard).

```markdown
# CORRECT (4-space)
1. **Item**
    - Sub item
    - Another sub item
        - Third level

# WRONG (2 or 3 spaces)
1. **Item**
  - Sub item          ← 2 spaces ❌
   - Sub item         ← 3 spaces ❌
```

### Tail Section Naming

Every document ends with these tail sections (in this order):

| Section | Purpose | Content |
|---|---|---|
| `## See Also` | Internal cross-links within this repository | Links to other pages in this guide |
| `## Sources` | External authoritative references | Links to Microsoft Learn (primary) |

### Canonical Document Templates

Every document follows one of 5 templates based on its section. Do not invent new structures.

#### Platform docs

```text
# Title
Brief introduction (1-2 sentences)
## Main Content
### Subsections
## See Also
## Sources
```

#### Best Practices docs

```text
# Title
Brief introduction
## Why This Matters
## Recommended Practices
## Common Mistakes / Anti-Patterns
## Validation Checklist
## See Also
## Sources
```

#### Operations docs

```text
# Title
Brief introduction
## Prerequisites
## When to Use
## Procedure
## Verification
## Rollback / Troubleshooting
## See Also
## Sources
```

#### Troubleshooting docs

```text
# Title
## Symptom
## Possible Causes
## Diagnosis Steps
## Resolution
## Prevention
## See Also
## Sources
```

#### Reference docs

```text
# Title
Brief introduction
## Topic/Command Groups
## Usage Notes
## See Also
## Sources
```

## Content Source Requirements

### MSLearn-First Policy

All content MUST be traceable to official Microsoft Learn documentation:

- **Platform content** (`docs/platform/`): MUST have direct MSLearn source URLs
- **Architecture diagrams**: MUST reference official Microsoft documentation
- **Architecture reviews and decision content**: MAY synthesize MSLearn content with clear attribution
- **Self-generated content**: MUST have justification explaining the source basis

### Source Types

| Type | Description | Allowed? |
|---|---|---|
| `mslearn` | Directly from Microsoft Learn | Required for platform content |
| `mslearn-adapted` | MSLearn content adapted for this guide | Allowed with source URL |
| `self-generated` | Original content for this guide | Requires justification |
| `community` | From community sources | Not allowed for core content |
| `unknown` | Source not documented | Must be validated |

### Diagram Source Documentation

Every Mermaid diagram MUST have source metadata in frontmatter:

```yaml
content_sources:
  diagrams:
    - id: architecture-overview
      type: flowchart
      source: mslearn
      mslearn_url: https://learn.microsoft.com/en-us/azure/architecture/...
    - id: decision-flow
      type: flowchart
      source: self-generated
      justification: "Synthesized from MSLearn articles X, Y, Z"
      based_on:
        - https://learn.microsoft.com/...
```

### Content Validation Tracking

- See [Content Validation Status](docs/reference/content-validation-status.md) for current status.
- See [Tutorial Validation Status](docs/reference/validation-status.md) for tutorial testing.

### Text Content Validation

Every non-tutorial document should include a `content_validation` block in frontmatter to track the verification status of its core claims.

```yaml
---
content_sources:
  - type: mslearn-adapted
    url: https://learn.microsoft.com/azure/architecture/...
content_validation:
  status: verified  # verified | pending_review | unverified
  last_reviewed: 2026-04-12
  reviewer: agent  # agent | human
  core_claims:
    - claim: "{example claim}"
      source: https://learn.microsoft.com/azure/architecture/...
      verified: true
---
```

#### Validation Status Values

| Status | Description |
|--------|-------------|
| `verified` | All core claims have been traced to Microsoft Learn sources |
| `pending_review` | Document exists but claims need source verification |
| `unverified` | New document, no validation performed |

#### Agent Rules for Content Validation

1. When creating or modifying Platform, Best Practices, or Operations documents, add `content_validation` frontmatter.
2. List 2-5 core claims that are factual assertions (not opinions or procedures).
3. Each claim must have a Microsoft Learn source URL.
4. Set `status: verified` only when ALL core claims have verified sources.
5. Run `python3 scripts/generate_content_validation_status.py` after updates.

## Quality Gates & Verification

1. **PII Check**: Manually verify no subscription IDs, tenant IDs, or private IP addresses are in the documentation.
2. **Link Validation**: Use `mkdocs build --strict` to ensure no broken internal or external links.
3. **Evidence Integrity**: Ensure every architecture review or design lab has a clear validation and falsification model.
4. **Content Source Validation**: All diagrams and platform content must have documented MSLearn sources.

## Mandatory Oracle Review (AI Agent Rule)

**ALL work performed by AI agents MUST undergo Oracle quality review before completion.**

### Review Protocol

1. **Work Completion**: Agent completes assigned task
2. **Build Verification**: Run `mkdocs build --strict` (must pass)
3. **Oracle Review Request**: Submit all changes to Oracle for quality review
4. **Quality Criteria**:
   - MSLearn-first policy compliance
   - Code explanation tables present for all CLI commands
   - Mermaid diagrams with proper `<!-- diagram-id: -->` comments
   - Long CLI flags only (no `-g`, `-n` shortcuts)
   - No PII in examples
   - Proper frontmatter with `content_sources`
5. **Iteration**: If Oracle identifies issues → fix and re-submit
6. **Completion**: Only mark done when Oracle approves (100% quality)

### Review Loop

```
while not oracle_approved:
    fix_identified_issues()
    run_build_verification()
    submit_to_oracle()
```

**NO WORK IS CONSIDERED COMPLETE WITHOUT ORACLE APPROVAL.**

## Tutorial Validation Tracking

Every tutorial document supports **validation frontmatter** that records when and how it was last tested against a real Azure deployment.

### Frontmatter Schema

Add a `validation` block inside the YAML frontmatter (`---` fences) of any tutorial file:

```yaml
---
hide:
  - toc
validation:
  az_cli:
    last_tested: 2026-04-09
    cli_version: "2.83.0"
    result: pass
  bicep:
    last_tested: null
    result: not_tested
---
```

### Agent Rules for Validation

1. **After deploying a tutorial end-to-end**, add or update the `validation` frontmatter with the current date, CLI version, and `result: pass`.
2. **If a tutorial step fails during validation**, set `result: fail` and note the issue.
3. **Never fabricate validation dates.** Only stamp a tutorial after actually executing all steps.
4. **After updating frontmatter**, regenerate the dashboard:
    ```bash
    python3 scripts/generate_validation_status.py
    ```
5. **Include the regenerated dashboard** (`docs/reference/validation-status.md`) in the same commit as the frontmatter change.
6. **Do not manually edit** `docs/reference/validation-status.md` — it is auto-generated.

## Build & Preview

```bash
# Install MkDocs dependencies
pip install mkdocs-material mkdocs-minify-plugin

# Build documentation (strict mode catches broken links)
mkdocs build --strict

# Local preview
mkdocs serve
```

## Git Commit Style

```text
type: short description
```

Allowed types: `feat`, `fix`, `docs`, `chore`, `refactor`

## Related Projects

| Repository | Description |
|---|---|
| [azure-virtual-machine-practical-guide](https://github.com/yeongseon/azure-virtual-machine-practical-guide) | Azure Virtual Machines practical guide |
| [azure-networking-practical-guide](https://github.com/yeongseon/azure-networking-practical-guide) | Azure Networking practical guide |
| [azure-storage-practical-guide](https://github.com/yeongseon/azure-storage-practical-guide) | Azure Storage practical guide |
| [azure-app-service-practical-guide](https://github.com/yeongseon/azure-app-service-practical-guide) | Azure App Service practical guide |
| [azure-functions-practical-guide](https://github.com/yeongseon/azure-functions-practical-guide) | Azure Functions practical guide |
| [azure-container-apps-practical-guide](https://github.com/yeongseon/azure-container-apps-practical-guide) | Azure Container Apps practical guide |
| [azure-communication-services-practical-guide](https://github.com/yeongseon/azure-communication-services-practical-guide) | Azure Communication Services practical guide |
| [azure-kubernetes-service-practical-guide](https://github.com/yeongseon/azure-kubernetes-service-practical-guide) | Azure Kubernetes Service (AKS) practical guide |
| [azure-monitoring-practical-guide](https://github.com/yeongseon/azure-monitoring-practical-guide) | Azure Monitoring practical guide |
