# 뽑기 연출 중 입력 및 연속 구매 허용

## 요청·승인 상태

2026-10-23 사용자 요청: 뽑기 중 능력 탭 열기, 수색, 추가 뽑기를 허용한다. 읽기·범위 조사 완료, 사용자 “진행”으로 이 계획의 코드/테스트 통합 승인 완료.

## 구체 적용안

- 구매 입력마다 당시 2% 상승 가격으로 즉시 한 번 결제·추첨·음료/빈캔 지급·저장한다. 잔액 부족/후보 없음은 결제하지 않는다. 연출 재생 중 입력도 새로운 구매로 인정한다.
- 투입·배출 연출은 구매 결과별로 보존하여 입력 순서대로 재생한다. 기존 단일 FX/공유 스타일을 재사용하며 연출 때문에 게임 전체를 잠그지 않는다. 대기열은 이미 결제·지급된 구매의 시각 표현이며 별도 재화 원장이 아니다. 재로드 시 이미 지급된 보상을 다시 지급하지 않는다.
- 기존 능력창·수색·수색 힌트·피버 표시에서 구매 연출만을 이유로 한 입력 잠금을 해제한다. ESC 일시정지와 모달 창 자체의 입력 차단은 유지한다. 능력창을 열면 기존대로 뒤의 플레이 입력은 차단한다.
- 각 결과의 음료 그림·능력 알림·피버 발동을 해당 결과와 연결해 last_drink 변경으로 덮어쓰지 않는다. 피버는 해당 음료의 배출 완료 시 발동하는 기존 시점을 유지한다. 다른 뽑기 연출만으로 기존 피버 타이머를 멈추지 않는다.
- 기존 펀치 피버 중 자판기 클릭의 타격 우선 동작은 유지한다. 새 연출 속도·자동 반복 구매·예약 결제·최대 연타 수 제한은 추가하지 않는다.

## Ownership / 품질 작성 전

- owner-found: src/game/game_session.gd purchase/search/punch/finish_purchase 및 src/game/progress_state.gd의 단일 진행·피버 상태를 사용한다. inserting_coin을 세션 입력 잠금으로 사용하던 계약을 변경한다. 결과별 완료 처리를 보존하며 boolean pending 덮어쓰기 방지. 저장 계약은 실제 새 영속 상태가 필요하지 않으면 변경하지 않는다.
- owner-found: src/features/play/play.gd 구매 핸들러·coin_tween·_refresh_ui·_process·수색/능력/타격 핸들러가 연출/입력 소유자다. 기존 coin_insert/drink_dispense/ability_toast 소유자를 재사용하고 금액/획득 계산은 복제하지 않는다.
- 직접 호출: app save_requested→progress_store, PauseMenu, Play→Session, _show_acquired_ability 및 FX begin/advance를 확인. 기존 테스트의 중복 입력 차단 기대값은 새 요청에 따라 연속 결제 기대값으로 교체한다. 정상 이벤트 한 번의 중복 지급 방지는 유지한다.
- UI: docs/04와 기존 A 공통 버튼·play_theme·PixelButton 상태를 재사용한다. 새로운 버튼·테마·레이아웃은 만들지 않는다. Notion 규칙과 Penpot 구매/배출 상태의 활성 버튼·문구를 동기화한다.
- 기본 계획은 신규 런타임 파일 없음. 단일 연출 스크립트를 이유 없이 복제하지 않는다. 기존 tests/features 구매/게임플레이/피버/메뉴 테스트를 확장한다.

## 체크리스트·검증

- [x] PRODUCT/PAVE·코드 안내 및 관련 기존 소유자/호출자/FX/검증 경계 조사. 현재 작업 폴더 clean.
- [x] 통합 작성 승인.
- [x] 구매 결과 보존 및 순차 연출, 수색·능력·추가 구매 잠금 해제.
- [x] 연속 구매 중 즉시 가격/잔액/음료/빈캔/저장 정확성, 부족 시 무차감, 서로 다른 음료의 그림·토스트·콜라/에너지 피버 결과 유지 회귀.
- [x] 연출 중 수색 성공·꽝, 능력창 열기/닫기, ESC pause/resume·피버 종료/중복·저장 재로드 검증.
- [x] 선언된 purchase_price/drink_dispense/gameplay/menu/purchase_area/search/search_fever/punch_fever/abilities/progress_store 회귀, Godot parse, 실제 연속 입력 화면 검수. 공유 세션 변경으로 실패가 발생하면 해당 직접 관련 회귀까지 확인.
- [x] Notion·PRODUCT 및 편집 가능한 Penpot 상태 동기화. 원본 접근 불가 시 미동기화 대상/사유 기록.
- [x] git diff --check·타입/탭/LF/100자·소유권/중복/테마 검토. docs/07에 바뀐 구매/연출 계약·검증 위치만 Knowledge Delta로 갱신.
- [x] 검증한 변경 로컬 커밋/main 머지·통합 확인. push 없음.

