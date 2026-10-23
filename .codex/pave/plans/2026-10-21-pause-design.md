# Plan: 일시정지 원본 정렬과 게임 적용

> 2026-10-23 정리: 미구현·승인 대기 계획으로 보존한다. 이번 저장소 동기화는 디자인 적용 승인이 아니다.
> 아래 원본 위치·커밋·리소스 후보는 2026-10-21 조사 기록이며, 재개 전에 현재 Penpot 원본과
> `docs/04-design-rules.md` 및 실제 구현을 다시 대조한다. 루트의 옛 씬은 실행 대상에서 제외하고
> `.godot/local-backup-before-sync-2026-10-23/`에 로컬 백업했다. 공유 테마 UID는 별도 정리 커밋에 포함한다.

## Goal / Success

Penpot의 저장 버튼 문구를 계속 버튼 문구와 같은 기준으로 정렬하고,
현재 일시정지 창에 첨부 디자인을 적용한다. 계속·저장·끝내기·ESC·저장 실패 시 종료 차단을 유지한다.

## Scope and Decision Ledger

- 사용자 확정: 저장 문구의 위치를 계속과 일치시키고 첨부 일시정지 디자인을 게임에 적용한다.
- 확인한 원본: 파일 cd444aaf-0d8c-801b-8008-cda246e18650,
  페이지 490e660f-738c-80e7-8008-d0f0d410a6b5,
  컴포넌트 b3f38c37-8163-8042-8008-d1013e7a547e.
- 기존 컴포넌트 이름은 400×436이지만 실제 수정 원본은 400×496이다. 실제 치수를 따른다.
- 원본의 저장 문구: X=160, width=208, 중앙 정렬에서 X=212, width=158, 왼쪽 정렬로 변경했다.
  Penpot 속성창은 상위 패널 상대 X=148로 표시한다. 계속의 X=212, font_size=24,
  왼쪽 정렬과 동일하다. 버튼 Y 위치 차이는 유지한다.
- 범위: 해당 패널과 세 버튼·텍스트·힌트의 표현만. 픽셀 A 224×64 프레임과 play/door 아이콘 재사용.
- 범위 밖: 다른 Play HUD·메뉴·음료 상세 패널, 음료 확대, 기능/저장 정책 변경.
- 음료 상세 패널 작업은 별도 승인 대기이며 이 승인 범위에 합치지 않는다.
- 남은 디자인/제품 질문 0, 코드·테스트 수정 승인 1건 대기.

## Ownership / Context

- owner-found: src/features/pause/pause_menu.tscn과 pause_menu.gd가 표현·포커스·signal을 소유한다.
  기존 노드 경로와 _on_resume_pressed/_on_save_pressed/_on_quit_pressed를 유지한다.
- 직접 호출자: Play의 ESC 처리·_on_pause_save_requested·_on_pause_quit_requested,
  저장은 app 경계로 위임한다. 새로운 저장/일시정지 상태를 만들지 않는다.
- 기존 shared/ui/icons/hud_buttons/frames/224x64_* 5상태와 icons/play.svg·door.svg,
  assets/fonts/Cafe24PROUP.ttf를 재사용한다. 프레임 SVG를 복제하지 않는다.
- 예상 코드 변경: pause_menu.tscn, 표현용 src/shared/ui/themes/pause_theme.tres 신규 1개.
  새 리소스는 원본에 맞는 패널·텍스트·버튼 상태의 연결을 소유한다. 기존 play_theme의
  메뉴·다른 화면 스타일을 바꾸지 않기 위해 별도 테마 변형을 사용한다. 새 스크립트·기반 클래스 없음.
- 현재 main, pause 관련 마지막 커밋 cc360a6. 다른 작업의 play_theme.tres 수정과 루트
  Game.tscn/main.tscn은 보존하고 커밋에 포함하지 않는다.
- 20줄 제한을 넘으므로 표준 경로로 진행한다.

## Checklist

- [x] 규칙·관련 소유자·호출자·기존 테스트·원본 파일 ID 확인
- [x] Penpot의 저장 글씨 위치·폭·왼쪽 정렬 수정 및 전체 패널 시각 확인
- [ ] 통합 코드 수정 승인
- [ ] codex/pause-design 작업 브랜치 생성, 원본의 패널·A 버튼·텍스트를 기존 씬에 연결
- [ ] 기본·hover·pressed·disabled·focus·저장 결과·ESC·작은 화면의 실제 렌더링 검수
- [ ] 관련 디자인 안내와 코드 안내의 실제 연결 경로 갱신
- [ ] 코드 품질 검사·검증 후 해당 변경만 로컬 커밋/main 머지, 포함 여부 확인

## Verification / Test Value

외형·위치 수정은 기존 menu_test의 실제 저장/로드·resume·ESC·실패 시 종료 차단 검증으로 보호한다.
색상값을 그대로 비교하는 새 테스트는 만들지 않는다. 테스트용 상태·실제 렌더러 캡처로 글씨 정렬과
클리핑을 확인한다. 보상/기획 규칙은 변경하지 않으므로 Notion 제품 규칙은 수정하지 않는다.

- Godot --headless --editor --path . --import
- Godot --headless --editor --path . --quit
- Godot --headless --path . --script res://tests/features/menu_test.gd
- Godot --headless --path . --script res://tests/features/punch_fever_test.gd
- 실제 렌더러의 일시정지 화면 확인, git diff --check.
- formatter/lint·release build 미설정은 실행 완료로 보고하지 않는다.

## Knowledge Delta

검증 후 pause 씬이 사용하는 공유 A 리소스와 원본 실제 크기만 기존 안내에 반영한다.
일시적 도구 출력·작업 이력은 프로젝트 규칙으로 승격하지 않는다.
