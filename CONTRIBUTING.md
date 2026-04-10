# Contributing to Azure Architecture Practical Guide

Thank you for your interest in contributing!

## How to Contribute

### Reporting Issues
- Use GitHub Issues for bugs, questions, or suggestions.
- Include architecture context, constraints, and expected outcomes when reporting issues.
- Tag issues appropriately (architecture-decision, documentation, infrastructure).

### Submitting Architecture Decisions and Guide Updates
1. Fork the repository.
2. Create a branch: `architecture-decision/your-topic-name`.
3. Follow the repository authoring standards and ADVR methodology in `AGENTS.md`.
4. Include:
    - Complete 16-section documentation where applicable.
    - Supporting Bicep templates or validation assets if applicable.
    - Evidence-tagged conclusions.
5. Submit a Pull Request.

### Documentation Standards
- Use the canonical repository structure and navigation in `mkdocs.yml`.
- Follow the Evidence Levels in `AGENTS.md` for conclusions.
- Include Mermaid diagrams where applicable.
- Test with `mkdocs build --strict` before submitting.

### Code Standards
- Shell scripts: Use `set -e`, quote variables.
- Python: Follow PEP 8, include type hints.
- Infrastructure: Use Bicep over ARM.

## Review Process
1. Automated CI checks (MkDocs build, linting).
2. Maintainer review for technical accuracy and completeness.
3. Merge to main triggers deployment.

## Code of Conduct
See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
