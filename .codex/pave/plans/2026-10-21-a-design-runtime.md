# 확정 A 디자인의 게임 적용

상태: 완료. 코드 선행을 중단하고 Penpot 원본 정합성 수정·저장·재확인을 먼저 완료한 뒤 구현을 대조·검증했다. 기능 커밋 `004781b`를 로컬 main에 fast-forward 병합했다. 원본 파일 `cd444aaf-0d8c-801b-8008-cda246e18650`의 00과 01을 Computer Use로 읽고 대표 화면·공통 패널의 편집 속성을 대조했다. 상세 임시 원본은 `/tmp/clicker-a-runtime-reference/`에 있으며 저장소의 새 디자인 원본으로 취급하지 않는다.

## 범위와 결정

- user-confirmed / active: A 팔레트·Cafe24 PRO UP·공통 버튼·패널·HUD를 실제 게임에 적용한다. Penpot 01의 29개 화면·상태가 시각 기준이다.
- repo-evidenced / preserve-current-behavior: 구매·해금·퀘스트·가격·저장/백업·오류·피버·배출 연출·화면 전환은 기존 소유자와 계약을 유지한다. 메뉴의 Settings는 계속 비활성이다.
- repo-evidenced / preserve-current-behavior: 배경·음료·자판기 아트, 일본어 브랜드·푸터의 대체 글리프를 유지한다. 원본에 맞춰 버튼 크기·아이콘·문구 배치·줄바꿈은 변경한다.
- deferred: 다음 스테이지, 모바일/로그인/Steam Cloud, 번역 및 전체 언어 글리프 검증, 새 메뉴 기능, 릴리스 설정.
- material blocking decisions: 0. 새 디자인 선택·밸런스 결정은 필요 없다.

## 기존 소유자 확인

- owner-found: `src/shared/ui/themes/play_theme.tres`, `ability_*.tres`, `quest_claim_*.tres`, `hud_style.tres`, `quest_style.tres`, `purchase_style.tres`. 각 리소스 정의와 Play 씬/음료 화면의 preload·theme override에서 실제 공유 사용을 확인했다. 화면별로 별도 A 테마를 만들지 않는다.
- owner-found: `src/shared/ui/icons/hud_buttons/frames/`의 6크기×5상태와 `icons/`의 14종, `assets/fonts/Cafe24PROUP.ttf`. A의 프레임·아이콘을 다시 생성하거나 문구를 이미지에 굽지 않는다.
- owner-found: Play·MainMenu·DrinkScreen·PauseMenu가 각각 배치·표시·입력을 소유하며 앱은 화면과 세션을 연결한다. 진행/저장 소유자에 UI 의존을 추가하지 않는다.
- owner-absent: 네 화면의 A 버튼 전환 피드백을 공유하는 코드. 상태 리소스와 입력 사용처 검색에서 공통 구현이 없었다. 필요한 공통 피드백은 `src/shared/ui/pixel_button.gd` 하나에 둔다. Button의 기존 활성/비활성·포커스·signal·hit rect를 보존하고 테마 리소스를 사용한다. 이 파일은 실제 사용하는 버튼에만 연결하며 미사용 확장 구조를 만들지 않는다.

## 작업 체크리스트

- [x] 원본 우선 수정: A 가격 금액을 네이티브 Text로 전환하고 25개 연결 화면 반영, 공통 가격판의 A 144×56 연결, PausePanel 400×496 규격명, 팔레트 강조/포커스 역할과 적용 상태 정정. 원본 버전 `A 원본 정합성 검수 · 편집 가능 가격·공통 규격 · 2026-10-21` 저장·UI 재열기 확인. 29개 보드/기존 컴포넌트 ID 보존, visible 금액 윤곽선·화면 밖 텍스트·파일 검증 오류 0. 관련 DESIGN·README·manifest를 갱신한 뒤 구현 대조 재개.

