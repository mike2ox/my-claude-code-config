---
name: my-check
description: 작업 완료 후 타입 체크를 실행하고 최적화 기회를 검토합니다.
disable-model-invocation: true
allowed-tools: Agent Bash(npx tsc *) Bash(pnpm tsc *) Read(*) Edit(*)
---

작업 완료 후 품질 검사를 두 단계로 실행합니다.

## 1단계: 타입 체크 (직접 실행)

```bash
npx tsc --noEmit
```

오류가 있으면 모두 수정한 후 2단계로 진행합니다.

## 2단계: 최적화 분석 (Agent 위임)

타입 오류가 없을 때만 실행합니다.

subagent_type을 code-reviewer로 지정하여 Agent tool을 호출하세요. 파라미터:
- description: "최적화 기회 분석"
- prompt: 아래 내용 전달

---
최근 변경된 코드를 분석하여 최적화 기회를 찾습니다.

git diff HEAD~1 또는 관련 파일을 읽어 최근 변경사항을 파악하세요.

아래 항목별로 최적화 가능 여부를 검토하고, 발견 시 파일 경로와 라인 번호를 포함한 구체적인 제안을 작성하세요:

1. **불필요한 re-render** — useMemo, useCallback 적용 가능한 곳
2. **중복 코드** — 공통 로직 추출 가능한 패턴
3. **GraphQL 쿼리** — 불필요한 필드 요청, fragment 재사용 기회
4. **번들 크기** — dynamic import 적용 가능한 큰 컴포넌트
5. **접근성** — aria 속성, 키보드 내비게이션 누락 여부

각 항목은 "발견 없음" 또는 구체적인 개선 제안으로 반환합니다. 코드 수정은 하지 않습니다.
---

에이전트 결과를 받은 후, 각 항목에 대해 "적용할까요?"를 사용자에게 확인하고 승인된 항목만 직접 수정합니다.
