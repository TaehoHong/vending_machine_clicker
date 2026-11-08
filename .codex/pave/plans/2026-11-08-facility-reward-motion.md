# 자동 자판기 골드 표시 시간·물품 부유 효과

## 요청·승인 상태

- 2026-11-08 사용자 요청: 자동 자판기의 돈이 너무 빨리 사라지는 문제를 개선하고 물품에 부유 효과를 추가한다.
- 사용자 “진해앻”을 진행 승인으로 해석하여 위에 제시한 통합 구현 범위를 승인받았다.
- 기존 사용자 변경인 `.impeccable/critique/2026-11-06T07-46-58Z__src-features-facilities-facility-world-gd.md`는 보존한다.

## 범위·결정 원장

| ID | 분류·소유자 | 출처·상태 | 적용 내용 |
| --- | --- | --- | --- |
| D1 | in-scope · 사용자 | user-confirmed · active | 자동 자판기 골드가 눈에 충분히 머물고 물품이 부유한다. |
| D2 | in-scope · 구현 | agent-assumed · active | 골드는 기존 0.5초에서 약 2초로 늘린다. 기존 상승·하강 뒤 선명한 대기와 마지막 페이드를 두고 종료 시 각 생산분을 한 번 자동 수령한다. 모션 감소에서도 정지 표시로 읽을 시간을 준다. 시간은 가역적인 검수용 조정값이다. |
| D3 | in-scope · 구현 | agent-assumed · active | 물품은 현재 첫 스테이지의 빈캔으로 해석한다. 기존 0.84초 낙하·굴림 뒤 그림만 약 4px·2.4초 주기로 부유한다. 입력 영역은 고정하고 호버·누름·반짝임을 재사용한다. 모션 감소는 부유를 끈다. 수치는 검수용 조정값이다. |
| D4 | preserve-current-behavior · 진행 | repo-evidenced · active | 생산 주기·골드/드롭 수량·확률·빈캔 15초 소멸·클릭 수령·쓰레기통 수집·ESC 정지·모달 입력 차단·중첩 지급·종료/재진입 복구를 유지한다. |
| D5 | in-scope · 동기화 | user-confirmed · active | Notion 원문·Penpot 편집 가능한 원본과 로컬 안내를 함께 갱신한다. 외부 반영을 확인하지 못하면 대상·사유를 미동기화로 명시한다. |
| D6 | out-of-scope | repo-evidenced · active | 수색/피버/퀘스트 효과·손님 동작·원화·새 테마·저장 필드·확률·강화 규칙을 바꾸지 않는다. 정당한 새 확장 경계는 없다. |

차단하는 미확정 기획 결정은 0개이며 통합 구현 승인을 받았다.

## 기존 소유자·디자인 근거

- owner-found: `src/features/facilities/facility_world.gd:33`의 `_start_gold_effect`와 `_finish_gold_effect`가 골드 연출·금액 한정 수령 요청을 소유한다. 현재 0.22초 상승 + 0.28초 하강/동시 페이드가 빠른 소멸의 직접 근거다. `facilities_test.gd`의 중첩/재진입 회귀와 Play의 `facility_world.advance` 호출로 소유권을 대조했다.
- owner-found: 같은 파일의 `_draw_can`·`_animate_can_drop`·`_set_can_drop_pose`와 `_can_elapsed`가 빈캔의 낙하·대기·반응 표현을 소유한다. 부유는 기존 그리기와 게임 표현 시계에 더해 별도 tween/타이머/파일을 만들지 않는다.
- owner-found: `game_session.collect_facility_gold` → `facility_rules.collect_gold`가 지급을 소유하고 기존 저장 경계를 유지한다. 표현에서 보상 계산이나 별도 잔액 원장을 만들지 않는다.
- 디자인 기준: `docs/04-design-rules.md`·`DESIGN.md`, 공통 `search_coin.gd`·`can_icon.svg`·`play_theme.tres`의 `AccentLabel`을 재사용한다. 정규 예시는 `facility_world.gd:131`의 호버/누름/반짝임이다. 새 아트·색·테마는 필요 없다.
- Penpot 대상은 지정 파일 `cd444aaf-0d8c-801b-8008-cda246e18650`의 01 시설 골드 보드·02 Currency·03 빈캔 모션이다. 새 Chrome 편집 탭에서 같은 파일을 열고 MCP 재연결 표시를 확인했다. 원본 조회·저장 확인은 아직 완료하지 않았다.
- Notion 원문은 연결 도구로 읽었다. 페이지 마지막 편집 시각은 2026-11-06이며 골드 자동 수령·빈캔 클릭/15초 소멸 규칙을 확인했다.

## 구현·검증 체크리스트

