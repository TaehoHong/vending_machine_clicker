# 재화 HUD 표시 규칙·이전 디자인 기록

> 2026-10-20 페이지 정리: 현재 원본 위치는 [페이지·에셋 정리 기록](../page-organization/README.md)을 따른다. 아래 Y 좌표·페이지 이름·생성 manifest는 작성 당시 기록이며, Penpot 링크는 현재 위치로 갱신했다.

- 편집 가능한 원본: `gold-hud-compact.svg` (네이티브 도형·텍스트).
- 현재 디자인: [00 공통 패널·HUD](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=b3f38c37-8163-8042-8008-d10122b08b05). 표시 규칙의 게임 적용 여부와 디자인 원본의 채택 상태를 구분한다.
- 이전 검토 원본: [99 보관함 · 재화·가격판](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=6587dfe1-cdcc-8063-8008-cfe00be50226&layout=layers&board-id=cba4763b-9ae7-8052-8008-d2a633070914). 02 에셋의 중복 검토 보드를 보관함으로 옮겼으며, 아래 SVG·캡처·좌표는 작성 당시 기록이다.
- 기획 동기화: [Notion](https://app.notion.com/p/3fcb6b9ead24800aa7bce8a1e1b045de)의 `2026-10-19 · 골드 HUD 표시와 음료 구매 가격 검토` 절. 확정 규칙과 미확정 가격 제안을 구분했으며 새로고침 후 저장된 내용을 확인했다.
- 동기화 증거: `penpot-synced.png`, `notion-synced.png`.
- 실제 게임 미리보기: `gold-10000.png`, `gold-999999.png` 등. 이전 `design/font-cafe24/play.png`는 축약 전 상태 기록이다.
- 폰트 원본·라이선스: `../../ui/fonts/Cafe24PROUP.ttf`, `../../ui/fonts/Cafe24PROUP-OFL.txt`. UI 구현: `../../game.gd`의 `_format_gold`와 `_refresh_ui`.

## 확정·적용

10,000 미만은 쉼표, 이상은 소수점 한 자리 버림으로 K를 표시한다. 백만부터 M, 십억부터 B를 사용한다. 실제 정수 잔액은 바꾸지 않으며 툴팁에는 정확한 금액을 표시한다. 글자 폭이 158px를 넘으면 28px부터 줄여 HUD 내부에 맞춘다.

## 구매 가격 · 5% 상승 확정 및 적용

첫 가격 100 Gold. n번째 구매는 `ceil(100 × 1.05^(n-1))` Gold. 성공한 구매 횟수를 저장하고 기존 저장은 누적 음료 수로 이어받는다. 큰 가격은 축약 표시한다.

현재 편집 원본: `purchase-price-5percent.svg`. 같은 Penpot 페이지의 `가격판 · 매 구매 5% 상승 · 확정` 그룹으로 동기화했다. 실제 게임 미리보기는 `purchase-price-1.png`부터 `purchase-price-100.png` 중 저장된 회차를 참고한다. 증거는 `penpot-price-synced.png`, `notion-price-synced.png`다.

`price-proposal.md`는 이전 미채택 +5 Gold 선형안 기록이며 현재 규칙으로 사용하지 않는다.

## 동기화 상태

이번 HUD 축약 표시와 가격 검토 내용은 Notion 및 Penpot 파일에 반영했다. 미동기화 항목 없음. Penpot에서는 새 HUD 명세 페이지를 최신 채택본으로 추가했으며 이전 메인 보드의 과거 고정 숫자 예시는 그대로 보존했다.
