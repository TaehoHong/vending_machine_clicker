# 기획·디자인 자료와 접속 안내

2026-10-20 구조 전환: 현재 게임 코드는 `src/`, 게임 에셋은 `assets/`, 검증은 `tests/features/`·`tests/integrations/`에 있다. [현재 아키텍처](../docs/06-architecture.md)를 따른다. 과거 적용 기록의 이전 코드 경로는 당시 이력이다. 기획·디자인 원본은 바뀌지 않았다.

**기획 SSOT는 Notion, 디자인 SSOT는 Penpot이다**(2026-10-20 사용자 확정). `PRODUCT.md`·`DESIGN.md`와 이 안내, PAVE 문서는 원본을 참조하는 로컬 요약·탐색 자료다. 확정 변경은 원본에 반영하고 로컬 요약을 함께 갱신한다. 접근할 수 없으면 대상·내용·사유를 동기화 대기로 남긴다.

## Penpot 페이지 구성 · 2026-10-20 정리 완료

사용자 확정에 따라 **00 시스템 / 01 게임 화면 / 02 에셋(HUD 포함) / 99 보관함** 순서의 4개 페이지로 정리했다. 공통 UI 마스터는 00, 채택·검토 중 화면은 01, 게임 아트와 HUD는 02, 이전 시안은 99에서 찾는다. 기존 컴포넌트 120개를 유지했다. [현재 원본 링크·이동 ID 매핑·검수 이미지](page-organization/README.md).

