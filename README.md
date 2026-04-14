# Azure Architecture Practical Guide

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [简体中文](README.zh-CN.md)

Comprehensive guide for designing, reviewing, and operating Azure architectures — from foundational decisions and Well-Architected trade-offs to workload blueprints and architecture reviews.

## What's Inside

| Section | Description |
|---------|-------------|
| [Start Here](https://yeongseon.github.io/azure-architecture-practical-guide/) | Overview, learning paths, repository map, and how to use the guide |
| [Platform](https://yeongseon.github.io/azure-architecture-practical-guide/platform/) | Azure architecture foundations including landing zones, identity, networking, compute, data, and resilience |
| [Well-Architected Framework](https://yeongseon.github.io/azure-architecture-practical-guide/waf/) | Cost, security, reliability, performance, and operational excellence guidance |
| [Architecture Patterns](https://yeongseon.github.io/azure-architecture-practical-guide/patterns/) | Proven decomposition, integration, data, resilience, networking, security, and deployment patterns |
| [Workload Guides](https://yeongseon.github.io/azure-architecture-practical-guide/workload-guides/) | Practical blueprints for public web, internal apps, integration, serverless, microservices, data, and AI workloads |
| [Operations](https://yeongseon.github.io/azure-architecture-practical-guide/operations/) | ADRs, IaC, governance guardrails, observability, FinOps, and continuity practices |
| [Architecture Reviews](https://yeongseon.github.io/azure-architecture-practical-guide/architecture-reviews/) | Decision tree, evidence map, first-60-minutes reviews, anti-patterns, and migration playbooks |
| [Design Labs](https://yeongseon.github.io/azure-architecture-practical-guide/design-labs/) | Guided design exercises for common Azure workload scenarios |
| [Reference](https://yeongseon.github.io/azure-architecture-practical-guide/reference/) | Decision matrices, service selection cheatsheets, mappings, glossary, and validation status |

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yeongseon/azure-architecture-practical-guide.git

# Install MkDocs dependencies
pip install mkdocs-material mkdocs-minify-plugin

# Start local documentation server
mkdocs serve
```

Visit `http://127.0.0.1:8000` to browse the documentation locally.

## Reference Architectures

Reference architectures and baseline assets are organized around reusable infrastructure and documentation patterns:

- `infra/bicep/` — Bicep templates for architecture baselines and shared services
- `docs/workload-guides/` — workload-specific architecture blueprints
- `docs/patterns/` — reusable decision and implementation patterns

## Contributing

Contributions welcome. Please ensure:
- All CLI examples use long flags (`--resource-group`, not `-g`)
- All documents include mermaid diagrams where applicable
- All content references Microsoft Learn with source URLs
- No PII in CLI output examples

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

## Disclaimer

This is an independent community project. Not affiliated with or endorsed by Microsoft. Azure is a trademark of Microsoft Corporation.

## License

[MIT](LICENSE)
