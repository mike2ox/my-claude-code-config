#!/usr/bin/env bash
# 글로벌(user 스코프) MCP 서버 등록 — 재현 가능한 단일 소스.
# 실행: bash mcp-install.sh   (재실행 안전: 이미 등록된 서버는 건너뜀)
#
# 버전은 의도적으로 고정(pin)한다. 업데이트는 아래 PIN 값을 bump + commit 후 재실행.
set -euo pipefail

# ---- pinned versions (검증된 버전) ----
CONTEXT7_VER="3.2.5"
SEQTHINK_VER="2026.7.4"
SHRIMP_VER="1.0.21"
SERENA_REF="v1.6.1"                       # git 태그(브랜치 HEAD 금지)
SHRIMP_DATA_DIR="${SHRIMP_DATA_DIR:-$HOME/.shrimp-data}"

mkdir -p "$SHRIMP_DATA_DIR" && chmod 700 "$SHRIMP_DATA_DIR"

# 이미 등록돼 있으면 스킵, 없으면 등록
add() {
  local name="$1"; shift
  if claude mcp get "$name" >/dev/null 2>&1; then
    echo "  ↺ $name (already registered, skipping — 갱신하려면 'claude mcp remove -s user $name' 후 재실행)"
  else
    claude mcp add -s user "$name" "$@"
    echo "  ✓ $name"
  fi
}

echo "Registering global (user-scope) MCP servers..."
add context7            -- npx -y "@upstash/context7-mcp@${CONTEXT7_VER}"
add sequential-thinking -- npx -y "@modelcontextprotocol/server-sequential-thinking@${SEQTHINK_VER}"
add shrimp-task-manager -e "DATA_DIR=${SHRIMP_DATA_DIR}" -- npx -y "mcp-shrimp-task-manager@${SHRIMP_VER}"
# Serena: --project-from-cwd 로 세션마다 현재 프로젝트에 자동 바인딩(worktree 안전, v1.6.0+)
add serena -- uvx --from "git+https://github.com/oraios/serena@${SERENA_REF}" \
              serena start-mcp-server --context claude-code --project-from-cwd

echo ""
echo "Done. 등록 확인:"
claude mcp list