- [x] 관련 가이드의 최신성 확인: 가이드 커밋 `98cbea5` 이후 대상 src/shared/ui·features·app·tests에 committed/staged/unstaged 변경이 없음을 확인. 현재 작업의 문서 변경은 별도로 보존한다.
- [x] 실제 Godot 4.7 실행 파일 버전 확인: `/private/tmp/clicker-godot-4.7/Godot.app/Contents/MacOS/Godot`.
- [x] 공통 외형과 Play 적용: 기존 테마/상태 리소스 및 `src/shared/ui/icons/ability_frame.svg`, `hud_frame.svg`를 원본 색상·선·모서리에 맞추고 가격은 기존 A 144×56 프레임을 재사용한다. `src/shared/ui/pixel_button.gd`는 상태 전환·문구/아이콘 피드백만 담당한다. `src/features/play/play.tscn`, `play.gd`의 능력/메뉴·재화·가격·목표/보상·잠금/비활성 표시를 연결한다. `src/features/play/effects/ability_toast.gd`는 공유 외형으로만 맞추며 보상 계산을 옮기지 않는다. 검증: import/parse, gameplay·purchase_price·coin_effect·purchase_area·drink_dispense·피버 회귀, 실제 Play/보상/잔액 부족 캡처.
- [x] 메뉴·음료·일시정지 적용: `src/features/main_menu/main_menu.tscn`, `main_menu.gd`, `src/features/drinks/drink_screen.gd`, `src/features/pause/pause_menu.tscn`, `pause_menu.gd`를 같은 공유 테마·버튼으로 연결한다. 새 게임/이어하기/백업 실패, 음료 초기/해금 가능/부족/선행 조건/획득/요약, pause 저장 성공/실패/종료 실패를 유지한다. 긴 추가 버튼과 저장 오류 줄바꿈, Cafe24 메뉴 글꼴, 닫기·아이콘·포커스를 원본에 맞춘다. 검증: menu·drink_screen·drink_unlock_screen·vending_display 회귀와 대표 실제 화면 캡처.
- [x] 입력·크기 검증: `tests/features/menu_test.gd`, `drink_screen_test.gd`에 필요한 경우 새 버튼의 keyboard focus/비활성 입력과 화면 축소 시 실제 클릭·정보 패널 경계 회귀를 보강한다. 기존 진행/가격 assertion은 완화하지 않는다. 단순 색상·상수·리소스 존재 확인용 테스트는 추가하지 않는다. 실제 렌더러에서 1152×648 원본, 출시 목표 1280×720, 확대 창 및 기존 800×600 회귀를 확인한다.
- [x] 기존 `DESIGN.md`, `design/README.md`, `design/hud-buttons/README.md`, 런타임 HUD 안내와 `docs/07-codebase-guide.md`의 적용 상태·공유 소유자·경로만 갱신한다. Penpot 기존 팔레트의 적용 상태 표기를 실제 결과와 맞춘다. 새 디자인 페이지·규칙 문서를 만들지 않는다.
- [x] 실제 diff의 중복 스타일·미사용 파일·책임 위반 검토. 보상 버튼도 ActionButton과 공유 피드백을 사용하며 관련 없는 숨겨진 레거시 카드 수정은 제외했다.
- [x] 기능 커밋 `004781b`를 로컬 main에 fast-forward 병합하고 import·parse·16개 회귀·실제 렌더링 37개 캡처를 다시 확인했다. Push/PR은 하지 않았다.

## 검증 계약

아래 `godot`은 위 4.7 실행 파일로 대체한다. 각 명령은 오류 로그와 종료 상태를 함께 확인한다.

```sh
godot --headless --editor --path . --import
godot --headless --editor --path . --quit
godot --headless --path . --script res://tests/features/gameplay_test.gd
godot --headless --path . --script res://tests/features/menu_test.gd
godot --headless --path . --script res://tests/features/purchase_price_test.gd
godot --headless --path . --script res://tests/features/drink_screen_test.gd
godot --headless --path . --script res://tests/features/drink_unlock_screen_test.gd
godot --headless --path . --script res://tests/features/vending_display_test.gd
godot --headless --path . --script res://tests/features/coin_effect_test.gd
godot --headless --path . --script res://tests/features/purchase_area_test.gd
godot --headless --path . --script res://tests/features/drink_dispense_test.gd
godot --headless --path . --script res://tests/features/search_fever_test.gd
godot --headless --path . --script res://tests/features/punch_fever_test.gd
git diff --check
```

실제 렌더링은 기존 캡처 지원 테스트와 임시 검수 실행으로 확인한다. Headless 성공만으로 디자인 일치를 선언하지 않는다. 기본/호버/누름/포커스/비활성, 픽셀 경계·긴 문구·아이콘 정렬·클릭 영역을 확인하며 남은 사람 검수·Windows 배포·다국어 전체 검증은 구분해 보고한다.

## 검증·지식 반영

- Godot 4.7 import·parse, whitespace 확인 완료. `run_checks.py` 임시 실행으로 gameplay, menu, purchase_price, drink_screen, drink_unlock_screen, vending_display, coin_effect, purchase_area, drink_dispense, search, search_fever, punch_fever, abilities, skill_tree, expanded_skills, progress_store 16개 회귀를 실행해 종료 코드 0·실패 0을 확인했다. 각 명령은 `godot --headless --path . --script res://tests/features/<이름>_test.gd`, progress_store만 integrations 경로다.
- 실제 Metal 렌더러의 37개 캡처로 1152×648·1280×720·1920×1080·800×600, 5상태·해금·부족·저장 오류·피버·구매 연출을 검수했다. 임시 캡처와 로그는 저장소에 추가하지 않는다.
- Test Value: menu에 실제 마우스 입력·초기 포커스·고정 클릭 영역 회귀를 추가했다. purchase_price·expanded_skills의 기존 문자열 기대값만 Penpot의 `100 G` 형식에 맞췄고 가격 계산·원자성 assertion은 유지했다. 마지막 보상 버튼의 공유 테마 연결 후 menu·gameplay를 다시 통과했다.
- Knowledge Delta: 사용자 확정 원본 우선 순서를 DESIGN.md에 명시하고, 원본의 native Text 가격·규격·연결 ID와 런타임 공유 소유자를 기존 README·manifest·코드 안내에 반영했다. 새 규칙 문서나 Penpot 규칙 보드는 추가하지 않았다.
- 사람 검수: Windows 배포와 지원 언어 전체 글리프, 최종 플레이 감각은 남아 있다. 공통 상태 코드는 pixel_button.gd 하나이며 새 게임 기능·설정·진행 규칙을 추가하지 않았다.

최종 통합 검증: 로컬 main의 Godot 4.7 import·parse 종료 0, 위 16개 회귀 실패 0, Metal 실제 캡처 완료. 기본·보상·부족·긴 저장 오류·다중 해상도 출력과 고정 클릭 영역을 확인했다. Penpot 팔레트의 적용 표기도 갱신하고 브라우저 재열기 후 저장을 확인했다. 새 일반 문서나 미사용 테마 변형은 만들지 않았다.
