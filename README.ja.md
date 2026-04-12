# Azure Architecture Practical Guide

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [简体中文](README.zh-CN.md)

Azure アーキテクチャを設計、レビュー、運用するための包括的なガイドです。基礎的な設計判断から Well-Architected のトレードオフ、ワークロードのブループリント、アーキテクチャレビューまでを扱います。

## 主な内容

| セクション | 説明 |
|---------|-------------|
| [ここから開始 (Start Here)](https://yeongseon.github.io/azure-architecture-practical-guide/) | 概要、学習パス、リポジトリマップ、ガイドの使い方 |
| [プラットフォーム (Platform)](https://yeongseon.github.io/azure-architecture-practical-guide/platform/) | ランディングゾーン、ID、ネットワーク、コンピュート、データ、回復性を含む Azure アーキテクチャ基盤 |
| [Well-Architected Framework](https://yeongseon.github.io/azure-architecture-practical-guide/waf/) | コスト、セキュリティ、信頼性、性能、運用の優秀性に関するガイダンス |
| [アーキテクチャパターン (Architecture Patterns)](https://yeongseon.github.io/azure-architecture-practical-guide/patterns/) | 分解、統合、データ、回復性、ネットワーク、セキュリティ、デプロイの実践パターン |
| [ワークロードガイド (Workload Guides)](https://yeongseon.github.io/azure-architecture-practical-guide/workload-guides/) | パブリック Web、内部アプリ、統合、サーバーレス、マイクロサービス、データ、AI のブループリント |
| [運用 (Operations)](https://yeongseon.github.io/azure-architecture-practical-guide/operations/) | ADR、IaC、ガバナンスガードレール、可観測性、FinOps、継続性 |
| [アーキテクチャレビュー (Architecture Reviews)](https://yeongseon.github.io/azure-architecture-practical-guide/architecture-reviews/) | 決定木、エビデンスマップ、最初の 60 分レビュー、アンチパターン、移行プレイブック |
| [デザインラボ (Design Labs)](https://yeongseon.github.io/azure-architecture-practical-guide/design-labs/) | 一般的な Azure ワークロードシナリオ向けの設計演習 |
| [リファレンス (Reference)](https://yeongseon.github.io/azure-architecture-practical-guide/reference/) | 判断マトリクス、サービス選定チートシート、マッピング、用語集、検証ステータス |

## クイックスタート

```bash
# リポジトリをクローン
git clone https://github.com/yeongseon/azure-architecture-practical-guide.git

# MkDocs の依存関係をインストール
pip install mkdocs-material mkdocs-minify-plugin

# ローカルドキュメントサーバーを起動
mkdocs serve
```

ローカルで `http://127.0.0.1:8000` にアクセスしてドキュメントを閲覧してください。

## リファレンスアーキテクチャ

再利用可能なインフラとドキュメントパターンを中心に、リファレンスアーキテクチャとベースライン資産を整理しています：

- `infra/bicep/` — アーキテクチャベースラインと共有サービス向け Bicep テンプレート
- `docs/workload-guides/` — ワークロード別アーキテクチャブループリント
- `docs/patterns/` — 再利用可能な意思決定パターンと実装パターン

## 貢献

貢献を歓迎します。以下の点を確認してください：
- すべての CLI の例で長いフラグを使用してください (`-g` ではなく `--resource-group`)
- 該当するドキュメントには Mermaid ダイアグラムを含めてください
- すべてのコンテンツは、ソース URL とともに Microsoft Learn を参照してください
- CLI 出力の例に個人情報 (PII) を含めないでください

## 関連プロジェクト

| リポジトリ | 説明 |
|---|---|
| [azure-virtual-machine-practical-guide](https://github.com/yeongseon/azure-virtual-machine-practical-guide) | Azure Virtual Machines 実務ガイド |
| [azure-networking-practical-guide](https://github.com/yeongseon/azure-networking-practical-guide) | Azure Networking 実務ガイド |
| [azure-storage-practical-guide](https://github.com/yeongseon/azure-storage-practical-guide) | Azure Storage 実務ガイド |
| [azure-functions-practical-guide](https://github.com/yeongseon/azure-functions-practical-guide) | Azure Functions 実務ガイド |
| [azure-container-apps-practical-guide](https://github.com/yeongseon/azure-container-apps-practical-guide) | Azure Container Apps 実務ガイド |
| [azure-kubernetes-service-practical-guide](https://github.com/yeongseon/azure-kubernetes-service-practical-guide) | Azure Kubernetes Service (AKS) 実務ガイド |
| [azure-monitoring-practical-guide](https://github.com/yeongseon/azure-monitoring-practical-guide) | Azure Monitoring 実務ガイド |

## 免責事項 (Disclaimer)

これは独立したコミュニティプロジェクトです。Microsoft との提携や承認を受けているものではありません。Azure は Microsoft Corporation の商標です。

## ライセンス

[MIT](LICENSE)
