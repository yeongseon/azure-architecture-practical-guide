# Azure Architecture Practical Guide

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [简体中文](README.zh-CN.md)

📘 Documentation site: <https://yeongseon.github.io/azure-architecture-practical-guide/>

Comprehensive guide for designing, reviewing, and operating Azure architectures — from foundational decisions and Well-Architected trade-offs to workload blueprints and architecture reviews.

## What's Inside

| Section | Description | Status |
|---------|-------------|--------|
| [Start Here](https://yeongseon.github.io/azure-architecture-practical-guide/) | Overview, learning paths, repository map, and how to use the guide | Comprehensive |
| [Platform](https://yeongseon.github.io/azure-architecture-practical-guide/platform/) | Azure architecture foundations including landing zones, identity, networking, compute, data, and resilience | Comprehensive |
| [Well-Architected Framework](https://yeongseon.github.io/azure-architecture-practical-guide/waf/) | Reliability, Security, Cost Optimization, Operational Excellence, and Performance Efficiency guidance | Comprehensive |
| [Architecture Patterns](https://yeongseon.github.io/azure-architecture-practical-guide/patterns/) | Proven decomposition, integration, data, resilience, networking, security, and deployment patterns | Comprehensive |
| [Workload Guides](https://yeongseon.github.io/azure-architecture-practical-guide/workload-guides/) | Practical blueprints for public web, internal apps, integration, serverless, microservices, data, and AI workloads | Comprehensive |
| [Operations](https://yeongseon.github.io/azure-architecture-practical-guide/operations/) | ADRs, IaC, governance guardrails, observability, FinOps, and continuity practices | Comprehensive |
| [Architecture Reviews](https://yeongseon.github.io/azure-architecture-practical-guide/architecture-reviews/) | Decision tree, evidence map, first-60-minutes reviews, anti-patterns, and migration playbooks | In progress |
| [Design Labs](https://yeongseon.github.io/azure-architecture-practical-guide/design-labs/) | Guided design exercises for common Azure workload scenarios | Published |
| [Reference](https://yeongseon.github.io/azure-architecture-practical-guide/reference/) | Decision matrices, service selection cheatsheets, mappings, glossary, and validation status | Comprehensive |

**Status legend**: **Lab-validated** = Comprehensive + reproducible labs prove the guidance · **Comprehensive** = Full section, MSLearn-verified, production-ready · **Published** = Core content in place, still expanding · **In progress** = Partial content, active development · **Planned** = Placeholder, content not yet started

## Quick Start

```bash
git clone https://github.com/yeongseon/azure-architecture-practical-guide.git
cd azure-architecture-practical-guide

python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements-docs.txt

mkdocs serve
```

Visit `http://127.0.0.1:8000` to browse the documentation locally.

## Reference Architectures

Reference architectures and baseline assets are organized around reusable infrastructure and documentation patterns:

- `infra/bicep/` — Bicep templates for architecture baselines and shared services
- `docs/workload-guides/` — workload-specific architecture blueprints
- `docs/patterns/` — reusable decision and implementation patterns

## Contributing

Contributions welcome! Please see our [Contributing Guide](https://yeongseon.github.io/azure-architecture-practical-guide/contributing/) for:

- Repository structure and content organization
- Document templates and writing standards
- CLI command style and PII rules
- Local development setup and build validation
- Pull request process

## Related Projects

| Repository | Description |
|---|---|
| [azure-virtual-machine-practical-guide](https://github.com/yeongseon/azure-virtual-machine-practical-guide) | Azure Virtual Machines practical guide |
| [azure-networking-practical-guide](https://github.com/yeongseon/azure-networking-practical-guide) | Azure Networking practical guide |
| [azure-storage-practical-guide](https://github.com/yeongseon/azure-storage-practical-guide) | Azure Storage practical guide |
| [azure-app-service-practical-guide](https://github.com/yeongseon/azure-app-service-practical-guide) | Azure App Service practical guide |
| [azure-functions-practical-guide](https://github.com/yeongseon/azure-functions-practical-guide) | Azure Functions practical guide |
| [azure-communication-services-practical-guide](https://github.com/yeongseon/azure-communication-services-practical-guide) | Azure Communication Services practical guide |
| [azure-container-apps-practical-guide](https://github.com/yeongseon/azure-container-apps-practical-guide) | Azure Container Apps practical guide |
| [azure-kubernetes-service-practical-guide](https://github.com/yeongseon/azure-kubernetes-service-practical-guide) | Azure Kubernetes Service (AKS) practical guide |
| [azure-architecture-practical-guide](https://github.com/yeongseon/azure-architecture-practical-guide) | Azure Architecture practical guide |
| [azure-monitoring-practical-guide](https://github.com/yeongseon/azure-monitoring-practical-guide) | Azure Monitoring practical guide |

## Disclaimer

This is an independent community project. Not affiliated with or endorsed by Microsoft. Azure is a trademark of Microsoft Corporation.

## License

[MIT](LICENSE)
