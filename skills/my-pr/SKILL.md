---
name: my-pr
description: 현재 브랜치의 변경사항을 분석하여 PR 제목을 추천합니다.
disable-model-invocation: true
allowed-tools: Bash(git log *) Bash(git diff *) Bash(git branch *)
---

현재 브랜치의 변경사항을 분석하여 PR 제목 후보를 제안합니다.

## 변경사항 수집

!`git log main..HEAD --oneline`

!`git diff main...HEAD --stat`

## 제안 형식

위 변경사항을 바탕으로 PR 제목 3-5개를 제안합니다.

- Conventional Commit 스타일: `feat(scope): 설명`
- 70자 이하, 명확하게
- 한국어·영어 각각 옵션 포함
- 각 옵션에 선택 이유 한 줄 첨부
