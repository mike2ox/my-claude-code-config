---
name: my-check
description: 작업 완료 후 타입 체크를 실행하고 최적화 기회를 검토합니다.
disable-model-invocation: true
allowed-tools: Bash(npx tsc *) Bash(pnpm tsc *)
---

작업 완료 후 품질 검사를 실행합니다.

## 1단계: 타입 체크

```bash
npx tsc --noEmit
```

오류가 있으면 모두 수정한 후 2단계로 진행합니다.

## 2단계: 최적화 검토 (타입 오류가 없을 때만)

아래 항목에 대해 최적화할 부분이 있는지 검토하고, 항목별로 "적용할까요?"를 사용자에게 확인 후 작업합니다.

- **불필요한 re-render** — `useMemo`, `useCallback` 적용 가능한 곳
- **중복 코드** — 공통 로직 추출 가능한 패턴
- **GraphQL 쿼리** — 불필요한 필드 요청, fragment 재사용 기회
- **번들 크기** — dynamic import 적용 가능한 큰 컴포넌트
- **접근성** — aria 속성, 키보드 내비게이션 누락 여부
