# Installation Guide

> **AI Agent**: 사용자가 이 프로젝트의 세팅이나 설치를 요청하면 아래 단계를 순서대로 실행하세요.

## Prerequisites

- macOS
- Claude Code CLI 설치됨

## 설치 단계

### 1. skills 디렉토리 생성

```bash
mkdir -p ~/.claude/skills
```

### 2. 각 my-* skill에 symlink 생성

`skills/` 하위의 `my-*` 디렉토리마다 `~/.claude/skills/` 에 symlink를 만듭니다.
이미 symlink가 있으면 건너뛰고, 일반 디렉토리가 존재하면 경고를 출력합니다.

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

### 3. Claude Code 재시작

skills를 로드하려면 Claude Code를 재시작하세요.

## 설치 확인

```bash
ls ~/.claude/skills/ | grep "^my-"
```

다음 항목이 보이면 정상입니다:

```
my-check
my-commit
my-disk
my-init
my-iterate
my-pivot
my-plan
my-pr
my-retro
my-review
my-split
```

## 제거

설치한 symlink를 모두 제거하려면:

```bash
for skill in ~/.claude/skills/my-*/; do
  [ -L "$skill" ] && rm "$skill" && echo "  ✗ $(basename "$skill") removed"
done
```
