---
name: my-init
description: 프로젝트 CLAUDE.md에 표준 작업 플로우 섹션을 추가합니다. 새 프로젝트 시작 시 한 번 실행하세요.
disable-model-invocation: true
allowed-tools: Read(*) Edit(*) Bash(ls *) Bash(test *)
---

현재 프로젝트의 CLAUDE.md에 표준 작업 플로우 섹션을 추가합니다.

## 순서

1. CLAUDE.md 파일이 있는지 확인
   - 없으면 사용자에게 알리고 중단 (CLAUDE.md 생성은 `/init` 커맨드로 따로 진행)

2. CLAUDE.md에 이미 `## 표준 작업 플로우` 섹션이 있으면 "이미 설정되어 있습니다"라고 알리고 중단

3. 없으면 CLAUDE.md 파일 맨 끝에 아래 섹션을 추가

```markdown

## 표준 작업 플로우

개발 작업은 아래 순서로 진행합니다. 각 커맨드는 `/my-<name>` 형식입니다.

| 단계 | 커맨드 | 설명 |
|------|--------|------|
| 1. 기획 | `/my-plan [기능명]` | 기능 아이디어와 설계 방향 정리 (plan 모드) → docs/plan/ 저장 |
| 2. 작업 분해 | `/my-split` | plan → 주니어 친화적 step별 작업 분해 (기본: step별 확인) |
| 3. 커밋 | `/my-commit` | step 완료마다 attribution 없이 커밋 |
| 4. 완료 검사 | `/my-check` | 타입 체크 후 최적화 기회 검토 |
| 5. PR 제목 | `/my-pr` | 브랜치 변경 분석 후 PR 제목 추천 |
| 6. 리뷰 반영 | `/my-review [피드백]` | 코드 리뷰 피드백 분류 및 적용 → docs/review/ 저장 |
| 7. 개선 분해 | `/my-iterate` | 리뷰 피드백 기반 개선 작업을 step별로 분해 |
| 8. 회고 | `/my-retro` | 작업 회고 문서 생성 (피드백 이력 + 코드 변화 포함) |
```

추가 완료 후 몇 번째 줄에 삽입했는지 알려줍니다.
