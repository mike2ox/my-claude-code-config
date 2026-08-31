---
name: my-daily-log
description: 오늘 Claude Code 대화 로그를 분석하여 Obsidian 일지 초안을 생성합니다. 업무 종료 후 일지 작성 시 사용하세요.
disable-model-invocation: true
argument-hint: [비개발 업무 또는 추가 메모]
allowed-tools: Agent
---

오늘 하루 작업한 내용을 분석하여 Obsidian 일지 초안을 생성합니다.

Agent tool을 호출하세요. 파라미터:
- description: "일일 업무 일지 초안 생성"
- prompt: 아래 내용 전달

---

오늘 날짜 기준으로 Claude Code 대화 로그를 분석하여 Obsidian 일지 초안을 생성합니다.
추가 컨텍스트: $ARGUMENTS

## 1단계: 로그 파일 탐색

현재 작업 디렉토리를 확인합니다 (`pwd`).

Claude Code 프로젝트 로그 경로를 계산합니다:
- 현재 경로의 `/`를 `-`로 치환하여 `~/.claude/projects/{변환된경로}/` 구성
- 예: `/Users/me/Projects/my-app` → `~/.claude/projects/-Users-me-Projects-my-app/`

오늘 날짜(YYYY-MM-DD)의 JSONL 파일을 찾습니다:

```bash
ls -la ~/.claude/projects/{로그디렉토리}/*.jsonl
```

수정 날짜가 오늘인 파일을 모두 대상으로 합니다. 파일이 여러 개면 모두 처리합니다.

## 2단계: 사용자 질의 추출

오늘의 각 JSONL 파일에서 사용자 메시지를 다음 Python 스크립트로 추출합니다:

```python
import sys, json

def extract_messages(filepath):
    messages = []
    with open(filepath) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
                if obj.get('type') == 'user' and 'message' in obj:
                    msg = obj['message']
                    if isinstance(msg, dict) and msg.get('role') == 'user':
                        content = msg.get('content', '')
                        ts = obj.get('timestamp', '')[:19]
                        if isinstance(content, list):
                            for c in content:
                                if isinstance(c, dict) and c.get('type') == 'text':
                                    text = c.get('text', '').strip()
                                    if text and not text.startswith('<') and len(text) > 10:
                                        messages.append((ts, text[:400]))
                        elif isinstance(content, str):
                            text = content.strip()
                            if text and not text.startswith('<') and len(text) > 10:
                                messages.append((ts, text[:400]))
            except:
                pass
    return messages

for path in sys.argv[1:]:
    for ts, m in extract_messages(path):
        print(f"[{ts}] {m}")
        print()
```

system-reminder, task-notification, command-message 등 메타 메시지는 무시합니다.

## 3단계: 내용 분류

추출된 질의를 아래 기준으로 분류합니다:

| 버킷 | 기준 |
|------|------|
| **개발 Done** | 코드 구현, API 설계/분석, 버그 수정, 스크립트 작성 완료 |
| **비개발 Done** | 기획 검토, 팀 운영, 환경 세팅, 기술 조사, 불필요 작업 차단 |
| **학습 Done** | 문서 리딩, 기술 개념 탐구, 개인 학습 |
| **기술 Todo** | 오늘 알게 된 개념 중 더 깊이 파야 할 것, 미완성 기술 작업 |
| **경영지원 Todo** | 팀 운영 후속, 미완성 비개발 업무 |
| **기타 Todo** | 개인 후속 처리 |
| **Memo** | 오늘 얻은 인사이트, 다음 작업 시 참고할 패턴, 주의사항 |

Done 항목은 "무엇을 왜 했는지"가 드러나도록 한 줄로 작성합니다.
단순 명령 실행이나 중단된 요청은 제외합니다.

## 4단계: 초안 출력

아래 형식을 코드블록으로 감싸서 복붙 가능하게 출력합니다.
항목이 없는 섹션은 비워두되 섹션 제목은 유지합니다.

```md
# {YYYY-MM-DD}

[[{YYYY} {M}월 목표]]

## Todo
### 기술
- 

### 경영지원
- 

### 기타
- 

## Done
### 개발
- 

### 비개발
- 

### 학습
- 

## Memo
- 

## Reference
- 
```

---

에이전트 완료 후 사용자에게 안내합니다:
- 생성된 초안을 Obsidian 일지에 복붙하면 됩니다
- $ARGUMENTS 에 추가 업무 내용을 넣으면 Done/Todo에 반영됩니다
