# Plan: 첫 스테이지 음료 능력·강화 상한 적용

## Goal / Execution

2026-10-22 최신 사용자 표를 등급·색상 제외 후 게임에 적용한다.
획득 기록 보존과 실제 능력 상한, 세 확률 음료의 균등 강화는 확정이다.
Notion 기존 기록에서 해당 항목을 수정하고 새로고침으로 저장을 확인했다.
2026-10-22 사용자가 직전 통합 승인안의 이온·사과 배분, 최대 강화 후보 정책을 적용하도록 승인했다.
황금만 제안과 달리 기존 빈캔 30개·에너지 선행 해금 조건을 유지하도록 확정했다. 코드/테스트 작성 승인 완료.
주차장 해금은 저장된 황금 획득으로 판정하며 실제 맵/캐릭터 이동 연출은 승인안대로 후속 범위다.

## Scope / Decision Ledger

| 항목 | 근거·상태 | 처리 |
| --- | --- | --- |
| 15종 능력·상한 | 사용자 확정 | 단일 카탈로그와 기존 규칙 소유자에서 적용 |
| 획득 기록 | 사용자 확정 | 원본 기록·저장 수는 유지, 계산에 쓰는 강화량만 제한 |
| 균등 강화 | 사용자 확정 | 진저 +2%p, 레모네이드 꽝 −2%p, 레몬라임 2회 인정 +8%p |
| 등급·색상 | 게임 적용 제외 요청 | 카탈로그 UI·색·가중치로 새로 추가하지 않음 |
| 이온·사과 | 후속 사용자 승인 | 각각 1골드 −1/−2%p를 5·10·50에 60:30:10으로 이동, 최대5회 |
| 최대 강화 제외·반복 피버 | 후속 사용자 승인 | 일반 최대 강화 제외, 콜라·에너지 반복, 남은 후보 균등 |
| 황금 추첨·보장·빈캔 해금 | 후속 사용자 승인 | 에너지 선행·30캔 해금 유지, 해금 후0.1%/최대10%/14종 완료100% |
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
- [x] 미정 확률·후보/황금 정책 및 코드 수정 통합 승인(황금 기존 해금 조건 유지)
- [x] 각 음료 실제 강화 수·보상·꽝·확률·클릭 2회·기간 적용
- [x] 후보 제외·피버 예외·황금 정책·저장 상태를 승인된 범위에서 연결
- [x] 획득/강화 적용 수 표시와 누적 능력·한도 갱신
- [x] 필요한 기존 회귀만 새 확정 계약에 맞게 갱신, 중요한 경계 검증 추가
- [x] Notion 구현 상태·Penpot 문구·PRODUCT·DESIGN·관련 코드 안내 동기화
- [x] 실제 diff에서 중복·임의 스타일·소유권·타입/LF/탭/100자·타 작업 혼입 검사
- [x] 검증한 작업만 로컬 커밋/main 머지, 통합 결과 확인. push/PR 없음

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

## 검증 결과·품질 검사

- Godot 4.7.2 official Windows 실행 파일로 docs/05의 16개 회귀 모두 성공. 오류 문자열·완료 출력·종료 코드 확인. `.godot/test_artifacts/ability-regression/`에 임시 로그.
- expanded_skills를 실제 D3D12/RTX 4070 렌더러로 실행해 획득15/강화10, 추첨 제외, 반복 피버·요약 화면 검수. 마지막 꽝 확률 계산 재사용 수정 후 관련 5개 회귀도 종료0·ERROR0으로 다시 통과했다. 로그 경로를 작업 폴더로 명시했다.
- 기존 미추적 루트 Game.tscn/main.tscn과 에디터 복원 캐시 때문에 원래 폴더 editor import는 관련 없는 구 경로 오류가 있었다. 사용자 파일은 보존했다. src/assets/project.godot/icon만 `.godot/ability-import-check/`에 복사해 선언된 --import와 --quit 명령 실행, 종료0·ERROR0 확인. 원본 폴더 import 성공으로 주장하지 않는다.
- 최종 diff: 기존 카탈로그/규칙/세션/UI 소유자 확장, 신규 런타임·테스트 파일 없음. 실제 강화량·꽝·골드 계산의 소유자를 재사용하고 새 테마·저장 원장 없음. 기존 key/index 및 저장 기록 보존.
- Notion 최신 절의 승인 규칙과 구현 상태, Penpot 02 에셋의 상세 패널 네이티브 Text 수정 후 새로고침 확인. PRODUCT와 디자인 안내 동기화. 다른 사용자의 theme/루트 씬/이전 승인 대기 계획·일시정지 문서 수정은 제외.
- Knowledge Delta: docs/07에 강화/추첨 및 기존 황금 기록으로 파생하는 주차장 해금 계약과 회귀 위치 갱신. 별도 troubleshooting 문서는 새 재현 결함이 없어 추가하지 않음.
- 자동 formatter/linter, 릴리스 export는 미설정. 실제 주차장 맵·이동 연출은 승인된 후속 범위다.
