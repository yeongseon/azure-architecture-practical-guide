# Azure Architecture Practical Guide

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [简体中文](README.zh-CN.md)

📘 文档网站: <https://yeongseon.github.io/azure-architecture-practical-guide/>

[![Docs](https://github.com/yeongseon/azure-architecture-practical-guide/actions/workflows/docs.yml/badge.svg)](https://github.com/yeongseon/azure-architecture-practical-guide/actions/workflows/docs.yml)
[![CI](https://github.com/yeongseon/azure-architecture-practical-guide/actions/workflows/quality-gates.yml/badge.svg)](https://github.com/yeongseon/azure-architecture-practical-guide/actions/workflows/quality-gates.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

这是一个用于设计、评审和运营 Azure 架构的综合指南 — 涵盖从基础决策、Well-Architected 权衡到工作负载蓝图及架构评审的方方面面。

## 主要内容

| 章节 | 描述 | 状态 |
|---------|-------------|--------|
| [从这里开始](https://yeongseon.github.io/azure-architecture-practical-guide/) | 概述、学习路径、仓库地图以及如何使用本指南 | Comprehensive |
| [平台](https://yeongseon.github.io/azure-architecture-practical-guide/platform/) | Azure 架构基础，包括登录区域、身份、网络、计算、数据和弹性 | Comprehensive |
| [Well-Architected Framework](https://yeongseon.github.io/azure-architecture-practical-guide/waf/) | 可靠性、安全、成本优化、运营卓越和性能效率指导 | Comprehensive |
| [架构模式](https://yeongseon.github.io/azure-architecture-practical-guide/patterns/) | 经过验证的拆分、集成、数据、弹性、网络、安全和部署模式 | Comprehensive |
| [工作负载指南](https://yeongseon.github.io/azure-architecture-practical-guide/workload-guides/) | 面向公共 Web、内部应用、集成、无服务器、微服务、数据和 AI 工作负载的实践蓝图 | Comprehensive |
| [运营](https://yeongseon.github.io/azure-architecture-practical-guide/operations/) | ADR、IaC、治理护栏、可观测性、FinOps 和业务连续性实践 | Comprehensive |
| [架构评审](https://yeongseon.github.io/azure-architecture-practical-guide/architecture-reviews/) | 决策树、证据图、前 60 分钟评审、反模式和迁移实战手册 | In progress |
| [设计实验室](https://yeongseon.github.io/azure-architecture-practical-guide/design-labs/) | 针对常见 Azure 工作负载场景的引导式设计练习 | Published |
| [参考](https://yeongseon.github.io/azure-architecture-practical-guide/reference/) | 决策矩阵、服务选型速查表、映射、术语表和验证状态 | Comprehensive |

**状态说明**: **Lab-validated** = 综合内容 + 可复用的实验室验证指南 · **Comprehensive** = 完整章节，经过 MSLearn 验证，生产就绪 · **Published** = 核心内容已就绪，持续扩展中 · **In progress** = 部分内容，正在积极开发中 · **Planned** = 占位符，内容尚未开始

## 快速入门

```bash
git clone https://github.com/yeongseon/azure-architecture-practical-guide.git
cd azure-architecture-practical-guide

python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements-docs.txt

mkdocs serve
```

访问 `http://127.0.0.1:8000` 在本地浏览文档。

## 参考架构

参考架构和基线资产围绕可复用的基础设施和文档模式组织：

- `infra/bicep/` — 用于架构基线和共享服务的 Bicep 模板
- `docs/workload-guides/` — 工作负载特定的架构蓝图
- `docs/patterns/` — 可复用的决策与实现模式

## 贡献

欢迎贡献！请参阅我们的 [贡献指南](https://yeongseon.github.io/azure-architecture-practical-guide/contributing/) 了解：

- 仓库结构和内容组织
- 文档模板和编写标准
- CLI 命令风格和 PII 规则
- 本地开发设置和构建验证
- 拉取请求流程

## 相关项目

| 仓库 | 描述 |
|---|---|
| [azure-virtual-machine-practical-guide](https://github.com/yeongseon/azure-virtual-machine-practical-guide) | Azure Virtual Machines 实操指南 |
| [azure-networking-practical-guide](https://github.com/yeongseon/azure-networking-practical-guide) | Azure Networking 实操指南 |
| [azure-storage-practical-guide](https://github.com/yeongseon/azure-storage-practical-guide) | Azure Storage 实操指南 |
| [azure-app-service-practical-guide](https://github.com/yeongseon/azure-app-service-practical-guide) | Azure App Service 实操指南 |
| [azure-functions-practical-guide](https://github.com/yeongseon/azure-functions-practical-guide) | Azure Functions 实操指南 |
| [azure-communication-services-practical-guide](https://github.com/yeongseon/azure-communication-services-practical-guide) | Azure Communication Services 实操指南 |
| [azure-container-apps-practical-guide](https://github.com/yeongseon/azure-container-apps-practical-guide) | Azure Container Apps 实操指南 |
| [azure-kubernetes-service-practical-guide](https://github.com/yeongseon/azure-kubernetes-service-practical-guide) | Azure Kubernetes Service (AKS) 实操指南 |
| [azure-architecture-practical-guide](https://github.com/yeongseon/azure-architecture-practical-guide) | Azure Architecture 实操指南 |
| [azure-monitoring-practical-guide](https://github.com/yeongseon/azure-monitoring-practical-guide) | Azure Monitoring 实操指南 |

## 免责声明 (Disclaimer)

这是一个独立的社区项目。与 Microsoft 无关，也不受其认可。Azure 是 Microsoft Corporation 的商标。

## 许可证

[MIT](LICENSE)
