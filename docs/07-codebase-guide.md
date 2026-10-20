# 07. 코드 안내

근거 확인: 2026-10-20. 폴더·메뉴/플레이 진입·구매/해금/저장 경계와 공유 UI 연결은 HEAD `ccaf3be`의 소스에서 다시 확인했다. 나머지 색인의 최초 작성 기준은 초기화 전 HEAD `fdae8f7`과 당시 로컬 파일이다. 이 색인은 소스를 좁혀 읽기 위한 안내이며 현재 코드 검증을 대체하지 않는다.

## 사용법

앞으로 지향할 폴더 구조·책임·의존성 규칙은 [목표 아키텍처](06-architecture.md)를 따른다. 목표 경로는 아직 구현되지 않았다. 이 문서는 현재 코드의 실제 파일·함수·회귀 테스트를 찾는 색인이다.

요청과 관련된 행의 근거 경로에 이 안내 이후 커밋·staged·unstaged 변경이 있는지 확인한다. 해당 모듈·직접 호출자/피호출자·공유 소유자·테스트부터 읽고 소유권이 없거나 모순될 때만 검색을 넓힌다. 예: 구매 가격은 `current_draw_price` → `_on_shop_button_pressed` → 저장 함수 → `purchase_price_test.gd`부터 확인한다.