Test Value Gate: 비동기 연출과 새 구매 사이 결과 덮어쓰기, 결제/보상/저장 누락·중복, 콜라/에너지 pending 덮어쓰기 및 pause 경계가 실제 회귀 위험이므로 결정적 입력으로 기존 회귀를 확장한다. 신규 범용 큐 프레임워크·미래 기능 구조는 만들지 않는다.

## 최종 검증·품질·Knowledge Delta

- 상태 소유자 progress_state.pending_purchases 한 곳에 결과를 보존한다. inserting_coin/search_fever_pending/punch_fever_pending은 대기열에서 계산한 조회값이다. 세션 purchase는 즉시 결제·지급, finish_purchase는 한 결과만 소비하며 추가 지급하지 않는다. 낡은 결과 팝업 경유 피버 완료 경로는 제거했다. 저장 형식은 그대로이며 배출 대기·일시 피버는 저장하지 않는다.
- Play는 기존 단일 coin_insert/drink_dispense/ability_toast와 공유 A 버튼·테마를 재사용한다. _purchase_animation_active는 코루틴 중복 실행 방지용이며 재화/결과 원장이 아니다. 새 런타임·테스트 파일 없음. 기존 play.tscn의 동전 강제 z_index=10을 제거하고 배출 FX를 모달 뒤로 배치했다. 구매 중 열린 능력창 위로 동전이 겹치던 화면 검수 문제를 수정했다.
- Godot4.7.2 official Windows로 선언된 16개 회귀 전체 종료0·ERROR0. 최종 --headless --editor --path . --quit 파싱도 오류0. 최초 관련10개 후 레이어 수정 영향으로 전체16개를 검증했다. 로그는 .godot/test_artifacts/nonblocking-purchase/의 *-final.log.
- 실제 D3D12/RTX4070Ti SUPER drink_dispense 회귀 통과. 3회 즉시 결제307/잔액0/음료3/빈캔3/다음107, 콜라→에너지→물 자산·토스트·피버 순서, 성공 수색/꽝, 능력 열기와 모달 배경 차단, pause/resize, 연출 중 타이머 진행, 저장 로드 시 재지급 없음 검증. GPU 중간 검수에서 모달보다 높은 동전 z를 발견·수정하고 같은 회귀 재실행 통과. 캡처는 같은 임시 폴더의 queued-cola/ability-during-purchase.png.
- Notion 가격 절의 연출 중 중복 입력 차단 규칙을 최신 연속 구매로 수정하고 같은 날짜 승인 절 추가·재로딩 확인. 연결 Penpot 파일ID 확인 후 기존 구매03 투입 보드의 정상 능력/메뉴 컴포넌트를 확인, 입력 허용 동작 상태명을 갱신하고 다음 가격 예시를 기존2% 식의102로 수정·재로딩 확인. 새로운 버튼/프레임/스타일은 추가하지 않았다. 미동기화 항목 없음.
- git diff --check 및 추가 GDScript 줄100자·LF·타입/탭 검사 통과. 실제 diff에서 세션 결제/저장 소유권과 UI 연출 책임 유지, 중복 경제 계산/공유 테마 복제 없음 확인.
- Knowledge Delta: docs/07에 FIFO 배출 결과·조회 상태·저장 제외·입력 및 검증 계약을 갱신했다. PRODUCT/디자인 작성 규칙·원본 링크 동기화. 별도 troubleshooting 문서는 수정·회귀로 닫힌 이번 레이어 문제의 별도 운영 절차가 없어 만들지 않음. 자동 formatter/linter·릴리스 export는 미설정으로 실행하지 않았다.