작업 준수사항은 [DESIGN.md](../DESIGN.md#디자인-작업-준수사항)에서 관리한다. Penpot 안의 작성 규칙 보드는 제거했다. [작성 규칙 초안 산출물](authoring-rules/README.md)은 과거 기록이다. 기존 생성 스크립트·manifest의 옛 페이지·보드 ID와 Y 좌표를 현재 위치로 사용하지 말고, 재실행 전 현재 원본과 이동 기록을 확인한다.

이 문서의 경로는 저장소 루트 기준이다. 현재 작업 폴더는 `C:/Users/gusgh/Documents/backstreet-clicker`이며 다른 PC에서는 저장소를 복제한 폴더를 기준으로 찾는다.

## 기획 문서

| 자료 | 위치 | 읽는 방법 |
| --- | --- | --- |
| 제품 방향·도메인 규칙의 로컬 요약 | [PRODUCT.md](../PRODUCT.md) | 작업 시작 시 원본 링크·확인 시점·미동기화 내역을 먼저 읽는다. 최신 기획 전체의 사본은 아니다. |
| 기획 SSOT | [Notion 자판기 클릭커 게임](https://app.notion.com/p/3fcb6b9ead24800aa7bce8a1e1b045de) | 문서 접근 권한이 있는 Notion 계정으로 브라우저 또는 앱에서 연다. |
| 지역·자판기·재화 확장 기획 | [stages-2026-10-18.md](planning/stages-2026-10-18.md) | 사용자 결정 사항과 검토용 제안이 구분되어 있다. |
| 작업 지침 | [AGENTS.md](../AGENTS.md) | 기획을 확인하는 순서와 원문 접근 불가 시 처리 방법을 확인한다. |

Notion 원문과 로컬 기록이 충돌하면 기획 SSOT인 Notion을 확인한다. 새 사용자 지시는 원본에 반영하며 미동기화 상태를 확정 원본 반영과 구분한다. 미정 수치나 검토용 제안을 확정 규칙으로 취급하지 않는다. 현재 게임의 구현 내용과 임시 밸런스는 루트 [README.md](../README.md)에 기록되어 있으며 기획 확정 여부와 별개다.

에이전트가 Notion을 다시 확인할 때는 연결 도구로 해당 문서를 읽는다. 접근하지 못하면 `PRODUCT.md`를 참고하고 원문을 최신 확인했다고 보고하지 않는다. 2026-10-18 재검토에서는 Notion MCP가 404를 반환했으나 CUA 연결 도구로 로그인된 Notion 앱에서 같은 URL을 새로고침해 15종 음료·피버 추가 내용을 확인했다. 인증 정보를 제외한 [원문 확인 기록](planning/notion-source-2026-10-18.json)과 `PRODUCT.md`의 Latest Planning Review에 구분하여 기록했다.

## 디자인 파일 위치

| 자료 | 위치 | 용도·상태 |
| --- | --- | --- |
| 현재 게임 디자인 시스템 | [current-game-system/README.md](current-game-system/README.md) | 00의 A 채택 01–03 / 현재 구현 90–93 / 참고 98–99. 승인 24색·5상태 버튼과 기존 Play·메뉴 자료를 구분한다. |
| HUD A 버튼 · 디자인 시트 채택 | [hud-buttons/README.md](hud-buttons/README.md) | 00에 16종 × 5상태 조립 마스터, 02에 14아이콘·30프레임·연결 견본 18개·A 글꼴. 네이티브 문구 편집, 기존 가격 기본형 재사용. 게임 미적용. |
| A 픽셀 가격 버튼 | [purchase-button/README.md](purchase-button/README.md) | 금액만 표시하는 144×56 `100 G` 버튼. 기존 02 에셋 페이지에 재사용 컴포넌트와 Cafe24 PRO UP 텍스트 스타일 등록. |
| 확정 음료 에셋 15종 | [v9/README.md](v9/README.md), [전체 확인 이미지](v9/approved-items.png) | 일반 14종 승인 + 황금음료 05 오로라 골드 확정. PNG·원본 이미지 내장 SVG를 각각 분리했다. 기존 **02 · 에셋 라이브러리** 안에 독립 컴포넌트 15종 등록 완료. |
| 현재 수정본 안내 | [DESIGN.md](../DESIGN.md) | v5 에셋 전용 범위, 추가 제작 목록, 기획·구현 차이와 이전 시안 기록 |
| v4 화면 구상 | [GAME_UI_V4_PLAN.md](GAME_UI_V4_PLAN.md) | 사이드 패널 제거, 중앙 자판기, 즉시 능력 적용 |
| v4 소스·아트 | [v4/](v4/) | `main-play.svg`, 생성·Penpot 편집 스크립트, 자판기·골목 PNG, 프롬프트, `penpot-manifest.json` |
| v4 검수 이미지 | [main-front-alley-penpot.png](review/v4/main-front-alley-penpot.png) | 정면 자판기·골목 배경으로 교체한 Penpot 내보내기 |
| v5 에셋 전용 자료 | [v5/](v5/) | 기존 13개 컴포넌트와 [추가 제작 27항목](v5/asset-requirements.csv). 최신 15종 음료 배정안의 신규 6종·환타 포도 검수와 피버 에셋은 제작 목록이며 완료 아트가 아니다. JSON에는 원문 근거·모션·미정 규칙도 기록한다. 새 게임 화면은 제외한다. |
| 기존 Godot 적용 시안 | [penpot-ui/README.md](penpot-ui/README.md) | 메인·플레이·획득·ESC의 SVG·PNG와 토큰, 생성 소스 |
| 기존 구현 화면 캡처 | [penpot-latest/README.md](penpot-latest/README.md), [godot-applied/](godot-applied/) | Godot 구현 화면 기록. 새 v4 수정본과 구분한다. |
| 이전 v3 | [GAME_UI_PLAN.md](GAME_UI_PLAN.md), [v3/](v3/), [review/v3/](review/v3/) | 미채택 기록. 별도 음료 사용·보관 및 고정 사이드 패널을 현재 규칙의 근거로 사용하지 않는다. |
| 이전 v2·초기 자료 | [DESIGN-v2.md](DESIGN-v2.md), [assets/](assets/), `penpot-draft.js`, `penpot-game.js` | 이전 구상·생성 소스·배경과 프롬프트 |

PNG는 이미지 뷰어에서, SVG는 브라우저 또는 벡터 편집기에서 연다. 기존 Godot 적용 SVG는 Penpot 캔버스로 가져와 편집할 수 있다. v4의 네이티브 편집본은 아래 Penpot 링크에서 연다. `.penpot.js`는 Penpot 실행 컨텍스트용 코드이며 브라우저에서 파일을 여는 것으로 실행되지 않는다.

## Penpot 접속

2026-10-18 음료 15종 교체·자판기 부품 36종 분해 및 원본/연결 복사본 적용 기록은 [v10/README.md](v10/README.md)에 있다. 사용자 변경 지시에 따라 이번 작업은 Computer Use로 진행했다.

공통 파일 ID는 `cd444aaf-0d8c-801b-8008-cda246e18650`, 팀 ID는 `ce180602-f36b-8035-8008-cda23f0a1b46`이다.

- [에셋 라이브러리 · 확정 음료 15종](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=af2aed71-3cfe-80ea-8008-ceaf7492d553&board-id=e7808af8-2ea3-8077-8008-cedf2d6bd36f&layout=layers)

- [현재 v4 메인 보드](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&board-id=55aeaacb-aa46-80be-8008-cdca500ac9c3)
- [기존 Godot UI 시안 5화면](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=311487d5-89f3-8074-8008-cda65b4d2bec&layout=layers)
- [기존 Godot 구현 화면 캡처 페이지](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=469fc32a-9a9d-800d-8008-cdb900d3f532&layout=layers)
- [이전 v3 페이지](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=e28ede4c-b451-80ef-8008-cdbf66419fb9&layout=layers)

브라우저에서 `design.penpot.app`에 로그인하고, 대상 팀·파일 권한이 있는 계정으로 위 링크를 연다. 편집하려면 편집 권한이 필요하다. 링크가 열리지 않으면 로그인 계정과 팀·파일 공유 권한을 확인한다.

## Penpot MCP·기존 연결 스크립트

사용 가능한 Penpot 연결 도구가 있으면 해당 연결을 사용한다. 기존 임시 연결 스크립트는 [penpot-mcp-session.py](penpot-mcp-session.py)이며 Python 3 표준 라이브러리만 사용한다.

- 접속 주소: `https://design.penpot.app/mcp/stream`. 스크립트가 실행 시 `userToken` 쿼리를 붙인다.
- 필수 환경변수: `PENPOT_SESSION_KEY`. 유효한 값은 실행 환경에만 전달하고 저장소·공유 URL·로그에 남기지 않는다.
- 실행: 저장소 루트에서 `python3 design/penpot-mcp-session.py`. 환경변수가 없으면 실행되지 않는다.
- 시작 시 MCP initialize를 수행하고 성공하면 `{"ready": true}`를 출력한다. 이후 표준 입력으로 한 줄에 하나씩 JSON 명령을 받는다.
- 도구 목록: `{"list": true}`. 종료: `{"close": true}`. 실제 도구 이름·인자는 반환된 스키마를 확인한 뒤 전달한다.

이전 작업에는 MCP가 403으로 차단되어 브라우저 UI로 작업한 기록과 임시 MCP 연결로 편집한 기록이 모두 있다. 이 과거 기록만으로 현재 연결 상태를 판단하지 않는다.

### MCP 원본 접근 복구 절차

1. 로그인된 Penpot에서 위 원본 파일을 열고 MCP 연결을 켠다. 브라우저에 `MCP connected`가 떠도 Codex 쪽 접속값이 같은지는 별도로 확인한다.
2. `No Penpot instance connected for user token`이 발생하면 Penpot의 메인 메뉴 → MCP server → Manage에서 현재 계정의 서버 URL을 확인하고 Codex의 기존 `penpot` 서버 URL과 대조한다. 인증값은 출력·캡처·커밋하지 않는다.
3. 두 값이 다르면 기존 서버 항목의 URL만 현재 계정 값으로 교체한다. 새 키 발급이나 다른 계정으로의 전환을 기본 해결책으로 삼지 않는다. Codex에서 해당 MCP 서버를 재시작해 이미 로드된 연결에도 반영한다.
4. 현재 파일 ID를 읽어 `cd444aaf-0d8c-801b-8008-cda246e18650`과 대조하고 페이지 목록·원본 보드 내보내기를 확인한다. 쓰기 확인이 필요하면 임시 객체 생성·수정·제거 후 남은 객체가 없는지 검증한다. 기존 디자인으로 쓰기 테스트하지 않는다.
5. 원격 접속 등으로 Codex의 서버 재시작이 불가능하면 위 `penpot-mcp-session.py`로 새 MCP 세션을 열어 작업한다. 현재 사용자 설정의 `penpot` URL에서 인증값을 프로세스 메모리로 읽어 `PENPOT_SESSION_KEY`에 전달하며, 값 자체를 사용자에게 다시 입력시키거나 로그·공유 문서에 기록하지 않는다. 시작된 세션에서 파일 ID를 다시 대조한다.

2026-10-20에는 현재 Penpot 계정과 Codex 설정의 접속값 불일치를 확인해 기존 사용자 설정의 URL 한 항목만 교체했다. 새 MCP 세션에서 파일명 `Design`, 지정 파일 ID, 페이지 6개, 원본 보드 PNG 읽기와 임시 객체 생성·수정·제거를 검증했다. 재시작할 수 없는 원격 사용 상황에서 위 스크립트로 새 연결을 유지해 읽기·쓰기 작업이 가능함을 확인했다. 이미 로드된 기본 MCP 도구의 재시작 후 검증은 별도이며 향후 모든 세션의 자동 연결을 보장하지 않는다.

## 최신 재화 HUD · 2026-10-19

- [편집 원본 SVG](currency-hud/gold-hud-compact.svg), [적용·동기화 안내](currency-hud/README.md), [이전 가격 검토안·미채택](currency-hud/price-proposal.md).
- [Penpot 04 · 재화 HUD · 축약 표기](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=6587dfe1-cdcc-8063-8008-cfd0f79b9bd3&layout=layers): 원본 도형·텍스트를 반영했다. 예전 페이지와 시안은 기록으로 보존했다.
- 실제 게임 미리보기: [10.0K Gold](currency-hud/gold-10000.png), [999.9K Gold](currency-hud/gold-999999.png). 이전 font-cafe24 캡처의 금액 표기는 과거 기록이다.
- [Penpot 저장 확인](currency-hud/penpot-synced.png), [Notion 저장 확인](currency-hud/notion-synced.png). 이번 변경의 미동기화 항목 없음.

### 구매마다 5% 가격 상승 · 사용자 확정

현재 가격판 원본은 [purchase-price-5percent.svg](currency-hud/purchase-price-5percent.svg)다. 위 Penpot HUD 페이지에 함께 반영했으며 [가격판 동기화 확인](currency-hud/penpot-price-synced.png), [Notion 가격 확정 확인](currency-hud/notion-price-synced.png)을 보관한다. 구매·저장·불러오기 검증: `tests/purchase_price_test.gd`. 기존 선형 +5 Gold 문서는 미채택 기록이다.

## 능력 목록 창 비교 시안 · 미채택

[세 가지 PNG·SVG·프롬프트 안내](ability-list-concepts/README.md). [Penpot 05 · 능력 창 · 비교 시안](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=6587dfe1-cdcc-8063-8008-cfe00be50226&layout=layers)에 네이티브 패널·텍스트를 반영했다. 내장 음료 이미지 표시가 누락되는 부분은 미동기화로 남겼다. 게임에는 아직 미적용이며 수치는 예시다.

## 중앙 자판기 크기 비교 · 2026-10-20 · 선택 전

[단순 배치도 3종: +5% / +10% / +15%](drink-machine-size/README.md). 2:3 비율·바닥·중심 고정, HUD와 정보창 위치 유지. 편집 SVG와 PNG를 함께 보관하고 Penpot 통합 페이지 Y=10600에 동기화했다. B(+10%)는 추천안이며 게임 적용 크기는 아직 변경하지 않았다.

## 능력 + 음료수 추가 통합 비교 · 미채택

**현재 게임 적용본:** [Play 픽셀 스타일 통일](drink-screen-references/applied/play-style/README.md). Play 음료수 추가 버튼 제거, 빈캔 HUD·요약·닫기·정보창을 공유 픽셀 스타일로 변경했다. 실제 Godot 실행 캡처·편집 원본·테스트 안내를 보관한다. 연결선 없음, 재진입 초기화, 호버 무반응. Penpot Y=9400·Notion·PRODUCT.md에 동기화했다. 아래 미적용 표기는 이전 제작 시점의 기록이다.

[A 기반 완성 화면 레퍼런스: 낮·노을·밤](drink-screen-references/README.md). 원본 자판기 384×576, 2:3을 유지하는 편집용 SVG와 AI PNG를 구분해서 보관한다. Penpot Y=7400에 반영했으며 게임에는 미적용이다.

**현재 실제 아트 미리보기:** [A 배치 + 게임 자판기](drink-layout-wireframes/game-machine-preview/README.md). 게임 원본 아트를 포함한 SVG는 384×576, 2:3을 유지하며 Penpot Y=6400에 반영했다. 생성 PNG는 시각 참고이며 정확한 치수는 편집 원본을 따른다. 기획·게임 코드 변경 없음.

**최신 A 수정:** [음료 이름만 남긴 배치도](drink-layout-wireframes/a-right-card.png), [편집 SVG](drink-layout-wireframes/a-right-card.svg). 자판기 캔 비용 배지를 모두 제거했고 오른쪽 선택 카드에서만 비용을 확인한다. Penpot Y=5400 및 Notion·PRODUCT.md에 반영했다. 기존 3종 비교와 배지 표시 설명은 이전 기록이다.

**현재 검토:** [중앙 자판기 + 작은 선택 정보 카드 배치도 3종](drink-layout-wireframes/README.md). 이전 완성 이미지들은 미채택이다. 미해금 음료만 캔 배지, 선택 상태별 작은 카드, 상단 능력 요약 버튼을 사용한다. Penpot Y=4400·Notion·PRODUCT.md에 반영했으며 A/B/C 최종 배치는 미선택이다.

**현재 수정본:** [밝은 카드형 · 동일 크기 패널](combined-drink-concepts/adopted-light-aligned/README.md). 비용은 이름 오른쪽 같은 줄, 하단 요약·다음 해금 제거, 자판기 확대, 우측 동일 크기 박스와 작은 내부 콘텐츠. Penpot Y=3200·Notion·PRODUCT.md에 반영했다. 게임 적용 전 시안이며 아래 compact는 이전 기록이다.

**최신 선택:** [밝은 카드형 축소 수정](combined-drink-concepts/adopted-light-compact/README.md). 사용자가 1번을 선택했고, 비용 표시·우측 축소를 반영했다. 편집용 구조는 같은 Penpot 페이지 Y=2150이다. Notion과 PRODUCT.md에 방향을 동기화했고 게임에는 미적용이다. 아래 내용은 비교 당시 기록이다.

후속 [A안 오른쪽 패널 3종](combined-drink-concepts/right-variants/README.md)은 왼쪽을 유지한 카드형·전자형·도감형이다. 기존 Penpot 통합 페이지 아래에 네이티브 편집용 구조를 추가했다. PNG는 완성 분위기 레퍼런스이며 게임 미적용이다.

[통합 시안 3개·편집용 구조·프롬프트](combined-drink-concepts/README.md). [Penpot 06 · 통합 시안](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=6587dfe1-cdcc-8063-8008-cfe19a746796&layout=layers)에 편집 가능한 패널·텍스트·자리표시 도형을 반영했다. AI 완성 분위기 PNG와 구조 SVG는 구분한다. 게임과 확정 기획은 미변경이다.
