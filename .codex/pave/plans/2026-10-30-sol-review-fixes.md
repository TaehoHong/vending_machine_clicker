# Sol 지적 수정·Terra 재검수

- 승인: 사용자가 Sol 확인 문제 수정, 시설 골드의 저장·재진입 보장, Terra 직접 재검수를 명시 요청했다. 해당 범위로 진행한다.
- 범위: F-01 시설/음료 모달 표시·입력, F-02 짧은 골드 튀어오름 뒤 자동 수령·저장·기존 pending 복구, F-03 상세 설명의 의미 단위 줄바꿈과 간격. 재화·빈캔·시설 주기와 기존 저장 키 유지. HUD 비행·새 그림체·빈캔 물리 연출·밸런스 변경은 제외.
- 결정: 자동 수령/한 번 복구는 user-confirmed·Notion 원문 근거. 연출별 금액 한정 수령은 기존 세션 소유자 확장. HUD 비행은 deferred. 재현 가능한 3개 결함 외 막는 제품 결정 0개.
- owner-found: facility_rules.collect_gold + game_session.collect_facility_gold(호출자/테스트 검색), facility_world.advance/refresh(표현), Play 저장 signal와 app main._save_game(저장). 새 재화 원장/스키마 없음.
- UI 재사용: docs/04-design-rules.md, play_theme InfoBody/InfoPanel, 기존 gold_icon, QuestScreen z=100 모달 예시. 신규 런타임 파일 없이 기존 소유자 수정.

## 실행·검증

- [x] 기존 facilities/menu/drink_screen/facility_rules 검사에 연출 중 저장·부분 수령·반복 복구·본문 영역 회귀를 추가하고 변경 전 실패 확인. 화면 z 순서는 실제 렌더링/입력 검수로 확인.
- [x] src/game/automation/facility_rules.gd, src/game/game_session.gd: 금액 한정 수령, 기본 전체 수령 호환. facility_rules_test에서 먼저 끝난 연출의 뒤 생산분 소비 방지 확인.
- [x] src/features/facilities/facility_world.gd, src/features/play/play.gd: 기존 아트의 독립 골드 연출·1회 완료/저장 및 진입 pending 복구. 시설/메뉴 실제 씬 검사로 연출 중 종료·저장·재진입·반복 로드·큰 정수 확인.
- [x] src/features/play/play.tscn, src/features/facilities/facilities_screen.tscn: 기존 퀘스트 모달 z=100 기준 적용. 빈캔 입력은 모달에 차단되는지 실제 클릭 검사.
- [x] src/features/drinks/drink_screen.gd: 공통 본문 유지, 의미 단위 줄바꿈·효과/상태 간격. drink_screen_test와 실제 1152/1280 화면 검수.
- [x] PRODUCT.md·DESIGN.md·design/README.md·docs/07-codebase-guide.md를 실제 동작/원본에 맞춰 갱신. Penpot 파일 ID 대조 후 해당 편집 원본 동기화, 접근 실패는 구체적인 미동기화로 명시. Notion 기존 확정 요구는 유지하며 불필요한 재작성 없음.
- [x] Godot4.7 import/parse·선언된 전체21개 회귀·git diff --check 실행. 종료코드뿐 아니라 성공 문구와 오류 확인.
- [x] Terra(gpt-6.1-terra)에게 격리된 저장으로 무입력 생산·중첩·기존 pending 재진입/반복 로드·연출 중 종료·두 해상도 모달/본문·모션감소를 직접 재검수시킴. 기존 보고서에 수정 후 결과와 미검증 범위 기록.
- [x] 실제 diff 재검토·문서/임시 산출물 정리·기능별 한국어 커밋·로컬 main 머지 후 통합 검증. 원격 push/PR 없음.

## 검증 결과·인수

- 변경 전 자동 수령·진입 복구·콜라 영역 분리 실패를 먼저 확인했다. 변경 후 전체 21개 회귀와 import/parse가 통과했다. 추가한 감소·pause 회귀도 통과했다.
- Terra는 두 해상도에서 자동 지급·재진입·콜라 문구를 직접 확인했다. 모달 관찰에서 겹침은 없었으나 모든 창 두 주기, 짧은 FX 중 직접 종료·감소 연출 시각 검수는 확보하지 못했다. 이를 수동 PASS로 합산하지 않는다. 중간 씬 해제/실제 앱 재로드·반복 로드·모달 뒤 빈캔 입력·큰 정수·pause는 자동 회귀로 확인했다.
- 기획 원문은 기존 자동 수령·한 번 복구 요구를 유지한다. Penpot 음료 상세 채택 상태와 골드 세 키프레임을 편집하고 별도 보기 모드에서 1,010 Gold 완료 상태까지 자동 전환을 확인했다. 링크는 design/README.md에 있다.
- 실제 diff에서 기존 소유자·공유 아트/본문·모달 기준 재사용, 저장 키/런타임 파일/패키지 추가 없음, 수정 GDScript 100자·공백·증거 링크를 확인했다. 사용자 데이터 전후 해시는 동일했다.
- 코드 커밋 2cac822·e540d4a를 로컬 main에 합쳤고 main에서 import/parse와 시설·메뉴·음료·시설 규칙·저장 호환 5개를 다시 통과했다. 전체/통합 로그는 docs/05-quality-rules.md에 있다. 검수 문서는 코드 검증 후 별도 docs 커밋으로 합친다.
- Knowledge Delta: 검증된 자동 수령·복구 계약은 PRODUCT·코드 안내·품질 문서에 반영했다. 시각 매끄러움·미실행 수동 항목은 보고서의 한계로 유지한다. 새 제품 결정이나 출시 승인을 추론하지 않았다.
