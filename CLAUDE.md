# my-claude-code-config — Agent Guide

## 프로젝트 개요

개인 Claude Code 워크플로우 스킬 모음. `skills/my-*/` 디렉토리를 `~/.claude/skills/` 에 symlink로 연결해 `/my-*` 커맨드를 전역으로 사용할 수 있게 합니다.

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

**Step 2** — 이 저장소의 절대 경로를 기준으로 각 `my-*` skill에 symlink 생성:

```bash
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_TARGET="$HOME/.claude/skills"

for skill_dir in "$REPO_DIR/skills"/my-*/; do
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

**Step 3** — 완료 후 사용자에게 Claude Code 재시작을 안내하세요.

**Step 4** — 설치 확인:

```bash
ls ~/.claude/skills/ | grep "^my-"
```

세부 사항은 [`INSTALL.md`](INSTALL.md)를 참조하세요.

## 사용 가능한 커맨드

| 커맨드 | 설명 |
|--------|------|
| `/my-init [update]` | 현재 프로젝트 CLAUDE.md에 표준 워크플로우 섹션 추가 |
| `/my-plan [기능명]` | 기능 아이디어와 설계 방향 정리 → `docs/plan/` 저장 |
| `/my-split [auto]` | plan → step별 작업 분해 |
| `/my-commit` | Claude attribution 없는 커밋 |
| `/my-check` | 타입 체크 후 최적화 기회 검토 |
| `/my-pr` | PR 제목 추천 |
| `/my-review [피드백]` | 코드 리뷰 피드백 분류 및 적용 |
| `/my-iterate [auto]` | 리뷰 피드백 기반 개선 작업 분해 |
| `/my-retro` | 작업 회고 문서 생성 |
| `/my-pivot` | 방향 전환 시 plan 재설계 |
| `/my-disk` | 맥 디스크 여유 공간 확인 및 정리 |
