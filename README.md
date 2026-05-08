# my-claude-code-config

개인 Claude Code 워크플로우 설정 모음입니다.

## 설치

```bash
git clone <repo-url> ~/Project/my-claude-code-config
bash ~/Project/my-claude-code-config/install.sh
```

`~/.claude/skills/` 에 symlink를 생성합니다. 이후 모든 프로젝트에서 `/my-*` 커맨드를 사용할 수 있습니다.

## 커맨드 목록

| 커맨드 | 설명 |
|--------|------|
| `/my-init` | 현재 프로젝트 CLAUDE.md에 표준 워크플로우 섹션 추가 |
| `/my-plan [기능명]` | 기능 아이디어와 설계 방향 정리 (plan 모드) |
| `/my-split [auto]` | plan → 주니어 친화적 step별 작업 분해. 기본값은 step 완료마다 사용자 확인 대기, `auto` 인자 시 자동 진행 |
| `/my-commit` | Claude attribution 없는 커밋 작성 |
| `/my-check` | `npx tsc` 타입 체크 후 최적화 기회 검토 (분석은 서브에이전트 위임) |
| `/my-pr` | 브랜치 변경 분석 후 PR 제목 추천 |
| `/my-review [피드백]` | 코드 리뷰 피드백 분류 및 적용 (분류 분석은 서브에이전트 위임) |
| `/my-retro` | 작업 회고 문서 생성 (`docs/retro/`, 전체 서브에이전트 위임) |

## 표준 작업 플로우

```
/my-plan → /my-split → (구현 + /my-commit 반복) → /my-check → /my-pr → /my-review → /my-retro
```

새 프로젝트 시작 시 `/my-init`을 한 번 실행하면 해당 프로젝트의 CLAUDE.md에 위 플로우가 기록됩니다.

## 설계 원칙

탐색·분석이 무거운 skill은 서브에이전트에 위임하여 메인 세션 context를 절약합니다.

| 패턴 | 적용 skill |
|------|-----------|
| 전체 위임 — agent가 모든 작업 수행, 결과만 반환 | `my-retro` |
| 부분 위임 — agent가 분석, 메인 세션이 수정 적용 | `my-check`, `my-review` |
| 메인 세션 직접 실행 — 작업이 가볍거나 plan mode 필요 | `my-init`, `my-plan`, `my-split`, `my-commit`, `my-pr` |

## 구조

```
skills/
├── my-init/SKILL.md
├── my-plan/SKILL.md
├── my-split/SKILL.md
├── my-commit/SKILL.md
├── my-check/SKILL.md
├── my-pr/SKILL.md
├── my-review/SKILL.md
└── my-retro/SKILL.md
```
