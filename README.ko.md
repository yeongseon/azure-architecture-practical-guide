# Azure Architecture Practical Guide

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [简体中文](README.zh-CN.md)

📘 문서 사이트: <https://yeongseon.github.io/azure-architecture-practical-guide/>

[![Docs](https://github.com/yeongseon/azure-architecture-practical-guide/actions/workflows/docs.yml/badge.svg)](https://github.com/yeongseon/azure-architecture-practical-guide/actions/workflows/docs.yml)
[![CI](https://github.com/yeongseon/azure-architecture-practical-guide/actions/workflows/quality-gates.yml/badge.svg)](https://github.com/yeongseon/azure-architecture-practical-guide/actions/workflows/quality-gates.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

기초 설계 결정부터 Well-Architected 트레이드오프, 워크로드 청사진, 아키텍처 리뷰까지 — Azure 아키텍처를 설계, 검토, 운영하기 위한 포괄적인 가이드입니다.

## 주요 내용

| 섹션 | 설명 | 상태 |
|---------|-------------|--------|
| [시작하기](https://yeongseon.github.io/azure-architecture-practical-guide/) | 개요, 학습 경로, 저장소 맵, 가이드 활용 방법 | Comprehensive |
| [플랫폼](https://yeongseon.github.io/azure-architecture-practical-guide/platform/) | 랜딩 존, ID, 네트워크, 컴퓨팅, 데이터, 복원력을 포함한 Azure 아키텍처 기초 | Comprehensive |
| [Well-Architected Framework](https://yeongseon.github.io/azure-architecture-practical-guide/waf/) | 안정성, 보안, 비용 최적화, 운영 우수성, 성능 효율성 가이드 | Comprehensive |
| [아키텍처 패턴](https://yeongseon.github.io/azure-architecture-practical-guide/patterns/) | 검증된 분해, 통합, 데이터, 복원력, 네트워킹, 보안, 배포 패턴 | Comprehensive |
| [워크로드 가이드](https://yeongseon.github.io/azure-architecture-practical-guide/workload-guides/) | 퍼블릭 웹, 내부 앱, 통합, 서버리스, 마이크로서비스, 데이터, AI 워크로드를 위한 실무 청사진 | Comprehensive |
| [운영](https://yeongseon.github.io/azure-architecture-practical-guide/operations/) | ADR, IaC, 거버넌스 가드레일, 관측성, FinOps, 비즈니스 연속성 실무 | Comprehensive |
| [아키텍처 리뷰](https://yeongseon.github.io/azure-architecture-practical-guide/architecture-reviews/) | 의사결정 트리, 증거 맵, 초기 60분 리뷰, 안티패턴, 마이그레이션 플레이북 | In progress |
| [디자인 랩](https://yeongseon.github.io/azure-architecture-practical-guide/design-labs/) | 일반적인 Azure 워크로드 시나리오를 위한 가이드형 설계 실습 | Published |
| [참조](https://yeongseon.github.io/azure-architecture-practical-guide/reference/) | 의사결정 매트릭스, 서비스 선택 치트시트, 매핑, 용어집, 검증 상태 | Comprehensive |

**상태 범례**: **Lab-validated** = 포괄적인 내용 + 재현 가능한 랩으로 가이드 검증 · **Comprehensive** = 전체 섹션 완료, MSLearn 검증 완료, 생산 환경 적용 가능 · **Published** = 핵심 콘텐츠 게시됨, 확장 중 · **In progress** = 일부 콘텐츠 포함, 활발히 개발 중 · **Planned** = 자리 표시자, 콘텐츠 시작 전

## 빠른 시작

```bash
git clone https://github.com/yeongseon/azure-architecture-practical-guide.git
cd azure-architecture-practical-guide

python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements-docs.txt

mkdocs serve
```

로컬에서 `http://127.0.0.1:8000`에 접속하여 문서를 확인하세요.

## 참조 아키텍처

참조 아키텍처와 기준 자산은 재사용 가능한 인프라 및 문서 패턴을 중심으로 구성됩니다:

- `infra/bicep/` — 아키텍처 기준선과 공유 서비스를 위한 Bicep 템플릿
- `docs/workload-guides/` — 워크로드별 아키텍처 청사진
- `docs/patterns/` — 재사용 가능한 의사결정 및 구현 패턴

## 기여하기

기여는 언제나 환영합니다! 다음 사항은 [기여 가이드](https://yeongseon.github.io/azure-architecture-practical-guide/contributing/)를 참조하세요:

- 저장소 구조 및 콘텐츠 구성
- 문서 템플릿 및 작성 표준
- CLI 명령 스타일 및 PII 규칙
- 로컬 개발 환경 설정 및 빌드 검증
- 풀 리퀘스트 프로세스

## 관련 프로젝트

| 저장소 | 설명 |
|---|---|
| [azure-virtual-machine-practical-guide](https://github.com/yeongseon/azure-virtual-machine-practical-guide) | Azure Virtual Machines 실무 가이드 |
| [azure-networking-practical-guide](https://github.com/yeongseon/azure-networking-practical-guide) | Azure Networking 실무 가이드 |
| [azure-storage-practical-guide](https://github.com/yeongseon/azure-storage-practical-guide) | Azure Storage 실무 가이드 |
| [azure-app-service-practical-guide](https://github.com/yeongseon/azure-app-service-practical-guide) | Azure App Service 실무 가이드 |
| [azure-functions-practical-guide](https://github.com/yeongseon/azure-functions-practical-guide) | Azure Functions 실무 가이드 |
| [azure-communication-services-practical-guide](https://github.com/yeongseon/azure-communication-services-practical-guide) | Azure Communication Services 실무 가이드 |
| [azure-container-apps-practical-guide](https://github.com/yeongseon/azure-container-apps-practical-guide) | Azure Container Apps 실무 가이드 |
| [azure-kubernetes-service-practical-guide](https://github.com/yeongseon/azure-kubernetes-service-practical-guide) | Azure Kubernetes Service (AKS) 실무 가이드 |
| [azure-architecture-practical-guide](https://github.com/yeongseon/azure-architecture-practical-guide) | Azure Architecture 실무 가이드 |
| [azure-monitoring-practical-guide](https://github.com/yeongseon/azure-monitoring-practical-guide) | Azure Monitoring 실무 가이드 |

## 면책 조항 (Disclaimer)

이 프로젝트는 독립적인 커뮤니티 프로젝트입니다. Microsoft와 제휴하거나 보증을 받지 않았습니다. Azure는 Microsoft Corporation의 상표입니다.

## 라이선스

[MIT](LICENSE)
