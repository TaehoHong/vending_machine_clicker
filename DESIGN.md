# 현재 수정본 · v4

사용자 지정 레퍼런스는 [Click the Button](https://store.steampowered.com/app/3946950/Click_the_Button/)이다. 사용자가 사이드 패널 제거를 명시했다. 현재 수정본은 중앙 자판기·바닥 수색, 모서리 재화 HUD, 자판기 옆 구매 가격, 우하단 강화·해금 진입으로 구성한다. 상시 사이드 패널, 가방 퀵슬롯, 별도 음료 사용 버튼은 없다.

[Penpot v4](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&board-id=55aeaacb-aa46-80be-8008-cdca500ac9c3)

구상: `design/GAME_UI_V4_PLAN.md`. 수정 범위는 메인 플레이와 핵심 입력의 전후 상태다. 구매 성공 즉시 능력이 적용되고 남은 빈캔·용기는 해금 재료다. 자동으로 얻은 물품으로 능력이 오르지 않는다. 현재 숫자·가격·시간은 배치 검토용 예시다.

2026-10-18 요청에 따라 두 자판기를 완전한 정면으로 바꾸고, 배경을 일본풍 골목길로 교체했다. 기존 메인 보드에서 배경·자판기 이미지 채우기만 교체하고 이전 바닥 타일을 제거했다. 사이드 패널 없는 HUD·버튼·동전 수색 위치는 유지한다.

자판기와 골목 배경은 built-in image_gen으로 제작했다. 원본 `design/v4/vending-machine-front.png`, `design/v4/japanese-alley.png`, Penpot 사용본 `design/v4/vending-machine-front-web.png`, `design/v4/japanese-alley-web.png`, 생성 프롬프트 `design/v4/front-alley-prompts.txt`. HUD·버튼·문구·동전·빈캔·쓰레기통은 네이티브 도형과 텍스트다. 현재 보드 내보내기: `design/review/v4/main-front-alley-penpot.png`.

## 이전 v3 · 사용자 피드백으로 미채택

아래는 이전 산출물의 기록이다. 별도 음료 사용·보관 조작과 물품 용도를 잘못 해석했으므로 현재 제품 규칙이나 화면 설계의 근거로 쓰지 않는다. 확정 규칙은 PRODUCT.md를 따른다.

# 골목 자판기 · 게임 UI v3

화면·정보·상태·모션을 먼저 구상한 뒤 Penpot MCP로 제작했다. 상단 재화 HUD, 왼쪽 플레이 공간, 오른쪽 고정 조작 패널을 사용한다.

[Penpot v3 페이지](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=e28ede4c-b451-80ef-8008-cdbf66419fb9&board-id=def906f0-0911-8055-8008-cdc23d5f4bdf)

구상·모션 명세: `design/GAME_UI_PLAN.md`. 이전 기록: `design/DESIGN-v2.md`.

## 화면

| 화면 | 정보와 행동 |
|---|---|
| 시작 | 저장된 골목, 보유 재화, 이어하기·새 게임·설정 |
| 메인 | 골드·빈캔, 클릭 영역·진행 칸, 자동 수익, 회수할 물품, 가방 |
| 구매 | 선택 상품, 수량, 효과, 가격, 꽝 안내, 구매 후 잔액 |
| 결과 | 물품, 수량 변화, 사용·보관·다시 뽑기·복귀 |
| 수집함 | 분류, 수량, 미발견 상태, 페이지 표시, 물품 사용 |
| 강화 | 현재 → 다음 효과, 레벨, 비용, 강화 가능·빈캔 부족 |
| 자동화 | 가동 기계, 생산 주기, 해금 수집량, 설치 자리, 확률 회수 |
| 일시정지 | 계속하기, 음향, 모션 줄이기, 타이틀 복귀 |

기본 8화면에 꽝 결과, 음료 사용 후 2종, 보관 후, 강화 후, 모바일 메인, 모션 보드를 더한 총 15개 보드다. PC 1600×900, 모바일 메인 390×844다.

## 시각 체계

[Clicker Heroes](https://store.steampowered.com/app/363970/Clicker_Heroes/)의 재화·투자 비용·고정 조작 목록과 [Tiny Vending Machines](https://store.steampowered.com/app/3595460/Tiny_Vending_Machines/)의 픽셀 오브젝트·게임 패널을 직접 확인했다. 다른 게임의 에셋이나 규칙은 가져오지 않았다.

자판기·캔·동전·아이템·벽·바닥은 새로 만든 벡터다. Penpot 네이티브 보드·사각형·패스·텍스트이며 이전 AI 배경을 사용하지 않는다. 큰 글자는 Do Hyeon, 본문은 Noto Sans KR다. 남색 바탕, 크림 글자, 골드 재화·구매, 민트 사용·강화, 청색 보조 동작을 사용했다.

본문 보조 글자 대비는 패널 7.41:1, 비활성 버튼 4.60:1이다. 버튼 글자와 민트·골드 바탕 대비는 11.19:1, 12.26:1이다. 모바일 핵심 조작은 높이 48px 이상이며 조작 공간과 하단 패널을 분리했다.

## 모션과 검증

클릭 80ms 이내 반응 → 동전 등장 180ms → HUD 이동 300ms. 구매는 점등 → 기계 반응 → 배출 → 결과다. 음료 사용 후 능력을 적용하고 빈캔을 지급한다. 패널·결과 이동은 200ms dissolve다. 모션 보드에는 단계·시간·반복 연출 건너뛰기·모션 줄이기를 표시했다.

58개 조작 경로를 연결했다. 미리보기에서 메인 → 구매 → 획득 → 바로 사용과 강화 → 강화 완료를 직접 확인했다. 획득 후 사용 예시는 12,130 G·빈캔 37·콜라 3·클릭 3회다. 강화 예시는 빈캔 12·클릭 3회다. 보관 상태에서는 음료가 빈캔으로 바뀌지 않는다.

정적 상태를 연결한 디자인 프로토타입이다. 숫자는 상태별 고정 예시이며 화면 간 재화 누적을 계산하지 않는다. 실제 연속 클릭·무작위 뽑기·자동 생산 타이머·물리·파티클·음향·모바일 전체 흐름은 구현하지 않았다. 가격·확률·해금 수량·시간은 확정 전 예시다. 물의 구체적인 효과 수치는 새로 정하지 않았다.

## 자료

- `design/review/v3/main-penpot.png`: Penpot에서 직접 내보낸 메인.
- `design/review/v3/main-editor.png`: 편집기 메인.
- `design/review/v3/purchase-use-prototype.png`: 구매·획득·사용 후 클릭 검증.
- `design/review/v3/upgrade-prototype.png`: 강화 후 상태 검증.
- `design/review/v3/mobile-editor.png`: 모바일 검수.
- `design/game-ui-v3.py`: 원본 SVG 생성 소스.
- `design/penpot-v3-prepare.py`, `design/v3/*.penpot.js`: 네이티브 도형 생성·상태·연결·검증 소스.

v1·v2·Backstreet UI·Godot 페이지를 보존했다. 승인된 임시 MCP 연결을 사용했으며 인증 키를 파일이나 영구 설정에 저장하지 않았다.
