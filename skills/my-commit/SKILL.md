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
3. **원자성 점검** — 아래 참조. 여러 논리 변경이 섞였으면 나눠 커밋
4. Conventional Commit 형식으로 메시지 작성
   - 타입: `feat` `fix` `chore` `refactor` `docs` `style` `test`
   - 스코프 있으면: `feat(scope): 설명`
   - 언어는 기존 커밋 메시지에 맞춤
5. 관련 파일만 스테이징 (`.env`, 인증 정보 등 민감한 파일 제외)
6. 아래 형식으로 커밋

```bash
git commit -m "$(cat <<'EOF'
<커밋 메시지>
EOF
)"
```

## 원자성 점검

**하나의 커밋은 하나의 논리적 변경**입니다. 커밋 전 변경 내용을 보고 확인합니다:

- 이 커밋을 한 문장으로 설명할 때 "그리고"가 필요한가? → 나눈다
- 기능 추가와 리팩터링이 섞였는가? → 나눈다
- 무관한 파일이 딸려 들어갔는가? → 빼낸다

특정 파일만 나눠 커밋할 때:

```bash
git add <관련 파일들>
git commit -m "..."
```

되돌리기 쉬운 커밋이 좋은 커밋입니다. 한 커밋 안에서 무언가를 삭제하면서 동시에 대체물을 넣지 않습니다.

## 커밋 메시지 작성 기준

**제목**: 명령형으로, 그 자체로 이해되게. `git log`만 보고도 무슨 변경인지 알 수 있어야 합니다.

- 좋음: `fix(auth): 토큰 만료 시 무한 리다이렉트 해결`
- 나쁨: `버그 수정`, `빌드 수정`, `1단계`, `코드 이동`

**본문** (필요한 경우): 코드만 봐서는 안 보이는 **왜**를 적습니다. 무엇을 바꿨는지는 diff가 말해주므로, 왜 그렇게 했는지·어떤 대안을 버렸는지를 남깁니다.

## 커밋 전 확인

스테이징한 내용에 아래가 없는지 확인합니다:

- `.env`, 키·토큰·비밀번호가 들어간 파일
- 디버깅용 `console.log`, 주석 처리한 코드 뭉치
- 커밋할 의도가 없던 파일 (`git status`로 재확인)

```bash
git diff --cached
```

## 중요

커밋 메시지에 `Co-Authored-By`, `Generated with`, `Claude` 등 attribution을 절대 포함하지 않습니다.