- [x] 관련 가이드의 근거 경로에 가이드 커밋 이후 변경이 없는지 확인하고 대상·직접 호출·공유 아트·시설 회귀를 조사한다.
- [x] 통합 구현 승인을 받는다.
- [x] 골드 표시 연장: `facility_world.gd`와 `tests/features/facilities_test.gd`에서 읽을 시간 확보·연출별 단일 지급을 검증한다. 기존 0.5초 소멸이 새 지속성 검사에서 실패하는지 먼저 확인하고 수정 후 통과시킨다. 모션 감소·ESC·중첩 생산·종료/재진입 회귀를 함께 확인한다.
- [x] 빈캔 부유: 같은 두 파일 범위에서 기존 입력 영역과 클릭 수령·모션 감소·ESC를 보호한다. 실제 GPU 렌더에서 착지 후 서로 다른 위상·호버·누름을 확인한다. 수학 공식을 그대로 복제하는 테스트는 추가하지 않는다.
- [x] `PRODUCT.md`·Notion 시설 문단, `DESIGN.md`·`design/README.md`·Penpot 관련 편집 원본을 동기화한다. 확인되지 않은 수치를 확정 밸런스로 승격하지 않는다. 관련 기존 Penpot 미동기화 상태도 접근 가능 범위에서 함께 반영한다.
- [x] `docs/07-codebase-guide.md`의 기존 시설 빈캔·골드 표현 계약만 갱신하고 검증된 지식만 반영한다. 새 런타임 파일·새 troubleshooting 문서는 필요 없다.
- [x] Godot 4.7 import/parse, `facilities_test.gd`·`facility_rules_test.gd`·`customer_animation_test.gd`·`menu_test.gd`·`progress_store_test.gd` 등 `docs/05-quality-rules.md`의 선언된 회귀 21개와 `git diff --check`를 실행한다. 실행 파일은 `/Applications/Godot.app/Contents/MacOS/Godot`이며 `4.7.stable.official.5b4e0cb0f`를 확인했다.
- [x] 실제 diff의 재사용·책임·스타일·추가 파일 필요성을 검토하고 임시 검수 산출물은 Git에 포함하지 않는다.
- [ ] 작업 브랜치 `codex/facility-reward-motion`에서 검증한 변경만 로컬 커밋하고 `main`으로 머지한 뒤 포함 여부·통합 검사를 확인한다. push/PR은 하지 않는다.

## 테스트 가치·완료 기준

골드의 눈에 보이는 대기와 중첩 지급·pause·복구는 연출 연장으로 회귀할 수 있는 관찰 가능한 동작이다. 기존 시설 회귀를 확장하며 새 테스트 파일은 만들지 않는다. 빈캔은 실제 렌더로 부유·고정 입력·기존 상호작용을 확인한다. 외부 원본이나 시각 검증이 막히면 해당 결과를 분리해서 보고한다.

예상 변경 파일은 이 계획과 `facility_world.gd`, `facilities_test.gd`, `PRODUCT.md`, `DESIGN.md`, `design/README.md`, `docs/07-codebase-guide.md`다. 문서 소유권·원본 동기화 때문에 2파일/20줄 빠른 변경 경로에 해당하지 않는다.


## 검증 결과·Knowledge Delta

- 기존 구현은 0.8초 표시 지속성 검사에서 실패했다(`/private/tmp/facility-motion-red.log`). 수정 후 시설 회귀의 표시·선명도·중첩 지급·모션 감소·pause·저장 복구를 통과했다.
- Godot 4.7 import/parse와 선언된 회귀 21개를 실행했다. 시설 이외 20개는 첫 전체 실행에서 통과했다. 시설은 기능 검사를 통과했지만 종료 시 리소스 경고가 한 번 발생했다. 기존 menu/search 회귀의 BGM 믹서 정리 대기를 적용한 뒤 최종 시설 검사가 오류 없이 통과했다. 무조건 재시도로 실패를 숨기지 않았다.
- Metal 1152×648의 실제 렌더를 캡처했다. 부유 양 끝의 픽셀이 달라지고 입력 변환은 같음을 확인했고 실제 클릭 수령·호버·누름·모션 감소 정지·ESC 정지·골드 대기 후 지급을 통과했다. 캡처는 `/private/tmp/facility-motion-visual/`, 회귀 로그는 `/private/tmp/facility-motion-verification/`이다.
- Notion의 기존 시설 문단만 수정했다. Penpot 지정 파일의 기존 골드 흐름에 대기 상태를 연결하고 Currency 빈캔의 연결 인스턴스로 부유·호버·누름·고정 입력·감소·수령 원본을 저장했다. 편집 탭 재로딩과 새 보기 탭에서 부유 단계가 재생되는 것을 확인했다. 원본 보기 모드의 클릭 수령 최종 확인은 브라우저 도구의 응답 지연으로 미완료이며 게임의 클릭 검증과 구분한다. 기존 자판기 원화 표시 불일치·손님 보행 대기 항목을 해결한 것으로 취급하지 않는다.
- 동시 작업이 같은 체크아웃의 브랜치를 전환하여 관리 worktree로 이 작업의 테스트 수정과 계획만 옮겼다. 원래 체크아웃의 다른 변경을 보존했다.
- 기존 facility_world·공유 coin/can 아트·AccentLabel·표현 시계·세션 지급/저장 경계를 재사용했다. 새 런타임 파일·테마·에셋·저장 필드는 없다. 새 파일은 저장소가 요구하는 이 체크리스트 계획뿐이다.
- Knowledge Delta: 사용자 확정한 골드 읽기 시간과 빈캔 부유 규칙을 Notion/PRODUCT/DESIGN/design 안내에, 검증된 표현 소유권과 회귀 정리를 코드 안내에 반영했다. 조정값은 검수값으로 유지했다. 원인이 명확한 국소 표현 변경이므로 별도 troubleshooting 문서는 만들지 않았다.
