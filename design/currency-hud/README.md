# 재화 HUD·가격 표시

현재 원본은 [00 공통 패널·HUD](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=b3f38c37-8163-8042-8008-d10122b08b05)다. 216×44 예시의 작은 어두운 배경에 골드·빈캔 아이콘과 24px 숫자를 표시하고, 게임에서는 숫자 폭에 맞춰 배경을 늘린다. 통화 이름은 표시하지 않고 정확한 수량은 툴팁으로 확인한다.

게임 표시 소유자는 `src/features/play/play.gd`, 금액 변환은 `src/shared/formatting/amount_format.gd`다. 10,000 미만 쉼표, 이후 K·M·B 축약 규칙과 실제 정수 잔액을 유지한다. 가격은 [자판기 내부 LCD](../purchase-button/README.md)에 숫자만 표시한다. 첫 가격 100 Gold, 매 구매 5% 증가 계산과 저장은 기존 세션 규칙이다.

이 폴더의 기존 SVG·캡처·가격 제안은 이전 기록이며 현재 디자인의 원본이 아니다. 이전 +5 Gold 선형안은 미채택이다. 기획 규칙의 SSOT는 Notion, 디자인 원본은 Penpot을 유지한다.
