---
name: my-pr
description: 현재 브랜치의 변경사항을 분석하여 PR 제목과 body를 생성합니다. `full` 또는 `auto` 파라미터를 입력하면 GitHub에 draft PR을 자동 생성하고 assignee를 설정합니다.
disable-model-invocation: true
argument-hint: [full|auto]
allowed-tools: Bash(git log *) Bash(git diff *) Bash(git branch *) Bash(git config *) Bash(git push *) Bash(gh pr create *) Bash(gh auth status *) Bash(gh api *) Read(docs/plan/*) Read(docs/review/*)
---

현재 브랜치의 변경사항을 분석하여 PR 제목 후보와 body를 생성합니다.

## 모드 판별

- `$ARGUMENTS`가 `full` 또는 `auto`이면: **자동 생성 모드** — PR 텍스트 생성 후 GitHub에 draft PR을 직접 생성합니다.
- 그 외(기본값): **텍스트 생성 모드** — PR 제목 후보와 body만 출력합니다.

## 변경사항 수집

아래 명령을 병렬로 실행합니다:

```bash
git branch --show-current
git log main..HEAD --oneline
git diff main...HEAD --stat
```

추가로 아래 파일이 있으면 읽어 내용을 반영합니다:
- `docs/plan/` 디렉토리의 가장 최근 파일 (기획 배경)
- `docs/review/` 디렉토리의 가장 최근 파일 (반영된 피드백)

## 출력 형식

### 제목 후보

Conventional Commit 스타일로 3개 제안합니다 (`feat(scope): 설명`).
- 70자 이하, 한국어·영어 혼용 가능
- 각 옵션에 선택 이유 한 줄 첨부

---

### PR Body (마크다운)

제목 후보 중 첫 번째를 기준으로 아래 형식의 PR body를 생성합니다.
사용자가 제목을 바꾸면 body도 그에 맞게 조정합니다.

```markdown
## 개요

<!-- 이 PR에서 무엇을 왜 변경했는지 2-3문장 -->

## 변경 내용

<!-- 핵심 변경사항을 항목별로 -->
- 

## 테스트 방법

<!-- 리뷰어가 직접 확인할 수 있는 방법 -->
- [ ] 

## 참고 사항

<!-- 리뷰어가 알아야 할 배경, 제약, 미적용 항목 등 (없으면 섹션 삭제) -->
```

body 생성 시 실제 변경 내용으로 항목을 채웁니다. 빈 placeholder는 남기지 않습니다.

---

## 자동 생성 모드 (`full` / `auto`)

텍스트 출력 이후 아래 순서로 진행합니다.

### 1단계: 사전 확인

아래 명령을 실행하여 환경을 확인합니다:

```bash
gh auth status
```

`gh`가 없거나 인증되지 않은 경우: "GitHub CLI(gh)가 필요합니다. `brew install gh && gh auth login`으로 설정 후 재시도하세요."라고 안내하고 중단합니다.

### 2단계: assignee 확인

```bash
gh api user --jq '.login'
```

위 명령으로 현재 인증된 GitHub 사용자명을 가져옵니다. 실패하면 `git config user.email`을 대신 사용합니다.

### 3단계: 브랜치 push

현재 브랜치를 remote에 push합니다 (이미 push된 경우 생략):

```bash
git push -u origin HEAD
```

### 4단계: PR 생성

생성된 제목 후보 중 **첫 번째**를 사용하여 draft PR을 생성합니다.
body는 임시 파일에 저장한 뒤 `--body-file`로 전달합니다:

```bash
# body를 임시 파일에 저장
tmp_file=$(mktemp /tmp/pr-body-XXXXXX.md)
cat > "$tmp_file" << 'PRBODY'
{생성된 PR body 내용}
PRBODY

# draft PR 생성
gh pr create \
  --draft \
  --title "{첫 번째 제목 후보}" \
  --body-file "$tmp_file" \
  --assignee "@me"

rm -f "$tmp_file"
```

### 5단계: 결과 보고

PR 생성 성공 시:
```
Draft PR 생성 완료
URL: {gh pr create 출력 URL}
제목: {사용된 제목}
Assignee: {GitHub 사용자명}

다른 제목으로 바꾸려면 PR URL에서 직접 편집하거나 아래 명령을 실행하세요:
  gh pr edit --title "{원하는 제목}"
```

실패 시 오류 메시지 전문을 출력하고 수동 생성 방법을 안내합니다.
