---
name: my-retro
description: 브랜치 작업을 정리해 비개발직군도 읽을 수 있는 HTML 회고 문서를 만듭니다. 사용자가 "작업 마무리하자", "이번 작업 끝내자", "세션 정리하자"처럼 작업을 마무리하는 뉘앙스로 말할 때도 사용하세요.
allowed-tools: Agent Bash(git log *) Bash(git branch *)
---

현재 브랜치 작업에 대한 회고 문서 작성을 Agent tool로 위임합니다.

## 위임 전 확인 (메인 루프)

```bash
git branch --show-current
git log main..HEAD --oneline
```

- `main`/`master`에 있거나 브랜치에 커밋이 없으면 위임하지 않습니다. "회고할 작업 내역이 없습니다"라고 알리고 종료합니다.
- 이 스킬은 파일을 **삭제하지 않습니다.** 원본 plan/review 문서는 아카이브로 옮길 뿐이므로 되돌릴 수 있습니다.

## Agent 위임

Agent tool을 호출하세요. 파라미터:
- description: "브랜치 회고 HTML 문서 생성"
- prompt: 아래 내용 전달

---
현재 브랜치의 작업 내용을 분석하여 회고 문서를 작성합니다.

아래 명령을 실행하여 정보를 수집하세요:
- git branch --show-current
- git log main..HEAD --oneline
- git log main..HEAD --format="%ai %s"
- git diff main...HEAD --stat
- git diff main...HEAD (주요 변경 파악용)
- git config user.name

---

## 0단계: plan/review 파일 통합 및 아카이브

**원본 파일을 삭제하지 않습니다.** 통합본을 만든 뒤 원본은 `_archive/` 하위로 옮깁니다. 삭제는 되돌릴 수 없지만 이동은 되돌릴 수 있습니다.

### docs/plan/ 통합

`docs/plan/` 파일이 2개 이상이면:

1. 모든 plan 파일을 날짜순으로 읽습니다
2. `docs/plan/{브랜치명}-merged.md`로 통합합니다:

```markdown
# [기능명] 통합 기획서

## 최종 기획 방향
(가장 최신 plan 파일의 핵심 내용 — 기능 개요, 사용자 스토리, 기술적 접근 방향)

## 기획 변경 이력
| 날짜 | 원본 파일 | 주요 변경 |
|------|----------|---------|
| {날짜} | {원본 파일명} | {초기 방향 요약} |
```

3. 원본 파일들을 `docs/plan/_archive/`로 **이동**합니다 (`mkdir -p docs/plan/_archive && mv ...`). 통합본은 `docs/plan/` 최상위에 남깁니다.

파일이 1개 이하이면 이 단계를 건너뜁니다.

### docs/review/ 통합

`docs/review/` 파일이 2개 이상이면 같은 방식으로 처리합니다.

1. 날짜순으로 읽어 `docs/review/{브랜치명}-merged.md`로 통합
2. 아래 형식 사용:

```markdown
# [기능명] 통합 리뷰 이력

## 리뷰 요약 테이블
| 회차 | 날짜 | 필수 수정 | 권장 개선 | 선택 제안 | 적용률 |
|------|------|---------|---------|---------|------|
| 1차 | {날짜} | {N}건 | {N}건 | {N}건 | {N}/{총}건 |

## 리뷰 상세
### 1차 리뷰 — {날짜}
(원본 review 파일 내용)
```

3. 원본 파일들을 `docs/review/_archive/`로 **이동**합니다.

파일이 1개 이하이면 이 단계를 건너뜁니다.

---

## 1단계: 회고 HTML 작성

0단계 완료 후 `docs/plan/`과 `docs/review/`의 (통합된) 문서를 읽어 내용을 반영합니다.

`docs/retro/YYYY-MM-DD-{브랜치명}.html` 파일을 생성합니다. `docs/retro/`가 없으면 먼저 만듭니다.

### 읽는 사람

**주니어 개발자와 비개발직군이 첫 독자입니다.** 이 사람들은 코드를 보지 않았고, 브랜치명이나 함수명도 모릅니다.

