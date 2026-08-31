---
name: my-disk
description: 맥 디스크 여유 공간을 확인하고, 안전하게 정리할 수 있는 항목을 찾아 사용자 확인 후 삭제합니다.
disable-model-invocation: true
allowed-tools: Bash(*) AskUserQuestion
---

맥 디스크 공간을 진단하고 정리합니다.

## 1단계: 현재 여유 공간 확인

```bash
df -h /
```

여유 공간이 충분하면(10GB 이상) 결과만 보고하고 종료합니다.

## 2단계: 공간 차지 항목 분석

아래 명령을 병렬로 실행합니다:

```bash
du -sh ~/Library/Caches/*/ 2>/dev/null | sort -rh | head -15
du -sh ~/Library/Developer/CoreSimulator 2>/dev/null
du -sh ~/Library/Application\ Support/audacity/SessionData 2>/dev/null
du -sh ~/Library/Application\ Support/Google/Chrome 2>/dev/null
du -sh ~/Library/Application\ Support/Notion 2>/dev/null
du -sh ~/Downloads ~/Desktop ~/Documents ~/Movies 2>/dev/null
du -sh ~/.Trash 2>/dev/null
```

## 3단계: 정리 항목 제안 및 확인

분석 결과를 바탕으로 아래 항목 중 해당하는 것을 AskUserQuestion으로 사용자에게 제시합니다 (multiSelect: true):

- **Homebrew 캐시** — `brew cleanup --prune=all`로 안전 삭제
- **Audacity SessionData** — 저장 완료된 세션 임시 데이터 (삭제 전 별도 확인 필수)
- **iOS 시뮬레이터 불필요 기기** — `xcrun simctl delete unavailable`
- **휴지통 비우기** — `~/.Trash` 비우기
- **npm/yarn/pnpm 캐시** — `npm cache clean --force` 등

항목별 예상 확보 용량을 함께 표시합니다.

## 4단계: Audacity 별도 확인 (해당 시)

Audacity SessionData가 선택됐다면 AskUserQuestion으로 별도 확인합니다:
"저장하지 않은 Audacity 작업이 없는 게 확실한가요? 삭제 후 복구 불가합니다."

확인 후에만 삭제합니다.

## 5단계: 선택된 항목 정리 실행

사용자가 선택한 항목만 순서대로 실행합니다.

## 6단계: 결과 보고

정리 전후 여유 공간 비교와 항목별 확보 용량을 표로 출력합니다.
