# 05. 품질·검증

제품 품질 방향은 Notion, 실행 명령의 진입점은 [AGENTS.md](../AGENTS.md)다. [개발 규칙의 코드 품질 필수 검사](02-development-rules.md#코드-품질-필수-검사)와 자동 회귀·실제 화면 검수를 함께 적용한다. 테스트 대상·소유자는 [코드 안내](07-codebase-guide.md)를 따른다.

## 실행 환경·명령

Godot 4.7을 사용한다. 이 호스트에서는 공식 4.7-stable 아카이브의 SHA512를 대조한 임시 실행 파일 `/private/tmp/clicker-godot-4.7/Godot.app/Contents/MacOS/Godot`로 검증했다. 버전은 `4.7.stable.official.5b4e0cb0f`이며 시스템/PATH 설치를 뜻하지 않는다. 아래 `godot`은 실제 실행 파일 경로로 바꿀 수 있다.

```sh
godot --headless --editor --path . --import
godot --headless --editor --path . --quit

godot --headless --path . --script res://tests/features/gameplay_test.gd
godot --headless --path . --script res://tests/features/menu_test.gd
godot --headless --path . --script res://tests/features/purchase_price_test.gd
godot --headless --path . --script res://tests/features/drink_screen_test.gd
godot --headless --path . --script res://tests/features/drink_unlock_screen_test.gd
godot --headless --path . --script res://tests/features/vending_display_test.gd
godot --headless --path . --script res://tests/features/search_test.gd
godot --headless --path . --script res://tests/features/coin_effect_test.gd
godot --headless --path . --script res://tests/features/search_fever_test.gd
godot --headless --path . --script res://tests/features/punch_fever_test.gd
godot --headless --path . --script res://tests/features/drink_dispense_test.gd
godot --headless --path . --script res://tests/features/purchase_area_test.gd
godot --headless --path . --script res://tests/features/abilities_test.gd
godot --headless --path . --script res://tests/features/skill_tree_test.gd
godot --headless --path . --script res://tests/features/expanded_skills_test.gd
godot --headless --path . --script res://tests/integrations/progress_store_test.gd
godot --headless --path . --script res://tests/integrations/facility_rules_test.gd
godot --headless --path . --script res://tests/features/facilities_test.gd
godot --headless --path . --script res://tests/features/settings_test.gd
godot --headless --path . --script res://tests/features/customer_animation_test.gd
godot --headless --path . --script res://tests/features/quest_screen_test.gd

git diff --check
```

종료 코드와 함께 `SCRIPT ERROR`·assertion·리소스 읽기 오류·완료 출력을 확인한다. Godot은 스크립트 오류가 있어도 0을 반환할 수 있으므로 종료 코드만으로 통과를 판단하지 않는다. 각 테스트를 독립 프로세스로 실행하고 타임아웃도 실패로 처리한다.

## 검증 경계

- `tests/features/`는 실제 씬과 주입된 게임 세션을 사용한다. `tests/support/game_fixture.gd`는 별도 저장 경로와 세션 대역을 연결하며 게임 규칙을 대신 구현하지 않는다.
- 저장은 `res://.godot/`의 테스트 전용 파일을 사용한다. 캡처는 `.godot/test_artifacts/`에 출력하며 채택 디자인이나 플레이어의 실제 저장을 덮어쓰지 않는다.
- 구매·해금·퀘스트: 잔액 부족·중복 입력·잘못된 순서가 진행을 바꾸지 않는지, 차감/획득/가격·진행이 함께 저장되는지 확인한다.
- 저장·백업: 기존 키와 기본값·타입/범위 처리·정수 키 음료 수·해금·이전 진행 복원·새 게임 백업·저장 실패 시 종료 차단을 확인한다.
- 입력·피버·일시정지: 클릭 영역과 클릭 위치, 꽝·보상·기간·중첩·pause·정상 복귀를 검증한다. viewport 로컬 좌표를 보내는 테스트는 `push_input(..., true)`로 좌표계를 명시한다.
- 디자인: 기존 공통 테마·상태 리소스·폰트 재사용과 선택·잠김·초기화·resize를 검사한다. headless만으로 실제 렌더링·글리프·가독성·조작 감각을 보장하지 않는다.
- 구조: 세션/규칙에 씬·Control·파일 I/O 의존이 없는지, UI가 직접 저장하지 않는지, 중복 진행 원장·규칙·스타일을 만들지 않았는지 실제 diff와 참조를 검토한다.

## Sol 검수 지적 수정·Terra 재검수 · 2026-10-30

- 자동 지급 누락·기존 미수령 골드 복구 누락·콜라 효과/상태 영역 침범을 변경 전 회귀 검사에서 재현했다. 수정 후 시설 연출별 부분 수령, 중첩 생산, 연출 중 씬 해제→실제 앱 재진입→반복 재진입, 즉시 저장된 잔액·pending 0, 10억 초과 금액을 확인했다. 모션 감소의 자동 지급과 pause 중 수령 보류·재개 후 한 번 지급도 통과했다.
- 기존 세션·시설 규칙·Play 저장 신호·골드 아트와 퀘스트의 모달 z=100 기준을 재사용했다. 시설창 뒤 빈캔의 실제 입력 차단과 닫은 뒤 수령, 음료 설명/상태 영역 분리를 검사했다. 저장 키·런타임 파일·외부 의존성을 추가하지 않았다.
- 위 21개 회귀와 Godot 4.7 import/parse가 모두 exit 0·완료 문구를 출력했다. 로그는 `/private/tmp/sol-review-fix-regression-20261030/`이다. 이후 추가한 감소·pause 검사는 `/private/tmp/sol-fix-pause-reduced.log`에서 통과했다. 기존 macOS 인증서 조회 경고와 스크립트 오류를 구분했다.
- Terra는 격리된 저장으로 직접 실행해 무입력 세 생산분 자동 지급·기존 pending 복구·정상 종료 후 재진입, 1152×648/1280×720의 콜라 세 상태를 확인했다. 관찰한 시설/음료 창에서 생산물·행인이 위를 가리지 않았다. 0.5초 연출 도중 직접 종료, 짧은 감소 연출의 시각 확인, 모든 창 두 주기 대기는 확보하지 못했다. 자동 검사 결과와 직접 플레이 결과의 세부 범위는 [검수 보고서](terra-user-test-report.md#수정-후-terra-직접-재검수--2026-10-30)에 구분한다.
- Penpot의 음료 상세 채택 상태와 시설 골드의 편집 가능한 세 키프레임을 동기화했다. 보기 모드가 완료 상태의 HUD 1,010까지 자동 전환함을 확인했다. 부드러운 tween 자체의 직접 시각 검수는 위 한계가 남는다. Notion의 기존 자동 수령·한 번 복구 요구를 구현했으며 새 기획 규칙은 추가하지 않았다.
- 기능 커밋 `2cac822`·`e540d4a`를 로컬 main에 합친 뒤 import/parse와 facilities·menu·drink_screen·facility_rules·progress_store 5개 통합 회귀를 다시 통과했다. 기록은 `/private/tmp/sol-fixes-main-20261030/results.json`에 있다.

## 퀘스트 목록·달성 알림 적용 검증 · 2026-10-29

- 메모지 HUD 누락과 시설 빈캔 중복 집계를 기존 코드에서 재현한 뒤 수정했다. 실제 클릭으로 목록·독립 행·상단 카드의 수령, 20초 만료 뒤 목록 수령, 중복 지급·저장 후 재수령 거절, X/ESC와 포커스·모달 입력·피버 정지·resize를 확인했다. 음료 정보창에서는 달성 카드와 표시 시간을 보류하여 버튼을 가리지 않는다.
- 골드 입자는 기존 `search_coin.gd` 아트를 재사용한다. 수령 즉시 지급·저장하고, 입자의 폭발·바닥 낙하·HUD 흡입·정리와 연출 중 수색을 검사했다. 기존 저장 필드를 유지했다.
- 로컬 main에 `ff8b1fd`를 반영한 뒤 import·parse와 quest_screen/gameplay/drink_screen/menu/progress_store 5개 통합 회귀를 다시 통과했다.
- 위 21개 회귀가 모두 통과했다. 실제 Metal 렌더러에서 1152×648·1280×720·1600×900의 목록/수령 상태와 상단 카드·골드 연출을 확인했다. 이 작업은 `/private/tmp/clicker-godot-passers-4.7/Godot.app/Contents/MacOS/Godot`를 사용했고 `--log-file /private/tmp/<검사명>.log`로 로그를 분리했다. 릴리스 export·린터 미설정은 그대로다.

## 구조 전환 검증 기록 · 2026-10-20

- 변경 전 main `34cff7c`: 15개 중 11개 통과·4개 실패를 분리된 복사본에서 확인했다.
- 기존 입력 실패 2개(`punch_fever`, `purchase_area`)는 로컬 좌표를 전역 좌표처럼 전달한 테스트 문제였다. 생산 코드와 기존 assertion을 유지한 원본 복사본에서 좌표계만 명시하자 통과했다.
- 기존 표시 실패 2개(`abilities`, `skill_tree`)는 이미 교체된 Catalog/Summary 노드를 검사했다. 현재 선택 상세·능력 요약·잠금/비용/획득 표시를 확인하도록 바꿨다. 가격·보상·차감·저장 기대값은 완화하지 않았다.
- `progress_store_test`는 새 구조에서 정수 키 획득량·해금·플래그·기존 저장 정규화 유실을 보호한다. 음료 수 저장을 일부러 누락시켰을 때 2개 assertion이 실패하는 것을 확인하고 원본을 복원했다.
- 실제 렌더러에서 같은 1152×648 크기·수색 안내 애니메이션 위상으로 메뉴·플레이·음료 초기·잠금 선택·요약·pause 6개 화면을 비교해 픽셀 차이가 없음을 확인했다. 이미지·글꼴·라이선스 등 53개 파일의 원본 바이트도 동일하다.
- 코드/테스트 29개에 임시 gdtoolkit 4.5.0의 `gdformat -l 100 --check`를 적용했다. 단순 이동한 데이터·연출·에셋을 일괄 포맷하지 않았고, 게임/저장소의 패키지 의존성을 추가하지 않았다.
- 구조 전환 후 회귀 16개 전체와 Godot import·parse를 통과했다. 통합 검증은 [구조 전환 계획](../.codex/pave/plans/2026-10-20-runtime-architecture-refactor.md)에 기록한다.

## Penpot 화면 적용 검증 · 2026-10-27

로컬 main의 최종 코드 `3b89e92`에서 import/parse와 위 19개 회귀 검사가 모두 통과했다. 목표 패널의 resize 위치 갱신 누락은 실패를 재현한 검사로 보정했으며, 해당 검사도 통과했다.

- 파일 ID를 대조한 Penpot 원본에서 사용하는 그래픽과 네이티브 씬을 추출했다. 1152×648 실제 Metal 렌더러에서 타이틀·플레이·음료·상세·일시정지·설정, 시설 구매·관리·강화·설치, 손님 결제·수령·피버·퀘스트를 확인했다. resize·해금·구매 중첩·입력 차단·저장 경계는 회귀 검사로 확인한다.
- 시설 규칙 검사는 중복 차감·강화 비용/상한·생산 시점·수령 중복·드롭 소멸·자동 수집·음료 능력과의 분리·저장 복원을 보호한다. 시설 UI 검사는 실제 클릭·미리보기 무차감·모달 입력·ESC를 보호한다. 설정 검사는 오디오 버스·파일 복원·슬라이더·선택 상태·돌아가기를 보호한다.
- 언어 선택은 기기 설정으로 저장하고 로케일에 적용한다. 전체 문구의 번역 리소스와 일본어/중국어 글리프 전수 검수, 오디오 콘텐츠 제작은 아직 출시 검증 범위 밖이다.
- sandbox의 macOS 인증서 조회에서 `get_system_ca_certificates` 경고가 출력된다. 스크립트/assertion/리소스 오류와 구분하며, 실제 Metal 실행에서는 이 경고 없이 화면을 확인했다.

## 손님 4종 동작 적용 검증 · 2026-10-27

- 승인된 기본 보행 6포즈와 귀·호흡·쥔 자세를 적용하고 외형 02·03·08도 연결된 상체·공통 하체로 제작했다. 관절 분할 회전과 가로 눌림을 제거하고 4종을 순환한다.
- `customer_animation_test`는 변경 전 등장 조건에서 실패했고, 변경 뒤 4종·5회 순환, .36초 정지와 후면 대기, 호흡 재생, 수령·퇴장, pause, 생산 이벤트의 fallback, cleanup과 재화 비변경을 통과했다. 기존 시설·시설 규칙·게임플레이·메뉴·구매 가격·저장 호환·음료 화면·동전 회귀도 통과했다.
- 1152×648 실제 Metal Play를 26초 재생해 최단 5초 생산에서 네 외형의 접근·조작·줍기·수령·퇴장과 방문자 누적 방지를 확인했다. 실제 사용자 저장을 사용하지 않았다.
- Sol·Terra의 이미지/프레임 검수 후 추가 외형의 허리 띠와 퇴장 골반판을 정리했다. 재검수에서 큰 띠·직선 골반 돌출 해소와 새 투명 틈 없음이 확인됐으며, 작은 옷자락 윤곽은 남아 있다. 연속 재생의 최종 사람 검수와 Windows 릴리스는 아래 범위대로 별도다.

기능 커밋 `09caa52`를 로컬 main에 통합한 뒤 main의 Godot import·손님 동작·시설·저장 호환 검사를 다시 통과했다.

## Penpot 전체 화면 전수 대조 · 2026-10-28

- 연결 파일 ID를 확인하고 게임 페이지의 화면·상태 113개를 라이브 원본에서 캡처해 대조했다. 사용자 최신 결정으로 시설 관리·보상 패널 9개를 미채택으로 구분하고, 나머지 104개를 Godot 4.7 Metal 1152×648로 재캡처했다. 캡처는 Play 74개, 메뉴·설정·일시정지 22개, 시설 구매·강화 8개다.
- 이미지 중복 합성 12개, 문단 정렬·텍스트 외곽선, 원본 인스턴스의 Frame·선택·비활성 상태와 실제 보상 버튼 전환을 보정했다. 수색 링·펀치 충격파와 동전 투입·피버 발광은 원본 벡터·PNG를 사용한다. 원본 이미지 참조 27개 중 24개는 바이트 동일하며 3개는 앞서 승인된 손님 동작 아틀라스로 대체됐다.
- 시설 구매→보유 시 업그레이드→강화→구매창 복귀, 설치 본체 무동작, 골드·빈캔 독립 직접 수령과 중복 방지를 실제 입력으로 검증했다. 부족·음료 획득 알림은 발생 순서대로 모두 표시하며 연출·보상 지급을 지연하지 않는다. Notion과 Penpot에 확정 변경을 반영하고 Penpot 새로고침 후 저장을 재확인했다.
- 선언된 회귀 20개 전체가 통과했다. 이후 목표 ready 프레임과 음료 상태별 글자 크기의 시각 보정 후 drink_screen·drink_unlock_screen·purchase_area·gameplay 관련 검사를 다시 통과했다. import/parse와 `git diff --check`도 통과했다. 공유 진행·저장 규칙은 변경하지 않았다.
- 로컬 main `8999cef`에 기능·문서를 통합한 뒤 깨끗한 main 작업 트리에서 import/parse와 gameplay·menu·drink_screen·facilities·settings 5개 회귀를 통과했다.
- 원본 캡처의 Display P3 색은 비교용 sRGB로 정규화했다. 실제 에셋의 색은 바꾸지 않았다. 정적 원본의 잔액·타이머·설정·연출 위상은 테스트 세션과 다를 수 있고 하드웨어 커서는 Godot viewport 캡처에 포함되지 않는다. JPEG 원본 캡처를 이용하므로 픽셀 완전 일치 검사로 주장하지 않는다.
- 비교 갤러리는 작업 첨부의 `penpot-full-screen-audit/index.html`에 113개 원본과 적용 104개·제외 9개를 구분한다. 원본 링크·보드 ID와 원본/실행 이미지를 함께 제공하며 저장소에 캡처 복제본을 추가하지 않았다. 전체 원본 추출 데이터와 임시 캡처 실행기는 개발 의존성으로 추가하지 않았다.

## 시설 재화 버튼·단일 구매 검증 · 2026-10-28

- 자동 자판기 빈캔 10개·쓰레기통 15개로 즉시 설치하고, 골드는 강화에만 사용한다. 변경 전 규칙 검사가 단일 구매 assertion에서 실패했고 변경 후 통과했다. 골드 0원 구매·물품 부족 무차감·중복 구매·강화 골드 부족·기존 해금 저장의 추가 차감 없는 복원을 보호한다.
- 공통 구매창의 문구를 숨기고 재화 묶음을 중앙 정렬했다. 미보유 행의 비활성 외형, 보유 시설의 골드 아이콘과 강화창 진입, 항목 이름을 밖에 둔 골드 비용 버튼, 부족·최대 강화 상태를 Metal 1152×648 7개 캡처로 확인했다. 공유 design_view·pixel_button·기존 Gold 씬·Can 아이콘과 비활성 표현을 재사용하며 새 런타임 파일은 추가하지 않았다.
- 실제 클릭에 의한 빈캔 구매→골드 강화→구매창 복귀·설치 본체 무동작·골드/물품 독립 수령 검사, 선언된 회귀 20개, Godot import/parse, `git diff --check`가 통과했다. Notion의 해당 규칙과 Penpot 공통 원본·게임 상태·강화 보드·규칙 문구를 갱신했다. 시설 UI 전반 재설계는 후속 결정이다. 기능 커밋 `ff9f24b`를 로컬 main에 통합한 뒤 import와 parse·facilities·facility_rules·progress_store·gameplay 5개 통합 검사도 통과했다.

- 보유 시설의 ‘업그레이드’ 문구를 Penpot 두 보유 상태와 시설 규칙 문구에 동기화했다. 같은 Chrome 로그인 세션의 새 편집 탭으로 Mac 잠금 해제 없이 작업했으며, 저장됨 표시·새로고침·MCP 재조회로 문구·숨김·가운데 정렬·보유 행 활성 외형과 두 강화창 연결을 확인했다. 원본의 다른 행에 있는 빈캔 가격도 해당 버튼 내부 좌표로 맞췄다. 푸시 전 현재 main의 선언된 회귀 20개를 모두 다시 통과했다. 이번 동기화에서 런타임 소스·에셋은 변경하지 않았다.

## 남은 설정·검증 범위

CI·저장소에서 고정한 포매터/린터 설치·릴리스 export/Steamworks 설정은 아직 없다. `.editorconfig`는 편집 기준이며 의미상 중복·아키텍처·디자인 일치까지 자동 강제하지 않는다. Windows 실제 배포 빌드·지원 언어 전체·플레이 감각의 최종 사람 검수는 별도로 필요하다. 성능 수치·지원 하드웨어 하한은 미확정이며 임의의 FPS 합격 기준을 만들지 않는다.

## Linked Sources

| Source | Owns | Not covered | Evidence paths |
| --- | --- | --- | --- |
| [AGENTS.md](../AGENTS.md) | 선언 명령·작업 진입 | 원격 CI 실행 | project.godot, tests/ |
| [코드 안내](07-codebase-guide.md) | 소유 모듈·관련 회귀 | 제품 기획 원본 | src/, tests/ |
| [개발 규칙](02-development-rules.md) | 재사용·파일 생성·코드 품질 | 실제 렌더링 증거 | docs/02-development-rules.md |
| [Notion](https://app.notion.com/p/3fcb6b9ead24800aa7bce8a1e1b045de) | 제품 차원의 품질 목표 | Godot 실행 환경 | PRODUCT.md |

## 시설 승인 시안 적용 검증 · 2026-10-28

- 1280×720 승인 시안의 구매 목록과 시설별 강화 상세를 기존 네이티브 씬에 반영했다. 공통 테마·176×64 버튼·재화/시설 그림·기존 글꼴을 재사용하며 신규 런타임 파일이나 경제 규칙은 추가하지 않았다. `design_view.fit`은 루트 크기로 배율을 정하고 버튼 상태는 SVG 바깥의 6px 투명 여백을 유지한다.
- `facilities_test`의 빈캔 HUD 누락 실패를 먼저 확인했다. 적용 후 실제 입력으로 빈캔 구매·골드 강화·재화/현재/다음 값/단계/다음 비용 갱신·부족 차감 차단·최대 버튼 숨김·수집량 조건·복귀/ESC·본체 무동작·생산물 독립 수령을 통과했다. 선언된 전체 회귀 20개와 Godot import·parse도 통과했다. 메타데이터·문구 정리 후 시설 검사를 다시 통과했다.
- 실제 Metal 렌더러에서 기본·보유·부족·두 시설 강화·강화 직후·최대 상태 및 1152×648/1280×720/1600×900 배율을 캡처했다. Penpot에 편집 가능한 공통 원본 3개와 연결 상태 보드 9개를 저장하고 새로고침 후 확인했으며 기존 메인 시설 버튼의 목적지를 새 구매창으로 연결했다. Notion과 로컬 기획·디자인 안내를 함께 갱신했다.

기능 커밋 `0c50b47`에 main의 시설 타이머·골드 저장 수정 3개 커밋을 통합했다. 통합본의 import·parse와 선언된 회귀 20개, main 작업 디렉터리의 시설 검사 및 최종 Metal 캡처가 통과했다. 큰 골드·빈캔도 헤더에서 단위가 잘리지 않는 것을 시설 검사에 포함했다. 원격 main의 적용 코드 `1f12a59`를 확인했다.

## 재화 통일·퀘스트 상시 HUD 검증

2026-10-31 Godot `4.7.stable.official.5b4e0cb0f`(`/private/tmp/clicker-godot-passers-4.7/Godot.app/Contents/MacOS/Godot`)로 import·parse와 위 21개 회귀를 모두 통과했다. 테스트별 종료 코드·스크립트/리소스 오류·완료 출력을 확인했으며 로그는 `/private/tmp/currency-quest-verification/`이다. 기존 macOS 인증서 조회 경고는 스크립트 실패와 구분했다.

퀘스트 검증은 실제 우상단 받기 클릭, 독립 수령·중복/로드 재수령 방지, 20초 카드 만료 후 HUD 수령, 상시 표시 중 수색·구매·피버 진행, ESC 일시정지, 4개 해상도의 균등 배율을 확인한다. 시설·구매 영역 검증은 빈캔 드롭/보유량의 호버 제거와 기존 클릭 수령·골드 툴팁을 보호한다. 실제 Metal 렌더링에서 진행·달성·완료, 시설 비용, 음료 해금의 공통 재화 그림을 확인했다. UI 배치와 그림은 자동 정적 문자열 검사 대신 실제 화면으로 검수한다.

## 중앙 알림 제거·순차 퀘스트 검증 · 2026-10-31

앞 절의 두 줄 독립 수령·20초 달성 카드는 최신 사용자 요청으로 대체했다. 변경 전 실제 씬 검사에서 중앙 카드 존재·두 목표 동시 노출 실패를 확인했다. 수정 후 현재 목표 한 개 표시·뒤 목표 조기 수령 차단·실제 받기 클릭 후 다음 목표 전환·최종 수령 후 숨김·배경 누적·이전 독립 수령 저장 호환·재지급 차단·4개 해상도 배율과 기존 골드 연출을 통과했다.

Godot `4.7.stable.official.5b4e0cb0f`의 같은 임시 실행 파일로 import·parse와 위 21개 회귀를 모두 통과했다. 종료 코드·스크립트/리소스 오류·완료 출력을 확인했으며 로그는 `/private/tmp/single-quest-verification/`이다. 실제 Metal 1152×648 렌더링에서 동전 받기·빈캔 받기·모두 완료 후 HUD 숨김과 중앙 카드 부재를 확인했다. 기존 HUD 행·디자인 테마·세션 지급·저장·수령 연출을 재사용하고 새 런타임 파일·저장 필드는 추가하지 않았다.
