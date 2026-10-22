# 자판기 가격 LCD

[00 공통 버튼 원본](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=d9c1a69c-6a27-809e-8008-d107e6137aa4)의 기존 컴포넌트 `8e4548c6-4cd1-8076-8008-ceef6c094af7`을 56×32 LCD로 수정했다. 금액은 Cafe24 PRO UP 19px 네이티브 Text, `#C0E58C` 초록 숫자만 표시한다. G·구매·투입 문구와 외부 가격판은 없다.

게임의 `SlotHint/Price`, 공유 테마 `PricePlate`에 연결한다. 잔액 부족은 숫자를 회색으로 구분하며 큰 가격은 기존 금액 표기로 축약하고 폭에 맞춰 줄인다. 100은 시각 예시이며 가격 계산은 세션이 소유한다. [등록 정보](penpot-manifest.json)를 따른다.

기존 `price-only-v3.svg`·PNG·144×56 기록은 이전 출력이다. 현재 원본으로 사용하지 않는다.
