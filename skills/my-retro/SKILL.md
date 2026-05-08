---
name: my-retro
description: 작업 완료 후 회고 문서를 생성합니다. 브랜치 삭제 전 포트폴리오·이력서 참고용 기록을 남깁니다.
disable-model-invocation: true
allowed-tools: Agent
---

현재 브랜치 작업에 대한 회고 문서 작성을 Agent tool로 위임합니다.

Agent tool을 호출하세요. 파라미터:
- description: "브랜치 회고 문서 생성"
- prompt: 아래 내용 전달

---
현재 브랜치의 작업 내용을 분석하여 회고 문서를 작성합니다.

아래 명령을 실행하여 정보를 수집하세요:
- git branch --show-current
- git log main..HEAD --oneline
- git log main..HEAD --format="%ai %s"
- git diff main...HEAD --stat
- git config user.name

수집한 정보를 바탕으로 docs/retro/YYYY-MM-DD-{브랜치명}.md 파일을 생성합니다.
docs/retro/ 디렉토리가 없으면 먼저 생성합니다.

파일 내용 형식:

# [기능명] 작업 회고

**작업 기간**: YYYY-MM-DD ~ YYYY-MM-DD
**브랜치**: {브랜치명}
**작업자**: {git config user.name}

## 기획 방향

- 이 기능을 만든 이유
- 해결하려는 문제
- 초기 설계 방향

## 주요 구현 내용

- 핵심 변경사항 (3-5개 항목)

## 기술적 고려사항

- 선택한 구현 방식과 이유
- 대안으로 고려했던 접근법
- 성능·접근성·유지보수 관련 결정

## 작업 단계별 기록

| Step | 내용 | 커밋 해시 | 예상 소요 시간 |
|------|------|----------|--------------|
|      |      |          |              |

## 배운 점 / 인사이트

- 이 작업을 통해 새로 알게 된 것
- 다음에 비슷한 작업 시 참고할 패턴

## 개선 여지

- 현재 구현의 한계
- 향후 개선 가능한 부분

파일 생성 완료 후 경로를 반환합니다.
---

에이전트 완료 후 생성된 파일 경로를 사용자에게 알립니다.
