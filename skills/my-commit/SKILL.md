---
name: my-commit
description: 현재 변경사항을 Claude attribution 없이 커밋합니다.
disable-model-invocation: true
allowed-tools: Bash(git status *) Bash(git diff *) Bash(git add *) Bash(git commit *) Bash(git log *)
---

현재 변경사항을 커밋합니다.

## 순서

1. `git status`와 `git diff`로 변경사항 파악
2. `git log --oneline -5`로 최근 커밋 메시지 스타일 확인
3. Conventional Commit 형식으로 메시지 작성
   - 타입: `feat` `fix` `chore` `refactor` `docs` `style` `test`
   - 스코프 있으면: `feat(scope): 설명`
   - 언어는 기존 커밋 메시지에 맞춤
4. 관련 파일만 스테이징 (`.env`, 인증 정보 등 민감한 파일 제외)
5. 아래 형식으로 커밋

```bash
git commit -m "$(cat <<'EOF'
<커밋 메시지>
EOF
)"
```

## 중요

커밋 메시지에 `Co-Authored-By`, `Generated with`, `Claude` 등 attribution을 절대 포함하지 않습니다.
