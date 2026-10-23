# Plan: Penpot 음료 상세 패널 적용

> 2026-10-23 정리: 미구현·승인 대기 계획으로 보존한다. 이번 저장소 동기화는 디자인 적용 승인이 아니다.
> 아래 원본 위치·커밋·리소스 후보는 2026-10-21 조사 기록이며, 재개 전에 현재 Penpot 원본과
> `docs/04-design-rules.md` 및 실제 구현을 다시 대조한다. 루트의 옛 씬은 실행 대상에서 제외하고
> `.godot/local-backup-before-sync-2026-10-23/`에 로컬 백업했다. 공유 테마 UID는 별도 정리 커밋에 포함한다.

## Goal / Scope

사용자가 첨부한 DetailPanel 306×278을 기존 음료와 능력 화면의 선택 정보창에 적용한다.
파일 ID cd444aaf-0d8c-801b-8008-cda246e18650, 페이지 490e660f-738c-80e7-8008-d0f0d410a6b5,
컴포넌트 b3f38c37-8163-8042-8008-d10123f3f7c8을 연결된 Penpot UI에서 대조했다.

- 포함: 패널 프레임·텍스트 계층·음료 추가 버튼의 원본 디자인, 실제 상품 상태 연결, 원본/적용 안내.
- 유지: 현재 오른쪽 정보창 위치·306×278 크기, 클릭 전용 선택·바깥 클릭/ESC 닫기,
  동적 빈캔 비용·선행 조건·정확한 차감·저장·능력 계산.
- 원본의 X=64,Y=220은 디자인 시스템 시트 좌표이므로 게임 배치 좌표로 사용하지 않는다.
- 자판기 확대, 나머지 HUD·퀘스트·일시정지·메뉴·A 버튼 전체 적용은 이번 범위에서 제외한다.
- 확장 경계: 상세 패널 전용 변형 리소스를 공유 UI 소유 경계에 둔다. 전체 테마를 재정의하지 않는다.
- 남은 제품/디자인 질문: 0. 코드/테스트 수정 승인: 대기.

## Decision Ledger

| ID | 근거 | 상태 | 결정 |
| --- | --- | --- | --- |
| D1 | 사용자 첨부와 원본 | 확정 | 음료 상세 패널 디자인을 게임에 적용 |
| D2 | 원본 확인 | 확인 | 파란 면 #4699c8, 테두리/그림자 #132433, 하이라이트 #9fddfa, 음영 #28648f, 글자 #fff2d9/#cbdde2, 외곽선 #1a3547, Cafe24 PRO UP |
| D3 | 기존 소유권 | 확인 | drink_screen가 표현/입력, Play가 세션 상태 전달, 세션이 해금·진행 변경 |
| D4 | 원본/기존 동작 대조 | 제안 | 원본처럼 카드 X를 표시하지 않고 기존 바깥 클릭·ESC로 닫기 유지. 버튼에는 동적 필요 빈캔을 표시하여 결제 정보 유지 |
| D5 | 현 작업 범위 판단 | 제안 | 스타일만 해당 카드에 적용; 다른 공유 패널·버튼 외형은 유지 |

## Context / Quality Before Writing

- owner-found: src/features/drinks/drink_screen.gd의 _ready, _panel, _label, _button,
  _refresh_selection, select_drink, update_state. 기존 데이터·상태·signal을 재사용한다.
- 직접 호출자: src/features/play/play.gd의 _on_ability_button_pressed → _on_skill_button_pressed,
  update_state와 _on_unlock_drink_requested. 직접 리소스: shared/ui/themes의 quest/ability/quest_claim,
  data/drink_catalog.gd. 현재 UI 테스트를 확인했다.
- 관련 마지막 커밋 cc360a6 이후 drink_screen 및 관련 테스트의 로컬 변경은 없다.
- 기존 play_theme.tres 로컬 수정과 추적되지 않은 루트 Game.tscn/main.tscn은 다른 작업으로 보존한다.
- 기존 PLAY_PANEL은 QuestPanel 등과 공유하므로 원본 색상 변경을 그 리소스에 전역 적용하지 않는다.
- 새 리소스 후보: src/shared/ui/themes/drink_detail_theme.tres(패널 전용 테마 변형),
  src/shared/ui/icons/drink_detail_frame.svg(텍스트 없는 nine-patch 프레임). 호출자는 drink_screen이다.
  기존 공유 프레임은 다른 화면도 사용하므로 덮어쓰지 않는다. 새 런타임 클래스/상태 원장은 없다.
- 표준 변경 경로: 2파일/20줄 제한을 넘으므로 Fast Path를 사용하지 않는다.

## Checklist

- [x] 로컬 규칙·아키텍처·관련 소유자·테스트·실제 Penpot 원본 읽기
- [ ] 한 번의 통합 구현 승인
- [ ] codex/drink-detail-panel 작업 브랜치에서 테마/프레임을 기존 소유자에 연결
- [ ] 기존 UI 테스트의 이전 QuestPanel 동일성 가정을 새 계약에 맞게 수정
- [ ] 잠금/선행 조건/부족/해금 완료/긴 음료명/hover·pressed·disabled·닫기·resize 화면 검수
- [ ] 원본 적용 상태와 DESIGN.md·design/README.md·관련 코드 안내 갱신
- [ ] 실제 diff의 중복·임의 스타일·책임·다른 작업 혼입 확인
- [ ] 검증 후 로컬 커밋·main 머지 및 포함 여부 확인; push/PR 없음

## Verification / Test Value Gate

별도 테스트 파일은 만들지 않는다. 기존 drink_screen_test의 클릭·해금·중복 차감 방지·resize 관찰을
재사용한다. 다른 패널과 동일한 StyleBox여야 한다는 이전 assertion은 더 이상 유효하지 않으므로
카드 크기·조작·상태·문구 넘침을 보호하는 검증으로 갱신한다. 단순 색상값 복제 assertion은 추가하지 않는다.

- Godot --headless --editor --path . --import
- Godot --headless --editor --path . --quit
- Godot --headless --path . --script res://tests/features/drink_screen_test.gd
- Godot --headless --path . --script res://tests/features/drink_unlock_screen_test.gd
- Godot 실제 렌더러로 drink_screen_test 실행 및 .godot/test_artifacts/ 임시 캡처 검수
- git diff --check, 변경 GDScript 타입·탭·100자·LF 검토
- 릴리스 빌드·다국어 전체·미설정 formatter/lint는 완료로 주장하지 않는다.

## Knowledge Delta

완료 후 검증한 원본 컴포넌트/런타임 연결만 안내에 반영한다. 스타일 적용 자체는 새 제품 규칙이
아니므로 Notion 능력·비용 규칙은 변경하지 않는다. 실제 새 동작이 확정되면 해당 항목을 별도로 동기화한다.
