#!/bin/bash
# Claude Code personal workflow skills 설치 스크립트
# 실행: bash install.sh

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_TARGET="$HOME/.claude/skills"

mkdir -p "$SKILLS_TARGET"

echo "Installing skills..."

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

echo ""
echo "Registering global (user-scope) MCP servers..."
if command -v claude >/dev/null 2>&1; then
  bash "$REPO_DIR/mcp-install.sh" || echo "  ⚠ mcp-install.sh failed — 수동 실행: bash mcp-install.sh"
else
  echo "  ⚠ claude CLI 없음 — MCP 등록 건너뜀. 설치 후: bash mcp-install.sh"
fi

echo ""
echo "Installing notification sound hooks..."
bash "$REPO_DIR/settings/install-sounds.sh" || echo "  ⚠ install-sounds.sh failed — 수동 실행: bash settings/install-sounds.sh"

echo ""
echo "Done. Restart Claude Code to load the skills."
printf "Available commands: "
ls "$REPO_DIR/skills" | sed 's|^|/|' | tr '\n' ',' | sed 's/,$//; s/,/, /g'
echo ""