- 문서 맨 위 "한 줄 요약"과 "왜 했나"만 읽고도 무슨 일이 있었는지 알 수 있어야 합니다.
- 기술 용어를 쓰면 **용어 풀이 표**에 일상어로 한 줄 설명을 답니다. (예: "마이그레이션 — 기존 데이터를 새 구조로 옮기는 작업")
- 약어, 화살표 연쇄(`A → B → 실패`), 작업 중에 만든 별칭을 쓰지 않습니다. 완전한 문장으로 씁니다.
- 상세 기술 내용은 지우지 말고 **뒤쪽 섹션으로** 보냅니다. 앞은 요약, 뒤는 근거입니다.

### 결과가 아니라 과정을 적는 세 섹션

무엇을 만들었는지는 diff에 남지만, **왜 그렇게 판단했는지는 아무 데도 남지 않습니다.** 아래 세 섹션이 그 기록입니다. 추측으로 채우지 말고, 근거를 못 찾으면 그 행을 비워 두거나 섹션째로 삭제합니다.

**① 문제를 어떻게 알게 됐나** — 기능을 만들기로 한 판단의 출발점입니다.

- 최초 신호가 무엇이었는지: 문의, 오류 로그, 지표 변화, 직접 관찰 중 어느 것이었나
- 그 신호를 확인하려고 무엇을 했고, 그 결과 범위가 어떻게 좁혀졌나
- 한 번의 사건인지 반복되는 문제인지 무엇으로 판단했나
- 근거를 찾을 곳: `docs/plan/`의 문제 정의, 브랜치 첫 커밋 이전의 대화, 연결된 이슈

**② 정리 먼저 — 고치기 전에 치운 것** — 동작을 바꾸지 않는 정리(이름 변경, 추출, 중복 제거, 위치 이동)와 동작을 바꾸는 변경을 나눠 적습니다.

- 커밋 메시지에서 `refactor:` `chore:` `style:`과 `feat:` `fix:`를 구분해 찾습니다
- 각 정리에 **"이 정리가 없었으면 다음 작업이 왜 어려웠는지"**를 씁니다. 그 이유를 못 쓰겠다면 필요 없던 정리였을 수 있으니 그렇게 적습니다
- 정리와 기능이 한 커밋에 섞여 있었다면 **그것도 사실대로 적습니다.** 다음 작업에서 고칠 지점입니다
- 정리 커밋이 하나도 없으면 이 섹션째로 삭제합니다

**③ 의사결정 기록** — 갈림길마다 무엇을 고르고 무엇을 버렸는지입니다.

- 코드에 흔적이 남는 결정(규칙, 저장 구조, 계산 시점)뿐 아니라 **범위를 줄인 결정**도 포함합니다
- **"버린 길과 이유"가 이 표의 핵심입니다.** 고른 것만 적으면 나중에 같은 고민을 처음부터 다시 하게 됩니다
- "되돌리기"는 이 결정을 나중에 무르는 비용입니다. 함수 한 곳이면 쉬움, 이미 저장된 데이터 구조가 걸리면 어려움
- 근거를 찾을 곳: `docs/review/`의 판단 기록, 리뷰에서 뒤집힌 항목, plan의 "안 할 것"

### HTML 요구사항

- **자체 완결**: CSS를 `<style>`에 인라인. 외부 폰트·스크립트·이미지를 참조하지 않습니다 (사내망·오프라인에서도 열려야 함).
- **라이트/다크 양쪽 대응**: 모든 색을 `:root` 토큰으로 정의하고, 다크에서는 **토큰 값만** 교체합니다. 색을 미디어 쿼리 안에서만 정의하면 한쪽 테마에서 글자가 안 보입니다. `body`에는 배경색을 명시적으로 지정합니다.
- **표는 가로 스크롤**: 표를 `overflow-x: auto` 컨테이너로 감싸 본문이 가로로 밀리지 않게 합니다.
- `<title>`은 `{기능명} 작업 회고`.

아래 골격을 그대로 사용하고 `{}` 자리만 채웁니다.

