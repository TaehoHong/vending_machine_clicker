# 디자인 원본과 게임 적용 경로

디자인 SSOT는 [Penpot](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650), 기획 SSOT는 [Notion](https://app.notion.com/p/3fcb6b9ead24800aa7bce8a1e1b045de)이다. 편집·검수는 [DESIGN.md](../DESIGN.md)를 따른다.

| 원본 | 용도 |
| --- | --- |
| [00 · 디자인 시스템](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers) | 공유 색상·폰트와 인스턴스 견본 |
| [01 · 게임 화면](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&layout=layers) | 채택 화면·상태·배치 |
| [02 · 에셋](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers) | 에셋·컴포넌트 원본 |
| [99 · 보관함](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=6587dfe1-cdcc-8063-8008-cfe00be50226&layout=layers) | 이전·미채택 원본 |

| 원본 | 실제 적용 파일·소유자 |
| --- | --- |
| [HUD 버튼](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers&board-id=b1fb0fb9-8b3e-80e3-8008-d383e5fd8f92) | `src/shared/ui/icons/hud_buttons/`, `src/shared/ui/themes/play_theme.tres`, `src/shared/ui/pixel_button.gd` · [연결 안내](hud-buttons/README.md) |
| [패널·재화·가격 LCD](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers&board-id=b1fb0fb9-8b3e-80e3-8008-d3844c04d0ca) | `src/shared/ui/themes/`, `src/features/play/play.tscn`, `src/features/play/play.gd` |
| [음료·자판기](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers) | `assets/`, `src/features/play/effects/vending_display.tres`, `src/features/drinks/` |
| [수색 발광·동전 줍기](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers&board-id=b1fb0fb9-8b3e-80e3-8008-d39c5327f8ba) · [미리보기](https://design.penpot.app/#/view?file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&section=interactions&frame-id=b1fb0fb9-8b3e-80e3-8008-d39cd4a94a32) | `src/features/play/effects/search_hint.gd`, `src/features/play/effects/search_light.gd`, `src/features/play/effects/search_coin.gd`, `src/features/play/play.gd` |
| [화면 배치](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&layout=layers) | `src/features/play/`, `src/features/drinks/`, `src/features/main_menu/`, `src/features/pause/` |

작은 재화 HUD·내부 숫자 LCD·진열 정렬·수색 장갑·목표 상세·재화 툴팁·동전 줍기 연출의 최신 디자인은 게임 미적용이다. 적용할 때 Penpot의 현재 채택본을 다시 확인한다. 상세 규격·컴포넌트 목록·보관 상태·변경 이력은 Penpot에서 확인한다.
