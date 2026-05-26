---
name: my-pivot
description: my-* 워크플로우 진행 중 다른 작업으로 전환합니다. 현재 step을 중단하고 새 작업을 완료한 후 복귀를 안내합니다.
disable-model-invocation: true
argument-hint: [새 작업 설명]
allowed-tools: Agent Bash(*) Read(*) Edit(*) Write(*) AskUserQuestion
---

진행 중인 my-* 워크플로우를 중단하고 $ARGUMENTS 작업으로 전환합니다.

## 1단계: 전환 선언

이 한 줄을 먼저 출력합니다:

> 현재 워크플로우를 중단하고 새 작업으로 전환합니다: [새 작업 한 줄 요약]

## 2단계: 작업 범위 확인

$ARGUMENTS가 없거나 의도가 불분명하면 `AskUserQuestion`으로 1가지만 확인합니다.
작업이 명확하면 바로 3단계로 진행합니다.

## 3단계: 새 작업 수행

$ARGUMENTS에 설명된 작업을 수행합니다.

- 코드 수정이 필요하면 Read → Edit으로 직접 처리합니다
- 분석이 필요하거나 범위가 넓으면 Agent tool에 위임합니다
- 변경 후 타입 오류나 빌드 오류가 없는지 확인합니다

## 4단계: 완료 후 복귀 안내

작업 완료 후 반드시 아래 형식으로 안내합니다:

---
새 작업 완료: [완료된 작업 한 줄 요약]

이전 워크플로우 복귀: 중단된 step부터 다시 진행하려면 "이전 step 이어서 진행해줘"라고 입력하세요.
---
