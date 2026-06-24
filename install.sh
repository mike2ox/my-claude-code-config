#!/bin/bash
# Claude Code personal workflow skills 설치 스크립트
# 실행: bash install.sh

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_TARGET="$HOME/.claude/skills"

mkdir -p "$SKILLS_TARGET"

echo "Installing my-* skills..."

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

echo ""
echo "Done. Restart Claude Code to load the skills."
echo "Available commands: /my-init, /my-plan, /my-split, /my-commit, /my-check, /my-pr, /my-review, /my-iterate, /my-retro, /my-pivot, /my-status, /my-disk, /my-daily-log"
