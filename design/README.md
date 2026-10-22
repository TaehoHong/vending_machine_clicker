# 기획·디자인 원본 안내

기획 SSOT는 [Notion 자판기 클릭커 게임](https://app.notion.com/p/3fcb6b9ead24800aa7bce8a1e1b045de), 디자인 SSOT는 [Penpot](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650)이다. 로컬 문서는 원본을 대체하지 않는다. 작업 규칙은 [DESIGN.md](../DESIGN.md), 기획 요약은 [PRODUCT.md](../PRODUCT.md)를 따른다.

## Penpot 구성

파일 ID: `cd444aaf-0d8c-801b-8008-cda246e18650` · 팀 ID: `ce180602-f36b-8035-8008-cda23f0a1b46`.

| 페이지 | 내용 |
| --- | --- |
| [00 · 디자인 시스템](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers) | [팔레트·폰트](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=438228d3-7709-80fa-8008-d11fbc46be89), [공통 버튼](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=d9c1a69c-6a27-809e-8008-d107e6137aa4), [공통 패널·HUD](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=b3f38c37-8163-8042-8008-d10122b08b05) |
| [01 · 게임 화면](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&layout=layers) | 현재 채택 화면과 검토 중 화면의 배치·상태 |
| [02 · 에셋](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers) | 음료·자판기·FX·HUD 프레임·아이콘·출력 조각 |
| [99 · 보관함](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=6587dfe1-cdcc-8063-8008-cfe00be50226&layout=layers) | 이전·미채택 시안. [이전 공통 UI 검토안](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=6587dfe1-cdcc-8063-8008-cfe00be50226&layout=layers&board-id=80a74875-ea87-801d-8008-d12ac018eeb8) 포함 |

## 적용 파일

| 자료 | 안내·파일 | 상태 |
| --- | --- | --- |
| HUD A 버튼 | [규격·ID](hud-buttons/README.md), `src/shared/ui/icons/hud_buttons/` | 디자인 채택, 게임 화면 연결 전 |
| 가격 버튼 A 기본형 | [원본 안내](purchase-button/README.md) | 공통 버튼 보드에서 재사용 |
| Play·음료와 능력 화면 | [적용본 안내](drink-screen-references/applied/play-style/README.md) | 현재 게임 적용 |
| 재화 HUD·가격판 | [안내](currency-hud/README.md) | 현재 게임 적용 |
| 음료·자판기 원본 | [음료 15종](v9/README.md), [자판기](v10/README.md) | 02 에셋의 원본 사용 |

## MCP 원본 접근 복구 절차

현재 파일 ID를 대조하고 읽기·쓰기 결과를 확인한다. MCP가 연결되지 않으면 로그인된 Penpot을 Computer Use로 직접 편집한다. 접속값이 다른 경우 현재 계정의 기존 서버 연결을 확인하되 인증값을 문서·로그·저장소에 남기지 않는다. 저장 후 다시 열어 반영과 렌더링을 확인한다. 접근 실패·미검수는 [DESIGN.md](../DESIGN.md)에 대기 항목으로 기록한다.

## 피버 HUD 에셋 · 2026-10-21

[수색·펀치 피버 HUD](fever-hud/README.md)를 00 디자인 시스템 → 공통 패널·HUD의 일시정지 창 아래에 추가했다. 기존 게임의 표시를 편집 가능한 프레임·문구·시간·게이지·배율로 분리한 재사용 컴포넌트이며, 388×84 SVG 두 개를 제공한다. 원본 저장·재로딩을 확인했다. 게임 코드나 효과·수치 변경은 없다.

## 2026-10-22 음료 능력·강화 상태 표시

기존 Cafe24 PRO UP과 Play 공통 패널·버튼을 재사용한다. 획득 기록과 실제 강화량/한도를 분리하고 누적 효과·최대 강화 추첨 제외/피버 반복 상태를 표시한다. 레이아웃·스타일·등급색은 이번 작업에서 변경하지 않았다.
편집 원본은 [02 에셋 상세 패널 마스터](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers&board-id=b3f38c37-8163-8042-8008-d10123f3f7c8)다. 네이티브 Text를 `획득 수 · 강화 적용/한도`, `누적 능력 · 추첨 상태`로 갱신하고 저장을 확인했다. 00 디자인 시스템의 연결 인스턴스가 같은 마스터를 사용한다.
적용 경로: `src/features/drinks/drink_screen.gd`, `src/features/play/play.gd`, 단일 음료 정의 `src/data/drink_catalog.gd`. 새 이미지/테마 파일은 없다. 기존 일시정지·상세 패널 스타일의 승인 대기 작업을 이번 변경에 포함하지 않았다.
