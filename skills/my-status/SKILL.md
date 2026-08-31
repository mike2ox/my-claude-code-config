---
name: my-status
description: 현재 워크플로우 위치를 한눈에 파악합니다. 중단했던 작업을 재개할 때 사용하세요.
disable-model-invocation: true
allowed-tools: Bash(git branch *) Bash(git log *) Bash(git diff *) Bash(git status *) Bash(ls *) Bash(find *)
---

현재 브랜치의 워크플로우 상태를 수집하여 보고합니다.

## 정보 수집

아래 명령을 병렬로 실행합니다:

```bash
git branch --show-current
git log main..HEAD --oneline
git log -1 --format="%h %s (%cr)"
git status --short
find docs/plan docs/review docs/retro -name "*.md" -o -name "*.html" 2>/dev/null | sort
```

## 출력 형식

아래 형식으로 출력합니다. 해당 항목이 없으면 "없음"으로 표시합니다.

---
**브랜치**: {현재 브랜치명}
**마지막 커밋**: {해시} {메시지} ({시간})

### 문서 현황
| 종류 | 파일 |
|------|------|
| plan | {파일명 or 없음} |
| review | {파일명 or 없음} |
| retro | {파일명 or 없음} |

### 미커밋 변경사항
{git status --short 결과. 없으면 "없음 (clean)"}

### 워크플로우 위치 추정

docs/ 파일 존재 여부와 미커밋 상태를 바탕으로 현재 단계를 추정합니다:

| 조건 | 추정 단계 |
|------|---------|
| plan 없음 | `/my-plan` 전 — 요구가 모호하면 `/my-interview` 먼저 |
| plan 있음, review 없음, 미커밋 있음 | my-split 구현 중 |
| plan 있음, review 없음, 미커밋 없음 | 구현 완료 → `/my-check` 또는 `/my-pr` |
| review 있음, retro 없음 | my-review 완료 → `/my-iterate` 또는 `/my-retro` |
| retro 있음 | 작업 완료 |

타입 체크·테스트가 실패하는 상태라면 단계와 무관하게 `/my-debug`를 먼저 권합니다.

**다음 권장 단계**: {추정 결과에 따른 권장 커맨드}
---
