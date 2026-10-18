# 기획·디자인 자료와 접속 안내

이 문서의 경로는 저장소 루트 기준이다. 현재 작업 폴더는 `/Users/hongtaeho/clicker`이며 다른 PC에서는 저장소를 복제한 폴더를 기준으로 찾는다.

## 기획 문서

| 자료 | 위치 | 읽는 방법 |
| --- | --- | --- |
| 확정된 제품 방향·도메인 규칙 | [PRODUCT.md](../PRODUCT.md) | 작업 시작 시 먼저 읽는다. Steam PC 우선, Godot, 구매 성공 즉시 능력 적용 등 사용자 확정 규칙을 담고 있다. |
| 기획 원문 | [Notion 자판기 클릭커 게임](https://app.notion.com/p/3fcb6b9ead24800aa7bce8a1e1b045de) | 문서 접근 권한이 있는 Notion 계정으로 브라우저 또는 앱에서 연다. |
| 지역·자판기·재화 확장 기획 | [stages-2026-10-18.md](planning/stages-2026-10-18.md) | 사용자 결정 사항과 검토용 제안이 구분되어 있다. |
| 작업 지침 | [AGENTS.md](../AGENTS.md) | 기획을 확인하는 순서와 원문 접근 불가 시 처리 방법을 확인한다. |

Notion 원문과 로컬 기록이 충돌하면 최신 사용자 확정 규칙을 우선한다. 미정 수치나 검토용 제안을 확정 규칙으로 취급하지 않는다. 현재 게임의 구현 내용과 임시 밸런스는 루트 [README.md](../README.md)에 기록되어 있으며 기획 확정 여부와 별개다.

에이전트가 Notion을 다시 확인할 때는 연결된 Notion 도구로 해당 문서를 읽는다. 연결 계정·워크스페이스가 다르거나 문서 권한이 없어 접근하지 못하면 `PRODUCT.md`를 참고하고 원문을 최신 확인했다고 보고하지 않는다. 기존 `PRODUCT.md`에는 데스크톱 앱에서 읽었던 기록이 있으나, 이 안내를 작성하면서 원문을 다시 읽지는 않았다.

## 디자인 파일 위치

| 자료 | 위치 | 용도·상태 |
| --- | --- | --- |
| 현재 수정본 안내 | [DESIGN.md](../DESIGN.md) | v4 메인 플레이 방향과 이전 시안의 미채택 사유 |
| v4 화면 구상 | [GAME_UI_V4_PLAN.md](GAME_UI_V4_PLAN.md) | 사이드 패널 제거, 중앙 자판기, 즉시 능력 적용 |
| v4 소스·아트 | [v4/](v4/) | `main-play.svg`, 생성·Penpot 편집 스크립트, 자판기·골목 PNG, 프롬프트, `penpot-manifest.json` |
| v4 검수 이미지 | [main-front-alley-penpot.png](review/v4/main-front-alley-penpot.png) | 정면 자판기·골목 배경으로 교체한 Penpot 내보내기 |
| v5 비교 자료 | [v5/](v5/) | `machine-comparison.svg`, 자판기 B PNG. 비교 자료이며 현재 채택 시안으로 단정하지 않는다. |
| 기존 Godot 적용 시안 | [penpot-ui/README.md](penpot-ui/README.md) | 메인·플레이·획득·ESC의 SVG·PNG와 토큰, 생성 소스 |
| 기존 구현 화면 캡처 | [penpot-latest/README.md](penpot-latest/README.md), [godot-applied/](godot-applied/) | Godot 구현 화면 기록. 새 v4 수정본과 구분한다. |
| 이전 v3 | [GAME_UI_PLAN.md](GAME_UI_PLAN.md), [v3/](v3/), [review/v3/](review/v3/) | 미채택 기록. 별도 음료 사용·보관 및 고정 사이드 패널을 현재 규칙의 근거로 사용하지 않는다. |
| 이전 v2·초기 자료 | [DESIGN-v2.md](DESIGN-v2.md), [assets/](assets/), `penpot-draft.js`, `penpot-game.js` | 이전 구상·생성 소스·배경과 프롬프트 |

PNG는 이미지 뷰어에서, SVG는 브라우저 또는 벡터 편집기에서 연다. 기존 Godot 적용 SVG는 Penpot 캔버스로 가져와 편집할 수 있다. v4의 네이티브 편집본은 아래 Penpot 링크에서 연다. `.penpot.js`는 Penpot 실행 컨텍스트용 코드이며 브라우저에서 파일을 여는 것으로 실행되지 않는다.

## Penpot 접속

공통 파일 ID는 `cd444aaf-0d8c-801b-8008-cda246e18650`, 팀 ID는 `ce180602-f36b-8035-8008-cda23f0a1b46`이다.

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

이전 작업에는 MCP가 403으로 차단되어 브라우저 UI로 작업한 기록과 임시 MCP 연결로 편집한 기록이 모두 있다. 영구 MCP 등록이나 현재 연결 성공을 보장하는 기록은 아니다. 연결이 안 되면 로그인한 브라우저에서 확인하고 로컬 이미지를 참고한다. 이번 문서화에서는 기존 소스·기록과 파일 경로를 확인했으며 외부 서비스 로그인이나 MCP 재접속은 검증하지 않았다.
