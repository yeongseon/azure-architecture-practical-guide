# Contributing

Thank you for your interest in contributing to Azure Architecture Practical Guide!

## Quick Start

1. Fork the repository
2. Clone: `git clone https://github.com/yeongseon/azure-architecture-practical-guide.git`
3. Install dependencies: `pip install mkdocs-material mkdocs-minify-plugin`
4. Start local preview: `mkdocs serve`
5. Open `http://127.0.0.1:8000` in your browser
6. Create a feature branch: `git checkout -b feature/your-change`
7. Make changes and validate: `mkdocs build --strict`
8. Submit a Pull Request

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

## Document Templates

Every document must follow the template for its section. Do not invent new structures.

### Platform docs

```text
# Title
Brief introduction (1-2 sentences)
## Main Content
### Subsections
## See Also
## Sources
```

### Best Practices docs

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

### Operations docs

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

### Troubleshooting docs

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

### Reference docs

```text
# Title
Brief introduction
## Topic/Command Groups
## Usage Notes
## See Also
## Sources
```

## Writing Standards

### CLI Commands

```bash
# ALWAYS use long flags for readability
az group create --name $RG --location $LOCATION

# NEVER use short flags in documentation
az group create -n $RG -l $LOCATION  # ❌ Don't do this
```

### Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `$RG` | Resource group name | `rg-architecture-demo` |
| `$LOCATION` | Azure region | `koreacentral` |
| `$SUBSCRIPTION_ID` | Subscription identifier placeholder | `<subscription-id>` |

### Mermaid Diagrams

All architectural diagrams use Mermaid. Every documentation page should include at least one diagram.

### Nested Lists

All nested list items MUST use **4-space indent** (Python-Markdown standard).

### Admonitions

For MkDocs admonitions, indent body content by **4 spaces**:

```markdown
!!! warning "Title"
    Body text here.
```

### Tail Sections

Every document ends with these sections in order:

1. `## See Also` — internal cross-links within this guide
2. `## Sources` — external references (Microsoft Learn URLs)

## Content Source Policy

All content must be traceable to official Microsoft Learn documentation.

| Source Type | Description | Allowed? |
|---|---|---|
| `mslearn` | Directly from Microsoft Learn | Required for platform content |
| `mslearn-adapted` | Adapted from Microsoft Learn | Yes, with source URL |
| `self-generated` | Original content | Requires justification |

## PII Rules

NEVER include real Azure identifiers in documentation or examples:

- Subscription IDs: use `<subscription-id>`
- Tenant IDs: use `<tenant-id>`
- Emails: use `user@example.com`
- Secrets, tokens, connection strings: NEVER include

## Build and Validate

```bash
# Install dependencies
pip install mkdocs-material mkdocs-minify-plugin

# Validate (must pass before submitting PR)
mkdocs build --strict

# Local preview
mkdocs serve
```

## Git Commit Style

```
type: short description
```

Allowed types: `feat`, `fix`, `docs`, `chore`, `refactor`

## Review Process

1. Automated CI checks (MkDocs build)
2. Maintainer review for accuracy and completeness
3. Merge to main triggers GitHub Pages deployment

## Code of Conduct

Please read our [Code of Conduct](https://github.com/yeongseon/azure-architecture-practical-guide/blob/main/CODE_OF_CONDUCT.md) before contributing.

## See Also

- [Repository Map](../start-here/repository-map.md)
- [Learning Paths](../start-here/learning-paths.md)
