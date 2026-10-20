# Plan: 기존 동작을 유지하는 목표 구조 전환

## 목표·완료 기준

- 사용자 확정 목표 구조(docs/06-architecture.md)로 실제 런타임 파일과 코드 책임을 옮긴다.
- 화면 외형·조작·구매 가격·보상·해금 조건·피버·일시정지·연출 순서와 기존 저장 호환을 유지한다.
- UI가 진행을 별도로 소유하지 않고, 게임 규칙이 Control·씬·파일 I/O·플랫폼 SDK에 의존하지 않도록 분리한다.
- 기존 소유자의 로직을 이동·호출하고, 같은 상태·규칙을 가진 옛 구현과 새 구현을 병렬로 남기지 않는다.
- 검증한 작업 커밋을 최신 main에 통합한다. 실제 코드/테스트 편집 전 아래 구현 계약의 통합 승인이 필요하다.

## 범위·결정

- in-scope: 런타임 폴더/파일 이동, 씬 참조·UID·signal 갱신, 상태/계산/저장/화면 책임 분리, 테스트 경로·계약 갱신, 실제 경로 문서화.
- preserve-current-behavior: user://progress.cfg, progress 섹션의 기존 키와 기본값·범위 처리·이전 저장 변환, 상품 순서·인덱스·키, RNG 호출 의미, 결제/획득의 저장 시점, 저장 실패 시 종료 차단, 모든 현재 UI·입력·연출.
- extension-boundary: 저장은 현재 로컬 구현을 주입 가능하게 분리하되 실제 사용되는 작은 연결만 둔다.
- deferred/out-of-scope: Steam Cloud·모바일 인증·새 콘텐츠·밸런스 조정·번역 구현·디자인 변경·일괄 에셋 삭제·Penpot 편집·CI/새 테스트 프레임워크 도입.
- 새 디자인·새 상태를 추가하지 않으며 기존 Play/Main 테마·픽셀 리소스·폰트를 재사용한다. 바이너리 에셋과 글꼴·라이선스는 내용 그대로 이동한다.
- 나중에 쓸 steam/mobile/audio/locales/addons 등의 빈 디렉터리나 미사용 기반 클래스를 생성하지 않는다.
- 남은 제품/설계 결정: 0. 이름·내부 인터페이스·분리 크기는 기존 동작 보존 범위의 구현 판단이다.

| ID | 근거 | 상태 | 결정 |
| --- | --- | --- | --- |
| ARCH-1 | user-confirmed | active | 목표 구조로 실제 폴더와 코드를 정리하며 기존 동작 유지 |
| ARCH-2 | repo-evidenced | active | 진행·가격·해금·저장 소유자는 현재 game.gd, 메뉴/백업은 main.gd; UI 카탈로그는 ui/drink_catalog.gd.DATA |
| ARCH-3 | user-confirmed | active | 필요한 검증 후 로컬 main 통합; push/PR 생성은 별도 요청 |
| ARCH-4 | repo-evidenced | active | 공유 체크아웃은 다른 HUD 작업의 codex/hud-button-sheet; 별도 managed worktree를 main에서 만들고 해당 변경을 보존 |
| ARCH-5 | repo-evidenced | active | main 34cff7c 기준 테스트 15개 중 11개 통과, 4개 실패; 실패를 구조 변경의 회귀로 혼동하지 않음 |
| ARCH-6 | agent-assumed | active | 기능별 씬/스크립트 근접 배치와 작은 도메인/저장 객체 추출; 사용되지 않는 추상 계층 생성 안 함 |

## 발견한 소유자·재사용 근거

모두 owner-found다. 함수명·호출자와 상태/파일 경로로 확인했다.

