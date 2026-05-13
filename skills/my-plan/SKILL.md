---
name: my-plan
description: 새 기능의 아이디어와 설계 방향을 plan 모드로 정리합니다. 기능 기획을 시작할 때 사용하세요.
disable-model-invocation: true
argument-hint: [기능 설명]
allowed-tools: Write(*) Bash(mkdir *)
---

$ARGUMENTS 기능을 계획합니다.

plan 모드를 사용하여 아래 구조로 설계 방향을 정리하고, 승인 후 구현을 시작합니다.

## 정리 항목

1. **기능 개요** — 무엇을 만드는지 1-2문장 요약
2. **사용자 스토리** — 누가, 무엇을, 왜 필요한지
3. **기술적 접근 방향**
   - 관련 파일 및 컴포넌트 구조
   - 필요한 API / GraphQL query·mutation
   - UI 컴포넌트 설계
   - 상태 관리 방식
4. **고려사항** — 엣지 케이스, 성능, 접근성
5. **의존성** — 먼저 완료되어야 하는 작업

현재 코드베이스의 기존 패턴을 분석하여 일관성을 유지하는 방향으로 제안하세요.

## plan 승인 후

승인된 plan 내용을 `docs/plan/YYYY-MM-DD-{기능명}.md` 파일로 저장합니다.
`docs/plan/` 디렉토리가 없으면 먼저 생성합니다.
저장 완료 후 `/my-split`으로 작업을 분해할 수 있음을 알립니다.
