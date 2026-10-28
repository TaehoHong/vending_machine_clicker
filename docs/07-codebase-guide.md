# 07. 코드 안내

2026-10-20 승인된 구조 전환의 실제 소스를 기준으로 갱신했다. 2026-10-28 Penpot 전체 화면 대조와 시설 구매·강화 동선을 반영했다. 폴더·책임·의존성은 [아키텍처](06-architecture.md), 작성 전/후 검사는 [개발 규칙](02-development-rules.md#코드-품질-필수-검사)를 따른다.

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
| 시설 규칙·저장 | src/game/automation/facility_rules.gd, game_session.gd | 첫 골목 해금·구매·강화·생산·드롭·수집, progress_store 정규화 | facility_rules_test.gd | src/game/automation/, src/integrations/saves/, tests/integrations/ |
| 시설 표현 | src/features/facilities/facility_world.gd, facilities_screen.gd, effects/customer_flow.gd, customer_animation.gd, customer_frames.tres | 공통 구매창의 정보·해금·구매·보유 시설 강화·미리보기와 손님 프레임 재생; 생산물은 월드에서 직접 수령, 지급은 세션 | facilities_test.gd, customer_animation_test.gd | src/features/facilities/, src/features/play/play.gd |
| 기기 설정 | src/features/settings/, src/integrations/settings/preferences_store.gd | 원본 패널·슬라이더, settings.cfg 저장·오디오·창 모드·로케일 | settings_test.gd | project.godot, src/features/settings/, src/integrations/settings/ |
| 원본 UI 연결 | src/shared/ui/design_view.gd | penpot_name 조회, Frame family/state 메타에 따른 네이티브 원본·같은 family의 상태 SVG 전환, 화면 fit | menu, drink_screen, facilities, settings | src/shared/ui/, src/features/ |
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
| 연속 구매·배출 | `game_session.purchase`, `finish_purchase`; `progress_state.pending_purchases`; Play `_start_purchase_effect`, `_finish_purchase_effect` | 결제·지급·저장은 즉시, 구매 ID별 FX/tween을 즉시 병렬 시작하고 해당 결과만 완료. 음료 획득·골드 부족 알림은 ability_toast가 발생 순서대로 모두 표시. 구매 중 입력 허용, 모달·pause 유지. 대기열은 저장하지 않으며 `inserting_coin`은 대기 여부 조회만 담당 |
| 음료 해금 | `game_session.unlock`, `drink_screen._refresh_selection`; `drink_catalog.DATA.cost` | 선행 순서 없이 비용만 확인, 세션이 단일 차감·기록 소유; UI는 비용·현재 해금 상태만 표시 |
| 음료 강화·추첨 | `drink_rules.enhancement_count`, `purchasable_drinks`, `draw_for_roll`; 세션 경유 | 원본 획득 수 보존·효과 상한·최대 강화 제외·피버 반복·황금 해금 후 별도 확률 |
| 주차장 해금 상태 | `game_session.parking_unlocked` | 저장된 황금 획득 수로 판정; 새 플래그나 스테이지 씬은 없음 |
| 저장·복구 | `progress_store.write`, `load_into`, `backup`; app 연결 | 기존 키·상품 인덱스·이전 저장 처리 보존 |
| 금액 표기 | `amount_format.format_amount`, `format_gold`; Play `_refresh_ui`, `_show_wallet_tooltip` | 표기 축약은 실제 잔액·가격 계산에 적용하지 않으며 원본 툴팁에 정수 전체를 표시 |
| 공유 외형 | `play_theme.tres`의 Button·PixelHudButton·PrimaryButton·SecondaryButton·PixelIconButton·ActionButton·PricePlate·InfoPanel·InfoTitle·InfoBody; `drink_screen._panel`, `_label` | 기존 StyleBox·상태를 재사용, 화면별 새 테마 복제 금지. InfoPanel은 크림색 정보 카드, InfoTitle은 짙은 Cafe24, InfoBody는 외곽선 없는 Noto Sans KR 400 본문. 재화 HUD는 기존 PLAY_PANEL 유지 |
| 공통 버튼 입력·피드백 | `shared/ui/pixel_button.gd`; MainMenu·Play·DrinkScreen·PauseMenu | 기본 Button이 입력·문구·포커스를 소유한다. 원본 상태는 네이티브 Frame의 색·선·숨김을 유지하고 다른 상태는 같은 family SVG로 90/60/100ms 전환한다. 설정의 선택은 keyboard focus와 별도로 유지하며 클릭 영역은 고정한다 |
| 시설 구매·강화 | `facilities_screen._purchase`, `_show_page`, `go_back`; `facility_world` | 미보유는 기존 해금→구매, 보유는 업그레이드. 강화에서 구매창으로 복귀하며 별도 관리·보상 카드는 없다. 설치 본체는 입력을 연결하지 않고 골드·빈캔만 각각 클릭 수령한다 |
| 외부 의존성 연결 | app의 세션 주입·save_requested 연결; tests/support/game_fixture | UI는 파일 저장소를 직접 생성/호출하지 않음 |
| 테스트 대역 | tests/features의 Session 하위 클래스 | 랜덤 결과만 통제하고 실제 진행 계산을 mock하지 않음 |

## 검증 맵

| 영역 | 명령의 스크립트 경로 | 기대 관찰 |
| --- | --- | --- |
| 구매·저장·가격 | tests/features/gameplay_test.gd, purchase_price_test.gd | 연속 구매별 단일 차감·잔액 부족 무차감·획득 즉시 저장·가격·이전 구매 횟수 |
| 메뉴·백업·저장 오류 | tests/features/menu_test.gd | A 프레임을 통과하는 실제 클릭·초기 포커스·고정 클릭 영역, 새 게임 백업·로드·ESC·수동 저장·실패 시 종료 차단 |
| 음료·해금·표시 | tests/features/drink_screen_test.gd, drink_unlock_screen_test.gd, vending_display_test.gd | 클릭 선택·선택 음료의 상세 그림 전환·무반응 hover·독립 해금·콜라10/에너지15 비용·정확한 차감·강화 완료 후 해금 진열 유지·resize |
| 수색·연출·피버 | tests/features/search_test.gd, coin_effect_test.gd, search_fever_test.gd, punch_fever_test.gd | 정확한 지급·꽝·이펙트·pause·기간·중첩·종료 |
| 배출·구매 영역 | tests/features/drink_dispense_test.gd, purchase_area_test.gd | 입력 영역·구매 중 수색/능력·겹친 동전/음료·ID별 그림/피버·부족/획득 발생 순서 알림·pause·저장 재지급 방지 |
| 음료 상한·확률·추첨 | tests/features/expanded_skills_test.gd | cap 경계·초과 기록 저장/로드·정수 확률 합계/구간·황금 빈캔 해금/보장·피버 중복/반복·빈 후보 차감 방지 |
| 시설·설정 상태 | tests/features/facilities_test.gd, settings_test.gd | 해금→구매→강화→구매창 복귀·본체 무동작·골드/빈캔 독립 클릭·중복 지급 방지, 음소거·선택 상태·슬라이더 범위 |
| 저장 데이터 호환 | tests/integrations/progress_store_test.gd | 정수 키 획득량·독립 플래그·누락 필드·잘못된 타입/범위 정규화 |

수색 피버 링과 펀치 타격은 `assets/penpot/search_fever_ring.svg`, `punch_fever_impact.svg`의 원본 벡터를 사용한다. 동전 투입과 피버 발광은 원본 PNG를 사용하며 UI 연출에서 보상 규칙을 재구현하지 않는다.

손님 애니메이션은 `customer_animation.gd`의 `show_clip`과 전용 SpriteFrames 리소스가 표현을 소유하고, `customer_flow.gd`가 시설 시계로 걷기·방향 전환·조작·줍기·퇴장 상태를 정한다. 4종 외형 01·02·03·08의 상태별 아틀라스를 순환한다. 호흡 변형은 원본에서 미리 내보내며 게임에는 관절 좌표·런타임 변형 데이터를 두지 않는다. 게임은 발밑 기준을 유지하는 224×248 프레임과 수평 투명 여백 16px를 사용한다. 관련 검사는 `tests/features/customer_animation_test.gd`다.

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
