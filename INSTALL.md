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

### 2. 각 skill에 symlink 생성

`skills/` 하위의 각 디렉토리를 `~/.claude/skills/` 에 symlink로 만듭니다.
이미 symlink가 있으면 건너뛰고, 일반 디렉토리가 존재하면 경고를 출력합니다.

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

### 3. 알림음 훅 설치

`~/.claude/settings.json`의 `hooks`에 알림음 훅 3개를 병합합니다.
파일을 통째로 덮지 않고 `hooks`에만 손대므로 `model`·`statusLine`·기존 훅은 그대로 유지됩니다.

```bash
bash settings/install-sounds.sh
```

넣는 훅은 `settings/notification-sounds.json`에 정의되어 있습니다.

| 이벤트 | 소리 | 울리는 순간 |
|--------|------|-------------|
| `Stop` | Aurora (없으면 Glass) | Claude가 응답을 마칠 때 |
| `Notification` | Ping ×3 + 알림 배너 | 권한 승인 대기 / 60초 이상 유휴 |
| `StopFailure` | Hero | overloaded·rate_limit 등으로 중단될 때 |

`jq`가 필요합니다 (`brew install jq`). 실행할 때마다 타임스탬프 백업을 남기고,
넣은 훅은 command 끝의 `# my-cc-config:sound` 마커로 식별하므로 **재실행해도 중복되지 않습니다.**

> Aurora는 `ToneLibrary.framework` 내부 파일이라 macOS 업데이트로 경로가 바뀔 수 있습니다.
> 그래서 훅에 폴백이 들어 있어, 파일이 사라지면 조용히 무음이 되지 않고 Glass로 대체 재생됩니다.

### 4. Claude Code 재시작

skills를 로드하려면 Claude Code를 재시작하세요.

## 설치 확인

```bash
ls ~/.claude/skills/ | grep -E "^(my-|goal-maker$)"
```

이 저장소의 `skills/` 하위 디렉터리와 **개수·이름이 모두 일치**하면 정상입니다. 아래 명령으로 한 번에 대조할 수 있습니다:

```bash
diff <(ls skills/) <(ls ~/.claude/skills/ | grep -E "^(my-|goal-maker$)") && echo "일치"
```

목록을 이 문서에 복제해 두지 않습니다 — 스킬이 추가·삭제될 때마다 어긋나기 때문입니다.

## 제거

설치한 symlink를 모두 제거하려면:

```bash
for skill in ~/.claude/skills/my-*/ ~/.claude/skills/goal-maker/; do
  [ -L "$skill" ] && rm "$skill" && echo "  ✗ $(basename "$skill") removed"
done
```

알림음 훅을 제거하려면:

```bash
bash settings/install-sounds.sh --uninstall
```

마커가 붙은 훅만 걷어내므로 `settings.json`의 다른 설정과 훅은 그대로 남습니다.
