# my-skillset — Agent Guide

## 프로젝트 개요

개인 Claude Code 워크플로우 스킬 모음. `skills/*/` 디렉토리를 `~/.claude/skills/` 에 symlink로 연결해 전역 커맨드로 사용할 수 있게 합니다.

## 세팅 요청 처리

사용자가 다음과 같은 요청을 하면 **아래 설치 절차를 직접 실행**하세요:

- "이 프로젝트 세팅해줘"
- "README.md, CLAUDE.md 파악해서 설치해줘"
- "처음 설치하는데 도와줘"
- 그 외 초기 설정 관련 요청

### 설치 절차

**Step 1** — skills 디렉토리 확보:

```bash
mkdir -p ~/.claude/skills
```

**Step 2** — 이 저장소의 절대 경로를 기준으로 각 skill에 symlink 생성:

```bash
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_TARGET="$HOME/.claude/skills"

for skill_dir in "$REPO_DIR/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  target="$SKILLS_TARGET/$skill_name"

  if [ -L "$target" ]; then
    echo "  ↺ $skill_name (symlink already exists, skipping)"
  elif [ -d "$target" ]; then
    echo "  ⚠ $skill_name (directory exists — remove manually to replace)"
  else
    ln -s "$skill_dir" "$target"
    echo "  ✓ $skill_name"
  fi
done
```

**Step 3** — 알림음 훅 설치 (`~/.claude/settings.json`의 `hooks`에 병합):

```bash
bash "$REPO_DIR/settings/install-sounds.sh"
```

settings.json을 통째로 덮지 말고 반드시 이 스크립트를 쓰세요. 파일에는 `model`·`statusLine` 등
사용자의 다른 설정이 들어 있습니다. 스크립트는 백업을 남기고 재실행해도 중복되지 않습니다.

**Step 4** — 완료 후 사용자에게 Claude Code 재시작을 안내하세요.

**Step 5** — 설치 확인:

```bash
ls ~/.claude/skills/ | grep -E "^(my-|goal-maker$)"
jq '.hooks | keys' ~/.claude/settings.json   # Stop, Notification, StopFailure 포함 확인
```

세부 사항은 [`INSTALL.md`](INSTALL.md)를 참조하세요.

## 사용 가능한 커맨드

| 커맨드 | 설명 |
|--------|------|
| `/goal-maker [목표 또는 초안]` | Claude Code/Codex 내장 `/goal` 대상을 자동 판별해 목표글 작성 또는 기존 글의 적합성 판정 |
| `/my-init [update]` | 현재 프로젝트 CLAUDE.md에 표준 워크플로우 섹션 추가 |
| `/my-interview [만들 것]` | 요청이 모호할 때 한 질문씩 던져 의도·성공 기준·제약 확정 |
| `/my-plan [기능명]` | 가정 명시 후 설계 방향·리스크 정리 → `docs/plan/` 저장 |
| `/my-split [auto]` | plan → 수직 슬라이스 단위 step별 작업 분해 |
| `/my-commit` | 원자성 점검 후 Claude attribution 없는 커밋 |
| `/my-debug [증상]` | 테스트·빌드 실패를 근본 원인 기반으로 해결 |
| `/my-check` | 타입·린트·테스트·빌드 검증 후 5축 코드 리뷰 |
| `/my-pr` | PR 제목 추천 |
| `/my-review [피드백]` | 코드 리뷰 피드백 분류 및 적용 |
| `/my-iterate [auto]` | 리뷰 피드백 기반 개선 작업 분해 |
| `/my-retro` | 작업 회고 HTML 문서 생성 (세션 마무리 뉘앙스에 자동 발동) |
| `/my-status` | 현재 워크플로우 위치 파악 |
| `/my-refine [피드백]` | 기획 단계(plan/step) 피드백 반영 |
| `/my-daily-log [메모]` | 오늘 대화 로그 분석 후 Obsidian 일지 초안 생성 |
| `/my-memo [대화 내용]` | 대화 기반 웹 리서치 후 Obsidian 인사이트 메모 저장 |
| `/my-disk` | 맥 디스크 여유 공간 확인 및 정리 |
