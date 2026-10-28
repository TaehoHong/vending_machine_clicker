# 시설 구매·강화 재화 버튼

## 확정 범위와 결정
- user-confirmed / active F1: 자동 자판기 빈캔 10개, 쓰레기통 15개를 한 번 내면 구매·설치. 1,000/500 Gold 단계 제거.
- user-confirmed / active F2: 강화는 기존 100 Gold부터 항목별 두 배, 최대 5회 유지.
- user-confirmed / active F3: 구매 버튼은 빈캔 아이콘+수량, 보유 시설 버튼은 골드 아이콘만 표시하여 강화창 열기. 강화 비용은 강화창에서 표시.
- user-confirmed / active F4: 문구 제거, 재화 묶음 중앙 정렬. 미보유 행은 비활성 외형, 충분한 물품이면 구매 가능.
- deferred F5: 시설 UI 전반 재설계. 이번에는 현재 목록·패널·동선을 재사용한다.
- repo-evidenced: 이전 저장 unlocked=true는 이미 빈캔을 지출한 상태. 정규화에서 owned로 이어 추가 차감을 방지한다. 저장 키·잔액·기존 보유·강화·생산은 보존한다.
- 구현 승인: 원 요청의 구체적 수정 지시와 후속 답변 범위 안에서 실행. 추가적인 범위 확대 없음. 남은 동작 결정 0.

## 소유자·디자인
- owner-found: facility_rules.gd purchase/normalize/upgrade와 game_session 직접 호출, facility_rules_test로 확인. 기존 owner에서 구매를 통합하고 미사용 unlock API 제거.
- owner-found: facilities_screen.gd와 purchase/auto_upgrade/trash_upgrade_design.tscn. 별도 UI 모듈·재화 원장 없음.
- 디자인: docs/04-design-rules.md → Penpot 공통 구매창 530a781c-9b38-80ef-8008-d8a9fa600823. design_view.gd action, pixel_button.gd, play_theme.tres 원본 프레임·Gold/Can 아이콘 사용. 기존 drink_screen.gd:223의 비활성 알파 0.55 재사용.
- 강화 항목 이름은 버튼 밖 행 제목으로 유지하고 버튼 안에는 골드 아이콘·숫자만 표시. 기존 패널·행 위치·버튼 프레임 재사용.
- 새 런타임 파일 없음. 검수 캡처·스크립트는 /private/tmp 및 검수 산출물 폴더에만 생성.

## 검증 가능한 작업
- [x] 기존 시설 규칙 테스트를 빈캔 단일 구매·실패 무차감·중복 구매·골드 강화·해금 저장 호환 조건으로 변경하고 변경 전 실패 확인. facility_rules.gd, game_session.gd 수정 후 facility_rules_test 통과.
- [x] facilities_screen.gd와 네이티브 씬 3개에서 재화만 버튼에 표시, 미보유 행 비활성, 보유 아이콘→강화창→항목별 Gold 차감. facilities_test로 실제 클릭·모달·월드 수령 회귀 검증.
- [x] 편집 가능한 Penpot 공통 원본·6개 상태·강화 2개 보드·규칙 문구, Notion의 해당 문단 동기화. PRODUCT.md, DESIGN.md, design/README.md, docs/07-codebase-guide.md 관련 규칙만 갱신.
- [x] Godot4.7 import/parse, facility_rules/facilities/progress_store 및 선언된 게임 회귀, git diff --check. Metal 실제 미보유·구매 직후·강화·잔액 부족·한도 상태 캡처 검수.
- [x] 기능별 커밋, 기존 사용자 DESIGN.md 수정 제외. 로컬 main에 머지 후 관련 통합 검증. push/PR 없음.

## 비범위
손님 애니메이션·생산 수치·설치 위치·오프라인 생산·다음 스테이지·시설 관리 화면 추가·전면 재설계.

## Test Value Gate
단일 빈캔 구매가 골드를 차감하거나 한 번에 설치하지 않는 결함, 중복 지출, 기존 unlocked 저장에서 물품 재차감, 강화의 재화 혼용을 검출한다. 레이아웃의 픽셀·정적 문구를 복제하는 테스트는 추가하지 않고 실제 캡처로 확인한다.

## 검증·지식 반영
- rules-red.log: 변경 전 단일 구매 assertion 실패. rules-green.log 및 최종 tests/results.json: 규칙·실제 저장 호환과 전체 20/20 통과.
- import-final.log와 parse.log, 실제 Metal capture.log count=7. 부족·미보유·각 시설 보유·각 강화·한도 화면을 확인했다. 최종 diff에서 신규 런타임 파일·추가 규칙 소유자·중복 테마 없음.
- 사용자 확정 구매/강화 재화와 저장 호환을 Notion+PRODUCT.md, 버튼·행 상태를 Penpot+DESIGN.md+design/README.md, 변경된 구매 진입을 codebase-guide, 검증을 quality-rules에 반영했다. 새 troubleshooting 문서는 단순 정책 변경이므로 만들지 않는다.
- Penpot API의 source 변경 응답과 원본 강화 화면 캡처를 확인했다. 이후 브라우저가 Mac 잠금으로 중단되어 선택적인 추가 미세 중앙 정렬 요청은 실행되지 않았다. 마지막 확인 원본에서 버튼·행·재화 변경은 반영돼 있다.

- 로컬 main ff9f24b 통합 후 import 및 parse·facilities·facility_rules·progress_store·gameplay 5개 검사 모두 통과. main 작업 트리 깨끗함, 기존 DESIGN.md 고객 원화 지침 수정과 .DS_Store/이전 계획은 이번 커밋에서 제외했다.
