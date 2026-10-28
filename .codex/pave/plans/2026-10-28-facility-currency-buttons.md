# 시설 구매·강화 재화 버튼

## 확정 범위와 결정
- user-confirmed / active F1: 자동 자판기 빈캔 10개, 쓰레기통 15개를 한 번 내면 구매·설치. 1,000/500 Gold 단계 제거.
- user-confirmed / active F2: 강화는 기존 100 Gold부터 항목별 두 배, 최대 5회 유지.
- user-confirmed / superseded F3 (F6): 구매 버튼은 빈캔 아이콘+수량, 보유 시설 버튼은 골드 아이콘만 표시하여 강화창 열기. 강화 비용은 강화창에서 표시.
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

## 후속 변경 · 보유 시설 업그레이드 문구
- user-confirmed / active F6: 구매창의 보유 시설 버튼은 골드 아이콘 대신 ‘업그레이드’ 텍스트. 강화창에서 항목별 Gold 비용을 표시하고 두 시설의 실제 진입 화면을 보여준다. F3의 골드 아이콘 단독 표시를 대체한다. 남은 동작 결정 0, 사용자의 직접 수정 지시 범위로 실행한다.
- owner-found: facilities_screen.refresh의 보유 상태와 facilities_test 실제 클릭 흐름. 기존 native Label·버튼 프레임·폰트·정렬을 재사용한다. 신규 런타임 파일 없음. 구매 비용·강화 수치·화면 배치 변경 없음.
- [x] facilities_screen.gd와 기존 facilities_test.gd의 보유 상태 기대값만 수정. 실제 클릭 후 auto/trash 강화창 진입, Gold 차감·복귀 회귀를 확인한다.
- [x] PRODUCT.md·Notion·DESIGN.md·design/README.md·codebase-guide의 같은 규칙을 갱신한다. Penpot은 연결 복구를 시도했으나 Mac 잠금으로 접근 불가. 보유 2개 보드의 Label 표시·Gold 아이콘 숨김 및 규칙 문구 미동기화를 명시한다.
- [x] Godot parse·facilities·facility_rules, diff --check 및 Metal 실제 클릭 진입 캡처. 전체 동작 규칙을 변경하지 않아 다른 기능의 전체 회귀 반복은 생략한다.

- 후속 검증: facilities_test·facility_rules_test·parse 및 diff --check 통과. Metal 실제 구매창에서 두 업그레이드 버튼을 각각 클릭해 진입 화면 3장을 캡처했으며, 화면 이동만으로 재화가 변하지 않음을 확인했다. 기획 규칙과 코드 안내는 최신 문구로 갱신했고 Penpot 미동기화 대상을 DESIGN.md에 기록했다.
- Git: 검증된 후속 변경도 로컬 main에 통합하고 관련 검사를 다시 수행한다.

## Penpot 연결 복구·원본 동기화
- 사용자 직접 승인: Mac 잠금 해제 없이 대체 경로를 찾아 Penpot 원본에도 ‘업그레이드’ 문구 적용. 추가 동작 결정 0.
- 기존 Chrome 로그인 세션을 사용하는 새 탭으로 접근한다. 화면 잠금 설정·인증·자격 증명은 변경하지 않는다. 원본 파일 ID와 대상 현재 상태를 먼저 대조한다.
- [x] 게임 페이지 보유 2개 보드의 기존 Label 표시·가운데 정렬, 기존 골드 아이콘·금액 숨김. 자식 구조·컴포넌트·프로토타입 연결 유지. 에셋 페이지의 시설 규칙 문구도 맞춘다.
- [x] 원본 저장 후 새로고침·재조회·캡처로 문구·가시성·강화창 연결 유지 확인. 새 코드는 작성하지 않으며 기존 게임 코드는 유지한다.
- [x] 검증 후 DESIGN.md·design/README.md의 미동기화 안내 제거, 검증된 연결 복구 방법만 기록하고 diff --check 후 로컬 main에 통합한다.

- 원본 동기화 검증 완료: 기존 Chrome 로그인 세션의 새 탭에서 Mac 잠금 해제 없이 편집했다. 기존 보유 버튼의 Label과 원본 규칙만 수정하고 컴포넌트 연결을 유지했다. 보유 행의 남아 있던 55% 흐림을 100%로 복원하고 다른 행의 가격·아이콘을 같은 버튼 내부 좌표로 맞췄다.
- 저장됨 UI 확인 뒤 새로고침하고 MCP 재연결·재조회했다. 두 Label은 업그레이드/표시/x=0/width=172/center, 골드 아이콘·금액 숨김, 보유 제목 opacity=1. 클릭 목적지는 각각 원래 auto/trash 강화 보드다. 규칙 문구 9줄과 다른 내용 보존을 확인했다.
- 푸시 전 main 회귀 20/20 통과. 런타임 파일 변경 없음. 원본 확인 이미지는 작업 첨부의 penpot-upgrade-label-sync에 두며 저장소에는 캡처를 복제하지 않는다. DESIGN·design/README의 미동기화를 해소하고 검증된 연결 복구 방법만 안내에 남겼다.
- 사용자 후속 지시: 완료 후 커밋·push 승인. origin/main은 로컬 main의 조상이며, 이번 대화의 기존 미푸시 게임 변경과 원본 동기화 안내를 main에 함께 fast-forward push한다.
