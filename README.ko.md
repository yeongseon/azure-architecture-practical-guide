# Azure Architecture Practical Guide

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [简体中文](README.zh-CN.md)

Azure 아키텍처를 설계, 검토, 운영하기 위한 포괄적인 가이드입니다. 기초 설계 결정부터 Well-Architected 트레이드오프, 워크로드 청사진, 아키텍처 리뷰까지 다룹니다.

## 주요 내용

| 섹션 | 설명 |
|---------|-------------|
| [시작하기 (Start Here)](https://yeongseon.github.io/azure-architecture-practical-guide/) | 개요, 학습 경로, 저장소 맵, 가이드 활용 방법 |
| [플랫폼 (Platform)](https://yeongseon.github.io/azure-architecture-practical-guide/platform/) | 랜딩 존, ID, 네트워크, 컴퓨팅, 데이터, 복원력을 포함한 Azure 아키텍처 기초 |
| [Well-Architected Framework](https://yeongseon.github.io/azure-architecture-practical-guide/waf/) | 비용, 보안, 안정성, 성능, 운영 우수성 가이드 |
| [아키텍처 패턴 (Architecture Patterns)](https://yeongseon.github.io/azure-architecture-practical-guide/patterns/) | 분해, 통합, 데이터, 복원력, 네트워킹, 보안, 배포 패턴 |
| [워크로드 가이드 (Workload Guides)](https://yeongseon.github.io/azure-architecture-practical-guide/workload-guides/) | 퍼블릭 웹, 내부 앱, 통합, 서버리스, 마이크로서비스, 데이터, AI 워크로드 청사진 |
| [운영 (Operations)](https://yeongseon.github.io/azure-architecture-practical-guide/operations/) | ADR, IaC, 거버넌스 가드레일, 관측성, FinOps, 비즈니스 연속성 |
| [아키텍처 리뷰 (Architecture Reviews)](https://yeongseon.github.io/azure-architecture-practical-guide/architecture-reviews/) | 의사결정 트리, 증거 맵, 초기 60분 리뷰, 안티패턴, 마이그레이션 플레이북 |
| [디자인 랩 (Design Labs)](https://yeongseon.github.io/azure-architecture-practical-guide/design-labs/) | 일반적인 Azure 워크로드 시나리오를 위한 설계 실습 |
| [참조 (Reference)](https://yeongseon.github.io/azure-architecture-practical-guide/reference/) | 의사결정 매트릭스, 서비스 선택 치트시트, 매핑, 용어집, 검증 상태 |

## 빠른 시작

```bash
# 저장소 복제
git clone https://github.com/yeongseon/azure-architecture-practical-guide.git

# MkDocs 의존성 설치
pip install mkdocs-material mkdocs-minify-plugin

# 로컬 문서 서버 시작
mkdocs serve
```

로컬에서 `http://127.0.0.1:8000`에 접속하여 문서를 확인하세요.

## 참조 아키텍처

재사용 가능한 인프라와 문서 패턴을 중심으로 참조 아키텍처와 기준 자산을 구성합니다:

- `infra/bicep/` — 아키텍처 기준선과 공유 서비스를 위한 Bicep 템플릿
- `docs/workload-guides/` — 워크로드별 아키텍처 청사진
- `docs/patterns/` — 재사용 가능한 의사결정 및 구현 패턴

## 기여하기

기여는 언제나 환영합니다. 다음 사항을 준수해 주세요:
- 모든 CLI 예제에는 긴 플래그를 사용하세요 (`-g` 대신 `--resource-group`)
- 해당되는 문서에는 Mermaid 다이어그램을 포함하세요
- 모든 콘텐츠는 출처 URL과 함께 Microsoft Learn을 참조해야 합니다
- CLI 출력 예제에 개인 식별 정보(PII)를 포함하지 마세요

## 관련 프로젝트

| 저장소 | 설명 |
|---|---|
| [azure-architecture-practical-guide](https://github.com/yeongseon/azure-architecture-practical-guide) | Azure Architecture 실무 가이드 |
| [azure-virtual-machine-practical-guide](https://github.com/yeongseon/azure-virtual-machine-practical-guide) | Azure Virtual Machines 실무 가이드 |
| [azure-networking-practical-guide](https://github.com/yeongseon/azure-networking-practical-guide) | Azure Networking 실무 가이드 |
| [azure-storage-practical-guide](https://github.com/yeongseon/azure-storage-practical-guide) | Azure Storage 실무 가이드 |
| [azure-functions-practical-guide](https://github.com/yeongseon/azure-functions-practical-guide) | Azure Functions 실무 가이드 |
| [azure-container-apps-practical-guide](https://github.com/yeongseon/azure-container-apps-practical-guide) | Azure Container Apps 실무 가이드 |
| [azure-kubernetes-service-practical-guide](https://github.com/yeongseon/azure-kubernetes-service-practical-guide) | Azure Kubernetes Service (AKS) 실무 가이드 |
| [azure-monitoring-practical-guide](https://github.com/yeongseon/azure-monitoring-practical-guide) | Azure Monitoring 실무 가이드 |

## 면책 조항 (Disclaimer)

이 프로젝트는 독립적인 커뮤니티 프로젝트입니다. Microsoft와 제휴하거나 보증을 받지 않았습니다. Azure는 Microsoft Corporation의 상표입니다.

## 라이선스

[MIT](LICENSE)
