# 07. 코드 안내

2026-10-20 승인된 구조 전환의 실제 소스를 기준으로 갱신했다. 폴더·책임·의존성은 [아키텍처](06-architecture.md), 작성 전/후 검사는 [개발 규칙](02-development-rules.md#코드-품질-필수-검사)를 따른다.

## 탐색 순서

관련 행의 근거 경로에 커밋·staged·unstaged 변경이 있는지 먼저 확인한다. 대상 소유자·직접 호출자/피호출자·공유 예시·테스트를 읽고 소유권이 없거나 모순될 때만 검색을 넓힌다. 예: 구매 가격은 `game_session.purchase` → `economy_rules.current_draw_price` → Play 구매 요청 → 구매/저장 테스트 순서로 확인한다. 예전 루트 game.gd·ui/ 경로에 새 기능을 만들지 않는다. 게임에 연결된 A HUD SVG는 `src/shared/ui/icons/hud_buttons/`에 있으며 연결 안내는 `design/hud-buttons/README.md`다.

## 모듈 맵

| 영역 | 경로·진입점 | 책임·호출 방향 | 관련 검증 | Evidence paths |
| --- | --- | --- | --- | --- |
| 실행·연결 | src/app/main.tscn, main.gd `_ready`, `_start_game`, `_save_game` | 메뉴·Play·세션·저장 생성/연결, 백업·저장 결과 처리 | menu_test.gd | project.godot, src/app/ |
| 메뉴 | src/features/main_menu/main_menu.tscn, main_menu.gd `update_save_status` | 저장 가능 상태 표시, 시작/종료 signal | menu_test.gd | src/features/main_menu/, src/app/main.gd |
| 실제 진행 | src/game/game_session.gd, progress_state.gd | 구매·수색·해금·퀘스트·피버 상태 변경; UI/I/O 없음 | gameplay, purchase_price, search, search_fever, punch_fever | src/game/, src/features/play/play.gd |
| 계산·상품 규칙 | src/game/economy/economy_rules.gd, progression/drink_rules.gd, search/search_rules.gd | 세션 상태를 읽는 가격·보너스·상품·클릭·기간 계산 | purchase_price, expanded_skills, search_fever | src/game/, src/data/drink_catalog.gd |
| Play 표현 | src/features/play/play.tscn, play.gd `_on_shop_button_pressed`, `_finish_action`, `_process` | 입력 차단·세션 호출·화면 갱신·저장 요청·연출 | gameplay, purchase_area, coin_effect, drink_dispense | src/features/play/, src/app/main.gd |
| 음료·능력 화면 | src/features/drinks/drink_screen.tscn, drink_screen.gd `select_drink`, `update_state` | 표시용 사본과 클릭 선택; 해금은 signal → Play → 세션 | drink_screen, drink_unlock_screen, vending_display | src/features/drinks/, src/features/play/play.gd |
| 일시정지 | src/features/pause/pause_menu.tscn, pause_menu.gd `set_open` | ESC·포커스·pause, 저장/종료/ESC signal → Play | menu, punch_fever | src/features/pause/, src/features/play/play.gd |
| 시각 효과 | src/features/play/effects/ | 세션의 결과를 표현, 별도 보상 지급 안 함 | coin_effect, drink_dispense, search_fever, punch_fever | src/features/play/effects/, src/features/play/play.gd |
| 저장·호환 | src/integrations/saves/progress_store.gd `write`, `load_into`, `exists`, `backup` | 기존 ConfigFile 형식·정규화·검사·백업 | menu, purchase_price, progress_store | src/integrations/saves/, src/app/main.gd |
| 카탈로그·에셋 | src/data/drink_catalog.gd.DATA, assets/ | 단일 상품 정의와 이미지/폰트; key·인덱스는 저장 계약 | vending_display | src/data/, assets/ |
| 공유 UI·표시 | src/shared/ui/themes/, icons/, pixel_button.gd, cursor_theme.gd; src/shared/formatting/amount_format.gd | A 공통 외형·Button 상태 전환·커서·금액 표시 | drink_screen, purchase_price, punch_fever | src/shared/, project.godot |
| 개발 생성 | tools/build_scenes.py | 단일 런타임 카탈로그와 디자인 토큰을 읽어 임시 미리보기만 출력 | Python parse·미리보기 출력 검사 | tools/, src/data/drink_catalog.gd |

테스트 이름은 아래의 `tests/features/<이름>_test.gd` 기준이며 저장 전용은 `tests/integrations/progress_store_test.gd`다. skills 계열 파일 이름은 기존 회귀의 식별자이며 현재 UI를 스킬트리로 정의하는 근거가 아니다.

## 공유 소유자·정규 예시

| 찾는 기능 | 소유자·사용 예시 | 계약 |
| --- | --- | --- |
| 진행 변경 | `game_session.purchase`, `search`, `punch`, `unlock`, `claim_quest`; Play 호출 | 실제 잔액·획득·해금은 세션 하나에만 존재 |
| 가격·보상 | `economy_rules.current_draw_price`, `calculate_reward`; 세션 경유 | 가격 2% 증가·최종 정수 처리·피버 곱을 UI에서 복제하지 않음 |
| 음료 강화·추첨 | `drink_rules.enhancement_count`, `purchasable_drinks`, `draw_for_roll`; 세션 경유 | 원본 획득 수 보존·효과 상한·최대 강화 제외·피버 반복·황금 해금 후 별도 확률 |
| 주차장 해금 상태 | `game_session.parking_unlocked` | 저장된 황금 획득 수로 판정; 새 플래그나 스테이지 씬은 없음 |
| 저장·복구 | `progress_store.write`, `load_into`, `backup`; app 연결 | 기존 키·상품 인덱스·이전 저장 처리 보존 |
| 금액 표기 | `amount_format.format_amount`, `format_gold`; Play `_refresh_ui` | 표기 축약은 실제 잔액·가격 계산에 적용하지 않음 |
| 공유 외형 | `play_theme.tres`의 Button·PixelHudButton·PrimaryButton·PixelIconButton·ActionButton·PricePlate; `drink_screen.PLAY_PANEL` | 기존 StyleBox·상태를 재사용, 화면별 새 테마 복제 금지 |
| 공통 버튼 입력·피드백 | `shared/ui/pixel_button.gd`; MainMenu·Play·DrinkScreen·PauseMenu | 기본 Button이 입력·문구·포커스를 소유하고 프레임만 90/60/100ms 전환, 클릭 영역을 이동하지 않음 |
| 외부 의존성 연결 | app의 세션 주입·save_requested 연결; tests/support/game_fixture | UI는 파일 저장소를 직접 생성/호출하지 않음 |
| 테스트 대역 | tests/features의 Session 하위 클래스 | 랜덤 결과만 통제하고 실제 진행 계산을 mock하지 않음 |

## 검증 맵

| 영역 | 명령의 스크립트 경로 | 기대 관찰 |
| --- | --- | --- |
| 구매·저장·가격 | tests/features/gameplay_test.gd, purchase_price_test.gd | 중복/잔액 부족 차감 방지·획득 즉시 저장·가격·이전 구매 횟수 |
| 메뉴·백업·저장 오류 | tests/features/menu_test.gd | A 프레임을 통과하는 실제 클릭·초기 포커스·고정 클릭 영역, 새 게임 백업·로드·ESC·수동 저장·실패 시 종료 차단 |
| 음료·해금·표시 | tests/features/drink_screen_test.gd, drink_unlock_screen_test.gd, vending_display_test.gd | 클릭 선택·무반응 hover·초기화·정확한 차감·진열·resize |
| 수색·연출·피버 | tests/features/search_test.gd, coin_effect_test.gd, search_fever_test.gd, punch_fever_test.gd | 정확한 지급·꽝·이펙트·pause·기간·중첩·종료 |
| 배출·구매 영역 | tests/features/drink_dispense_test.gd, purchase_area_test.gd | 입력 영역·중복 방지·배출/알림 순서 |
| 음료 상한·확률·추첨 | tests/features/expanded_skills_test.gd | cap 경계·초과 기록 저장/로드·정수 확률 합계/구간·황금 선행 조건/보장·피버 중복/반복·빈 후보 차감 방지 |
| 저장 데이터 호환 | tests/integrations/progress_store_test.gd | 정수 키 획득량·독립 플래그·누락 필드·잘못된 타입/범위 정규화 |

전체 명령과 한계는 [품질·검증](05-quality-rules.md)을 따른다. 각 파일은 실제 저장을 쓰지 않으며 테스트 캡처는 `.godot/test_artifacts/`에 생성한다.

## 제외·주의 경로

- `.git/`, `.godot/`, `android/`: Git 내부·캐시·생성 출력. 캐시/미리보기를 구현 원본으로 삼지 않는다.
- `design/`, `docs/`, `tools/`: `.gdignore`로 Godot import 제외. 관련 UI 작업의 원본 안내는 선별해서 읽는다.
- `.uid`, `.import`: 리소스 식별·가져오기 메타데이터. 이동할 때 관련 파일과 함께 확인한다.
- 과거 design/v*·검토 시안·캡처는 현재 채택의 근거가 아니다. Penpot 링크와 DESIGN.md를 확인한다.
- `node_2d.tscn`은 현재 실행 경로 밖이며 새 진입점의 정규 예시가 아니다.
- `tools/build_scenes.py`는 이전 시안 미리보기다. 현재 앱의 빌드/설치/검증 단계로 실행하지 않는다.

## 남은 경계

Steam Cloud·모바일 인증·번역 리소스·릴리스 export·CI는 아직 구현/설정되지 않았다. 관련 제품 기획은 Notion을 직접 확인하고, 현재 코드에서 미정 밸런스를 확정 기획으로 승격하지 않는다.

## Linked Sources

| Source | Owns | Not covered | Evidence paths |
| --- | --- | --- | --- |
| [아키텍처](06-architecture.md) | 폴더·의존성·상태 소유권 | 제품 기획 | src/ |
| [검증 안내](05-quality-rules.md) | 명령·실행 결과·한계 | 새 기능 승인 | tests/ |
| [자료 안내](../design/README.md) | Penpot 연결·채택 원본 위치 | 런타임 코드 원본 | DESIGN.md, design/README.md |
