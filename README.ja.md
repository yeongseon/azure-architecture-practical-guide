# Azure Architecture Practical Guide

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [简体中文](README.zh-CN.md)

📘 ドキュメントサイト: <https://yeongseon.github.io/azure-architecture-practical-guide/>

[![Docs](https://github.com/yeongseon/azure-architecture-practical-guide/actions/workflows/docs.yml/badge.svg)](https://github.com/yeongseon/azure-architecture-practical-guide/actions/workflows/docs.yml)
[![CI](https://github.com/yeongseon/azure-architecture-practical-guide/actions/workflows/quality-gates.yml/badge.svg)](https://github.com/yeongseon/azure-architecture-practical-guide/actions/workflows/quality-gates.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

基礎的な設計判断から Well-Architected のトレードオフ、ワークロードのブループリント、アーキテクチャレビューまで — Azure アーキテクチャを設計、レビュー、運用するための包括的なガイドです。

## 主な内容

| セクション | 説明 | 状態 |
|---------|-------------|--------|
| [ここから開始](https://yeongseon.github.io/azure-architecture-practical-guide/) | 概要、学習パス、リポジトリマップ、ガイドの使い方 | Comprehensive |
| [プラットフォーム](https://yeongseon.github.io/azure-architecture-practical-guide/platform/) | ランディングゾーン、ID、ネットワーク、コンピュート、データ、回復性を含む Azure アーキテクチャ基盤 | Comprehensive |
| [Well-Architected Framework](https://yeongseon.github.io/azure-architecture-practical-guide/waf/) | 信頼性、セキュリティ、コストの最適化、運用の優秀性、パフォーマンス効率のガイダンス | Comprehensive |
| [アーキテクチャパターン](https://yeongseon.github.io/azure-architecture-practical-guide/patterns/) | 実証済みの分解、統合、データ、回復性、ネットワーク、セキュリティ、デプロイパターン | Comprehensive |
| [ワークロードガイド](https://yeongseon.github.io/azure-architecture-practical-guide/workload-guides/) | パブリック Web、内部アプリ、統合、サーバーレス、マイクロサービス、データ、AI ワークロード向けの実践的なブループリント | Comprehensive |
| [運用](https://yeongseon.github.io/azure-architecture-practical-guide/operations/) | ADR、IaC、ガバナンスガードレール、可観測性、FinOps、継続性の実践 | Comprehensive |
| [アーキテクチャレビュー](https://yeongseon.github.io/azure-architecture-practical-guide/architecture-reviews/) | 決定木、エビデンスマップ、最初の 60 分レビュー、アンチパターン、移行プレイブック | In progress |
| [デザインラボ](https://yeongseon.github.io/azure-architecture-practical-guide/design-labs/) | 一般的な Azure ワークロードシナリオ向けのガイド付き設計演習 | Published |
| [リファレンス](https://yeongseon.github.io/azure-architecture-practical-guide/reference/) | 判断マトリクス、サービス選定チートシート、マッピング、用語集、検証ステータス | Comprehensive |

**状態の凡例**: **Lab-validated** = 包括的な内容 + 再現可能なラボによるガイドの検証済み · **Comprehensive** = セクション全体完了、MSLearn 検証済み、本番環境対応 · **Published** = コアコンテンツ公開済み、拡張中 · **In progress** = 一部コンテンツあり、活発に開発中 · **Planned** = プレースホルダー、コンテンツ未着手

## クイックスタート

```bash
git clone https://github.com/yeongseon/azure-architecture-practical-guide.git
cd azure-architecture-practical-guide

python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements-docs.txt

mkdocs serve
```

ローカルで `http://127.0.0.1:8000` にアクセスしてドキュメントを閲覧してください。

## リファレンスアーキテクチャ

リファレンスアーキテクチャとベースライン資産は、再利用可能なインフラストラクチャとドキュメントパターンを中心に構成されています：

- `infra/bicep/` — アーキテクチャベースラインと共有サービス向け Bicep テンプレート
- `docs/workload-guides/` — ワークロード別アーキテクチャブループリント
- `docs/patterns/` — 再利用可能な意思決定パターンと実装パターン

## 貢献

貢献を歓迎します！以下の点については [貢献ガイド](https://yeongseon.github.io/azure-architecture-practical-guide/contributing/) を参照してください：

- リポジトリ構造とコンテンツ構成
- ドキュメントテンプレートと執筆基準
- CLI コマンドスタイルと PII ルール
- ローカル開発環境のセットアップとビルド検証
- プルリクエストプロセス

## 関連プロジェクト

| リポジトリ | 説明 |
|---|---|
| [azure-virtual-machine-practical-guide](https://github.com/yeongseon/azure-virtual-machine-practical-guide) | Azure Virtual Machines 実務ガイド |
| [azure-networking-practical-guide](https://github.com/yeongseon/azure-networking-practical-guide) | Azure Networking 実務ガイド |
| [azure-storage-practical-guide](https://github.com/yeongseon/azure-storage-practical-guide) | Azure Storage 実務ガイド |
| [azure-app-service-practical-guide](https://github.com/yeongseon/azure-app-service-practical-guide) | Azure App Service 実務ガイド |
| [azure-functions-practical-guide](https://github.com/yeongseon/azure-functions-practical-guide) | Azure Functions 実務ガイド |
| [azure-communication-services-practical-guide](https://github.com/yeongseon/azure-communication-services-practical-guide) | Azure Communication Services 実務ガイド |
| [azure-container-apps-practical-guide](https://github.com/yeongseon/azure-container-apps-practical-guide) | Azure Container Apps 実무ガイド |
| [azure-kubernetes-service-practical-guide](https://github.com/yeongseon/azure-kubernetes-service-practical-guide) | Azure Kubernetes Service (AKS) 実務ガイド |
| [azure-architecture-practical-guide](https://github.com/yeongseon/azure-architecture-practical-guide) | Azure Architecture 実務ガイド |
| [azure-monitoring-practical-guide](https://github.com/yeongseon/azure-monitoring-practical-guide) | Azure Monitoring 実務ガイド |

## 免責事項 (Disclaimer)

これは独立したコミュニティプロジェクトです。Microsoft との提携や承認を受けているものではありません。Azure は Microsoft Corporation の商標です。

## ライセンス

[MIT](LICENSE)
