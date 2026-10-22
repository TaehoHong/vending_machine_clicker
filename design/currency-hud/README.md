# 재화 HUD·가격 표시

현재 원본은 [02 공통 패널·HUD 원본](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers&board-id=b1fb0fb9-8b3e-80e3-8008-d3844c04d0ca)다. 216×44 예시의 작은 어두운 배경에 골드·빈캔 아이콘과 24px 숫자를 표시하고, 긴 숫자에서도 읽기 쉽도록 폭을 늘리는 디자인이다. 새 디자인은 게임 미적용이다. 통화 이름은 표시하지 않고 정확한 수량은 툴팁으로 확인한다.

게임 표시 소유자는 `src/features/play/play.gd`, 금액 변환은 `src/shared/formatting/amount_format.gd`다. 10,000 미만 쉼표, 이후 K·M·B 축약 규칙과 실제 정수 잔액을 유지한다. 가격은 [자판기 내부 LCD](../purchase-button/README.md)에 숫자만 표시한다. 첫 가격 100 Gold, 매 구매 5% 증가 계산과 저장은 기존 세션 규칙이다.

이 폴더의 기존 SVG·캡처·가격 제안은 이전 기록이며 현재 디자인의 원본이 아니다. 이전 +5 Gold 선형안은 미채택이다. 기획 규칙의 SSOT는 Notion, 디자인 원본은 Penpot을 유지한다.
