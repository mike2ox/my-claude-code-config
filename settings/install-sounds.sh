#!/bin/bash
# Claude Code 알림음 훅 설치 스크립트
#
#   bash settings/install-sounds.sh              설치 (재실행해도 중복되지 않음)
#   bash settings/install-sounds.sh --uninstall  제거
#
# settings.json을 통째로 덮지 않고 `hooks`에만 병합합니다.
# 이 스크립트가 넣은 훅은 command 끝의 `# my-cc-config:sound` 마커로 식별하며,
# 재실행 시 마커가 붙은 훅만 걷어내고 다시 넣으므로 다른 훅은 건드리지 않습니다.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FRAGMENT="$REPO_DIR/settings/notification-sounds.json"
SETTINGS="${CLAUDE_SETTINGS:-$HOME/.claude/settings.json}"
MARK="# my-cc-config:sound"

command -v jq >/dev/null 2>&1 || { echo "  ✗ jq가 필요합니다 — brew install jq"; exit 1; }
[ -f "$FRAGMENT" ] || { echo "  ✗ 훅 정의 파일 없음: $FRAGMENT"; exit 1; }

mkdir -p "$(dirname "$SETTINGS")"
[ -f "$SETTINGS" ] || echo '{}' >"$SETTINGS"

if ! jq empty "$SETTINGS" >/dev/null 2>&1; then
  echo "  ✗ $SETTINGS 가 올바른 JSON이 아닙니다. 먼저 고친 뒤 다시 실행하세요."
  exit 1
fi

BACKUP="$SETTINGS.bak-$(date +%Y%m%d-%H%M%S)"
cp "$SETTINGS" "$BACKUP"

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

# 마커가 붙은 훅을 걷어내고, 그 결과 비어버린 항목은 통째로 제거한다.
STRIP='
  def stripMarked($mark):
    ((. // [])
     | map(.hooks |= map(select(((.command // "") | contains($mark)) | not)))
     | map(select((.hooks | length) > 0)));
'

if [ "${1:-}" = "--uninstall" ]; then
  jq --arg mark "$MARK" "$STRIP"'
    .hooks //= {}
    | .hooks |= with_entries(.value |= stripMarked($mark))
    | .hooks |= with_entries(select((.value | length) > 0))
  ' "$SETTINGS" >"$TMP"
  ACTION="제거"
else
  # 같은 matcher를 쓰는 항목이 이미 있으면 그 안에 훅만 덧붙이고, 없으면 새 항목을 만든다.
  jq --arg mark "$MARK" --slurpfile frag "$FRAGMENT" "$STRIP"'
    def mergeEntry($entry):
      . as $arr
      | ([$arr | to_entries[] | select(.value.matcher == $entry.matcher) | .key]) as $idx
      | if ($idx | length) > 0
        then (.[$idx[0]].hooks += $entry.hooks)
        else . + [$entry]
        end;
    .hooks //= {}
    | reduce ($frag[0] | to_entries[]) as $e (.;
        .hooks[$e.key] = (
          reduce $e.value[] as $entry
            ((.hooks[$e.key] | stripMarked($mark)); mergeEntry($entry))))
  ' "$SETTINGS" >"$TMP"
  ACTION="설치"
fi

if ! jq empty "$TMP" >/dev/null 2>&1; then
  echo "  ✗ 병합 결과가 올바른 JSON이 아닙니다. 원본을 그대로 두었습니다: $SETTINGS"
  exit 1
fi

mv "$TMP" "$SETTINGS"
trap - EXIT

echo "  ✓ 알림음 훅 $ACTION 완료 — $SETTINGS"
echo "    백업: $BACKUP"
