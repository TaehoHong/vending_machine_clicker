# 중앙 알림 제거 · 순차 퀘스트 한 개 표시

사용자 요청: 중앙 상단 퀘스트 달성 카드를 제거하고 우상단 퀘스트를 순서대로 한 개만 표시한다. 기존 QUEST_IDS의 동전 → 빈캔 순서를 사용하고 보상 수령 후 다음 목표로 전환한다. 모두 수령하면 HUD를 숨긴다. 다음 목표의 누적 집계·기존 저장 flag·수치·수령 골드 연출은 유지한다. 이전 두 줄 독립 수령·20초 카드 결정은 이 요청으로 대체한다.

## 소유자·범위

- `owner-found`: quests/quest_hud.gd의 refresh와 기존 hud_design·hud_row_design이 표시를 소유한다. game_session.QUEST_IDS·quest_status·claim_quest와 Play의 연결·실제 입력/저장 테스트를 대조했다. 선택·순차 표시는 HUD 한 곳에서 정하고 Play는 현재 표시 ID만 수령 요청으로 허용한다.
- 기존 QuestRow·InfoTitle·공통 재화·PixelButton·폰트·위치·배율을 재사용한다. 304×44 한 줄 크기로 바꾸며 새 파일·테마·재화 규칙은 만들지 않는다.
- Play의 quest_toast 생성·갱신·배치를 제거하고 유일 사용처가 사라지는 quest_toast.gd/uid·toast_design.tscn·row_design.tscn을 제거한다. 공통 compact 행의 완료 표시도 순차 전환으로 불필요해져 제거한다.
- 수정: play.gd, quests의 HUD 씬/스크립트, quest_screen_test·drink_screen_test·abilities_test의 영향 범위, PRODUCT·DESIGN·design/README·docs/05·06·07. Notion·연결 Penpot 원본도 같은 사용자 규칙으로 반영한다.

## 체크리스트

- [x] 실제 씬 테스트로 중앙 카드 없음·한 목표만 노출·뒤 목표 조기 수령 차단·첫 수령 후 다음 목표 표시·모두 수령 후 숨김·기존 저장 호환을 검증한다. 변경 전 실패를 확인한다.
- [x] 기존 HUD/Play 소유자에만 순차 표시와 입력 경계를 적용하고 상단 카드 전용 코드·리소스를 정리한다.
- [x] Notion 규칙·로컬 문서·Penpot 공통 HUD와 상태/프로토타입을 갱신하고 저장·렌더링을 재확인한다. 지난 작업 대기 항목은 실제 확인한 범위만 해소한다.
- [x] Godot 4.7 import·parse, quest_screen·gameplay·abilities·drink_screen·purchase_area·menu·progress_store 중심 회귀와 실제 화면, git diff --check·품질 검토. 검증된 변경을 커밋하고 로컬 main에 머지한다. push·PR 없음.

테스트 가치: 두 목표가 동시에 표시되거나 숨겨진 목표를 수령하는 회귀, 저장 후 완료 목표가 다시 나타나거나 재지급되는 결함을 실제 입력과 세션 상태로 잡는다. 재화 그림·폰트의 정적 문자열 검사는 추가하지 않고 기존 씬과 실제 렌더링으로 확인한다.

## 검증·품질 검토

- RED: 변경 전 중앙 카드 존재·뒤 목표 동시 노출 assertion 실패를 확인했다(`/private/tmp/single-quest-red.log`). GREEN: 순차 HUD 검사와 리뷰 후 기존 구매·HUD 아트/입력 배율·연출 중 수색 검사를 유지한 재검사가 모두 0 failures다.
- Godot 4.7 import·parse·선언된 전체 회귀 21개가 exit 0·완료 출력을 통과했다(`/private/tmp/single-quest-verification/results.json`). 실제 Metal에서 동전 받기·다음 빈캔 받기·전체 완료 후 숨김과 중앙 카드 제거를 확인했다.
- 실제 diff에서 HUD만 표시 순서를 소유하고 Play는 현재 ID의 입력만 연결함을 확인했다. 지급·저장·누적량 규칙과 공통 테마·버튼·재화·골드 연출을 재사용했다. 새 런타임 파일·저장 필드·스타일 override는 없다. 제거한 row/toast 리소스의 남은 런타임 참조는 없다.
- Knowledge Delta: 사용자 확정 단일 순차 표시를 PRODUCT·Notion·DESIGN에 반영하고, 확인된 표시 소유자·304×44 크기·회귀 경계를 docs/06·07에 갱신했다. 별도 장애 기록은 만들지 않는다.
- Penpot 파일 ID를 대조하고 공통 HUD를 304×44로 갱신했다. 직접 재화 HUD가 있는 화면과 중첩 Main 배치 화면을 함께 확인하여 플레이·애니메이션 보드 81개의 HUD 연결·한 행 표시/완료 숨김·중앙 카드와 큰 목표 상세 제거를 확인했다. 저장됨 표시·새 보기 탭에서 동전 받기 → 빈캔 받기 → 모두 완료 후 숨김을 실제 클릭으로 확인했다. 지난 재화 전체 사용처의 시각 대조 대기는 별도로 유지했다.
- 기능 커밋 `2df5dcb`를 로컬 main에 fast-forward 머지한 뒤 main의 parse·quest_screen 검사를 다시 통과했다. main 포함 여부·작업 트리와 `git diff --check`를 확인했다. 임시 캡처 실행기·중간 이미지를 제거했고 게임 화면 결과와 검증 로그만 작업 산출물로 남겼다. push·PR은 수행하지 않았다.