코드 작성과 새 파일 추가 전 [개발 규칙의 코드 품질 필수 검사](02-development-rules.md#코드-품질-필수-검사)에 따라 기존 소유자·재사용 경로·파일 배치 근거를 확인한다. 아래 맵에 없다는 이유만으로 소유자가 없다고 단정하지 않는다.

## 모듈 맵

| 영역 | 경로·진입점 | 책임·의존성 | 관련 테스트 | Evidence paths |
| --- | --- | --- | --- | --- |
| 앱·메뉴 | project.godot, main.tscn, main.gd `_start_game` | 시작·백업·로드 → Game.tscn | menu_test.gd | project.godot, main.gd, main.tscn, tests/menu_test.gd |
| 경제·수색·구매·저장 | Game.tscn, game.gd | 진행 소유; 카탈로그·UI·ConfigFile 의존 | gameplay_test.gd, purchase_price_test.gd, search_test.gd | Game.tscn, game.gd, tests/gameplay_test.gd, tests/purchase_price_test.gd, tests/search_test.gd |
| 상품·해금 UI | ui/drink_catalog.gd.DATA, ui/skill_tree.gd `update_state`, `select_drink` | 상품 정의·선택·표현; 해금은 signal로 game에 요청 | drink_screen_test.gd, vending_display_test.gd | ui/drink_catalog.gd, ui/skill_tree.gd, game.gd, tests/drink_screen_test.gd, tests/vending_display_test.gd |
| 일시정지 | pause_menu.gd `set_open` | ESC·포커스·pause, 저장·종료 signal → game | menu_test.gd, punch_fever_test.gd | pause_menu.gd, game.gd, tests/menu_test.gd, tests/punch_fever_test.gd |
| 피버·시각 효과 | ui/search_fever.gd, ui/punch_fever.gd, ui/search_coin.gd, ui/drink_dispense_fx.gd, ui/ability_toast.gd | 상태를 받아 연출; 보상·타이머 소유자는 game | search_fever_test.gd, punch_fever_test.gd, coin_effect_test.gd, drink_dispense_test.gd | game.gd, ui/search_fever.gd, ui/punch_fever.gd, ui/search_coin.gd, tests/search_fever_test.gd, tests/punch_fever_test.gd, tests/coin_effect_test.gd, tests/drink_dispense_test.gd |
| 테마·커서 | ui/play_theme.tres, ui/backstreet_theme.tres, ui/pixel/, ui/cursor_theme.gd | Play/Main 테마·공유 스타일·autoload 커서 | drink_screen_test.gd, punch_fever_test.gd | project.godot, Game.tscn, main.tscn, ui/skill_tree.gd, ui/cursor_theme.gd, ui/play_theme.tres |
| 개발용 생성 | ui/build_scenes.py, ui/drinks.json, design/penpot-ui/tokens.json | 씬·테마 쓰기, 게임 실행에 불필요 | 전용 자동 검증 없음 | ui/build_scenes.py, ui/drinks.json, design/penpot-ui/tokens.json |

테스트 경로 열은 모두 `tests/` 기준이다. 이전 스킬트리·해금 화면 테스트(`skill_tree_test.gd`, `expanded_skills_test.gd`, `drink_unlock_screen_test.gd`)는 현재 화면과 기대값의 동등성을 검토한 뒤 사용한다.

## 공유 기능과 정규 예시

| 기능 | 정규 소유자·예시 | 계약·주의 | Evidence paths |
| --- | --- | --- | --- |
| 구매 가격·중복 방지 | game.gd `current_draw_price`, `_on_shop_button_pressed` | UI에 별도 계산을 만들지 않음 | game.gd, tests/purchase_price_test.gd |
| 금액 표기 | game.gd `_format_gold`, `_refresh_ui` | 표시 축약과 실제 정수 잔액 구분 | game.gd, tests/purchase_price_test.gd |
| 진행 저장·호환 | game.gd `_save_progress`, `_load_progress`; main.gd `_backup_existing_save` | 기존 저장·카탈로그 인덱스 호환 확인 | game.gd, main.gd, tests/menu_test.gd, tests/gameplay_test.gd |
| 상품 정의 | ui/drink_catalog.gd.DATA | key·인덱스는 저장 호환과 연관 | ui/drink_catalog.gd, game.gd, ui/skill_tree.gd |
| 해금 요청·상태 갱신 | ui/skill_tree.gd `unlock_requested`, `update_state`; game.gd `_on_unlock_drink_requested` | UI signal → game의 잔액·저장 갱신 → UI refresh | ui/skill_tree.gd, game.gd, tests/drink_screen_test.gd |
| 오류 처리 | main.gd `_backup_existing_save`, `_start_game` | 백업 실패 시 새 진행 시작 차단; 다른 경계는 현재 소스 확인 | main.gd, tests/menu_test.gd |
| 테스트 대역·설정 주입 | tests/purchase_price_test.gd `PriceGame`, tests/drink_screen_test.gd `ScreenGame` | 상속으로 랜덤·저장 통제, save_path 분리 | tests/purchase_price_test.gd, tests/drink_screen_test.gd |
| UI 공유 스타일 | ui/skill_tree.gd `PLAY_PANEL`, `PLAY_BUTTONS`, `PLAY_ACTIONS` | 기존 Play 리소스 재사용 | ui/skill_tree.gd, ui/pixel/, tests/drink_screen_test.gd |

## 의존성·관찰 규칙

- 현재: 씬 → 연결 스크립트; main → Game; game → 카탈로그·UI; 선택 UI → 카탈로그·리소스와 signal. 카탈로그가 game을 역참조하지 않는다.
- 변경 시 진행 원장은 game의 소유 경계를 따른다. 미래 계정·저장 연동은 [06](06-architecture.md)의 사용자 확정 경계에 맞춰 설계한다.
- `ui/drinks.json`과 생성 Python은 런타임 카탈로그와 자동 동기화되지 않는다. 생성 도구 실행은 현재 씬을 덮어쓰는 별도 작업이다.
- 로그·관측의 통일된 런타임 규약은 없다. 테스트의 `print`·assert를 출시 관측 정책으로 확대하지 않는다. 코드 스타일은 [개발 규칙](02-development-rules.md)을 따르며, 혼용된 기존 코드 전체를 재정렬하지 않고 새 코드와 수정 부분부터 적용한다.

## 검증 맵

공통 접두어는 `godot --headless --path . --script res://tests/`이며 아래 파일명을 이어 실행한다. Godot 실행 환경과 한계는 [05](05-quality-rules.md)를 따른다.

| 영역 | 좁은 검증 파일 | 함께 확인할 검증 | 기대 증거 |
| --- | --- | --- | --- |
| 구매·금액·저장 | purchase_price_test.gd | gameplay_test.gd, menu_test.gd | 차감·가격 증가·로드·호환 assertion과 완료 출력 |
| 선택·해금·레이아웃 입력 | drink_screen_test.gd | vending_display_test.gd | 클릭·호버·재진입·잔액·ESC·크기 assertion |
| 수색·보상 연출 | search_test.gd, coin_effect_test.gd | search_fever_test.gd | 정확한 지급·꽝·중복 효과 검증 |
| 펀치·일시정지 | punch_fever_test.gd | menu_test.gd | 발동·영역·보상·pause·복원 검증 |
| 음료 배출·구매 영역 | drink_dispense_test.gd, purchase_area_test.gd | purchase_price_test.gd | 연출·입력·중복 구매 검증 |

검증 맵 근거는 각 `tests/<파일명>`과 연결된 game/UI 소스다. 더 넓은 검증은 변경 영향에 따라 선택하며 과거 테스트 전체를 검증된 최신 스위트로 단정하지 않는다.

## 제외·보관 경로

| 경로 | 이유 | 근거 |
| --- | --- | --- |
| .git/ | Git 내부 상태 | Git 저장소 |
| .godot/, android/ | 생성 캐시·플랫폼 출력 | .gitignore |
| design/ | Godot import 제외, 기획·원본 보관; 관련 UI 작업에는 선별 확인 | design/.gdignore, design/README.md |
| design/v2~v10, design/review/, 각 concepts/ | 채택·이전 기록 혼재; 폴더명만으로 최신 판단 금지 | DESIGN.md, design/README.md |
| *.uid, *.import | 엔진 식별·import 메타데이터, 일반 기능 탐색에서는 후순위 | project.godot, 각 리소스 |
| .DS_Store | 로컬 파일 탐색기 메타데이터 | 로컬 파일 목록 |

## 알려진 공백

Godot 실행 파일·export·CI·Steam Cloud·모바일 인증·번역 리소스는 준비 또는 구현이 필요하다. README·과거 지역 기록·PRODUCT의 오래된 기능 요약과 최신 Notion 간 차이가 있으므로 관련 기능을 구현할 때 SSOT를 직접 확인한다. 검증된 고신호 장애 기록이 없어 troubleshooting 디렉터리는 생성하지 않는다.

## Linked Sources

| Source | Owns | Not covered | Evidence paths |
| --- | --- | --- | --- |
| [README.md](../README.md) | 편집·실행·기존 구현 안내 | 최신 전체 코드 구조 | project.godot, main.gd, game.gd |
| [자료 안내](../design/README.md) | 에셋·원본·생성 자료 위치 | 런타임 의존성 | design/README.md, ui/build_scenes.py |
| [PRODUCT.md](../PRODUCT.md) | 기획 SSOT 포인터·구현과 기획 구분 | 코드 소유권 | PRODUCT.md, ui/drink_catalog.gd |
