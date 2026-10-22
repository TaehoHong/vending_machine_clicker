# 확정 기본 UI·관련 에셋 적용

상태: 원본·구현·검수 완료, 로컬 main 통합 대기. 이전 `004781b`·`d505b34`의 큰 파란 HUD·외부 가격판 적용은 이번 확정안의 완료 근거가 아니다.

## 범위·승인

사용자가 확정한 작은 어두운 재화 HUD, 작은 아이콘 전용 능력·메뉴, 접힌 목표 진행 버튼, 자판기 내부 초록 숫자 LCD, 선반 정렬·접지 그림자, 최초 픽셀 장갑·첫 클릭 후 호버 모서리를 적용한다. 사용자 「진행해」「디자인 파일들부터 수정」「관련된 에셋도 전부 바꿔」「수정해」에 따른 승인된 재작업이다. 구매·가격 5%·해금·저장·피버 규칙은 유지한다. 거절한 피버 개편과 미채택 음료 상태 제안은 제외한다. Push·PR은 범위에 없다.

사용자 확정 증거는 「기획문서에서 추가 화면 찾기」의 `currency-legibility.html`, `price-large.html`, `drink-shelf.html`, `search-hint.html`, `search-glove.svg`이며, 디자인 SSOT는 계속 Penpot이다.

## 소유자·품질 판단

- owner-found: Play 씬·스크립트가 배치·표시·입력을 소유한다. 기존 `pixel_button.gd`·A 프레임·`play_theme.tres`에 PixelIconButton·QuestToggle·PricePlate를 연결했다. 별도 버튼 구현·테마를 만들지 않았다.
- owner-found: 검색 안내는 기존 `effects/search_hint.gd`, 진열 해금은 기존 `vending_display.gdshader`와 `unlocked_slots`, 음료 선택은 기존 DrinkScreen이다. 상품 선택 영역을 새 진열 좌표에 맞췄다.
- 새 파일: `assets/vending_empty.png`는 같은 좌표의 잠긴 상품을 제거하는 셰이더 입력, `gold_icon.svg`는 재화·목표 버튼, `search_glove.svg`는 기존 검색 안내에서 사용한다. 원본에서 출력한 실제 사용 에셋이며 관련 `.import`를 포함한다. 기존 `can_icon.svg`·`vending_approved_15.png`를 교체했다. 교체로 미사용이 된 `hud_frame.svg`와 메타데이터를 제거했다. 새 코드 파일은 없다.
- Test Value: 기존 abilities에 목표 상세 펼침·닫힘, search에 최초 장갑 제거·idle 비복귀·실제 호버 진입/이탈 회귀를 보강했다. 구매 영역·음료 화면의 기존 테스트는 새 그림 좌표·비율로 갱신하며 차감·중복·저장 assertion을 유지했다. 단순 색상 상수 테스트는 추가하지 않았다.

## 체크리스트

- [x] 현재 파일 ID 대조. MCP 장애 동안 Computer Use로 편집하고 복구 후 MCP로 재확인했다. 원본 수정·출력 확인 뒤 구현했다.
- [x] 00 마스터·02 본체/15종/아이콘/검색 안내, 01 연결 배경 26개와 음료 전면 7개 수정. 기존 29개 보드 ID 유지. 네이티브 Text·연결 컴포넌트 유지. 파일 검증 오류 0.
- [x] 원본 버전 `확정 기본 UI · 원본·연결 화면·관련 에셋 수정 · 게임 적용 전 · 2026-10-22`, `확정 기본 UI · 관련 에셋·게임 적용 검수 완료 · 2026-10-22` 저장.
- [x] 관련 게임 에셋·테마·Play·DrinkScreen 적용. 목표 상세와 수색 안내 입력 검증.
- [x] 기존 DESIGN·README·관련 manifest·코드 안내 갱신. 새 일반 문서·디자인 페이지 없음. 다른 체크아웃의 변경 보존.
- [x] Godot 4.7 import, 회귀 16개 통과. 실제 Metal의 기본/목표/저장 오류/해금/구매/피버·1152×648/1280×720/1920×1080/800×600 출력과 전체 15종·긴 수량/LCD 검수.
- [ ] 커밋 후 로컬 main 통합과 import·parse·회귀 확인.

## 검증·한계

실행 엔진은 `/tmp/clicker-godot-4.7/Godot.app/Contents/MacOS/Godot`(4.7.stable.official.5b4e0cb0f)이다. `--headless --editor --path . --import`, `--headless --editor --path . --quit`, `git diff --check`를 사용한다. 테스트 명령은 `--headless --path . --script res://tests/features/<이름>_test.gd`이며 gameplay, menu, purchase_price, drink_screen, drink_unlock_screen, vending_display, coin_effect, purchase_area, drink_dispense, search, search_fever, punch_fever, abilities, skill_tree, expanded_skills 및 integrations/progress_store를 포함한다. 임시 병렬 실행기는 각 로그의 오류와 종료 코드를 함께 확인했다.

실제 렌더러 검수 파일과 스크립트는 `/tmp/clicker-approved-runtime/`·`.godot/`에 두고 저장소에 추가하지 않는다. Windows 배포·전체 지원 언어 글리프·사람의 최종 플레이 검수는 남아 있다.

Knowledge Delta: 확정된 실제 UI·에셋·공유 소유자와 현재 원본 ID만 기존 안내에 반영했다. 새 제품 규칙·저장 스키마·향후 기능은 추가하지 않았다.
