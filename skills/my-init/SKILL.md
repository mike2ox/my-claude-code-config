---
name: my-init
description: 프로젝트 CLAUDE.md에 표준 작업 플로우 섹션을 추가하거나 최신 버전으로 교체합니다. 새 프로젝트 시작 시 또는 워크플로우 업데이트 시 사용하세요.
disable-model-invocation: true
argument-hint: [update]
allowed-tools: Read(*) Edit(*) Bash(ls *) Bash(test *)
---

현재 프로젝트의 CLAUDE.md에 표준 작업 플로우 섹션을 추가하거나 업데이트합니다.

## 모드 판별

$ARGUMENTS가 `update`이면: 기존 `## 표준 작업 플로우` 섹션을 최신 버전으로 교체합니다.
그 외(기본값): 섹션이 이미 있으면 "이미 설정되어 있습니다. 업데이트하려면 `/my-init update`를 실행하세요."라고 알리고 중단합니다.

## 순서

1. CLAUDE.md 파일이 있는지 확인
   - 없으면 사용자에게 알리고 중단 (CLAUDE.md 생성은 `/init` 커맨드로 따로 진행)

2. **기본 모드**: `## 표준 작업 플로우` 섹션이 없으면 파일 맨 끝에 추가합니다.

3. **update 모드**: 아래 두 파일을 순서대로 업데이트합니다.

### CLAUDE.md 업데이트

`## 표준 작업 플로우` 섹션 전체(다음 `##` 섹션 직전까지)를 아래 최신 내용으로 교체합니다.

```markdown

## 표준 작업 플로우

개발 작업은 아래 순서로 진행합니다. 각 커맨드는 `/my-<name>` 형식입니다.

| 단계 | 커맨드 | 설명 |
|------|--------|------|
| 1. 기획 | `/my-plan [기능명]` | 기능 아이디어와 설계 방향 정리 (plan 모드) → docs/plan/ 저장 |
| 2. 작업 분해 | `/my-split` | plan → 주니어 친화적 step별 작업 분해 (기본: step별 확인) |
| 3. 커밋 | `/my-commit` | step 완료마다 attribution 없이 커밋 |
| 4. 완료 검사 | `/my-check` | 타입 체크 후 최적화 기회 검토 |
| 5. PR 생성 | `/my-pr [full\|auto]` | 브랜치 변경 분석 후 PR 제목 후보 + body 생성. `full`/`auto` 파라미터 시 GitHub draft PR 자동 생성 + assignee 설정 |
| 6. 리뷰 반영 | `/my-review [피드백]` | 코드 리뷰 피드백 분류 및 적용 → docs/review/ 저장 |
| 7. 개선 분해 | `/my-iterate` | 리뷰 피드백 기반 개선 작업을 step별로 분해 |
| 8. 회고 | `/my-retro` | 작업 회고 문서 생성 (피드백 이력 + 코드 변화 포함) |
```

### README.md 업데이트

README.md 파일이 있고 `## 커맨드 목록` 섹션이 존재하면, 해당 섹션 전체(다음 `##` 섹션 직전까지)를 아래 최신 내용으로 교체합니다. README.md가 없거나 해당 섹션이 없으면 이 단계를 건너뜁니다.

```markdown
## 커맨드 목록

| 커맨드 | 설명 |
|--------|------|
| `/my-init [update]` | 현재 프로젝트 CLAUDE.md에 표준 워크플로우 섹션 추가. `update` 인자 시 CLAUDE.md와 README.md를 최신 버전으로 교체 |
| `/my-plan [기능명]` | 기능 아이디어와 설계 방향 정리 (plan 모드) → `docs/plan/` 저장 |
| `/my-split [auto]` | plan → 주니어 친화적 step별 작업 분해. 기본값은 step 완료마다 사용자 확인 대기, `auto` 인자 시 자동 진행 |
| `/my-commit` | Claude attribution 없는 커밋 작성 |
| `/my-check` | `npx tsc` 타입 체크 후 최적화 기회 검토 (분석은 서브에이전트 위임) |
| `/my-pr [full\|auto]` | 브랜치 변경 분석 후 PR 제목 후보 + body 생성. `full`/`auto` 파라미터 시 GitHub draft PR 자동 생성 + assignee 설정 |
| `/my-review [피드백]` | 코드 리뷰 피드백 분류 및 적용 (분류 분석은 서브에이전트 위임) → `docs/review/` 저장 |
| `/my-iterate [auto]` | 리뷰 피드백 기반 개선 작업을 step별로 분해. my-review 이후 사용 |
| `/my-retro` | 작업 회고 문서 생성 — 피드백 이력·코드 변화 포함 (`docs/retro/`, 전체 서브에이전트 위임) |
| `/my-status` | 현재 워크플로우 위치 파악 — 브랜치·문서 현황·미커밋 변경사항·다음 권장 단계 |
| `/my-pivot [작업 설명]` | 진행 중인 워크플로우를 중단하고 다른 작업으로 전환 후 복귀 안내 |
| `/my-disk` | 맥 디스크 여유 공간 확인 및 안전한 항목 정리 |
```

작업 완료 후 업데이트된 파일 목록과 각 파일에서 교체된 섹션을 알립니다.