```html
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{기능명} 작업 회고</title>
<style>
  :root {
    --paper: #f6f5f2; --card: #ffffff; --ink: #1c1e23; --muted: #6a6e75; --line: #e2e0da;
    --accent: #2f6b5f; --accent-bg: #e6efec;
    --sev-high: #a8412a; --sev-mid: #8f6518; --sev-low: #6a6e75;
  }
  @media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) {
      --paper: #15171a; --card: #1c1f24; --ink: #e6e5e1; --muted: #9a9da4; --line: #2b2e34;
      --accent: #6fbfa9; --accent-bg: #1c2b28;
      --sev-high: #e08a72; --sev-mid: #d6a54a; --sev-low: #9a9da4;
    }
  }
  :root[data-theme="dark"] {
    --paper: #15171a; --card: #1c1f24; --ink: #e6e5e1; --muted: #9a9da4; --line: #2b2e34;
    --accent: #6fbfa9; --accent-bg: #1c2b28;
    --sev-high: #e08a72; --sev-mid: #d6a54a; --sev-low: #9a9da4;
  }
  *, *::before, *::after { box-sizing: border-box; }
  body {
    margin: 0; padding: 3.5rem 1.5rem 4rem;
    background: var(--paper); color: var(--ink);
    font-family: "Apple SD Gothic Neo", Pretendard, "Malgun Gothic", "Noto Sans KR", -apple-system, BlinkMacSystemFont, sans-serif;
    font-size: 16px; line-height: 1.75; word-break: keep-all; overflow-wrap: anywhere;
    -webkit-font-smoothing: antialiased;
  }
  .doc { max-width: 44rem; margin: 0 auto; display: flex; flex-direction: column; gap: 2.75rem; }
  .head { display: flex; flex-direction: column; gap: .75rem; }
  h1 { font-size: clamp(1.6rem, 1.2rem + 1.6vw, 2.1rem); font-weight: 700; letter-spacing: -.022em; line-height: 1.3; text-wrap: balance; margin: 0; }
  .rule { display: flex; gap: 2px; height: 6px; }
  .rule i { flex: 1; background: var(--line); border-radius: 1px; }
  .rule i.on { flex: 0 0 7px; background: var(--ink); opacity: .5; }
  .meta { color: var(--muted); font-size: .875rem; line-height: 1.6; display: flex; flex-wrap: wrap; gap: .3rem .9rem; }
  .meta span { white-space: nowrap; }
  .summary { background: var(--card); border: 1px solid var(--line); border-left: 3px solid var(--accent); border-radius: 2px; padding: 1.4rem 1.5rem; display: flex; flex-direction: column; gap: 1rem; }
  .summary > div { display: flex; flex-direction: column; gap: .15rem; }
  .summary dt { font-size: .7rem; font-weight: 700; letter-spacing: .1em; color: var(--accent); }
  .summary dd { margin: 0; font-size: 1.02rem; line-height: 1.7; }
  section { display: flex; flex-direction: column; gap: .85rem; }
  h2 { font-size: 1.08rem; font-weight: 700; letter-spacing: -.012em; margin: 0; padding-bottom: .5rem; border-bottom: 1px solid var(--line); }
  p { margin: 0; }
  ul { margin: 0; padding-left: 1.15rem; display: flex; flex-direction: column; gap: .5rem; }
  li::marker { color: var(--accent); }
  .lede { color: var(--muted); font-size: .9rem; }
  .scroll { overflow-x: auto; border: 1px solid var(--line); border-radius: 2px; background: var(--card); }
  table { border-collapse: collapse; width: 100%; min-width: 34rem; font-size: .9rem; }
  caption { caption-side: bottom; padding: .6rem .9rem; color: var(--muted); font-size: .8rem; text-align: left; }
  th, td { padding: .6rem .9rem; text-align: left; vertical-align: top; border-bottom: 1px solid var(--line); }
  tbody tr:last-child th, tbody tr:last-child td { border-bottom: 0; }
  thead th { font-size: .72rem; font-weight: 700; letter-spacing: .06em; color: var(--muted); white-space: nowrap; }
  td.num, th.num { text-align: right; font-variant-numeric: tabular-nums; white-space: nowrap; }
  .term th { width: 8.5rem; font-weight: 700; white-space: nowrap; }
  code { font-family: ui-monospace, SFMono-Regular, "SF Mono", Menlo, monospace; font-size: .84em; background: var(--accent-bg); color: var(--ink); padding: .1rem .35rem; border-radius: 2px; }
  .pill { display: inline-flex; align-items: center; gap: .35rem; font-size: .78rem; font-weight: 700; white-space: nowrap; }
  .pill::before { content: ""; width: 7px; height: 7px; border-radius: 50%; background: currentColor; }
  .pill.high { color: var(--sev-high); }
  .pill.mid { color: var(--sev-mid); }
  .pill.low { color: var(--sev-low); }
  footer { border-top: 1px solid var(--line); padding-top: 1.1rem; color: var(--muted); font-size: .82rem; line-height: 1.7; display: flex; flex-direction: column; gap: .3rem; }
</style>
</head>
<body>
<article class="doc">

  <header class="head">
    <h1>{기능명} 작업 회고</h1>
    <div class="rule" aria-hidden="true">
      <i></i><i class="on"></i><i></i><i class="on"></i><i></i><i></i><i class="on"></i><i></i><i class="on"></i><i></i><i class="on"></i><i></i><i></i><i class="on"></i><i></i><i class="on"></i><i></i><i class="on"></i><i></i><i></i>
    </div>
    <p class="meta">
      <span>{YYYY-MM-DD} ~ {YYYY-MM-DD}</span>
      <span>브랜치 <code>{브랜치명}</code></span>
      <span>작성자 {git config user.name}</span>
    </p>
  </header>

  <dl class="summary">
    <div><dt>한 줄 요약</dt><dd>{무엇을 했는지 한 문장. 기술 용어 없이}</dd></div>
    <div><dt>왜 했나</dt><dd>{이 작업이 없었으면 어떤 문제가 계속됐는지}</dd></div>
    <div><dt>무엇이 달라졌나</dt><dd>{사용자나 팀 입장에서 체감되는 변화}</dd></div>
  </dl>

  <section>
    <h2>용어 풀이</h2>
    <p class="lede">이 문서에 나오는 개발 용어를 먼저 풀어 둡니다.</p>
    <div class="scroll"><table class="term"><tbody>
      <tr><th scope="row">{용어}</th><td>{일상어 한 줄 설명}</td></tr>
    </tbody></table></div>
  </section>

  <section>
    <h2>문제를 어떻게 알게 됐나</h2>
    <p class="lede">기능을 만들기로 결정하기까지, 무엇을 보고 무엇을 확인했는지의 기록입니다.</p>
    <div class="scroll">
      <table>
        <thead><tr><th>시점</th><th>관측한 것</th><th>여기서 알게 된 것</th></tr></thead>
        <tbody><tr><td>{날짜}</td><td>{눈에 띈 신호 — 문의, 오류, 지표, 직접 관찰}</td><td>{그 관측이 좁혀준 범위}</td></tr></tbody>
      </table>
      <caption>{개별 대응이 아니라 이 작업을 하기로 판단한 이유 한 줄}</caption>
    </div>
  </section>

  <section>
    <h2>기획 방향</h2>
    <ul>
      <li><strong>해결하려던 문제</strong> — {문제와 그 크기. 가능하면 숫자로}</li>
      <li><strong>초기 설계 방향</strong> — {docs/plan 기반}</li>
      <li><strong>이번에 하지 않기로 한 것</strong> — {범위 밖으로 둔 것과 그 이유}</li>
    </ul>
  </section>

  <section>
    <h2>주요 구현 내용</h2>
    <ul><li>{핵심 변경사항 3~5개}</li></ul>
  </section>

  <section>
    <h2>정리 먼저 — 고치기 전에 치운 것</h2>
    <p class="lede">동작을 바꾸는 변경과, 동작은 그대로 두고 구조만 정리하는 변경을 섞지 않았습니다. 정리를 먼저 따로 커밋해 두면 나중에 문제가 생겼을 때 어느 쪽이 원인인지 바로 가려낼 수 있습니다.</p>
    <div class="scroll">
      <table>
        <thead><tr><th>정리한 것</th><th>왜 먼저 했나</th><th>동작 변화</th><th>커밋</th></tr></thead>
        <tbody>
          <tr><td>{이름 변경 · 추출 · 중복 제거 · 위치 이동}</td><td>{이 정리가 없었으면 다음 작업이 왜 어려웠는지}</td><td><span class="pill low">없음</span></td><td><code>{해시}</code></td></tr>
          <tr><td>— 여기서부터 실제 기능 —</td><td>{정리 위에 무엇을 얹었는지}</td><td><span class="pill mid">있음</span></td><td><code>{해시}</code></td></tr>
        </tbody>
      </table>
      <caption>{정리와 기능을 나눈 덕에 실제로 도움이 된 지점. 없었으면 이 섹션째로 삭제}</caption>
    </div>
  </section>

  <section>
    <h2>작업 단계별 기록</h2>
    <div class="scroll">
      <table>
        <thead><tr><th class="num">단계</th><th>내용</th><th>커밋</th><th class="num">소요</th></tr></thead>
        <tbody><tr><td class="num">{N}</td><td>{내용}</td><td><code>{해시}</code></td><td class="num">{기간}</td></tr></tbody>
      </table>
      <caption>{단계를 그렇게 나눈 이유 한 줄}</caption>
    </div>
  </section>

  <section>
    <h2>의사결정 기록</h2>
    <p class="lede">작업 중 갈림길에서 무엇을 고르고 무엇을 버렸는지, 그리고 나중에 되돌릴 수 있는 결정인지 남깁니다.</p>
    <div class="scroll">
      <table>
        <thead><tr><th>갈림길</th><th>고른 길</th><th>버린 길과 이유</th><th>되돌리기</th></tr></thead>
        <tbody><tr><td>{무엇을 정해야 했는지}</td><td>{고른 것}</td><td>{버린 선택지와 버린 이유}</td><td><span class="pill low">쉬움</span></td></tr></tbody>
      </table>
      <caption>{되돌리기 어려운 결정이 있으면 그것을 짚는 한 줄}</caption>
    </div>
  </section>

  <section>
    <h2>피드백 이력</h2>
    <div class="scroll">
      <table>
        <thead><tr><th>회차</th><th>날짜</th><th class="num">필수</th><th class="num">권장</th><th class="num">선택</th><th class="num">적용</th></tr></thead>
        <tbody><tr>
          <td>{N}차</td><td>{날짜}</td>
          <td class="num"><span class="pill high">{N}건</span></td>
          <td class="num"><span class="pill mid">{N}건</span></td>
          <td class="num"><span class="pill low">{N}건</span></td>
          <td class="num">{N}/{총}건</td>
        </tr></tbody>
      </table>
      <caption>{어떤 지적이 있었고 어떻게 해소됐는지 한 줄}</caption>
    </div>
  </section>

  <section>
    <h2>코드 변경 상세</h2>
    <p class="lede">개발자를 위한 항목입니다. 앞의 내용만으로 충분하다면 건너뛰셔도 됩니다.</p>
    <div class="scroll"><table>
      <thead><tr><th>파일</th><th>변경 전</th><th>변경 후</th><th>변경 이유</th></tr></thead>
      <tbody><tr><td><code>{경로}</code></td><td>{before 요약}</td><td>{after 요약}</td><td>{피드백 항목 or 설계 결정}</td></tr></tbody>
    </table></div>
  </section>

  <section>
    <h2>배운 점</h2>
    <ul><li>{새로 알게 된 것 · 다음에 참고할 패턴}</li></ul>
  </section>

  <section>
    <h2>개선 여지</h2>
    <ul><li>{현재 구현의 한계 · 향후 개선 가능한 부분}</li></ul>
  </section>

  <footer>
    <p>이 문서는 <code>/my-retro</code>로 생성되었습니다.</p>
  </footer>

</article>
</body>
</html>
```

내용이 없는 섹션은 자리표시자를 남기지 말고 해당 `<h2>` 블록째로 삭제합니다.

파일 생성 완료 후 경로를 반환합니다.
---

## 완료 보고 (메인 루프)

에이전트 완료 후 사용자에게 알립니다:

1. 생성된 retro 파일 경로 — 브라우저로 바로 열 수 있음을 함께 안내
2. 통합된 plan/review 파일 경로 (통합이 발생한 경우만)
3. `_archive/`로 옮긴 원본 파일 개수 — "삭제가 아니라 이동이므로 되돌릴 수 있습니다"
