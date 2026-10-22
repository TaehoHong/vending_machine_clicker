# Plan: 첫 스테이지 음료 능력·강화 상한 적용

## Goal / Execution

2026-10-22 최신 사용자 표를 등급·색상 제외 후 게임에 적용한다.
획득 기록 보존과 실제 능력 상한, 세 확률 음료의 균등 강화는 확정이다.
Notion 기존 기록에서 해당 항목을 수정하고 새로고침으로 저장을 확인했다.
코드/테스트 편집은 미정 사항을 포함한 통합 승인 직전에 대기한다. Fast Path 대상이 아니다.

## Scope / Decision Ledger

| 항목 | 근거·상태 | 처리 |
| --- | --- | --- |
| 15종 능력·상한 | 사용자 확정 | 단일 카탈로그와 기존 규칙 소유자에서 적용 |
| 획득 기록 | 사용자 확정 | 원본 기록·저장 수는 유지, 계산에 쓰는 강화량만 제한 |
| 균등 강화 | 사용자 확정 | 진저 +2%p, 레모네이드 꽝 −2%p, 레몬라임 2회 인정 +8%p |
| 등급·색상 | 게임 적용 제외 요청 | 카탈로그 UI·색·가중치로 새로 추가하지 않음 |
| 이온·사과 | 수치 미정 | 이전 Notion 제안 배분표를 승인안으로 제시하되 코드에 임의 적용하지 않음 |
| 최대 강화 제외·반복 피버 | 충돌 미정 | 콜라·에너지 예외 여부와 후보 재분배 승인 필요 |
| 황금 추첨·보장·빈캔 해금 | 관계 미정 | 0.1% 기본/최대10%/14종 완료 보장의 적용 순서와 기존 빈캔 해금 조건 정리 필요 |
| 주차장 해금 | 사용자 표 포함 | 해금 상태 저장을 포함하는 안. 현재 런타임에 주차장 씬·캐릭터·전환용 아트가 없으므로 실제 맵/이동 연출 범위도 승인에서 명확히 구분 |

현재 관련 src/·tests/의 마지막 커밋은 cc360a6이며 해당 경로의 로컬 수정은 없다.
다른 작업의 play_theme.tres, DESIGN.md, design/README.md, 루트 Game.tscn/main.tscn과
이전 두 승인 대기 계획은 보존하고 이번 구현에 섞지 않는다.

## Ownership / 품질 작성 전

- owner-found: `src/data/drink_catalog.gd`가 상품 키·인덱스·비용·선행 조건·문구를 소유한다.
  저장 호환 key/index와 기존 해금 비용/순서는 별도 결정 없이는 바꾸지 않는다.
- owner-found: `src/game/progression/drink_rules.gd`에서 총 획득량·실제 강화량·후보 자격을 계산한다.
  같은 상한을 UI나 저장소에 복사하지 않고 세션을 통해 사용한다.
- owner-found: `src/game/economy/economy_rules.gd`, `src/game/search/search_rules.gd`가 보상·클릭·기간을 계산한다.
- owner-found: `src/game/game_session.gd`가 추첨·진행·빈캔 지급·피버를 변경한다.
  랜덤 추첨 경계는 기존 _roll_drink/_search_is_empty를 확장하며 테스트 가능한 인자/결과를 사용한다.
- owner-found: `src/game/progress_state.gd` 및 `src/integrations/saves/progress_store.gd`가 상태/직렬화를 소유한다.
  저장된 총 획득 수를 상한까지 덮어쓰지 않는다. 실제 새 상태가 필요할 때만 이 경계에 필드를 추가한다.
- 직접 호출자: `src/features/play/play.gd`의 구매·수색·해금 요청, _refresh_skill_tree와
  _drink_cumulative_text, `src/features/drinks/drink_screen.gd`의 update_state/선택 상세.
  표시용 스냅샷과 신호 경계를 유지하며 새 잔액·해금 원장을 두지 않는다.
- 디자인: 기존 Play Theme/PLAY_PANEL·PLAY_BUTTONS·PLAY_ACTIONS와 Cafe24 PRO UP을 재사용한다.
  화면 배치·스타일은 바꾸지 않고 문구·강화량·한도 표시만 갱신한다.
  실제 변경되는 네이티브 문구/상태 예시는 연결 Penpot 상세 컴포넌트에도 같은 작업에서 반영한다.
- 새로운 런타임 파일은 기본 계획에 없다. 미래 스테이지/외부 SDK용 빈 구조를 만들지 않는다.

## 체크리스트

- [x] PRODUCT/PAVE/개발/구조/코드 안내와 관련 실제 소유자·직접 호출·테스트 확인
- [x] 획득 기록 보존·균등 강화·등급/색상 제외를 Notion과 PRODUCT에 동기화
- [ ] 미정 확률·후보/황금 정책 및 코드 수정 통합 승인
- [ ] 각 음료 실제 강화 수·보상·꽝·확률·클릭 2회·기간 적용
- [ ] 후보 제외·피버 예외·황금 정책·저장 상태를 승인된 범위에서 연결
- [ ] 획득/강화 적용 수 표시와 누적 능력·한도 갱신
- [ ] 필요한 기존 회귀만 새 확정 계약에 맞게 갱신, 중요한 경계 검증 추가
- [ ] Notion 구현 상태·Penpot 문구·PRODUCT·DESIGN·관련 코드 안내 동기화
- [ ] 실제 diff에서 중복·임의 스타일·소유권·타입/LF/탭/100자·타 작업 혼입 검사
- [ ] 검증한 작업만 로컬 커밋/main 머지, 통합 결과 확인. push/PR 없음

## Verification / Test Value Gate

- 기존 `tests/features/expanded_skills_test.gd`, search/abilities/skill_tree/drink_screen 테스트의
  이전 능력 기대값은 사용자 변경이 대체한다. 숫자만 완화하지 않고 새로운 동작을 검증한다.
- cap−1/cap/cap+1 및 초과 기록 저장/로드에서 획득 수 불변·실제 능력 상한을 확인한다.
- 확률은 표 총합·구간 경계·0%/최댓값·후보 제외를 결정적 입력으로 검증한다.
  확률이 나올 때까지 반복하는 불안정 테스트는 만들지 않는다.
- 꽝은 모든 보너스 후에도0, 클릭 2회는 진행만 증가, 진저×수색피버×펀치 중첩을 검증한다.
- 기존 구매 5% 증가·단일 차감·빈캔·선행 조건·저장 호환·ESC를 회귀 검증한다.
- 선언된 Godot import/parse, 관련 feature 테스트와 progress_store_test를 사용한다.
  관련 공유 변경이 넓으므로 완료 전 docs/05-quality-rules.md의 기존 16개 회귀를 실행한다.
- 실제 렌더러로 강화 전/최대/초과 저장·잠금·부족·해금·피버와 작은 창을 검수한다.
- git diff --check. 미설정 formatter/lint·릴리스 빌드는 성공으로 주장하지 않는다.

## Knowledge Delta

검증 후 강화 적용량/후보 자격의 기존 소유자 확장, 실제 새 저장 키·문구·검증 계약만
코드 안내에 남긴다. 추천 수치·승인 대기 범위를 확정 기획이나 구현 완료로 승격하지 않는다.
