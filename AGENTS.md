# AGENTS.md

## Project Overview
**Project Name:** Azure Architecture Practical Guide
**Description:** A comprehensive, hands-on guide for designing, reviewing, and operating Azure architectures, covering foundational platform decisions, workload blueprints, and evidence-based architecture reviews.
**Core Mission:** Provide practical, reproducible, evidence-based guidance that helps teams make better Azure architecture decisions, validate them, and operate them with clear trade-off awareness.

## Repository Structure
- `infra/`: Bicep/Terraform templates for reference architectures, landing zones, and shared platform components.
    - `bicep/`: Primary infrastructure-as-code assets for deployable architecture baselines.
- `docs/`: Markdown documentation source for the MkDocs site.
    - `architecture-reviews/`: Primary area for review methodology, decision trees, anti-patterns, and migration playbooks.
        - `playbooks/`: Review guides for common workload archetypes.
        - `anti-patterns/`: Architecture failure modes and corrective patterns.
        - `migration-playbooks/`: Stepwise modernization and transition guides.
    - `platform/`, `waf/`, `patterns/`, `workload-guides/`, `operations/`, `design-labs/`, `reference/`: General guide content.
- `scripts/`: Validation and quality scripts for Markdown, Mermaid, and source metadata.
- `labs/`: Optional supporting assets for architecture validation exercises and design labs.
- `mkdocs.yml`: Configuration for the documentation site, including navigation and plugins.

## Content Types & Methodology

### 1. Architecture Decisions, Reviews, and Validation Records (ADVR)
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

### 2. Evidence Levels
When documenting architecture decisions or reviews, use these tags to specify the strength of the evidence:
- `[Documented]`: Explicitly stated in official documentation, standards, or approved design records.
- `[Observed]`: Directly seen in logs, metrics, deployment behavior, or product behavior.
- `[Measured]`: Quantified data such as latency, cost, throughput, or recovery times.
- `[Validated]`: Confirmed through testing, drills, proofs of concept, or production verification.
- `[Correlated]`: Multiple signals align but do not fully prove causation.
- `[Inferred]`: Conclusion based on logic and multiple pieces of evidence.
- `[Assumed]`: Working assumption pending validation.
- `[Unknown]`: Missing data or unresolved ambiguity.

## Technical Standards & Conventions

### 1. Language Usage
- **Shell**: Use `bash` for all CLI examples.
- **Python**: Use `python` for all script examples.
- **KQL**: Use `kusto` for all Kusto Query Language blocks.
- **Mermaid**: Use `mermaid` for all architecture and flow diagrams.

### 2. CLI Standards
- Always use long flags for Azure CLI commands (e.g., `--resource-group` instead of `-g`).
- Ensure no Personally Identifiable Information (PII) is included in CLI output examples.

### 3. Documentation Style
- All content must reference official Microsoft Learn documentation with source URLs where applicable.
- Use `admonitions` (note, warning, tip) for highlighting critical information.
- Ensure all documents include a Mermaid diagram to visualize the concept or flow.

## Content Source Requirements

### 1. MSLearn-First Policy
All content MUST be traceable to official Microsoft Learn documentation:

- **Platform content** (`docs/platform/`): MUST have direct MSLearn source URLs
- **Architecture diagrams**: MUST reference official Microsoft documentation
- **Architecture reviews and decision content**: MAY synthesize MSLearn content with clear attribution
- **Self-generated content**: MUST have justification explaining the source basis

### 2. Source Types
| Type | Description | Allowed? |
|---|---|---|
| `mslearn` | Directly from Microsoft Learn | ✅ Required for platform content |
| `mslearn-adapted` | MSLearn content adapted for this guide | ✅ With source URL |
| `self-generated` | Original content for this guide | ⚠️ Requires justification |
| `community` | From community sources | ❌ Not for core content |
| `unknown` | Source not documented | ❌ Must be validated |

### 3. Diagram Source Documentation
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

### 4. Content Validation Tracking
- See [Content Validation Status](docs/reference/content-validation-status.md) for current status
- See [Tutorial Validation Status](docs/reference/validation-status.md) for tutorial testing

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

## Build & Contribution
- **Build Command**: `pip install mkdocs-material mkdocs-minify-plugin && mkdocs build`
- **Development Server**: `mkdocs serve`
- **Git Commit Types**:
    - `feat`: New architecture guide, workload blueprint, or review playbook.
    - `fix`: Correction of technical inaccuracies or broken links.
    - `docs`: General documentation improvements (typos, clarity).
    - `chore`: Updates to build scripts, dependencies, or metadata.
    - `refactor`: Restructuring existing content without changing the technical meaning.