| 현재 소유자 | 찾은 함수·참조 | 목표 |
| --- | --- | --- |
| game.gd | current_draw_price, calculate_reward, coin_bonus, clicks_required, drink_count/unlocked | game_session과 필요한 economy/progression/search 규칙으로 이동 |
| game.gd | _on_shop_button_pressed, _on_unlock_drink_requested, _on_quest_complete_button_pressed | UI 차단/연출은 play, 실제 진행 검증·변경은 세션에 귀속 |
| game.gd, main.gd | _save_progress, _load_progress, _backup_existing_save, has_saved_game | integrations/saves/progress_store.gd에서 동일 저장 계약 재사용 |
| game.gd | _format_amount, _format_gold | shared/formatting/amount_format.gd로 이동 |
| ui/drink_catalog.gd | game.gd와 ui/skill_tree.gd의 DATA preload | src/data/drink_catalog.gd 단일 런타임 정의 유지 |
| ui/skill_tree.gd, ui/pixel/, ui/*theme.tres | PLAY_PANEL, PLAY_BUTTONS, PLAY_ACTIONS 및 Game.tscn/Main theme | 기능별 화면과 shared/ui의 동일 리소스 사용 |

## 변경 전 검증·환경

- main 34cff7c의 런타임을 /private/tmp/clicker-refactor-baseline-34cff7c로 내보냈다. 실제 저장소의 코드·테스트는 변경하지 않았다.
- 공식 Godot 4.7-stable macOS 실행 파일을 /private/tmp/clicker-godot-4.7에 준비했고 공식 SHA512와 일치한다. 버전은 4.7.stable.official.5b4e0cb0f다. 시스템 엔진 버전을 바꾸지 않는다.
- 임시 복사본의 앱 이름만 별도 테스트 이름으로 지정해 사용자 데이터 영역을 구분했다. 테스트 저장은 각 스크립트의 res://.godot/ 임시 경로 또는 저장 스텁을 사용한다.
- 결과: /private/tmp/clicker-refactor-baseline-results/summary.json 및 각 테스트 로그.
- 통과 11개: coin_effect, drink_dispense, drink_screen, drink_unlock_screen, expanded_skills, gameplay, menu, purchase_price, search_fever, search, vending_display.
- 기존 실패: abilities/skill_tree는 현재 통합 화면에서 사용하지 않는 이전 Catalog/Summary 표시를 기대한다. punch_fever는 본체 클릭 보상 assertion, purchase_area는 클릭 구매 assertion에서 실패한다. 후자 2개는 단독 실행에서도 재현했다.
- 입력 실패 2개는 viewport 로컬 좌표를 전역 좌표로 전달한 harness 오류였다. 원본 코드에 `root.push_input(event, true)`만 적용해 같은 보상·구매 assertion의 통과를 확인했다. 낡은 UI 기대 2개는 채택된 통합 음료 화면의 실제 표시를 검사하도록 바꿨다. 기대값 완화·skip·재시도로 통과시키지 않았다.

## 구현 계약·예상 파일

기존 관련 파일 전체를 대상으로 하되 현재 다른 작업의 미커밋 HUD/디자인 변경은 가져오거나 덮어쓰지 않는다. 현재 ui/images/tests의 커밋된 파일 189개에는 에셋·import/UID 메타데이터가 포함된다. 내용 변경과 단순 이동은 diff에서 구분한다.

| 기존/추출 대상 | 새 경로 또는 변경 범위 | 이유·호출자 |
| --- | --- | --- |
| main.tscn/main.gd | src/app/main.tscn, main.gd; src/features/main_menu/main_menu.tscn, main_menu.gd | 앱이 화면·세션·저장을 연결하고 메뉴는 입력/표시 담당 |
| Game.tscn/game.gd | src/features/play/play.tscn, play.gd | 씬과 표현·입력·연출 연결; 게임 세션을 사용 |
| game.gd의 실제 진행 | src/game/game_session.gd, progress_state.gd | 구매·수색·해금·퀘스트의 단일 진행 소유자 |
| 계산·능력·피버 규칙 | src/game/economy/economy_rules.gd, progression/drink_rules.gd, search/search_rules.gd | 세션이 기존 계산을 호출; UI·I/O 의존 제거 |
| 저장/로드/검사/백업 | src/integrations/saves/progress_store.gd | 앱·세션 연결에서 사용; 기존 형식·기본값·변환 보존 |
| skill_tree.gd, drink_lock.gd | src/features/drinks/drink_screen.gd/.tscn, drink_lock.gd | 기존 음료·능력 화면과 그 전용 동작 |
| pause_menu.gd, 기존 내장 pause 노드 | src/features/pause/pause_menu.gd/.tscn | 저장/종료/닫기 요청으로 연결; 부모 내부 노드 직접 접근 제거 |
| ui의 연출 gd·shader·전용 tres/icon | src/features/play/effects/ 및 필요 기능 전용 리소스 | 기존 동전·배출·알림·빛·피버 연출을 byte/동작 그대로 재사용 |
| ui의 theme/pixel/cursor 공통 자원 | src/shared/ui/themes/, components/, icons/ | 동일 외형·상태를 공유; 필요 없는 wrapper 컴포넌트 추가 안 함 |
| game.gd의 금액 표기 | src/shared/formatting/amount_format.gd | 동일 축약·정확한 금액 표기를 Play/HUD에서 사용 |
| ui/drink_catalog.gd | src/data/drink_catalog.gd | 런타임 상품 원본 한 개 유지; 키·인덱스 보존 |
| images/**, ui/fonts/** | assets/**, assets/fonts/** | 참조 경로를 함께 갱신; 원본 이미지/글꼴/라이선스 내용 보존 |
| ui/build_scenes.py, ui/drinks.json | tools/build_scenes.py, export_catalog.gd | 단일 런타임 카탈로그를 Godot로 읽어 임시 미리보기 생성; 채택 씬 자동 재생성 금지 |
| tests/*_test.gd 및 uid | tests/features/ 중심으로 책임에 맞게 이동·연결 갱신 | 현재 의미 있는 assertion 보존; 세션/저장 경계에 맞게 테스트 대상 갱신 |
| 테스트 연결 공통부 | tests/support/game_fixture.gd | 앱과 동일한 세션·저장 주입을 재사용하고 테스트 저장을 격리 |
| 저장 경계 회귀 보강 | tests/integrations/progress_store_test.gd | 분리 중 누락하기 쉬운 저장 필드·형/범위·이전 저장 호환 보호; 기존 검증과 중복되는 값 나열은 추가 안 함 |
| 설정·안내 | project.godot, AGENTS.md, README.md, PRODUCT.md의 현재 코드 경로, docs/00~07의 관련 경로, DESIGN.md/design/README.md의 해당 적용 경로만 | 진입·autoload·검증 명령과 실제 소유자를 일치; 역사 기록·진행 중 디자인 변경은 보존 |

## 실행 체크리스트

### [x] 1. 작업 공간·실행 진입·리소스 이동

- main 기반 managed worktree와 codex/runtime-architecture-refactor 브랜치를 사용한다. 공유 체크아웃의 브랜치를 전환하지 않는다.
- 위 경로 매핑대로 추적 중인 파일·UID/import 메타데이터와 참조를 함께 이동한다. 메뉴·Play·음료·pause 씬을 연결한다.
- 검증: Godot --headless --editor --path <worktree> --import 및 --quit, 메뉴/음료/진열 회귀. 씬·스크립트·리소스 오류 0개, 채택 테마·이미지·폰트 동일.

### [x] 2. 진행·규칙·저장 책임 분리

- progress_state/game_session이 실제 진행을 소유하고 기존 규칙을 호출한다. Play는 입력·표현·연출 상태만 소유한다.
- 저장 검사·백업·로드·직렬화는 progress_store로, 금액 표기는 amount_format으로 이동한다. 옛 상태 복제본·가격 공식·저장 함수를 남기지 않는다.
- 검증: 구매/해금 중복 차감 방지, 결제·획득 즉시 저장, 가격 증가, 수색·피버·퀘스트·pause, 새 게임 백업/이전 저장/저장 실패 종료 차단. 테스트 실제 저장에 접근하지 않음.

### [x] 3. 테스트·화면·경로 검증

- 15개 기존 검증의 의미를 유지하며 새 위치·상태 소유자·독립 씬에 맞게 연결한다. 기존 실패 4개는 원인을 근거로 구분하고 낡은 UI 기대나 잘못된 입력 harness만 정정한다.
- 저장 추출로 필드/타입/호환이 유실되는 현실적인 결함을 잡는 좁은 회귀를 추가한다. 단순 경로 존재나 구현을 복사하는 테스트는 만들지 않는다.
- 변경 전/후 메뉴·플레이·음료 선택·잠금·요약·pause 화면을 같은 창 크기에서 확인한다. 캡처는 임시 검증 자료로 둔다. 새로운 디자인 원본이나 스타일을 만들지 않는다.
- 검증: 모든 관련 현행 회귀 통과, 새로운 parse/리소스/경로 오류 없음, 이전 실패의 해결 근거와 남은 한계 명시. 미해결 행동 회귀가 있으면 main 통합/완료 보류.

### [ ] 4. 문서·최종 검증·main 통합

- 실제 새 경로·모듈 소유자·공유 예시·검증 명령을 코드 안내와 관련 문서에 반영한다. 이미 main에 커밋된 규칙 문서와 다른 작업 변경을 분리한다.
- git diff --check, Godot import/parse, 이동 후 테스트, 에셋 byte 비교와 diff/의존성 검토를 수행한다. 오래된 res:// 참조·옛 진행 원장·중복 규칙 없음 확인.
- 최신 main과 충돌을 해소하고 필요한 검증 후 로컬 머지한다. 공유 작업 브랜치는 보존하고 push/PR/배포는 하지 않는다.

## 승인 상태

- 코드/테스트 편집: 2026-10-20 사용자 통합 승인. 계획대로 구현·검증·main 머지까지 진행한다.
- 승인 요청 범위: 위 경로 이동·책임 분리·테스트/문서 갱신, 별도 managed worktree 생성, 검증 후 로컬 main 통합.
- 파괴적 데이터 변경·DDL·외부 게시/전송·디자인/기획 변경: 없음.
- 사용자의 승인 후 같은 범위는 재확인 없이 완료까지 진행한다.

## 검증 기록

- Godot 4.7 import·parse 통과, 회귀 16/16 통과. 저장 필드 누락 mutation이 실제 assertion 실패를 일으킴을 확인하고 원복했다.
- 동일한 1152×648 viewport·애니메이션 시점에서 메뉴·플레이·음료 초기/선택·요약·pause 6개 화면이 원본과 픽셀 단위로 일치했다.
- 원본 이미지·글꼴·라이선스·SVG 53개 byte 동일, 이동 매핑 197개와 런타임 리소스 참조 확인.
- 생성기 실실행 후 채택 씬/테마 해시 불변, 생성 출력의 리소스 참조 유효. 임시 gdformat 검사 대상은 변경한 코드/테스트/도구 29개다.
- 동시 작업의 main `1f7926f`에 HUD 에셋이 추가됨을 확인했다. 해당 커밋을 merge로 보존하고 공통 SVG 44개를 `src/shared/ui/icons/hud_buttons/`로 byte 그대로 옮겼다. 통합 상태에서 import·parse와 회귀 16/16이 다시 통과했다.
- 통합 후 gdformat 대상 29개·공백 검사·리소스 경로·게임/UI 의존성 경계 검토를 통과했다. 로컬 main 머지는 마지막 단계에서 기록한다.
