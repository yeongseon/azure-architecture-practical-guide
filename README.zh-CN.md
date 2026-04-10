# Azure Architecture Practical Guide

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [简体中文](README.zh-CN.md)

这是一个用于设计、评审和运营 Azure 架构的综合指南，涵盖基础架构决策、Well-Architected 权衡、工作负载蓝图以及架构评审方法。

## 主要内容

| 章节 | 描述 |
|---------|-------------|
| [从这里开始 (Start Here)](https://yeongseon.github.io/azure-architecture-practical-guide/) | 概述、学习路径、仓库地图以及如何使用本指南 |
| [平台 (Platform)](https://yeongseon.github.io/azure-architecture-practical-guide/platform/) | 包括登录区域、身份、网络、计算、数据与弹性的 Azure 架构基础 |
| [Well-Architected Framework](https://yeongseon.github.io/azure-architecture-practical-guide/waf/) | 成本、安全、可靠性、性能和运营卓越指导 |
| [架构模式 (Architecture Patterns)](https://yeongseon.github.io/azure-architecture-practical-guide/patterns/) | 拆分、集成、数据、弹性、网络、安全和部署模式 |
| [工作负载指南 (Workload Guides)](https://yeongseon.github.io/azure-architecture-practical-guide/workload-guides/) | 面向公共 Web、内部应用、集成、无服务器、微服务、数据和 AI 的实践蓝图 |
| [运营 (Operations)](https://yeongseon.github.io/azure-architecture-practical-guide/operations/) | ADR、IaC、治理护栏、可观测性、FinOps 和业务连续性 |
| [架构评审 (Architecture Reviews)](https://yeongseon.github.io/azure-architecture-practical-guide/architecture-reviews/) | 决策树、证据图、前 60 分钟评审、反模式和迁移实战手册 |
| [设计实验室 (Design Labs)](https://yeongseon.github.io/azure-architecture-practical-guide/design-labs/) | 面向常见 Azure 工作负载场景的设计练习 |
| [参考 (Reference)](https://yeongseon.github.io/azure-architecture-practical-guide/reference/) | 决策矩阵、服务选型速查表、映射、术语表和验证状态 |

## 快速入门

```bash
# 克隆仓库
git clone https://github.com/yeongseon/azure-architecture-practical-guide.git

# 安装 MkDocs 依赖
pip install mkdocs-material mkdocs-minify-plugin

# 启动本地文档服务器
mkdocs serve
```

访问 `http://127.0.0.1:8000` 在本地浏览文档。

## 参考架构

参考架构和基线资产围绕可复用的基础设施与文档模式组织：

- `infra/bicep/` — 用于架构基线和共享服务的 Bicep 模板
- `docs/workload-guides/` — 按工作负载划分的架构蓝图
- `docs/patterns/` — 可复用的决策与实现模式

## 贡献

欢迎贡献。请确保：
- 所有 CLI 示例使用长标记（使用 `--resource-group` 而不是 `-g`）
- 在适用时为所有文档添加 Mermaid 图表
- 所有内容参考 Microsoft Learn 并附带源 URL
- CLI 输出示例中不含个人身份信息 (PII)

## 相关项目

| 仓库 | 描述 |
|---|---|
| [azure-architecture-practical-guide](https://github.com/yeongseon/azure-architecture-practical-guide) | Azure Architecture 实操指南 |
| [azure-virtual-machine-practical-guide](https://github.com/yeongseon/azure-virtual-machine-practical-guide) | Azure Virtual Machines 实操指南 |
| [azure-networking-practical-guide](https://github.com/yeongseon/azure-networking-practical-guide) | Azure Networking 实操指南 |
| [azure-storage-practical-guide](https://github.com/yeongseon/azure-storage-practical-guide) | Azure Storage 实操指南 |
| [azure-functions-practical-guide](https://github.com/yeongseon/azure-functions-practical-guide) | Azure Functions 实操指南 |
| [azure-container-apps-practical-guide](https://github.com/yeongseon/azure-container-apps-practical-guide) | Azure Container Apps 实操指南 |
| [azure-aks-practical-guide](https://github.com/yeongseon/azure-aks-practical-guide) | Azure Kubernetes Service (AKS) 实操指南 |
| [azure-monitoring-practical-guide](https://github.com/yeongseon/azure-monitoring-practical-guide) | Azure Monitoring 实操指南 |

## 免责声明 (Disclaimer)

这是一个独立的社区项目。与 Microsoft 无关，也不受其认可。Azure 是 Microsoft Corporation 的商标。

## 许可证

[MIT](LICENSE)
